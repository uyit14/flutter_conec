import 'package:conecapp/ui/address/province_page.dart';
import 'package:conecapp/ui/address/ward_page.dart';
import 'package:conecapp/ui/authen/pages/confirm_email_page.dart';
import 'package:conecapp/ui/authen/pages/forgot_password_page.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:conecapp/ui/authen/pages/register_page.dart';
import 'package:conecapp/ui/authen/pages/signup_page.dart';
import 'package:conecapp/ui/home/blocs/items_by_category_bloc.dart';
import 'package:conecapp/ui/home/pages/google_map_page.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:conecapp/ui/home/pages/nearby_page.dart';
import 'package:conecapp/ui/home/widgets/scroll_behavior.dart';
import 'package:conecapp/ui/mypost/blocs/post_action_bloc.dart';
import 'package:conecapp/ui/mypost/pages/edit_mypost_page.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import 'package:conecapp/ui/notify/pages/notify_page.dart';
import 'package:conecapp/ui/others/open_letter_page.dart';
import 'package:conecapp/ui/others/terms_condition_page.dart';
import 'package:conecapp/ui/profile/pages/detail_profile_page.dart';
import 'package:conecapp/ui/profile/pages/edit_info_page.dart';
import 'package:conecapp/ui/profile/pages/edit_profile_page.dart';
import 'package:conecapp/ui/profile/pages/change_password_page.dart';
import 'package:conecapp/ui/profile/pages/info_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/address/district_page.dart';
import 'ui/authen/blocs/authen_bloc.dart';
import 'ui/authen/pages/reset_pass_page.dart';
import 'ui/conec_home_page.dart';
import 'ui/home/pages/items_by_category_page.dart';
import 'ui/mypost/pages/post_action_page.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/search/pages/search_page.dart';
import 'ui/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ConecApp());
}

class ConecApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: child,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        OnBoardingScreen.ROUTE_NAME: (context) => OnBoardingScreen(),
        ConecHomePage.ROUTE_NAME: (context) => ConecHomePage(),
        LoginPage.ROUTE_NAME: (context) => Provider(
            create: (_) => AuthenBloc(),
            dispose: (_, AuthenBloc bloc) => bloc.dispose(),
            child: LoginPage()),
        SignUpPage.ROUTE_NAME: (context) => Provider(
            create: (_) => AuthenBloc(),
            dispose: (_, AuthenBloc bloc) => bloc.dispose(),
            child: SignUpPage()),
        RegisterPage.ROUTE_NAME: (context) => RegisterPage(),
        SearchPage.ROUTE_NAME: (context) => SearchPage(),
        ItemByCategory.ROUTE_NAME: (context) => Provider<ItemsByCategoryBloc>(
              create: (_) => ItemsByCategoryBloc(),
              dispose: (_, ItemsByCategoryBloc bloc) => bloc.dispose(),
              child: ItemByCategory(),
            ),
        ItemDetailPage.ROUTE_NAME: (context) => ItemDetailPage(),
        PostActionPage.ROUTE_NAME: (context) =>
            Provider(create: (_) => PostActionBloc(), child: PostActionPage()),
        OpenLetterPage.ROUTE_NAME: (context) => OpenLetterPage(),
        TermConditionPage.ROUTE_NAME: (context) => TermConditionPage(),
        NotifyPage.ROUTE_NAME: (context) => NotifyPage(),
        SellDetailPage.ROUTE_NAME: (context) => SellDetailPage(),
        DetailProfilePage.ROUTE_NAME: (context) => DetailProfilePage(),
        EditProfilePage.ROUTE_NAME: (context) => EditProfilePage(),
        NewsDetailPage.ROUTE_NAME: (context) => NewsDetailPage(),
        ForGotPasswordPage.ROUTE_NAME: (context) => ForGotPasswordPage(),
        EditMyPostPage.ROUTE_NAME: (context) => EditMyPostPage(),
        GoogleMapPage.ROUTE_NAME: (context) => GoogleMapPage(),
        ChangePassWordPage.ROUTE_NAME: (context) => ChangePassWordPage(),
        ResetPasswordPage.ROUTE_NAME: (context) => ResetPasswordPage(),
        ConfirmEmailPage.ROUTE_NAME: (context) => ConfirmEmailPage(),
        ProvincePage.ROUTE_NAME: (context) => ProvincePage(),
        DistrictPage.ROUTE_NAME: (context) => DistrictPage(),
        WardPage.ROUTE_NAME: (context) => WardPage(),
        NearByPage.ROUTE_NAME: (context) => NearByPage(),
        IntroducePage.ROUTE_NAME: (context) => IntroducePage(),
        InfoPage.ROUTE_NAME: (context) => InfoPage(),
        EditInfoPage.ROUTE_NAME: (context) => EditInfoPage(),
      },
    );
  }
}
