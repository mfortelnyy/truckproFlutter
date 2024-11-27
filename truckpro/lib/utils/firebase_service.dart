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
    const android = AndroidInitializationSettings('@mipmap-anydpi-v26/ic_launcher');
    const  iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);

    _localNotificationsPlugin.initialize(initSettings);

    _requestNotificationPermissions();


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

  //notification permissions for iOS
  void _requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();

    // Check the permission status and handle accordingly
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Notification permissions granted");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("Notification permissions granted provisionally");
    } else {
      print("Notification permissions denied");
    }
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
      _showNotification(message.notification?.title, message.notification?.body);
    });
  }

  

  //bg message handler
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Log the message when it comes in the background
    print("Background message received: ${message.notification?.title}");

    // Handle notification payload
    if (message.notification != null) {
      await _showNotification(message.notification?.title, message.notification?.body);
    }

    // You can also process data payload here if needed
    if (message.data.isNotEmpty) {
      print('Data payload: ${message.data}');
    }
  }

  static Future<void> _showNotification(String? title, String? body) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await FlutterLocalNotificationsPlugin().show(0, title, body, details);
  }

  //init background messages
  void initializeBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  

  
}
