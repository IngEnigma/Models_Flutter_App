import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../main.dart';

class SingUpPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> createUser(BuildContext context, String email, String username,
      String password) async {
    const String registerMutation = """
    mutation CreateUser(\$email: String!, \$password: String!, \$username: String!) {
      createUser(email: \$email, password: \$password, username: \$username) {
        user {
          id
          email
          username
        }
      }
    }
    """;

    final options = MutationOptions(
      document: gql(registerMutation),
      variables: {
        'email': email,
        'username': username,
        'password': password,
      },
    );

    try {
      final result = await client.value.mutate(options);
      if (result.hasException) {
        logger
            .e("Error al realizar la mutación: ${result.exception.toString()}");
      } else {
        logger.i("Usuario creado exitosamente");
      }
    } catch (e) {
      logger.e("Error al realizar la mutación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
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
                    "Sign Up",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF152D3C)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Hi there! Please Create an account",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF152D3C)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Email",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF256b8e)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
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
                          final email = emailController.text.trim();

                          if (username.isEmpty ||
                              password.isEmpty ||
                              email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please, complete the form."),
                              ),
                            );
                          } else {
                            logger.d(
                                "Iniciando autenticación ... \nUsername: $username \nPassword: $password \nEmail: $email");
                            createUser(context, email, username, password);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF256b8e),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Sign Up",
                          style:
                              TextStyle(color: Color(0xFFf3f8fc), fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        logger.d("Navegando al inicio de sesión.");
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style:
                            TextStyle(color: Color(0xFF256b8e), fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
