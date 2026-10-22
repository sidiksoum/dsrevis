import 'package:dsrevis/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

// MODIFIEZ CET IMPORT AVEC UN ALIAS "as" :
import 'package:dsrevis/core/services/firebase_service.dart' as custom_service; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Utilisation de l'alias pour éviter toute ambiguïté avec les classes natives de Firebase
  custom_service.FirebaseService.observeNetworkConnectivity(); 
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white, 
      systemNavigationBarIconBrightness: Brightness.dark, 
      systemNavigationBarDividerColor: Colors.transparent, 
    ),
  );
  
  runApp(const AppWidget());
}