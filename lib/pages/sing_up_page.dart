import 'package:app/widgets/navegation_text_button_widget.dart';
import 'package:app/widgets/login_signup_button_widget.dart';
import 'package:app/widgets/custom_title_text_widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app/widgets/text_field_widget.dart';
import 'package:app/widgets/snakbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';

class SingUpPage extends StatefulWidget {
  const SingUpPage({super.key});

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

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
      setState(() {
        isLoading = true;
      });

      final result = await client.value.mutate(options);
      if (result.hasException) {
        showCustomSnackbar(context, "Registration failed.");
      } else {
        Navigator.pushNamed(context, '/login');
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 32.0,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customTitleText("Models App"),
                  const SizedBox(height: 16),
                  customTitleText("Sign Up", fontSize: 28),
                  const SizedBox(height: 16),
                  customTitleText("Hi there! Please Create an account",
                      fontSize: 18, fontWeight: FontWeight.normal),
                  const SizedBox(height: 16),
                  buildTextField("Email", emailController),
                  buildTextField("Username", usernameController),
                  buildTextField("Password", passwordController,
                      obscureText: true),
                  const SizedBox(height: 24),
                  Center(
                    child: loginSignUpButton(
                      context: context,
                      isLoading: isLoading,
                      buttonText: "Sign Up",
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        final username = usernameController.text.trim();
                        final password = passwordController.text.trim();
                        final email = emailController.text.trim();

                        if (username.isEmpty ||
                            password.isEmpty ||
                            email.isEmpty) {
                          showCustomSnackbar(
                              context, "Please fill all the fields.");
                        } else {
                          await createUser(context, email, username, password);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  navigationTextButton(
                    context: context,
                    buttonText: "Already have an account? Login",
                    routeName: '/login',
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
