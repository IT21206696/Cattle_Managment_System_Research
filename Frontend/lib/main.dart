import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:chat_app/navigations/landing_screen.dart';
import 'package:chat_app/navigations/signin_window.dart';
import 'package:chat_app/navigations/signup_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider(),
      child: MaterialApp(
        title: 'NVD App',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(137, 217, 242, 1),
                brightness: Brightness.dark),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(),
            appBarTheme: AppBarTheme(
                centerTitle: true,
                titleTextStyle: GoogleFonts.poppins(fontSize: 15)),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    shadowColor: Styles.shadowColor))),
        darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(137, 217, 242, 1),
                brightness: Brightness.dark),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    shadowColor: Styles.shadowColor))),
        home: Consumer<SessionProvider>(
          builder: (context, sessionProvider, _) {
            // Check if session is available
            if (sessionProvider.authEmployeeID != null) {
              return const HomeScreen();
            } else {
              checkSharedPreferences(context);
              return const LandingPage();
            }
          },
        ),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/landing': (context) => const LandingPage(),
          '/sign-up': (context) => RegisterUserScreen(),
          '/sign-in': (context) => SignInWindow(),
        },
      ),
    );
  }

  Future<void> checkSharedPreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if session information is available in shared preferences
    String? authEmployeeID = prefs.getString('username');
    if (authEmployeeID != null) {
      // If session information is available, update the session provider
      Provider.of<SessionProvider>(context, listen: false).updateSession(
        accessToken: prefs.getString('accessToken').toString(),
        refreshToken: prefs.getString('refreshToken').toString(),
        userRole: prefs.getString('userRole').toString(),
        username: authEmployeeID,
        complications: [],
        contactNumber: '',
        createdAt: DateTime.parse('2022-04-05'),
        email: '',
        fullName: '',
        userId: '',
        authEmployeeID: '0',
      );
      // Navigate to the HomeWindow
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _counter = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return const Scaffold();
  }
}
