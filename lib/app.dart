import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'widgets/app_shell.dart';

class SysmlApp extends StatelessWidget {
  const SysmlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'SysML v2 Modeler',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AppShell(),
      ),
    );
  }
}
