import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trucksnap/utils/driver_api_service.dart';
import 'package:trucksnap/utils/login_service.dart';
import 'package:trucksnap/utils/session_manager.dart';
import 'package:trucksnap/views/base_home_view.dart';
import 'package:trucksnap/views/upload_photos_view.dart';
import 'package:trucksnap/views/update_password_view.dart';
import 'package:trucksnap/views/user_signin_page.dart';

import '../models/userDto.dart';

class DriverHomeView extends BaseHomeView {
  final String token;
  @override
  final SessionManager sessionManager;
  @override
  final Function(bool) toggleTheme;

  DriverHomeView({
    Key? key,
    required this.token,
    required this.sessionManager,
    required this.toggleTheme,
  }) : super(sessionManager: sessionManager, toggleTheme: toggleTheme);

  late DriverApiService driverApiService = DriverApiService(token: token);

  @override
  _DriverHomeViewState createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends BaseHomeViewState<DriverHomeView> {
  UserDto? user;
  bool isDarkMode = false;
  /// This flag tells us whether the driver has already uploaded the photo today.
  /// It starts as null (unknown) and is set after we the API query.
  bool? photoUploaded;
  
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchUser();
    _fetchDailyPhotoStatus();
    // refresh the photo upload status every 5 minutes.
    _statusTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _fetchDailyPhotoStatus();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _fetchUser() async {
    try {
      final fetchedUser = await LoginService().getUserById(widget.token);
      setState(() {
        user = fetchedUser;
      });
    } catch (e) {
      widget.sessionManager.clearSession();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(toggleTheme: widget.toggleTheme),
        ),
      );
    }
  }

  Future<void> _fetchDailyPhotoStatus() async {
    
    // Future<bool> hasUploadedPhotoForToday();
    try {
      bool status = await widget.driverApiService.hasUploadedPhotoForToday();
      setState(() {
        photoUploaded = status;
      });
    } catch (e) {
      // In case of error, assume no photo has been uploaded.
      setState(() {
        photoUploaded = false;
      });
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  /// checks if the current local time is after 5:00 AM.
  bool _isAfterFiveAM() {
    DateTime now = DateTime.now();
    return now.hour >= 5;
  }

  /// When it’s after 5:00 AM and the photo is not uploaded,
  /// we “lock” the UI with a message and an Upload button.
  Widget _buildLockedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              "Daily Photo Upload Required",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "It's after 5:00 AM. Please upload your truck photo to continue.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to the photo upload screen.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPhotosScreen(
                      token: widget.token,
                      onPhotoUpload: () {
                        // After a successful upload, refresh the status.
                        return _fetchDailyPhotoStatus();
                      },
                    ),
                  ),
                );
              },
              child: Text("Upload Photo"),
            ),
          ],
        ),
      ),
    );
  }

  /// When it’s not yet time or the photo has been uploaded,
  /// we show a “normal” home page with a welcome message and status.
  Widget _buildNormalScreen() {
    DateTime now = DateTime.now();
    String welcomeMessage =
        user != null ? "Welcome, ${user!.firstName} ${user!.lastName}" : "Driver Home";
    String statusMessage;
    if (_isAfterFiveAM()) {
      if (photoUploaded == true) {
        statusMessage = "Your photo for today has been uploaded. Thank you!";
      } else {
        statusMessage = "Please upload your truck photo for today.";
      }
    } else {
      // Calculate time remaining until 5:00 AM.
      DateTime nextFiveAM = DateTime(now.year, now.month, now.day, 5);
      if (now.hour >= 5) {
        // If already past 5, then the next window is tomorrow.
        nextFiveAM = nextFiveAM.add(Duration(days: 1));
      }
      Duration diff = nextFiveAM.difference(now);
      String hours = diff.inHours.toString().padLeft(2, '0');
      String minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      statusMessage = "Next photo upload window opens in $hours:$minutes (HH:MM)";
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              welcomeMessage,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              statusMessage,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            // If it’s after 5:00 AM and the photo isn’t uploaded yet, offer the upload button.
            if (_isAfterFiveAM() && (photoUploaded == false))
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadPhotosScreen(
                        token: widget.token,
                        onPhotoUpload: () {
                          return _fetchDailyPhotoStatus();
                        },
                      ),
                    ),
                  );
                },
                child: Text("Upload Photo Now"),
              ),
          ],
        ),
      ),
    );
  }

  /// The drawer remains largely unchanged except for options that are
  /// now relevant to this simplified photo upload functionality.
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 241, 158, 89),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Driver Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  user != null ? user!.email : 'Loading...',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.password_rounded, color: isDarkMode ? Colors.white : Colors.black),
            title: Text('Change Password', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UpdatePasswordView(token: widget.token, toggleTheme: widget.toggleTheme),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: isDarkMode ? Colors.white : Colors.black),
            title: Text('Sign Out', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              widget.sessionManager.clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInPage(toggleTheme: widget.toggleTheme),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we have not yet determined whether the photo is uploaded,
    // show a loading indicator.
    if (photoUploaded == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Driver Home"),
          backgroundColor: Color.fromARGB(255, 241, 158, 89),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
                widget.toggleTheme(isDarkMode);
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If it’s after 5:00 AM and the photo hasn’t been uploaded,
    // display the locked screen.
    if (_isAfterFiveAM() && photoUploaded == false) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Driver Home"),
          backgroundColor: Color.fromARGB(255, 241, 158, 89),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
                widget.toggleTheme(isDarkMode);
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: _buildLockedScreen(),
      );
    } else {
      // Otherwise, show the normal home screen.
      return Scaffold(
        appBar: AppBar(
          title: Text(user != null ? "Welcome, ${user!.firstName}" : "Driver Home"),
          backgroundColor: Color.fromARGB(255, 241, 158, 89),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
                widget.toggleTheme(isDarkMode);
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: _buildNormalScreen(),
      );
    }
  }
}