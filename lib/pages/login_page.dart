import 'package:app/widgets/navegation_text_button_widget.dart';
import 'package:app/widgets/login_signup_button_widget.dart';
import 'package:app/widgets/custom_title_text_widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app/widgets/text_field_widget.dart';
import 'package:app/widgets/snakbar_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

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
      variables: {'username': username, 'password': password},
    );

    try {
      setState(() {
        isLoading = true;
      });

      final result = await client.value.mutate(options);
      if (result.hasException) {
        showCustomSnackbar(context, "Authentication failed.");
      } else if (result.data?['tokenAuth'] != null) {
        final token = result.data?['tokenAuth']['token'];
        Provider.of<MyAppState>(context, listen: false).updateToken(token);
        Provider.of<MyAppState>(context, listen: false).updateUser(username);
        Navigator.pushNamed(context, '/logs');
      } else {
        showCustomSnackbar(context, "Invalid credentials.");
      }
    } catch (e) {
      showCustomSnackbar(context, "An error occurred. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
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
            customTitleText("Models App"),
            const SizedBox(height: 16),
            customTitleText("Login", fontSize: 28),
            const SizedBox(height: 16),
            customTitleText("Welcome back!",
                fontSize: 18, fontWeight: FontWeight.normal),
            const SizedBox(height: 16),
            buildTextField("Username", usernameController),
            buildTextField("Password", passwordController, obscureText: true),
            const SizedBox(height: 24),
            Center(
              child: loginSignUpButton(
                context: context,
                isLoading: isLoading,
                buttonText: "Login",
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  final username = usernameController.text.trim();
                  final password = passwordController.text.trim();

                  if (username.isEmpty || password.isEmpty) {
                    showCustomSnackbar(
                        context, "Please enter username and password.");
                  } else {
                    await authenticateUser(context, username, password);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            navigationTextButton(
              context: context,
              buttonText: "Don't have an account? Sign up",
              routeName: '/signup',
            ),
          ],
        ),
      ),
    );
  }
}
