import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAkeRe2gVMPWhxoGs08ffe8tZvtzFH0W0g',
      authDomain: 'studybrain-4a176.firebaseapp.com',
      projectId: 'studybrain-4a176',
      storageBucket: 'studybrain-4a176.firebasestorage.app',
      messagingSenderId: '359516470236',
      appId: '1:359516470236:web:6c237757f3c729497d6d19',
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => StorageService()),
        ChangeNotifierProvider(create: (_) => AiService()),
      ],
      child: const StudyBrainApp(),
    ),
  );
}
