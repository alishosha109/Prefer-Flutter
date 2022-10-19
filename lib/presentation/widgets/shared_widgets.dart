import "package:flutter/material.dart";
import 'package:Prefer/constants/globals.dart' as globals;

import 'package:Prefer/constants/my_colors.dart';

Widget NoInternetWidget(context) {
  return Center(
    child: Container(
        color:
            globals.theme_mode == ThemeMode.dark ? Colors.black : Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            Text(
              "Check internet connection",
              style: TextStyle(
                color: globals.theme_mode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            Image.asset('assets/images/nointernet.png'),
            CircularProgressIndicator(
              color: MyColors.myRed,
            )
          ],
        )),
  );
}
