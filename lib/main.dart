import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Prefer/business_logic/cubit/posts_cubit.dart';
import 'package:Prefer/business_logic/cubit/theme_cubit.dart';
import 'package:Prefer/business_logic/cubit/users_cubit.dart';
import 'package:Prefer/constants/globals.dart';
import 'package:Prefer/constants/globals.dart' as globals;
import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/constants/theme/theme_constatns.dart';
import 'package:Prefer/data/apis/posts_apis.dart';
import 'package:Prefer/data/apis/users_apis.dart';
import 'package:Prefer/data/repos/posts_repo.dart';
import 'package:Prefer/data/repos/users_repo.dart';
import 'package:Prefer/presentation/screens/addpost_page.dart';
import 'package:Prefer/presentation/screens/choices_history.dart';
import 'package:Prefer/presentation/screens/login_page.dart';
import 'package:Prefer/presentation/screens/myposts_page.dart';
import 'package:Prefer/presentation/screens/profile_page.dart';
import 'package:Prefer/presentation/screens/signup_page.dart';
import 'app_localizations.dart';
import 'presentation/screens/boarding_page.dart';
import 'presentation/screens/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await globals.return_initialize();
  Timer(Duration(seconds: 3), () {
    runApp(PreferApp());
  });
}

class PreferApp extends StatelessWidget {
  const PreferApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit()..getSavedLanguage(),
      child: BlocConsumer<ThemeCubit, ThemeState>(
        listener: (context, state) {
          if (state is ThemeChanged) {
            globals.theme_mode = state.themeMode;
          }
          if (state is ChangeLocaleState) {
            globals.locale = state.locale;
          }
        },
        builder: (context, state) {
          return MaterialApp(
            locale: globals.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              for (var locale in supportedLocales) {
                if (deviceLocale != null &&
                    deviceLocale.languageCode == locale.languageCode) {
                  return deviceLocale;
                }
              }

              return supportedLocales.first;
            },
            debugShowCheckedModeBanner: false,
            initialRoute: globals.initialize,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: globals.theme_mode,
            routes: {
              homePageScreen: (context) => BlocProvider(
                    create: (context) => PostsCubit(postsRepo(postsApis())),
                    child: HomePage(
                      usertype: main_user.sId == null ? "guest" : "user",
                    ),
                  ),
              boardingScreen: (context) => Onboarding(),
              loginScreen: (context) => BlocProvider(
                    create: (context) => UsersCubit(usersRepo(usersApis())),
                    child: LoginPage(),
                  ),
              SignUpScreen: (context) => BlocProvider(
                    create: (context) => UsersCubit(usersRepo(usersApis())),
                    child: SignUpPage(),
                  ),
              addpostScreen: (context) => BlocProvider(
                    create: (context) => PostsCubit(postsRepo(postsApis())),
                    child: AddPost(),
                  ),
              myPostsScreen: (context) => BlocProvider(
                    create: (context) => PostsCubit(postsRepo(postsApis())),
                    child: MyPostsPage(),
                  ),
              ProfileScreen: (context) => BlocProvider(
                    create: (context) => UsersCubit(usersRepo(usersApis())),
                    child: ProfilePage(),
                  ),
              ChoicesScreen: (context) => BlocProvider(
                    create: (context) => PostsCubit(postsRepo(postsApis())),
                    child: ChoicesHistoryPage(),
                  ),
            },
          );
        },
      ),
    );
  }
}
