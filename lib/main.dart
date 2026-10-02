import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(ExpenseTrackerApp(cameras: cameras));
}

class ExpenseTrackerApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const ExpenseTrackerApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: HomeDashboardScreen(cameras: cameras),
    );
  }
}