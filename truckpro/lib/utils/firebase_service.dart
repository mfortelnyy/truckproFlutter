import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:truckpro/utils/session_manager.dart';

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final SessionManager _sessionManager = SessionManager();
  
  FirebaseService() {
    // local notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const  iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);

    _localNotificationsPlugin.initialize(initSettings);

    //subscribe to a company topic based on companyId
    void subscribeToCompanyTopic() async {
      try {
        String? jwtToken = await _sessionManager.getToken();

        Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken!);

        String companyId = decodedToken['companyId']; 

        await _firebaseMessaging.subscribeToTopic(companyId);
        print("Subscribed to topic: $companyId");
      } catch (e) {
        print("Error subscribing to topic: $e");
      }
    }
    
    //foreground message handler
    configureForegroundMessageHandler();
    
    // background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  
  //retrieve current FCM token for the device
  Future<String?> getDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");
      return token;
    } catch (e) {
      print("Error retrieving FCM token: $e");
      return null;
    }
  }

  

  // listen for FCM token refresh
  void onTokenRefresh(Function(String) callback) {
    _firebaseMessaging.onTokenRefresh.listen(callback);
  }

  //handle incoming messages when the app is in the foreground
  void configureForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      //send notficiation
    });
  }

  //bg message handler
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Background message received: ${message.notification?.title}");
      //send notficiation
  }

  //init background messages
  void initializeBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  
}
