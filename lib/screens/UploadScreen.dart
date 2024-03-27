import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inst_clone/resources/FirestoreMethod.dart';
import 'package:inst_clone/utils/ImagePickerUtil.dart';
import 'package:inst_clone/utils/SnackBarUtil.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? _file;
  String? profilePicUrlData;
  String? usernameData;
  String? uidData;
  bool isLoading = false;

  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
  }

  void getCurrentUserData() async {
    String photoUrl = await FirestoreMethod().getUserData('photoUrl');
    String username = await FirestoreMethod().getUserData('username');
    String uid = await FirestoreMethod().getUserData('uid');
    setState(() {
      profilePicUrlData = photoUrl;
      usernameData = username;
      uidData = uid;
    });
  }

  void postImage(String uid, String username, String profilePic) async {
    try {
      setState(() {
        isLoading = true;
      });
      String res = await FirestoreMethod().postDatabase(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profilePic,
      );

      if (res == 'success') {
        showSnackBar('Posted!', context);
        clearImage();
      } else {
        showSnackBar(res, context);
      }

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
      _descriptionController.text = '';
    });
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create Post'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Select from Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _file == null
        ? SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: InkWell(
                onTap: () => _selectImage(context),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload,
                        size: 54,
                      ),
                      SizedBox(height: 18),
                      Text('Upload Photo'),
                    ],
                  ),
                ),
              ),
            ),
          )
        : SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: clearImage,
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                title: const Text(
                  'Post to',
                  style: TextStyle(color: Colors.black),
                ),
                centerTitle: false,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      isLoading
                          ? const LinearProgressIndicator()
                          : const Padding(
                              padding: EdgeInsets.only(top: 0),
                            ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(
                                    profilePicUrlData!,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  usernameData!,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => postImage(
                                uidData!,
                                usernameData!,
                                profilePicUrlData!,
                              ),
                              child: Text(
                                'Post',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: double.infinity,
                        // child: Image.network(
                        //   'https://w0.peakpx.com/wallpaper/874/34/HD-wallpaper-star-wars-2019-thumbnail.jpg',
                        //   fit: BoxFit.cover,
                        // ),
                        decoration: BoxDecoration(
                          color: Colors.grey[150],
                          image: DecorationImage(image: MemoryImage(_file!)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      TextField(
                        obscureText: false,
                        maxLines: 3,
                        controller: _descriptionController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Write Your Post Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
