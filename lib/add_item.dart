import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  GlobalKey<FormState> key = GlobalKey();

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('gallery');

  String imageUrl = '';

  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add an image'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isSuccess,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: key,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Place your image here'),
                  IconButton(
                      onPressed: () async {
                        setState(() {
                          isSuccess = true;
                        });
                        ImagePicker imagePicker = ImagePicker();
                        XFile? file = await imagePicker.pickImage(
                            source: ImageSource.gallery);
                        print('${file?.path}');

                        if (file == null) return;

                        String uniqueFileName =
                            DateTime.now().millisecondsSinceEpoch.toString();

                        Reference referenceRoot =
                            FirebaseStorage.instance.ref();
                        Reference referenceDirImages =
                            referenceRoot.child('images');

                        Reference referenceImageToUpload =
                            referenceDirImages.child(uniqueFileName);

                        try {
                          await referenceImageToUpload
                              .putFile(File(file!.path));

                          imageUrl =
                              await referenceImageToUpload.getDownloadURL();
                          setState(() {
                            isSuccess = false;
                          });
                        } catch (error) {}
                      },
                      icon: Icon(Icons.camera_alt)),
                  ElevatedButton(
                      onPressed: () async {
                        if (imageUrl.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Please upload an image')));

                          return;
                        }

                        if (key.currentState!.validate()) {
                          Map<String, String> dataToSend = {
                            'image': imageUrl,
                          };

                          _reference.add(dataToSend);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Submit'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
