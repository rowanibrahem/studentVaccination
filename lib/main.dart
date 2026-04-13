import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaccacine_app/student_provider.dart';
import 'package:vaccacine_app/student_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentsProvider()),
      ],
      child: MaterialApp(
        title: 'إدارة التطعيمات',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'Cairo', 
          useMaterial3: true,
        ),
        home: const StudentsScreen(),
      ),
    );
  }
}