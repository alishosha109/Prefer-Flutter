import 'dart:io';

import 'package:Prefer/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:Prefer/business_logic/cubit/posts_cubit.dart';
import 'package:Prefer/constants/my_colors.dart';
import 'package:Prefer/constants/strings.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Prefer/constants/globals.dart' as globals;
import 'package:Prefer/presentation/widgets/shared_widgets.dart';

class AddPost extends StatefulWidget {
  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  double _currentSliderValue = 23;
  final ImagePicker imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool photos_is_uploaded = false;
  List<XFile>? imageFileList = [];
  String description = "";

  void selectImages() async {
    final List<XFile>? selectedImages =
        await imagePicker.pickMultiImage(imageQuality: 50);
    if (selectedImages!.isNotEmpty && selectedImages.length <= 4) {
      if (imageFileList!.length == 4) {
        setState(() {
          imageFileList!.clear();
          imageFileList!.addAll(selectedImages);
        });
      } else {
        setState(() {
          if (selectedImages.length + imageFileList!.length > 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 3),
                content: Text(
                  AppLocalizations.of(context)!
                      .translate("Can't upload more than 4 photos"),
                ),
                backgroundColor: Colors.grey.withOpacity(0.5),
              ),
            );
          } else {
            imageFileList!.addAll(selectedImages);
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
            AppLocalizations.of(context)!.translate("Choose 2,3 or 4 photos"),
          ),
          backgroundColor: Colors.grey.withOpacity(0.5),
        ),
      );
    }
    print("Image List Length:" + imageFileList!.length.toString());
  }

  Widget blocChildWidget() {
    return SingleChildScrollView(
        child: Form(
      key: _formKey,
      child: Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Text(
              AppLocalizations.of(context)!
                  .translate("Describe your case and let people help you!"),
              style: TextStyle(
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              minLines: 3,
              maxLines: 5,
              autofocus: false,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: globals.theme_mode == ThemeMode.dark
                    ? Colors.grey.shade900
                    : Colors.grey,

                hintStyle: TextStyle(fontSize: 16, color: Colors.white),
                contentPadding:
                    const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                  borderRadius: BorderRadius.circular(12.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.7),
                ),
                //
              ),
              validator: ((value) {
                if (value!.length > 100) {
                  return 'Max Charachters : 100';
                } else if (value.length == 0) {
                  return "Description can't be empty";
                }
                description = value;
                return null;
              }),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text(
                  AppLocalizations.of(context)!.translate(
                    "Upload Your Photos (min:2, max:4)",
                  ),
                  style: TextStyle(
                      color: globals.theme_mode == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      imageFileList!.clear();
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.translate(
                      "Clear",
                    ),
                    style: TextStyle(color: MyColors.myRed, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.grey.shade900
                      : Colors.grey,
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12.7))),
              //color: Colors.grey,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  !(imageFileList!.length >= 1)
                      ? Expanded(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: InkWell(
                              onTap: () {
                                selectImages();
                              },
                              child: Icon(
                                Icons.add,
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              child: Image.file(File(imageFileList![0].path)),
                              // height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ),
                        ),
                  VerticalDivider(
                    color: Colors.white,
                  ),
                  !(imageFileList!.length >= 2)
                      ? Expanded(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: InkWell(
                              onTap: () {
                                selectImages();
                              },
                              child: Icon(
                                Icons.add,
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: Container(
                              child: Image.file(File(imageFileList![1].path)),
                              // height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ),
                        ),
                  VerticalDivider(
                    color: Colors.white,
                  ),
                  !(imageFileList!.length >= 3)
                      ? Expanded(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: InkWell(
                              onTap: () {
                                selectImages();
                              },
                              child: Icon(
                                Icons.add,
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: Container(
                              child: Image.file(File(imageFileList![2].path)),
                              // height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ),
                        ),
                  VerticalDivider(
                    color: Colors.white,
                  ),
                  !(imageFileList!.length >= 4)
                      ? Expanded(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: InkWell(
                              onTap: () {
                                selectImages();
                              },
                              child: Icon(
                                Icons.add,
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              child: Image.file(File(imageFileList![3].path)),
                              // height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Text(
              AppLocalizations.of(context)!.translate(
                "Post period in hours (min:1, max:24)",
              ),
              style: TextStyle(
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 18),
            ),
          ),
          Slider(
            activeColor: globals.theme_mode == ThemeMode.dark
                ? Colors.white
                : Colors.black,
            value: _currentSliderValue,
            // thumbColor: MyColors.myRed,
            inactiveColor: globals.theme_mode == ThemeMode.dark
                ? Colors.grey.shade600
                : Colors.black,
            min: 1,
            max: 24,
            divisions: 23,
            label: _currentSliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
              print(value);
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          InkWell(
            onTap: () {
              if (_formKey.currentState!.validate()) {
                if (imageFileList!.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 3),
                      content: Text(
                        AppLocalizations.of(context)!
                            .translate("Choose 2,3 or 4 photos"),
                      ),
                      backgroundColor: Colors.grey.withOpacity(0.5),
                    ),
                  );
                } else {
                  BlocProvider.of<PostsCubit>(context)
                      .upload_photos(imageFileList);
                }
              }
            },
            child: Center(
                child: Container(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xFFE60023),
                        Color(0xFFE60023),
                      ]),
                  borderRadius: BorderRadius.circular(50.0)),
              child: Center(
                  child: !loading
                      ? Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          size: 40,
                        )
                      : CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 4,
                        )),
            )),
          ),
        ]),
      ),
    ));
  }

  Widget buildblocWidget() {
    return BlocConsumer<PostsCubit, PostsState>(
      listener: (context, state) {
        if (state is photos_upload_loading) {
          loading = true;
        } else if (state is photos_uploaded) {
          print(state.urls);
          if (state.urls.isNotEmpty) {
            BlocProvider.of<PostsCubit>(context)
                .upload_post(description, state.urls, _currentSliderValue);
          } else {
            loading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 3),
                content: Text(
                  AppLocalizations.of(context)!
                      .translate("Error occured while uploading photos"),
                ),
                backgroundColor: Colors.grey.withOpacity(0.5),
              ),
            );
          }
        } else if (state is post_uploaded) {
          if (state.uploaded) {
            Navigator.pushReplacementNamed(context, myPostsScreen);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 3),
                content: Text(
                  AppLocalizations.of(context)!
                      .translate("Post uploaded Successfully"),
                ),
                backgroundColor: Colors.grey.withOpacity(0.5),
              ),
            );
          } else {
            loading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 3),
                content: Text(AppLocalizations.of(context)!
                    .translate("Error occured while uploading your post")),
                backgroundColor: Colors.grey.withOpacity(0.5),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return blocChildWidget();
      },
    );
  }

  Widget mainWidget() {
    return OfflineBuilder(
        connectivityBuilder: ((
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
          if (connected) {
            return buildblocWidget();
          } else {
            return NoInternetWidget(context);
          }
        }),
        child: Container());
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          globals.theme_mode == ThemeMode.dark ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.close,
                color: globals.theme_mode == ThemeMode.dark
                    ? Colors.white
                    : Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: globals.theme_mode == ThemeMode.dark
            ? Colors.black
            : MyColors.myRed,
        title: Text(
          AppLocalizations.of(context)!.translate("Add Post"),
          style: TextStyle(
              color: globals.theme_mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.white),
        ),
      ),
      body: mainWidget(),
    );
  }
}
