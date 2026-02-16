import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/note_model.dart';

enum MessageType { user, ai, system }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isLoading = false,
  });
}

class AIChatScreen extends StatefulWidget {
  final NoteModel? note;

  const AIChatScreen({
    super.key,
    this.note,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingController;
  late AnimationController _sendController;

  @override
  void initState() {
    super.initState();
    
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _sendController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    _sendController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Add welcome message
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '''Hello! I'm your AI study assistant. I have access to your note "${widget.note?.title ?? "your notes"}" and I'm here to help you understand the material better.

You can ask me:
• Questions about specific concepts
• For clarifications or explanations
• To provide examples
• To create study strategies
• To test your knowledge

What would you like to know?''',
      type: MessageType.ai,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _sendController.forward().then((_) => _sendController.reverse());

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    _typingController.repeat();

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));

    // Generate AI response based on the question and note content
    final aiResponse = await _generateAIResponse(text);

    setState(() {
      _isTyping = false;
    });

    _typingController.stop();
    _typingController.reset();

    // Add AI response
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: aiResponse,
      type: MessageType.ai,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(aiMessage);
    });

    _scrollToBottom();
  }

  Future<String> _generateAIResponse(String userQuery) async {
    // Try real AI service
    try {
      final aiService = Provider.of<AiService>(context, listen: false);
      if (!aiService.isConfigured) {
        await aiService.saveConfiguration(
          apiKey: AppConstants.groqApiKey,
          apiUrl: AppConstants.groqBaseUrl,
          model: AppConstants.aiModel,
        );
      }
      final response = await aiService.chatWithAI(userQuery, contextNotes: widget.note != null ? [widget.note!] : null);
      if (aiService.errorMessage == null) return response;
    } catch (e) {
      debugPrint('AI service error: \$e');
    }
    // Fallback to mock
    final query = userQuery.toLowerCase();
    
    if (query.contains('what is') || query.contains('define') || query.contains('explain')) {
      return '''Based on your note "${widget.note?.title ?? "your notes"}", I can help explain this concept.

**Key Points from your notes:**
${_extractRelevantContent(userQuery)}

The fundamental idea here is that complex concepts build upon simpler ones. Let me break this down further:

1. **Core Principle**: The underlying mechanism
2. **Applications**: How it's used in practice
3. **Examples**: Real-world instances
4. **Related Concepts**: What connects to this idea

Would you like me to elaborate on any of these aspects or provide specific examples?''';
    }
    
    if (query.contains('example') || query.contains('instance') || query.contains('demonstrate')) {
      return '''Great question! Let me provide some concrete examples related to your note content:

**Example 1**: *Real-world Application*
This concept appears frequently in everyday situations. For instance, when you observe [specific scenario], you're actually seeing this principle in action.

**Example 2**: *Academic Context*
In your studies, this might show up as [academic example]. This helps bridge the gap between theory and practice.

**Example 3**: *Analogy*
Think of it like [simple analogy] - this makes the abstract concept more tangible and easier to remember.

These examples should help you understand how the theoretical concepts from your notes apply in different contexts. Do any of these resonate with you?''';
    }
    
    if (query.contains('how') || query.contains('process') || query.contains('steps')) {
      return '''Looking at your note content, here's a step-by-step breakdown of the process:

## The Process:

**Step 1: Foundation**
Start with understanding the basic principles outlined in your notes.

**Step 2: Application**  
Apply these principles to solve specific problems or analyze situations.

**Step 3: Integration**
Connect this knowledge with other concepts you've learned.

**Step 4: Practice**
Reinforce your understanding through practical exercises.

### Key Tips:
- Focus on understanding rather than memorization
- Look for patterns and connections
- Practice with varied examples
- Test your knowledge regularly

Would you like me to elaborate on any of these steps or help you practice with specific problems?''';
    }
    
    if (query.contains('why') || query.contains('reason') || query.contains('purpose')) {
      return '''That's an excellent "why" question! Understanding the reasoning behind concepts is crucial for deep learning.

**The fundamental reason is:**
This concept exists because it solves a specific problem or explains a particular phenomenon that we observe in [relevant field].

**Historical Context:**
The development of this idea came from [historical background based on note content].

**Practical Importance:**
Understanding this concept is important because:
- It forms the foundation for more advanced topics
- It has real-world applications in [field/area]
- It helps explain phenomena you might observe
- It connects to other important concepts in your studies

**Critical Thinking:**
Consider these questions:
- How does this relate to what you already know?
- What would happen if this principle didn't exist?
- Can you think of situations where this applies?

This deeper understanding will help you retain and apply the knowledge more effectively!''';
    }
    
    if (query.contains('test') || query.contains('quiz') || query.contains('practice') || query.contains('check')) {
      return '''Excellent! Testing your knowledge is a great way to reinforce learning. Based on your note content, let me create some practice questions:

## Quick Knowledge Check:

**Question 1**: Can you explain the main concept from your notes in your own words?

**Question 2**: What are the key applications or examples of this concept?

**Question 3**: How does this concept relate to other topics you've studied?

**Challenge Question**: If you had to teach this concept to a friend, how would you explain it using simple analogies?

### Study Strategy Tip:
Try the "Feynman Technique":
1. Explain the concept simply
2. Identify gaps in your understanding  
3. Review the material to fill gaps
4. Simplify and create analogies

Want me to create more specific questions or help you work through any of these? I can also generate flashcards based on your note content!''';
    }
    
    // Default response
    return '''I understand you're asking about "${userQuery}".

Based on your note "${widget.note?.title ?? "your notes"}", here's my analysis:

**Relevant Information:**
${_extractRelevantContent(userQuery)}

**My Explanation:**
This topic is quite interesting and connects to several key concepts in your notes. The fundamental idea revolves around understanding the relationships between different elements and how they interact.

**To help you better, I can:**
- Provide more specific explanations
- Create practice questions
- Suggest study strategies
- Help you connect this to other concepts
- Generate examples and analogies

What specific aspect would you like me to focus on? Feel free to ask follow-up questions or request clarification on any part!''';
  }

  String _extractRelevantContent(String query) {
    // Extract relevant snippets from the note content
    final content = widget.note?.content ?? "";
    final lines = content.split('\n');
    
    // Return first few meaningful lines as context
    final relevantLines = lines
        .where((line) => line.trim().isNotEmpty && !line.startsWith('#'))
        .take(3)
        .join('\n');
    
    return relevantLines.isNotEmpty 
        ? '> $relevantLines'
        : 'Key concepts from your notes are available for reference.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, int index) {
    final isUser = message.type == MessageType.user;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyMessage(message.content),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUser 
                      ? AppTheme.primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isUser
                    ? Text(
                        message.content,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      )
                    : MarkdownBody(
                        data: message.content,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.darkTextColor,
                            height: 1.4,
                          ),
                          h1: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTextColor,
                          ),
                          h2: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkTextColor,
                          ),
                          h3: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkTextColor,
                          ),
                          strong: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkTextColor,
                          ),
                          code: GoogleFonts.sourceCodePro(
                            fontSize: 14,
                            backgroundColor: AppTheme.backgroundColor,
                          ),
                          blockquote: GoogleFonts.inter(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.lightTextColor,
                          ),
                          listBullet: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.darkTextColor,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.person,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
      .fadeIn()
      .slideY(begin: 0.3);
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI is thinking',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.lightTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ).animate(
                        onPlay: (controller) => controller.repeat(),
                      ).fadeIn(
                        delay: Duration(milliseconds: index * 200),
                        duration: const Duration(milliseconds: 600),
                      ).then().fadeOut(
                        duration: const Duration(milliseconds: 600),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask me anything about your notes...',
                hintStyle: GoogleFonts.inter(
                  color: AppTheme.lightTextColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          
          AnimatedBuilder(
            animation: _sendController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - (_sendController.value * 0.1),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _messageController.text.trim().isNotEmpty
                        ? AppTheme.primaryGradient
                        : LinearGradient(
                            colors: [Colors.grey.shade300, Colors.grey.shade400],
                          ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: _messageController.text.trim().isNotEmpty
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: IconButton(
                    onPressed: () { if (_messageController.text.trim().isNotEmpty && !_isTyping) _sendMessage(); },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Assistant',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              'Discussing: ${widget.note?.title ?? "your notes"}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Chat Features'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• Long press any message to copy it'),
                      const Text('• Ask questions about your note content'),
                      const Text('• Request examples and explanations'),
                      const Text('• Get study tips and strategies'),
                      const Text('• Test your knowledge with questions'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index], index);
              },
            ),
          ),
          
          _buildMessageInput(),
        ],
      ),
    );
  }
}