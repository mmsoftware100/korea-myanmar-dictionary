import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:koreadictioanry/data.dart';


const String FCM_TOPIC = "korea_dictionary";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Map<String, dynamic>> dictionary = data;

  // FlutterTts flutterTts = FlutterTts();
  TextEditingController textEditingController = TextEditingController();



  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;



  @override
  void initState() {
    super.initState();
    //initializeTts();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // executes after build


      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
        'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      _firebaseMessaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: false, // Set to true for iOS 12 and above to enable provisional authorization.
      );


      print("trying to subscribe topic $FCM_TOPIC");
      _firebaseMessaging.subscribeToTopic(FCM_TOPIC);
      print("subscribed");

      _firebaseMessaging.getToken().then((token) {
        print("Firebase Token: $token");
      });

      // foreground handler

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("FCM->foreground handler");
        print("Received FCM message: ${message.notification?.body}");
        showFlutterNotification(message);
      });

    });

  }

  Future<void> initializeTts() async {
    //await flutterTts.setLanguage("ko-KR");
    //await flutterTts.setPitch(1.0);
    //await flutterTts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Korea Myanmar Dictionary"),
      ),
      body: Column(
        children: [
          /*
          TextFormField(
            onChanged: _onChange,
          ),

           */
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              // controller: _controller,
              onChanged: _onChange,
              decoration: InputDecoration(
                hintText: 'Search for a word',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
            ),
          ),

          SizedBox(height: 8.0,),
          if(dictionary.isEmpty) Expanded(child: Center(child: Text("No Result Found"),)),
          if(dictionary.isNotEmpty) Text("${dictionary.length} results found!", style: TextStyle(color: Colors.grey),),
          SizedBox(height: 8.0,),
          Expanded(
              child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => _card(dictionary[index]),
                  separatorBuilder: (index, context) => Divider(),
                  itemCount: dictionary.length
              )
          )
        ],
      ),
    );
  }

  void _onChange(String str){
    // filter and set state data
    // Find the map containing the specified Myanmar word
    var result = data.where((item) => item["myn_word"].toString().contains(str) ||  item["kr_word"].toString().contains(str)).toList();
    setState(() {
      dictionary = result;
    });
  }


  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      // how to handle callback on this notification.
      // we also need payload
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'background',
          ),
        ),
      );
    }
  }


  Widget _card(Map<String, dynamic> meaning){
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
      child: Row(
        children: [
          Expanded(child: Text(meaning['myn_word'] ?? "မင်္ဂလာပါ")),
          Expanded(child: Text(meaning['kr_word'] ?? "안녕하세요")),
          IconButton(onPressed: (){ speakText(meaning['kr_word'] ?? "안녕하세요"); }, icon: Icon(Icons.speaker_outlined)),
          IconButton(onPressed: (){ _copyToClipboard(meaning['kr_word'] ?? "안녕하세요"); }, icon: Icon(Icons.copy))
        ],
      ),
    );
  }


  Future<void> speakText(String text) async {
    // flutterTts.speak(text);

    FlutterTts flutterTts = FlutterTts();
    try {
      print("trying to speak $text");
      await flutterTts.speak(text);
      print("done");
    } catch (e) {
      print("Error while speaking: $e");
    }


    //var result = await flutterTts.speak(text);
    //print(result);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // You can show a message or perform any other action here
    // toast message , snack bar

    _showSnackBar(context, '$text ကို ကူးယူပြီးပါပြီ');
  }


  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
