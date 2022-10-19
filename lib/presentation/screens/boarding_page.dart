import 'package:flutter/material.dart';
import 'package:Prefer/constants/globals.dart';
import 'package:Prefer/constants/strings.dart';

import 'home_page.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      surfaceTintColor: Color(0xffE60023),
      primary: Colors.white,
      minimumSize: Size(88, 44),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      backgroundColor: Color(0xFFE60023),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: EdgeInsets.all(40),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.asset(
                          contents[i].image,
                          height: 300,
                        ),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                contents[i].title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                contents[i].title2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            contents[i].discription,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => buildDot(index, context),
              ),
            ),
          ),
          Container(
            height: 60,
            margin: EdgeInsets.all(40),
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                if (currentIndex == contents.length - 1) {
                  Navigator.pushReplacementNamed(
                    context,
                    homePageScreen,
                  );
                }
                _controller.nextPage(
                  duration: Duration(milliseconds: 100),
                  curve: Curves.bounceIn,
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0xFFE60023), Color(0xFFE60023)]),
                    borderRadius: BorderRadius.circular(50.0)),
                child: Center(
                    child: Text(
                  currentIndex == contents.length - 1 ? "Continue" : "Next",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 18.0),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFFE60023),
      ),
    );
  }
}

class UnbordingContent {
  String image;
  String title;
  String title2;
  String discription;

  UnbordingContent(
      {required this.image,
      required this.title,
      required this.title2,
      required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: "Relieve Other's",
      title2: "Confusion",
      image: 'assets/images/confused.png',
      discription:
          "Prefer is an application that allows you to help people confused in making some choices in many aspects of life by asking you: 'Which do you prefer?'"),
  UnbordingContent(
      title: "Legal Notice",
      title2: "",
      image: 'assets/images/note.png',
      discription:
          "Prefer is a legal entity that holds no legal responsibility for any pictures posted on the platform that might be deemed as inappropriate.  If you come across a picture that you think might be improper, please report it so that we can remove it in a suitable time and fashion."),
  UnbordingContent(
      title: 'Warning',
      title2: "",
      image: 'assets/images/warning.png',
      discription:
          "We kindly ask you to avoid posting posts that may hurt others, such as nudity, violence, etc.."),
];
