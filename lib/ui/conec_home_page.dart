import 'package:badges/badges.dart';
import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/helper.dart';
import 'package:conecapp/ui/home/pages/home_page.dart';
import 'package:conecapp/ui/mypost/pages/post_action_page.dart';
import 'package:conecapp/ui/notify/pages/notify_page.dart';
import 'package:conecapp/ui/profile/blocs/profile_bloc.dart';
import 'package:conecapp/ui/profile/pages/edit_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'home/blocs/home_bloc.dart';
import 'home/pages/items_by_category_page.dart';
import 'mypost/pages/mypost_page.dart';
import 'news/pages/news_page.dart';
import 'profile/pages/profile_pages.dart';
import '../common/globals.dart' as globals;

class ConecHomePage extends StatefulWidget {
  static const ROUTE_NAME = '/home';

  @override
  _ConecHomePageState createState() => _ConecHomePageState();
}

class _ConecHomePageState extends State<ConecHomePage> {
  PageController _pageController = PageController(initialPage: 0);
  int _selectedPageIndex = 0;
  int _initIndex = 0;
  bool _isMissingData = true;
  var _profile;
  int _number = 0;
  ProfileBloc _profileBloc = ProfileBloc();
  HomeBloc _homeBloc = HomeBloc();

  String _token;
  bool _isTokenExpired = true;

  //For one signal
  String _debugLabelString = "";
  String _emailAddress;
  String _externalUserId;
  bool _enableConsentButton = false;

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = true;

  void getToken() async {
    String token = await Helper.getToken();
    bool expired = await Helper.isTokenExpired();
    setState(() {
      _token = token;
      _isTokenExpired = expired;
    });
    if (!_isTokenExpired && _token != null) {
      _profileBloc.requestGetProfile();
      _homeBloc.requestGetNumberNotify();
      _profileBloc.profileStream.listen((event) {
        if (event.status == Status.COMPLETED) {
          final profile = event.data;
          if (profile.name != null &&
              profile.type != null &&
              profile.phoneNumber != null) {
            setState(() {
              _profile = profile;
              _isMissingData = false;
            });
          } else {
            setState(() {
              _profile = profile;
            });
            return;
          }
        }
      });
      _homeBloc.numberNotifyStream.listen((event) {
        if (event.status == Status.COMPLETED) {
          setState(() {
            _number = event.data;
          });
        }
      });
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _initTab1Page(int index, int initIndex) {
    debugPrint("initIndex " + initIndex.toString());
    _selectPage(index);
    setState(() {
      _initIndex = initIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    //getLocation();
    initPlatformState();
    getToken();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
        "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
        "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
        "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
            (OSEmailSubscriptionStateChanges changes) {
          print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
        });

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared
        .init("b2f7f966-d8cc-11e4-bed1-df8f05be55ba", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    this.setState(() {
      _enableConsentButton = requiresConsent;
    });

    // Some examples of how to use In App Messaging public methods with OneSignal SDK
    oneSignalInAppMessagingTriggerExamples();

    // Some examples of how to use Outcome Events public methods with OneSignal SDK
    oneSignalOutcomeEventsExamples();
  }

  oneSignalInAppMessagingTriggerExamples() async {
    /// Example addTrigger call for IAM
    /// This will add 1 trigger so if there are any IAM satisfying it, it
    /// will be shown to the user
    OneSignal.shared.addTrigger("trigger_1", "one");

    /// Example addTriggers call for IAM
    /// This will add 2 triggers so if there are any IAM satisfying these, they
    /// will be shown to the user
    Map<String, Object> triggers = new Map<String, Object>();
    triggers["trigger_2"] = "two";
    triggers["trigger_3"] = "three";
    OneSignal.shared.addTriggers(triggers);

    // Removes a trigger by its key so if any future IAM are pulled with
    // these triggers they will not be shown until the trigger is added back
    OneSignal.shared.removeTriggerForKey("trigger_2");

    // Get the value for a trigger by its key
    Object triggerValue = await OneSignal.shared.getTriggerValueForKey("trigger_3");
    print("'trigger_3' key trigger value: " + triggerValue.toString());

    // Create a list and bulk remove triggers based on keys supplied
    List<String> keys = ["trigger_1", "trigger_3"];
    OneSignal.shared.removeTriggersForKeys(keys);

    // Toggle pausing (displaying or not) of IAMs
    OneSignal.shared.pauseInAppMessages(false);
  }

  oneSignalOutcomeEventsExamples() async {
    // Await example for sending outcomes
    outcomeAwaitExample();

    // Send a normal outcome and get a reply with the name of the outcome
    OneSignal.shared.sendOutcome("normal_1");
    OneSignal.shared.sendOutcome("normal_2").then((outcomeEvent) {
      print(outcomeEvent.jsonRepresentation());
    });

    // Send a unique outcome and get a reply with the name of the outcome
    OneSignal.shared.sendUniqueOutcome("unique_1");
    OneSignal.shared.sendUniqueOutcome("unique_2").then((outcomeEvent) {
      print(outcomeEvent.jsonRepresentation());
    });

    // Send an outcome with a value and get a reply with the name of the outcome
    OneSignal.shared.sendOutcomeWithValue("value_1", 3.2);
    OneSignal.shared.sendOutcomeWithValue("value_2", 3.9).then((outcomeEvent) {
      print(outcomeEvent.jsonRepresentation());
    });
  }

  Future<void> outcomeAwaitExample() async {
    var outcomeEvent = await OneSignal.shared.sendOutcome("await_normal_1");
    print(outcomeEvent.jsonRepresentation());
  }


  void getLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("latttt: ${position.latitude}" ?? "---aaa---");
    print("longgg: ${position.longitude}" ?? "---aaa---");
    globals.latitude = position.latitude;
    globals.longitude = position.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _selectedPageIndex == 0
            ? AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Colors.red, Colors.redAccent[200]],
                  )),
                ),
                title: Text(
                  "Conec Sport",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black, size: 26),
                backgroundColor: Colors.redAccent[200],
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search, size: 32),
                    onPressed: () => Navigator.of(context).pushNamed(
                        ItemByCategory.ROUTE_NAME,
                        arguments: {'id': null, 'title': null}),
                  ),
                  _token != null && !_isTokenExpired
                      ? Badge(
                    padding: const EdgeInsets.all(3.0),
                    position: BadgePosition.topEnd(top: 5, end: -7),
                    badgeContent: Text(
                      _number.toString(),
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    badgeColor: Colors.yellowAccent,
                    showBadge: _number > 0 ? true : false,
                    child: InkWell(
                      child: Icon(Icons.notifications, size: 32, color: Colors.black87.withOpacity(0.8),),
                      onTap: () => Navigator.of(context)
                          .pushNamed(NotifyPage.ROUTE_NAME).then((value) {
                            if(value==1){
                              _homeBloc.requestGetNumberNotify();
                            }
                      }),
                    ),
                  )
                      : Container(),
                  SizedBox(width: 16,)
                ],
              )
            : null,
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            HomePage(callback: _initTab1Page),
           NewsPage(_initIndex),
            MyPost(),
            ProfilePage()
          ],
        ),
        floatingActionButton: Container(
          child: FloatingActionButton(
            onPressed: () {
              if (_token == null || _token.length == 0) {
                Helper.showAuthenticationDialog(context);
              } else {
                if (_isTokenExpired) {
                  Helper.showTokenExpiredDialog(context);
                } else {
                  if (_isMissingData) {
                    Helper.showMissingDataDialog(context, () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushNamed(EditProfilePage.ROUTE_NAME,
                              arguments: _profile)
                          .then((value) {
                        if (value == 0) {
                          _profileBloc.requestGetProfile();
                        }
                      });
                    });
                  } else {
                    Navigator.of(context).pushNamed(PostActionPage.ROUTE_NAME);
                  }
                }
              }
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        extendBody: true,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  color: _selectedPageIndex == 0 ? Colors.red : Colors.grey,
                  onPressed: () => _selectPage(0),
                  iconSize: 30,
                  icon: Icon(Icons.home),
                  tooltip: "Trang chủ",
                ),
                IconButton(
                  color: _selectedPageIndex == 1 ? Colors.red : Colors.grey,
                  onPressed: () => _selectPage(1),
                  iconSize: 30,
                  icon: Icon(Icons.explore),
                  tooltip: "Dụng cụ",
                ),
                IconButton(
                  color: _selectedPageIndex == 2 ? Colors.red : Colors.grey,
                  onPressed: () => _selectPage(2),
                  iconSize: 30,
                  icon: Icon(Icons.list),
                  tooltip: "Tin đăng",
                ),
                IconButton(
                  color: _selectedPageIndex == 3 ? Colors.red : Colors.grey,
                  onPressed: () => _selectPage(3),
                  iconSize: 30,
                  icon: Icon(Icons.more_horiz),
                  tooltip: "Thêm",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
- filter at home
- filter at ads
- add, update ads, news
- google map
*/
