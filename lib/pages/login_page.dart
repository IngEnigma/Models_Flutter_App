import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> authenticateUser(
      BuildContext context, String username, String password) async {
    const String authMutation = """
      mutation TokenAuth(\$username: String!, \$password: String!) {
        tokenAuth(username: \$username, password: \$password) {
          token
        }
      }
    """;

    final options = MutationOptions(
      document: gql(authMutation),
      variables: {
        'username': username,
        'password': password,
      },
    );

    logger.d("Autenticación iniciada...");
    try {
      final result = await client.value.mutate(options);

      if (result.hasException) {
        logger
            .e("Error al realizar la mutación: ${result.exception.toString()}");
      } else if (result.data == null || result.data?['tokenAuth'] == null) {
        logger.w("Respuesta inesperada: ${result.data}");
      } else {
        final token = result.data?['tokenAuth']['token'];
        logger.i(
            "Autenticación exitosa, Token recibido: $token. Username: $username");
        Provider.of<MyAppState>(context, listen: false).updateToken(token);
        Provider.of<MyAppState>(context, listen: false).updateUser(username);
        Navigator.pushNamed(context, '/logs');
      }
    } catch (e) {
      logger.e("Excepción durante la autenticación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Models App",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF152D3C),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Login",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF152D3C)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Welcome back!",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF152D3C)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Username",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF256b8e)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(
                    color: Color(0xFF152D3C),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(
                    color: Color(0xFF256b8e),
                    width: 3.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Password",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF256b8e)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(
                    color: Color(0xFF152D3C),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(
                    color: Color(0xFF256b8e),
                    width: 3.0,
                  ),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ElevatedButton(
                  onPressed: () {
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();

                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please, complete the form."),
                        ),
                      );
                    } else {
                      logger.d(
                          "Iniciando autenticación ... \nUsername: $username \nPassword: $password");
                      authenticateUser(context, username, password);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF256b8e),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Color(0xFFf3f8fc), fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  logger.d("Navegando al registro de usuario.");
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: Color(0xFF256b8e), fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
