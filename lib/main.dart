import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app/pages/linear_model_page.dart';
import 'package:app/pages/flower_model_page.dart';
import 'package:app/pages/faces_model_page.dart';
import 'package:app/pages/sing_up_page.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/logs_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

final HttpLink httplink =
    HttpLink("https://apilogin-6iuf.onrender.com/graphql/");

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httplink,
    cache: GraphQLCache(),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
      ],
      child: GraphQLProvider(
        client: client,
        child: MyApp(),
      ),
    ),
  );
}

class MyAppState extends ChangeNotifier {
  String user = "";
  String token = "";
  String username = "";

  bool get isAuthenticated => token.isNotEmpty && username.isNotEmpty;

  void updateToken(String newToken) {
    token = newToken;
    notifyListeners();
  }

  void updateUser(String newUser) {
    username = newUser;
    notifyListeners();
  }

  void logout() {
    token = "";
    username = "";
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Models App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 33, 201, 243),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SingUpPage(),
        '/logs': (context) => const LogsPage(),
        '/linear': (context) => const LinearModelPage(),
        '/flower': (context) => FlowerModelPage(),
        '/faces': (context) => FacesModelPage(),
      },
      home: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return appState.isAuthenticated
              ? const LogsPage()
              : const LoginPage();
        },
      ),
    );
  }
}
