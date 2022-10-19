// import 'package:flutter/material.dart';
// import 'package:help_me/business_logic/cubit/users_cubit.dart';
// import 'package:help_me/data/apis/users_apis.dart';
// import 'package:help_me/data/repos/users_repo.dart';
// import 'package:help_me/presentation/screens/login_page.dart';
// import 'package:help_me/presentation/screens/signup_page.dart';
// import 'business_logic/cubit/posts_cubit.dart';
// import 'constants/strings.dart';
// import 'data/apis/posts_apis.dart';
// import 'data/repos/posts_repo.dart';
// import 'presentation/screens/addpost_page.dart';
// import 'presentation/screens/boarding_page.dart';
// import 'presentation/screens/home_page.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class AppRouter {
//   late postsRepo postsrepo;
//   late PostsCubit postscubit;
//   late usersRepo usersrepo;
//   late UsersCubit userscubit;
//   AppRouter() {
//     postsrepo = postsRepo(postsApis());
//     postscubit = PostsCubit(postsrepo);
//     usersrepo = usersRepo(usersApis());
//     userscubit = UsersCubit(usersrepo);
//   }

//   Route? generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case homePageScreen:
//         return MaterialPageRoute(
//             builder: (_) => BlocProvider(
//                   create: (BuildContext context) => postscubit,
//                   child: HomePage(),
//                 ));
//       case addpostScreen:
//         return MaterialPageRoute(
//             builder: (_) => BlocProvider(
//                   create: (BuildContext context) => PostsCubit(postsrepo),
//                   child: AddPost(),
//                 ));
//       case loginScreen:
//         return MaterialPageRoute(
//             builder: (_) => BlocProvider(
//                   create: (BuildContext context) => UsersCubit(usersrepo),
//                   child: LoginPage(),
//                 ));
//       case SignUpScreen:
//         return MaterialPageRoute(
//             builder: (_) => BlocProvider(
//                   create: (BuildContext context) => userscubit,
//                   child: SignUpPage(),
//                 ));
//       case boardingScreen:
//         return MaterialPageRoute(builder: (_) => Onboarding());
//     }
//   }
// }
