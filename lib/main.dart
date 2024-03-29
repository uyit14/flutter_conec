import 'dart:io';

import 'package:conecapp/partner_module/ui/member/accept_request.dart';
import 'package:conecapp/partner_module/ui/member/add_group_page.dart';
import 'package:conecapp/partner_module/ui/member/add_member_page.dart';
import 'package:conecapp/partner_module/ui/member/group_detail_page.dart';
import 'package:conecapp/partner_module/ui/member/member_detail_page.dart';
import 'package:conecapp/partner_module/ui/member/member_group_page.dart';
import 'package:conecapp/partner_module/ui/member/member_page.dart';
import 'package:conecapp/partner_module/ui/member/requests_page.dart';
import 'package:conecapp/partner_module/ui/member/search_group.dart';
import 'package:conecapp/partner_module/ui/member/search_member_page.dart';
import 'package:conecapp/partner_module/ui/member/swap_group.dart';
import 'package:conecapp/partner_module/ui/member/update_group_page.dart';
import 'package:conecapp/partner_module/ui/member/update_member_page.dart';
import 'package:conecapp/partner_module/ui/notify/add_notify_page.dart';
import 'package:conecapp/partner_module/ui/notify/notify_partner_detail_page.dart';
import 'package:conecapp/partner_module/ui/notify/notify_partner_page.dart';
import 'package:conecapp/partner_module/ui/notify/update_notify_page.dart';
import 'package:conecapp/partner_module/ui/partner_main.dart';
import 'package:conecapp/ui/address/province_page.dart';
import 'package:conecapp/ui/address/ward_page.dart';
import 'package:conecapp/ui/authen/pages/confirm_email_page.dart';
import 'package:conecapp/ui/authen/pages/forgot_password_page.dart';
import 'package:conecapp/ui/authen/pages/login_page.dart';
import 'package:conecapp/ui/authen/pages/register_page.dart';
import 'package:conecapp/ui/chat/chat_list_page.dart';
import 'package:conecapp/ui/chat/chat_page.dart';
import 'package:conecapp/ui/home/pages/google_map_page.dart';
import 'package:conecapp/ui/home/pages/introduce_page.dart';
import 'package:conecapp/ui/home/pages/item_detail_page.dart';
import 'package:conecapp/ui/home/pages/nearby_page.dart';
import 'package:conecapp/ui/home/pages/report_page.dart';
import 'package:conecapp/ui/home/widgets/scroll_behavior.dart';
import 'package:conecapp/ui/member2/member2_detail_page.dart';
import 'package:conecapp/ui/member2/member3_detail_page.dart';
import 'package:conecapp/ui/mypost/pages/category_page.dart';
import 'package:conecapp/ui/mypost/pages/edit_mypost_page.dart';
import 'package:conecapp/ui/mypost/pages/mypost_page.dart';
import 'package:conecapp/ui/news/pages/news_detail_page.dart';
import 'package:conecapp/ui/news/pages/news_page.dart';
import 'package:conecapp/ui/news/pages/sell_detail_page.dart';
import 'package:conecapp/ui/news/widgets/news_widget.dart';
import 'package:conecapp/ui/news/widgets/sell_widget.dart';
import 'package:conecapp/ui/notify/pages/notify_page.dart';
import 'package:conecapp/ui/others/open_letter_page.dart';
import 'package:conecapp/ui/others/terms_condition_page.dart';
import 'package:conecapp/ui/profile/pages/detail_profile_page.dart';
import 'package:conecapp/ui/profile/pages/edit_profile_page.dart';
import 'package:conecapp/ui/profile/pages/change_password_page.dart';
import 'package:conecapp/ui/profile/pages/guide_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'partner_module/ui/member/add_custom_member.dart';
import 'partner_module/ui/member/complete_update_payment.dart';
import 'ui/address/district_page.dart';
import 'ui/authen/pages/reset_pass_page.dart';
import 'ui/chat/search_member_chat.dart';
import 'ui/conec_home_page.dart';
import 'ui/home/pages/items_by_category_page.dart';
import 'ui/member2/fl_main_page.dart';
import 'ui/mypost/pages/post_action_page.dart';
import 'ui/mypost/pages/sub_category_page.dart';
import 'ui/notify/pages/notify_detail_page.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/profile/pages/help_page.dart';
import 'ui/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  runApp(ConecApp());
}

class ConecApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Connection',
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
        LoginPage.ROUTE_NAME: (context) => LoginPage(),
        RegisterPage.ROUTE_NAME: (context) => RegisterPage(),
        ItemByCategory.ROUTE_NAME: (context) => ItemByCategory(),
        ItemDetailPage.ROUTE_NAME: (context) => ItemDetailPage(),
        PostActionPage.ROUTE_NAME: (context) =>PostActionPage(),
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
        //VideoPlayerPage.ROUTE_NAME: (context) => VideoPlayerPage(),
        GuidePage.ROUTE_NAME: (context) => GuidePage(),
        CategoryPage.ROUTE_NAME: (context) => CategoryPage(),
        NotifyDetailPage.ROUTE_NAME: (context) => NotifyDetailPage(),
        ReportPage.ROUTE_NAME: (context) => ReportPage(),
        HelpPage.ROUTE_NAME: (context) => HelpPage(),
        SubCategoryPage.ROUTE_NAME: (context) => SubCategoryPage(),
        ChatPage.ROUTE_NAME: (context) => ChatPage(),
        PartnerMain.ROUTE_NAME: (context) => PartnerMain(),
        NotifyPartnerPage.ROUTE_NAME: (context) => NotifyPartnerPage(),
        NotifyPartnerDetailPage.ROUTE_NAME: (context) => NotifyPartnerDetailPage(),
        AddNotifyPage.ROUTE_NAME: (context) => AddNotifyPage(),
        UpdateNotifyPage.ROUTE_NAME: (context) => UpdateNotifyPage(),
        ChatListPage.ROUTE_NAME: (context) => ChatListPage(),
        MemberPage.ROUTE_NAME: (context) => MemberPage(),
        AddMemberPage.ROUTE_NAME: (context) => AddMemberPage(),
        SearchMemberPage.ROUTE_NAME: (context) => SearchMemberPage(),
        UpdateMemberPage.ROUTE_NAME: (context) => UpdateMemberPage(),
        MemberDetailPage.ROUTE_NAME: (context) => MemberDetailPage(),
        CompleteUpdatePayment.ROUTE_NAME: (context) => CompleteUpdatePayment(),
        SearchMemberChatPage.ROUTE_NAME: (context) => SearchMemberChatPage(),
        CustomMemberPage.ROUTE_NAME: (context) => CustomMemberPage(),
        FlMainPage.ROUTE_NAME: (context) => FlMainPage(),
        Member2DetailPage.ROUTE_NAME: (context) => Member2DetailPage(),
        Member3DetailPage.ROUTE_NAME: (context) => Member3DetailPage(),
        MemberGroupPage.ROUTE_NAME: (context) => MemberGroupPage(),
        GroupDetailPage.ROUTE_NAME: (context) => GroupDetailPage(),
        AddGroupPage.ROUTE_NAME: (context) => AddGroupPage(),
        UpdateGroupPage.ROUTE_NAME: (context) => UpdateGroupPage(),
        SearchGroupPage.ROUTE_NAME: (context) => SearchGroupPage(),
        SwapGroup.ROUTE_NAME: (context) => SwapGroup(),
        MyPost.ROUTE_NAME: (context) => MyPost(),
        NewsWidget.ROUTE_NAME: (context) => NewsWidget(),
        SellWidget.ROUTE_NAME: (context) => SellWidget(),
        RequestPage.ROUTE_NAME: (context) => RequestPage(),
        AcceptRequestPage.ROUTE_NAME: (context) => AcceptRequestPage(),
      },
    );
  }
}

//7C:01:2C:F5:F4:E5:E3:21:B0:9A:F2:12:F1:E8:6A:19:7F:4F:10:D7
//C9:58:FE:8D:68:F9:A4:58:29:00:39:99:8C:AF:81:88:35:A2:AB:A3:6A:DF:F6:81:41:0F:30:59:FD:C2:EA:C2