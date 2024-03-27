import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inst_clone/resources/AuthMethod.dart';
import 'package:inst_clone/screens/LoginScreen.dart';
import 'package:inst_clone/utils/ImagePickerUtil.dart';
import 'package:inst_clone/utils/SnackBarUtil.dart';
import 'package:inst_clone/widgets/TextFieldWidget.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // TODO Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  //TODO isLoading
  bool isLoading = false;

  // TODO Dispose Methods
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  // TODO Profile Pic Image Selection Fn
  Uint8List? _image;
  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  //TODO createAccount
  void createAccount() async {
    //TODO Setting Loading
    setState(() {
      isLoading = true;
    });

    if (_image != null) {
      String res = await AuthMethod().createUser(
        file: _image,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (res != 'success') {
        showSnackBar(res, context);
      } else {
        showSnackBar('Account Created! ', context);
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return const LoginScreen();
        }), (route) => false);
      }
    } else {
      showSnackBar('Please Select Profile Picture', context);
    }

    //TODO Setting Loading
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
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.transparent,
                          backgroundImage: MemoryImage(
                            _image!,
                          ),
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/user.png'),
                        ),
                  Positioned(
                    bottom: 5,
                    right: 0,
                    child: InkWell(
                      onTap: selectImage,
                      child: const Icon(
                        Icons.add_a_photo,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFieldWidget(
                textEditingController: _usernameController,
                isPassword: false,
                hintText: 'Enter your Username',
                textInputType: TextInputType.text,
              ),
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
                onTap: createAccount,
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
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Create Account',
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
                  const Text("Alread have an Account ? "),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                    },
                    child: const Text(
                      'LogIn',
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
