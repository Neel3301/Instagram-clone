import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inst_clone/resources/AuthMethod.dart';
import 'package:inst_clone/screens/CreateAccountScreen.dart';
import 'package:inst_clone/screens/MainScreen.dart';
import 'package:inst_clone/utils/SnackBarUtil.dart';
import 'package:inst_clone/widgets/TextFieldWidget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //TODO Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //TODO isLoading
  bool isLoading = false;

  // TODO Dispose Methods
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  //TODO Logged in to account
  void logedInToAccount() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethod().logedInUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return const MainScreen();
      }), (route) => false);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/instagram_title.svg'),
              TextFieldWidget(
                textEditingController: _emailController,
                isPassword: false,
                hintText: 'Enter your Email',
                textInputType: TextInputType.emailAddress,
              ),
              TextFieldWidget(
                textEditingController: _passwordController,
                isPassword: true,
                hintText: 'Enter your Password',
                textInputType: TextInputType.emailAddress,
              ),
              InkWell(
                onTap: logedInToAccount,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 34, vertical: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.blue,
                  ),
                  child: isLoading == true
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an Account ? "),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CreateAccountScreen()));
                    },
                    child: const Text(
                      'Create Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
