import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
