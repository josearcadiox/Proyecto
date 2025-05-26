import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/register_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'app/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const WelcomePage(), // Cambiamos el nombre para evitar confusión
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => HomePage(), // HomePage con dispositivos
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Renombramos la página de bienvenida
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Smart Home', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C2C2E),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o título principal
            const Icon(Icons.home_outlined, size: 80, color: Color(0xFF3282B8)),
            const SizedBox(height: 16),
            const Text(
              'Smart Control',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Controla tu hogar inteligente',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3282B8), Color(0xFF44A08D)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3282B8), width: 2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    color: Color(0xFF3282B8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            StreamBuilder(
              stream: authService.value.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3A3A3C)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Usuario autenticado:',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.data?.email ?? 'Sin email',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3282B8),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botón para ir al dashboard
                        Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3282B8), Color(0xFF44A08D)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/dashboard');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              await authService.value.signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3A3A3C)),
                    ),
                    child: const Text(
                      'No hay usuario autenticado',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
