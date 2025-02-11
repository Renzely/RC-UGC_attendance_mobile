// ignore_for_file: must_be_immutable, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, unnecessary_string_interpolations, sort_child_properties_last, avoid_print, use_rethrow_when_possible, depend_on_referenced_packages
import 'dart:convert';
import 'dart:io';

import 'package:demo_app/editInventory_screen.dart';
import 'package:demo_app/editRTV_screen.dart';
import 'package:demo_app/inventoryAdd_screen.dart';
import 'package:demo_app/login_screen.dart';
import 'package:demo_app/dbHelper/constant.dart';
import 'package:demo_app/dbHelper/mongodb.dart';
import 'package:demo_app/dbHelper/mongodbDraft.dart';
import 'package:demo_app/provider.dart';
import 'package:demo_app/returnVendor_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:io';
import 'dart:async'; // Import for Timer

class Attendance extends StatelessWidget {
  final String userName;
  final String userLastName;
  final String userEmail;
  String userMiddleName;
  String userContactNum;

  Attendance({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
    required this.userContactNum,
    required this.userMiddleName,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: SideBarLayout(
          title: "ATTENDANCE",
          mainContent: SingleChildScrollView(
            // Wrap the Column with SingleChildScrollView
            child: Column(
              children: [
                DateTimeWidget(),
                AttendanceWidget(
                    userEmail: userEmail,
                    userFirstName: userName,
                    userLastName: userLastName),
              ],
            ),
          ),
          userName: userName,
          userLastName: userLastName,
          userEmail: userEmail,
          userContactNum: userContactNum,
          userMiddleName: userMiddleName,
        ));
  }
}

class AttendanceWidget extends StatefulWidget {
  final String userEmail;
  final String userFirstName;
  final String userLastName;

  AttendanceWidget({
    required this.userEmail,
    required this.userFirstName,
    required this.userLastName,
  });
  @override
  _AttendanceWidgetState createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  String? timeInLocation = 'No location';
  String? timeOutLocation = 'No location';
  bool _isTimeInLoading = false; // For Time In button loading state
  bool _isTimeOutLoading = false; // For Time Out button loading state
  String? _selectedAccount; // Persisted selected value
  List<String> _branchList = [];
  Map<String, Map<String, dynamic>> _attendanceData = {};
  File? _selfie;
  File? _timeOutSelfie;
  final picker = ImagePicker();

  Future<void> _pickSelfie() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selfie = File(pickedFile.path);
      });

      // Save the selfie URL (or file path) to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'selfieUrl', pickedFile.path); // Store the path of the image file
    }
  }

  Future<void> _loadSelfieUrl(BuildContext context) async {
    if (_selectedAccount == null) {
      print("No branch selected. Cannot load selfie URL.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load 'isTimeInRecorded' flag and selfie URL for the selected branch
    bool isRecorded =
        prefs.getBool('isTimeInRecorded_${_selectedAccount!}') ?? false;
    String? storedSelfieUrl = prefs.getString('selfieUrl_${_selectedAccount!}');

    // Update the AttendanceModel
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);
    attendanceModel.setIsTimeInRecorded(isRecorded);

    if (storedSelfieUrl != null) {
      attendanceModel.setSelfieUrlForBranch(_selectedAccount!, storedSelfieUrl);
      print("Loaded selfie URL for branch $_selectedAccount: $storedSelfieUrl");
    } else {
      print("No selfie URL found for branch $_selectedAccount.");
    }
  }

  Future<void> _pickTimeOutSelfie() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _timeOutSelfie = File(pickedFile.path);
      });

      // Save the time-out selfie URL (or file path) to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('timeOutSelfieUrl_${_selectedAccount!}',
          pickedFile.path); // Store the time-out selfie file path
      await prefs.setBool('isTimeOutRecorded_${_selectedAccount!}',
          true); // Flag indicating time-out selfie was recorded
    }
  }

  Future<void> _loadTimeOutSelfieUrl(BuildContext context) async {
    if (_selectedAccount == null) {
      print("No branch selected. Cannot load time-out selfie URL.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load 'isTimeOutRecorded' flag and time-out selfie URL for the selected branch
    bool isRecorded =
        prefs.getBool('isTimeOutRecorded_${_selectedAccount!}') ?? false;
    String? storedTimeOutSelfieUrl =
        prefs.getString('timeOutSelfieUrl_${_selectedAccount!}');

    // Update the AttendanceModel
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);
    attendanceModel.setIsTimeOutRecorded(isRecorded);

    if (storedTimeOutSelfieUrl != null) {
      attendanceModel.setTimeOutSelfieUrlForBranch(
          _selectedAccount!, storedTimeOutSelfieUrl);
      print(
          "Loaded time-out selfie URL for branch $_selectedAccount: $storedTimeOutSelfieUrl");
    } else {
      print("No time-out selfie URL found for branch $_selectedAccount.");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSelfieUrl(
          context); // Load the selfie URL when the screen is initialized
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeOutSelfieUrl(
          context); // Load the selfie URL when the screen is initialized
    });
    _loadSavedBranch();

    // Set loading states to true initially
    _isTimeInLoading = true;
    _isTimeOutLoading = true;

    // Fetch branches and initialize attendance status
    fetchBranches().then((_) {
      // After branches are fetched, initialize the attendance status
      _initializeAttendanceStatus().then((_) {
        // Once the attendance status is initialized, set loading states to false
        setState(() {
          _isTimeInLoading = false;
          _isTimeOutLoading = false;
        });
      }).catchError((error) {
        // Handle any errors that occur during initialization
        print("Error initializing attendance status: $error");
        setState(() {
          _isTimeInLoading = false;
          _isTimeOutLoading =
              false; // Ensure loading states are reset even on error
        });
      });
    }).catchError((error) {
      // Handle any errors that occur during branch fetching
      print("Error fetching branches: $error");
      setState(() {
        _isTimeInLoading = false;
        _isTimeOutLoading =
            false; // Ensure loading states are reset even on error
      });
    });
  }

  Future<void> fetchBranches() async {
    try {
      final db = await mongo.Db.create(MONGO_CONN_URL);
      await db.open();
      final collection = db.collection(USER_COLLECTION);
      final List<Map<String, dynamic>> branchDocs = await collection
          .find(mongo.where.eq('emailAddress', widget.userEmail))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final savedBranch = prefs.getString('selectedBranch');

      setState(() {
        _branchList = branchDocs
            .map((doc) => doc['accountNameBranchManning'])
            .where((branch) => branch != null)
            .expand((branch) => branch is List ? branch : [branch])
            .map((branch) => branch.toString())
            .toList();

        // Use the saved branch if it exists, otherwise fallback to the first branch
        _selectedAccount =
            savedBranch != null && _branchList.contains(savedBranch)
                ? savedBranch
                : (_branchList.isNotEmpty ? _branchList.first : '');
      });

      // Load attendance data for the saved/selected branch
      if (_selectedAccount != null && _attendanceData.isEmpty) {
        await _loadAttendanceLocally(_selectedAccount!);
      }

      await db.close();
    } catch (e) {
      print('Error fetching branch data: $e');
    }
  }

  Future<void> _loadSavedBranch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAccount = prefs.getString('selectedBranch');
    });
  }

  Future<void> _saveSelectedBranch(String branch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedBranch', branch);
  }

  Future<void> _onBranchChanged(String newBranch) async {
    setState(() {
      _selectedAccount = newBranch;
    });
    _loadSelfieUrl(context);
    _loadTimeOutSelfieUrl(context);
    _saveSelectedBranch(newBranch); // Save the selected branch

    // Reset attendance model
    Provider.of<AttendanceModel>(context, listen: false).reset();

    // Remove cached data for the selected branch to ensure fresh data loads
    _attendanceData.remove(newBranch);

    // Re-initialize attendance status for the selected branch
    await _initializeAttendanceStatus();
  }

  Future<Map<String, dynamic>?> _loadAttendanceLocally(
      String accountNameBranchManning) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = '${widget.userEmail}_${accountNameBranchManning}';
    String? storedData = prefs.getString(key);
    if (storedData != null) {
      return jsonDecode(storedData);
    }
    return null;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> _initializeAttendanceStatus() async {
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? currentBranch = _selectedAccount;

    if (currentBranch == null) {
      print("Warning: No selected account found.");
      return;
    }

    Map<String, dynamic>? localData = _attendanceData[currentBranch];

    if (localData != null && localData.isNotEmpty) {
      _updateUIFromLocalData(localData);
    } else {
      var attendanceStatus = await MongoDatabase.getAttendanceStatus(
          widget.userEmail, _selectedAccount!);

      if (attendanceStatus != null && attendanceStatus.isNotEmpty) {
        if (attendanceStatus['accountNameBranchManning'] == currentBranch) {
          List<dynamic> rawLogs = attendanceStatus['timeLogs'];

          Map<String, dynamic>? latestLog;
          if (rawLogs.isNotEmpty) {
            latestLog = rawLogs.reduce((a, b) =>
                DateTime.parse(a['timeIn']).isAfter(DateTime.parse(b['timeIn']))
                    ? a
                    : b);
          }

          if (latestLog != null) {
            Map<String, dynamic> attendanceData = {
              'timeIn': latestLog['timeIn'],
              'timeOut': latestLog['timeOut'],
              'timeInLocation': latestLog['timeInLocation'],
              'timeOutLocation': latestLog['timeOutLocation'],
              'accountNameBranchManning':
                  attendanceStatus['accountNameBranchManning'],
              'isTimeInRecorded': latestLog['timeIn'] != null,
              'isTimeOutRecorded': latestLog['timeOut'] != null,
            };

            _updateUIFromServerData(attendanceData);
            _attendanceData[currentBranch] = attendanceData;
            _saveAttendanceLocally(currentBranch, attendanceData);
          } else {
            _updateUIForNoAttendance();
          }
        } else {
          _updateUIForNoAttendance();
        }
      } else {
        _updateUIForNoAttendance();
      }
    }
  }

  void _updateUIFromLocalData(Map<String, dynamic> localData) {
    setState(() {
      timeInLocation = localData['timeInLocation'] ?? 'No location';
      timeOutLocation = localData['timeOutLocation'] ?? 'No location';
    });

    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);
    attendanceModel.updateTimeIn(localData['timeIn']);
    attendanceModel.updateTimeOut(localData['timeOut']);
    attendanceModel.setIsTimeInRecorded(localData['isTimeInRecorded']);
    attendanceModel.setIsTimeOutRecorded(localData['isTimeOutRecorded']);
  }

  void _updateUIFromServerData(Map<String, dynamic> serverData) {
    setState(() {
      timeInLocation = serverData['timeInLocation'] ?? 'No location';
      timeOutLocation = serverData['timeOutLocation'] ?? 'No location';
    });

    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);

    attendanceModel.updateTimeIn(serverData['timeIn']);
    attendanceModel.updateTimeOut(serverData['timeOut']);
    attendanceModel
        .setIsTimeInRecorded(serverData['isTimeInRecorded'] ?? false);
    attendanceModel
        .setIsTimeOutRecorded(serverData['isTimeOutRecorded'] ?? false);

    if (_selectedAccount != null && serverData.isNotEmpty) {
      _attendanceData[_selectedAccount!] = serverData; // Use '!' for null check
      _saveAttendanceLocally(
          _selectedAccount!, serverData); // Use '!' for null check
    }
  }

  void _updateUIForNoAttendance() {
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);
    attendanceModel.reset();
    setState(() {
      timeInLocation = 'No location';
      timeOutLocation = 'No location';
    });

    if (_selectedAccount != null) {
      _attendanceData[_selectedAccount!] = {};
      _saveAttendanceLocally(_selectedAccount!, {}); // Use '!' for null check
    }
  }

  void _saveAttendanceLocally(
      String branch, Map<String, dynamic> attendanceData) {
    SharedPreferences.getInstance().then((prefs) {
      String key = '${widget.userEmail}_all_attendance';
      String? storedData = prefs.getString(key);
      Map<String, dynamic> allAttendanceData;

      if (storedData != null) {
        allAttendanceData = jsonDecode(storedData);
      } else {
        allAttendanceData = {};
      }

      if (branch != null && attendanceData.isNotEmpty) {
        allAttendanceData[branch] = attendanceData;
      } else if (branch != null) {
        allAttendanceData.remove(branch);
      }
      prefs.setString(key, jsonEncode(allAttendanceData));
    });
  }

  Future<Map<String, dynamic>> _loadAllAttendanceLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = '${widget.userEmail}_all_attendance';
    String? storedData = prefs.getString(key);

    if (storedData != null) {
      return jsonDecode(storedData);
    }
    return {};
  }

  String? _formatTime(String? time) {
    if (time == null) return 'Not recorded';
    try {
      // Try parsing the time using DateTime.tryParse() for safer error handling
      DateTime dateTime = DateTime.tryParse(time) ??
          DateTime.now(); // Default to current time if parsing fails
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      print('Error formatting time: $e');
      return 'Not recorded';
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    return "${place.street}, ${place.locality}, ${place.administrativeArea}";
  }

  Future<void> _confirmAndRecordTimeIn(BuildContext context) async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar(
          context, 'Please enable location services to mark attendance.');
      return;
    }

    // Check if location permission is granted
    bool permissionGranted = await checkLocationPermission();
    if (!permissionGranted) {
      _showSnackbar(
          context, 'Location permission denied. Please allow access.');
      return;
    }

    // Proceed with confirmation and recording time in
    bool confirmed = await _showConfirmationDialog('Time In');
    if (confirmed) {
      setState(() {
        _isTimeInLoading = true; // Start loading
      });

      try {
        _recordTimeIn(context); // Existing code to record time in
      } finally {
        setState(() {
          _isTimeInLoading =
              false; // Ensure loading stops even if an error occurs
        });
      }
    }
  }

  Future<void> _confirmAndRecordTimeOut(BuildContext context) async {
    bool confirmed = await _showConfirmationDialog('Time Out');
    if (confirmed) {
      setState(() {
        _isTimeOutLoading = true; // Start loading
      });

      try {
        _recordTimeOut(context);
      } finally {
        setState(() {
          _isTimeOutLoading =
              false; // Ensure loading stops even if an error occurs
        });
      }
    }
  }

  void _recordTimeIn(BuildContext context) async {
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);
    String currentTimeIn =
        DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());

    Position? position = await _getCurrentLocation();
    String location = 'No location';
    double? latitude;
    double? longitude;

    if (position != null) {
      location = await _getAddressFromLatLong(position);
      latitude = position.latitude;
      longitude = position.longitude;

      setState(() {
        timeInLocation = location;
      });
    }

    // Step 1: Capture and upload selfie
    if (_selfie == null) {
      await _pickSelfie();
    }
    if (_selfie == null) {
      _showSnackbar(context, 'Selfie is required to record Time In');
      return;
    }

    String selfieUrl = '';
    try {
      // Format the date as YYYY-MM-DD
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Generate the file name with a "timein" indication
      String fileName =
          '${widget.userFirstName}_${widget.userLastName}_timein_$formattedDate.jpg';

      // Compress and resize the image (optional step to reduce file size)
      File compressedImage = await _compressImage(_selfie!);

      // Get the pre-signed URL from the backend
      final response = await http.post(
        Uri.parse('http://192.168.50.55:8080/save-attendance-images'),
        body: jsonEncode({
          'fileName': fileName, // Pass the modified file name
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to generate pre-signed URL');
      }

      final uploadUrl = jsonDecode(response.body)['url'];

      // Step 2: Upload selfie to S3
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        body: compressedImage.readAsBytesSync(),
        headers: {'Content-Type': 'image/jpeg'},
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception(
            'Failed to upload selfie. Status Code: ${uploadResponse.statusCode}');
      }

      // Extract the uploaded image URL (this URL doesn't include the query params)
      selfieUrl = uploadUrl.split('?').first;
    } catch (e) {
      _showSnackbar(context, 'Error uploading selfie: $e');
      return;
    }

    // Step 2: Save data to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('timeInLocation', location);
    await prefs.setDouble('timeInLatitude', latitude ?? 0.0);
    await prefs.setDouble('timeInLongitude', longitude ?? 0.0);
    await prefs.setString('timeIn', currentTimeIn); // Save Time In
    await prefs.setBool('isTimeInRecorded_${_selectedAccount}', true);
    await prefs.setString('selfieUrl_${_selectedAccount}', selfieUrl);

    // Step 3: Save Time In to the database
    try {
      var result = await MongoDatabase.logTimeIn(
        widget.userEmail,
        location,
        _selectedAccount ?? '',
        latitude ?? 0.0, // Default to 0.0 if position is null
        longitude ?? 0.0, // Default to 0.0 if position is null
        selfieUrl, // Pass the selfie URL
      );

      if (result == "Success") {
        // Update the attendance model and UI state after successful Time In
        attendanceModel.updateTimeIn(currentTimeIn);
        attendanceModel.setIsTimeInRecorded(true);
        attendanceModel.setSelfieUrlForBranch(_selectedAccount!, selfieUrl);

        _showSnackbar(context, 'Time In recorded successfully');
      } else {
        _showSnackbar(context, 'Failed to record Time In');
      }
    } catch (e) {
      _showSnackbar(context, 'Error recording Time In');
    }
  }

  Future<File> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

    if (image != null) {
      // Resize the image (optional: adjust the width and height as needed)
      img.Image resizedImage =
          img.copyResize(image, width: 800); // Adjust width to 800px

      // Compress the image to reduce quality (optional: adjust the quality from 0 to 100)
      List<int> compressedBytes =
          img.encodeJpg(resizedImage, quality: 80); // Quality 80 (out of 100)

      // Convert compressed image to File for upload
      File compressedImageFile = File(imageFile.path)
        ..writeAsBytesSync(compressedBytes);
      return compressedImageFile;
    } else {
      throw Exception('Failed to process image');
    }
  }

  void _recordTimeOut(BuildContext context) async {
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);
    String currentTimeOut =
        DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());

    Position? position = await _getCurrentLocation();
    String location = 'No location';
    double? latitude;
    double? longitude;

    if (position != null) {
      location = await _getAddressFromLatLong(position);
      latitude = position.latitude;
      longitude = position.longitude;

      setState(() {
        timeOutLocation = location;
      });
    }

    // ✅ Ensure selfie is captured
    if (_timeOutSelfie == null) {
      await _pickTimeOutSelfie();
    }
    if (_timeOutSelfie == null) {
      _showSnackbar(context, 'Selfie is required to record Time Out');
      return;
    }

    String timeOutselfieUrl = '';
    try {
      // Format the date as YYYY-MM-DD
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Generate the file name with a "timeout" indication
      String fileName =
          '${widget.userFirstName}_${widget.userLastName}_timeout_$formattedDate.jpg';

      File compressedImage = await _compressImage(_timeOutSelfie!);

      final response = await http.post(
        Uri.parse('http://192.168.50.55:8080/save-attendance-images'),
        body: jsonEncode({'fileName': fileName}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200)
        throw Exception('Failed to generate pre-signed URL');

      final uploadUrl = jsonDecode(response.body)['url'];

      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        body: compressedImage.readAsBytesSync(),
        headers: {'Content-Type': 'image/jpeg'},
      );

      if (uploadResponse.statusCode != 200)
        throw Exception('Failed to upload selfie');

      timeOutselfieUrl = uploadUrl.split('?').first;
    } catch (e) {
      _showSnackbar(context, 'Error uploading selfie: $e');
      return;
    }

    // ✅ Save data to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('timeOutLocation', location);
    await prefs.setDouble('timeOutLatitude', latitude ?? 0.0);
    await prefs.setDouble('timeOutLongitude', longitude ?? 0.0);
    await prefs.setString('timeOut', currentTimeOut);
    await prefs.setBool('isTimeOutRecorded_${_selectedAccount}', true);
    await prefs.setString(
        'timeOutSelfieUrl_${_selectedAccount}', timeOutselfieUrl);

    // ✅ Save Time Out to the database
    try {
      var result = await MongoDatabase.logTimeOut(
        widget.userEmail,
        location,
        _selectedAccount ?? '',
        latitude ?? 0.0,
        longitude ?? 0.0,
        timeOutselfieUrl,
      );

      if (result == "Success") {
        attendanceModel.updateTimeOut(currentTimeOut);
        attendanceModel.setIsTimeOutRecorded(true);
        attendanceModel.setTimeOutSelfieUrlForBranch(
            _selectedAccount!, timeOutselfieUrl);

        _showSnackbar(context, 'Time Out recorded successfully');
      } else if (result == "No open time found for today") {
        _showSnackbar(context, 'No open Time In found to log Time Out');
      } else {
        _showSnackbar(context, 'Failed to record Time Out');
      }
    } catch (e) {
      _showSnackbar(context, 'Error recording Time Out');
    } finally {
      setState(() {
        _isTimeOutLoading = false; // Stop loading
      });
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _viewSelfie(BuildContext context) {
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);

    // Safely handle null _selectedAccount
    if (_selectedAccount == null) {
      _showSnackbar(context, "Please select a branch first.");
      return;
    }

    final selfieUrl = attendanceModel.getSelfieUrlForBranch(_selectedAccount!);
    final timeIn = attendanceModel.timeIn;
    final location = timeInLocation; // Assuming this holds the location value

    print("Retrieved selfie URL for branch $_selectedAccount: $selfieUrl");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your Time In Picture",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 15),
              selfieUrl != null
                  ? (selfieUrl.startsWith(
                          '/data/user/') // Check if it's a local file path
                      ? Image.file(
                          File(selfieUrl),
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        )
                      : Image.network(
                          selfieUrl, // Handle network URL if needed
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ))
                  : const Text("No photo available."),
              SizedBox(height: 15),

              // ✅ Time In and Location Below the Picture
              Text(
                "Time In: ${_formatTime(attendanceModel.timeIn)}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),

              Text(
                "Location: $location",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _viewTimeOutSelfie(BuildContext context) {
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);

    // Safely handle null _selectedAccount
    if (_selectedAccount == null) {
      _showSnackbar(context, "Please select a branch first.");
      return;
    }

    final timeOutSelfieUrl =
        attendanceModel.getTimeOutSelfieUrlForBranch(_selectedAccount!);
    final timeOut = attendanceModel.timeOut;
    final timeOutlocation = timeOutLocation;

    print(
        "Retrieved Time Out selfie URL for branch $_selectedAccount: $timeOutSelfieUrl");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your Time Out Picture",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 15),
              timeOutSelfieUrl != null
                  ? (timeOutSelfieUrl.startsWith(
                          '/data/user/') // Check if it's a local file path
                      ? Image.file(
                          File(timeOutSelfieUrl), // Local file path image
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        )
                      : Uri.tryParse(timeOutSelfieUrl)?.isAbsolute == true
                          ? Image.network(
                              timeOutSelfieUrl, // Handle network URL
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                            )
                          : const Text("Invalid URL"))
                  : const Text("No photo available."),
              SizedBox(height: 10),
              Text(
                "Time Out: ${_formatTime(attendanceModel.timeOut)}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                "Location: $timeOutlocation",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Consumer<AttendanceModel>(
        builder: (context, attendanceModel, child) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedAccount,
                  items: _branchList.map((branch) {
                    return DropdownMenuItem<String>(
                      value: branch,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        child: Row(
                          children: [
                            Icon(Icons.storefront_outlined,
                                color: Colors.blue[900]!),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                branch,
                                style: TextStyle(color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: attendanceModel.isTimeInRecorded &&
                          !attendanceModel.isTimeOutRecorded
                      ? null // Disable if user is clocked in
                      : (value) => _onBranchChanged(value!),
                  decoration: InputDecoration(
                    hintText: 'Select Branch',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.blue[900]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          BorderSide(color: Colors.blue[900]!, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a branch';
                    }
                    return null;
                  },
                  disabledHint: Text(_selectedAccount ?? 'Select Branch',
                      style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(height: 20),

                // Time In Container
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[900]!.withOpacity(0.8),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "TIME IN",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: !attendanceModel.isTimeInRecorded &&
                                !_isTimeInLoading
                            ? () async {
                                setState(() {
                                  _isTimeInLoading =
                                      true; // Show loading spinner
                                });

                                // Step 1: Capture a selfie
                                await _pickSelfie();

                                if (_selfie == null) {
                                  _showSnackbar(context,
                                      'Selfie is required for Time In');
                                  setState(() {
                                    _isTimeInLoading =
                                        false; // Stop loading spinner
                                  });
                                  return;
                                }

                                // Step 2: Record Time In with selfie
                                await _confirmAndRecordTimeIn(context);

                                setState(() {
                                  _isTimeInLoading =
                                      false; // Stop loading spinner
                                });
                              }
                            : null,
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(vertical: 30),
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                            const Size(150, 50),
                          ),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (!attendanceModel.isTimeInRecorded) {
                                return Colors.blue[900]!;
                              } else {
                                return Colors.grey;
                              }
                            },
                          ),
                        ),
                        child: _isTimeInLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Time In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                      SizedBox(height: 15),
                      if (attendanceModel.isTimeInRecorded &&
                          _selectedAccount != null &&
                          attendanceModel
                                  .getSelfieUrlForBranch(_selectedAccount!) !=
                              null)
                        ElevatedButton(
                          onPressed: () {
                            _viewSelfie(context); // Function to view the selfie
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            backgroundColor: Colors.blue[400],
                          ),
                          child: const Text(
                            "View Picture",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      SizedBox(height: 35),
                      Text(
                        "Time In: ${_formatTime(attendanceModel.timeIn)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        "Location: $timeInLocation",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Time Out Container
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[900]!.withOpacity(0.8),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "TIME OUT",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: attendanceModel.isTimeInRecorded &&
                                !attendanceModel.isTimeOutRecorded &&
                                !_isTimeOutLoading
                            ? () async {
                                setState(() {
                                  _isTimeOutLoading =
                                      true; // Show loading spinner
                                });

                                // Step 1: Capture a selfie
                                await _pickTimeOutSelfie();

                                if (_timeOutSelfie == null) {
                                  _showSnackbar(context,
                                      'Selfie is required for Time Out');
                                  setState(() {
                                    _isTimeOutLoading =
                                        false; // Stop loading spinner
                                  });
                                  return;
                                }

                                // Step 2: Record Time Out with selfie URL
                                await _confirmAndRecordTimeOut(context);

                                // ✅ Step 3: Update AttendanceModel immediately
                                final updatedTimeOutSelfieUrl = attendanceModel
                                    .getTimeOutSelfieUrlForBranch(
                                        _selectedAccount!);

                                setState(() {
                                  attendanceModel.setTimeOutSelfieUrlForBranch(
                                    _selectedAccount!,
                                    updatedTimeOutSelfieUrl ??
                                        '', // ✅ Fallback to an empty string if null
                                  );
                                  _isTimeOutLoading =
                                      false; // Stop loading spinner
                                });
                              }
                            : null,
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(vertical: 30),
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                              const Size(150, 50)),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (attendanceModel.isTimeInRecorded &&
                                !attendanceModel.isTimeOutRecorded) {
                              return Colors.red; // Time Out button active
                            } else {
                              return Colors.grey; // Time Out button inactive
                            }
                          }),
                        ),
                        child: _isTimeOutLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Time Out",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                      SizedBox(height: 15),

                      // ✅ View Picture Button (Updated Condition)
                      if (attendanceModel.isTimeOutRecorded &&
                          _selectedAccount != null &&
                          (attendanceModel.getTimeOutSelfieUrlForBranch(
                                      _selectedAccount!) !=
                                  null &&
                              attendanceModel
                                  .getTimeOutSelfieUrlForBranch(
                                      _selectedAccount!)!
                                  .isNotEmpty)) // Ensure it's not empty
                        ElevatedButton(
                          onPressed: () {
                            _viewTimeOutSelfie(
                                context); // Function to view the selfie
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            backgroundColor: Colors.blue[400],
                          ),
                          child: const Text(
                            "View Picture",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      SizedBox(height: 15),

                      // ✅ Display Time Out and Location
                      Text(
                        "Time Out: ${_formatTime(attendanceModel.timeOut)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        "Location: $timeOutLocation",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                if (attendanceModel.timeIn == null ||
                    _formatTime(attendanceModel.timeIn) == null)
                  Text(
                    'No attendance recorded for this branch.',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String action) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm $action'),
            content: Text('Are you sure you want to record $action?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// class Inventory extends StatefulWidget {
//   final String userName;
//   final String userLastName;
//   final String userEmail;
//   final String userContactNum;
//   final String userMiddleName;

//   const Inventory({
//     required this.userName,
//     required this.userLastName,
//     required this.userEmail,
//     required this.userContactNum,
//     required this.userMiddleName,
//   });

//   @override
//   _InventoryState createState() => _InventoryState();
// }

// class _InventoryState extends State<Inventory> {
//   int pageSize = 5;
//   int currentPage = 0;
//   late Future<List<InventoryItem>> _futureInventory;
//   bool _sortByLatest = true; // Default to sorting by latest date
//   Map<String, bool> itemEditingStatus = {};
//   List<InventoryItem> currentPageItems = []; // Populate with your items
//   Map<String, bool> editingStates = {};
//   // // SharedPreferences Helper Functions
//   // Future<void> saveEditingStatus(
//   //     String inputId, bool status, String userEmail) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   try {
//   //     String key = '${userEmail}_$inputId'; // Include the user email in the key
//   //     print('Saving editing status for key: $key with status: $status');
//   //     await prefs.setBool(key, status);
//   //   } catch (e) {
//   //     print('Error saving editing status: $e');
//   //   }
//   // }

//   // Future<bool> loadEditingStatus(String inputId, String userEmail) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   String key = '${userEmail}_$inputId'; // Include the user email in the key
//   //   bool status = prefs.getBool(key) ?? false;
//   //   print('Loaded editing status for key: $key - Status: $status');
//   //   return status;
//   // }

//   // Future<void> clearEditingStatus(String inputId, String userEmail) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   String key = '${userEmail}_$inputId'; // Include the user email in the key
//   //   await prefs.remove(key);
//   // }

//   // Function to fetch editing status from MongoDB

//   Future<bool> _getEditingStatus(String inputId, String userEmail) async {
//     return await MongoDatabase.getEditingStatus(inputId, userEmail);
//   }

//   Future<void> _updateEditingStatus(
//       String inputId, String userEmail, bool isEditing) async {
//     try {
//       final db = await mongo.Db.create(
//           INVENTORY_CONN_URL); // Ensure 'mongo' is imported correctly
//       await db.open();
//       final collection = db.collection(USER_INVENTORY);

//       // Update the document where 'inputId' and 'userEmail' match, setting 'isEditing' to the provided value
//       await collection.update(
//         mongo.where.eq('inputId', inputId).eq('userEmail', userEmail),
//         mongo.modify.set('isEditing', isEditing),
//       );

//       await db.close();
//     } catch (e) {
//       print('Error updating editing status: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   void _fetchData() {
//     setState(() {
//       _futureInventory = _fetchInventoryData();
//     });
//   }

//   Future<List<InventoryItem>> _fetchInventoryData() async {
//     try {
//       final db = await mongo.Db.create(INVENTORY_CONN_URL);
//       await db.open();
//       final collection = db.collection(USER_INVENTORY);

//       // Query only items that match the current user's email
//       final List<Map<String, dynamic>> results =
//           await collection.find({'userEmail': widget.userEmail}).toList();

//       await db.close();

//       List<InventoryItem> inventoryItems =
//           results.map((data) => InventoryItem.fromJson(data)).toList();
//       // Sort inventory items based on _sortByLatest flag
//       inventoryItems.sort((a, b) {
//         // Extract the numeric part from the 'week' string using RegExp
//         int weekA =
//             int.tryParse(RegExp(r'\d+').firstMatch(b.week)?.group(0) ?? '0') ??
//                 0;
//         int weekB =
//             int.tryParse(RegExp(r'\d+').firstMatch(a.week)?.group(0) ?? '0') ??
//                 0;

//         if (_sortByLatest) {
//           return weekB
//               .compareTo(weekA); // Sort by latest to oldest (descending)
//         } else {
//           return weekA.compareTo(weekB); // Sort by oldest to latest (ascending)
//         }
//       });

//       return inventoryItems;
//     } catch (e) {
//       print('Error fetching inventory data: $e');
//       throw e;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new WillPopScope(
//         onWillPop: () async => false,
//         child: new Scaffold(
//           body: SideBarLayout(
//             title: "INVENTORY",
//             mainContent: RefreshIndicator(
//               onRefresh: () async {
//                 _fetchData();
//               },
//               child: FutureBuilder<List<InventoryItem>>(
//                 future: _futureInventory,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.green,
//                         backgroundColor: Colors.transparent,
//                       ),
//                     );
//                   } else if (snapshot.hasError) {
//                     return Center(
//                       child: Text('Error: ${snapshot.error}'),
//                     );
//                   } else {
//                     List<InventoryItem> inventoryItems = snapshot.data ?? [];
//                     if (inventoryItems.isEmpty) {
//                       return Center(
//                         child: Text(
//                           'No inventory created',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Colors.black,
//                           ),
//                         ),
//                       );
//                     } else {
//                       // Calculate total number of pages
//                       int totalPages =
//                           (inventoryItems.length / pageSize).ceil();

//                       // Ensure currentPage does not exceed totalPages
//                       currentPage = currentPage.clamp(0, totalPages - 1);

//                       // Calculate startIndex and endIndex for current page
//                       int startIndex = currentPage * pageSize;
//                       int endIndex = (currentPage + 1) * pageSize;

//                       // Slice the list based on current page and page size
//                       List<InventoryItem> currentPageItems =
//                           inventoryItems.reversed.toList().sublist(startIndex,
//                               endIndex.clamp(0, inventoryItems.length));

//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.arrow_back),
//                                 onPressed: currentPage > 0
//                                     ? () {
//                                         setState(() {
//                                           currentPage--;
//                                         });
//                                       }
//                                     : null,
//                               ),
//                               Text(
//                                 'Page ${currentPage + 1} of $totalPages',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.arrow_forward),
//                                 onPressed: currentPage < totalPages - 1
//                                     ? () {
//                                         setState(() {
//                                           currentPage++;
//                                         });
//                                       }
//                                     : null,
//                               ),
//                             ],
//                           ),
//                           Expanded(
//                             child: ListView.builder(
//                                 itemCount: currentPageItems.length,
//                                 itemBuilder: (context, index) {
//                                   InventoryItem item = currentPageItems[index];
//                                   return FutureBuilder<bool>(
//                                     key: ValueKey(item.inputId),
//                                     future: _getEditingStatus(
//                                         item.inputId, widget.userEmail),
//                                     builder: (context, snapshot) {
//                                       if (snapshot.hasError) {
//                                         return ListTile(
//                                           title: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(item.week),
//                                               Icon(Icons
//                                                   .error), // Show error icon
//                                             ],
//                                           ),
//                                         );
//                                       }

//                                       bool isEditing = snapshot.data ??
//                                           true; // Use false as default
//                                       print(
//                                           'Item ${item.inputId} isEditing: $isEditing');

//                                       // Function to check if the item should be disabled based on the day of the week and item status
//                                       bool _isEditingDisabled(
//                                           InventoryItem item) {
//                                         DateTime now = DateTime.now();
//                                         bool isMondayToThursday = now.weekday >=
//                                                 DateTime.monday &&
//                                             now.weekday <= DateTime.thursday;

//                                         // // Disable button if it's Monday to Thursday and the item status is "Carried"
//                                         // if (item.status == 'Carried' &&
//                                         //     isMondayToThursday) {
//                                         //   return true; // Disabled Monday to Thursday for "Carried"
//                                         // }

//                                         // Disable permanently for "Not Carried" or "Delisted"
//                                         return item.status == 'Not Carried' ||
//                                             item.status == 'Delisted';
//                                       }

//                                       // Function to get the color for the button
//                                       Color? _getButtonColor(
//                                           InventoryItem item) {
//                                         if (_isEditingDisabled(item)) {
//                                           return Colors.red; // Red for disabled
//                                         }
//                                         return null; // Default color if enabled
//                                       }

//                                       // Function to get the onPressed action based on the item status and current day
//                                       VoidCallback? _getButtonAction(
//                                           InventoryItem item) {
//                                         if (_isEditingDisabled(item)) {
//                                           return null; // Disable the button if the condition is met
//                                         }

//                                         return item.status == 'Carried' &&
//                                                 !isEditing
//                                             ? () async {
//                                                 await _updateEditingStatus(
//                                                     item.inputId,
//                                                     widget.userEmail,
//                                                     false); // Start editing
//                                                 bool hasSavedChanges =
//                                                     false; // Track if changes are saved

//                                                 await Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         EditInventoryScreen(
//                                                       inventoryItem: item,
//                                                       userEmail:
//                                                           widget.userEmail,
//                                                       userContactNum:
//                                                           widget.userContactNum,
//                                                       userLastName:
//                                                           widget.userLastName,
//                                                       userMiddleName:
//                                                           widget.userMiddleName,
//                                                       userName: widget.userName,
//                                                       onCancel: () async {
//                                                         // Reset editing status back to false (not editing anymore)
//                                                         await _updateEditingStatus(
//                                                             item.inputId,
//                                                             widget.userEmail,
//                                                             false);
//                                                         setState(
//                                                             () {}); // Refresh UI after cancel
//                                                       },
//                                                       onSave: () async {
//                                                         hasSavedChanges =
//                                                             true; // Indicate that changes have been saved
//                                                         await _updateEditingStatus(
//                                                             item.inputId,
//                                                             widget.userEmail,
//                                                             true); // Mark as edited
//                                                         setState(
//                                                             () {}); // Refresh UI after saving
//                                                       },
//                                                     ),
//                                                   ),
//                                                 );

//                                                 // Only update editing status to true if changes were saved
//                                                 if (hasSavedChanges) {
//                                                   await _updateEditingStatus(
//                                                       item.inputId,
//                                                       widget.userEmail,
//                                                       true);
//                                                 }

//                                                 setState(
//                                                     () {}); // Refresh UI after editing
//                                               }
//                                             : null; // No action if not "Carried" or isEditing is true
//                                       }

//                                       return ListTile(
//                                         title: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(item.week),
//                                             if (item.status != 'Not Carried' &&
//                                                 item.status != 'Delisted')
//                                               IconButton(
//                                                 icon: Icon(
//                                                   isEditing
//                                                       ? Icons.edit_off_sharp
//                                                       : Icons
//                                                           .edit, // Show edit_off_sharp if enabled, edit if disabled
//                                                 ),
//                                                 color: _getButtonColor(item) ??
//                                                     Colors
//                                                         .green, // Use green or red based on status
//                                                 onPressed: _getButtonAction(
//                                                     item), // Enable/disable button based on status
//                                               ),
//                                           ],
//                                         ),
//                                         subtitle: Container(
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey.shade200,
//                                             border: Border.all(
//                                               color: Colors.black,
//                                               width: 1.0,
//                                             ),
//                                           ),
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'Date: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.date}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Input ID: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.inputId}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Merchandiser: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.name}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Account Name Branch Manning: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.accountNameBranchManning}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Period: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.period}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Month: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.month}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Week: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.week}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Category: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text('${item.category}'),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'SKU Description: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.skuDescription}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               // SizedBox(height: 10),
//                                               // Text(
//                                               //   'Products: ',
//                                               //   style: TextStyle(
//                                               //       fontWeight: FontWeight.bold,
//                                               //       color: Colors.black),
//                                               // ),
//                                               // Text(
//                                               //   '${item.products}',
//                                               //   style: TextStyle(
//                                               //       color: Colors.black),
//                                               // ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'SKU Code: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.skuCode}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Status: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.status}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Beginning (Selling Area): ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.beginningSA}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Beginning (Warehouse Area): ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.beginningWA}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Ending (Selling Area): ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.endingWA}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Ending (Warehouse Area): ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.endingWA}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Beginning: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.beginning}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Delivery: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.delivery}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Ending: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.ending}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Expiration: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: item.expiryFields
//                                                     .map((expiry) {
//                                                   return Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         'Expiry Date: ${expiry['expiryMonth']}',
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.black),
//                                                       ),
//                                                       Text(
//                                                         'Quantity: ${expiry['expiryPcs']}',
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.black),
//                                                       ),
//                                                       if (expiry.containsKey(
//                                                           'manualPcsInput')) // Check if 'manualPcsInput' exists
//                                                         Text(
//                                                           'Manual PCS Input: ${expiry['expiryPcs']}',
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.black),
//                                                         ),
//                                                       SizedBox(
//                                                           height:
//                                                               10), // Adjust spacing as needed
//                                                     ],
//                                                   );
//                                                 }).toList(),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Offtake: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.offtake}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Inventory Days Level: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.inventoryDaysLevel}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Number of Days OOS: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.noOfDaysOOS}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Remarks: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.remarksOOS}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                 'Reason: ',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                               Text(
//                                                 '${item.reasonOOS}',
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 }),
//                           )
//                         ],
//                       );
//                     }
//                   }
//                 },
//               ),
//             ),
//             appBarActions: [
//               IconButton(
//                 icon: Icon(
//                   Icons.refresh,
//                   color: Colors.white,
//                 ),
//                 onPressed: () {
//                   _fetchData();
//                 },
//               ),
//               PopupMenuButton<String>(
//                 onSelected: (value) {
//                   setState(() {
//                     _sortByLatest = value == 'latestToOldest';
//                     _fetchData(); // Reload data based on new sort order
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                   PopupMenuItem<String>(
//                     value: 'latestToOldest',
//                     child: Text('Sort by Latest to Oldest'),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'oldestToLatest',
//                     child: Text('Sort by Oldest to Latest'),
//                   ),
//                 ],
//               ),
//             ],
//             userName: widget.userName,
//             userLastName: widget.userLastName,
//             userEmail: widget.userEmail,
//             userContactNum: widget.userContactNum,
//             userMiddleName: widget.userMiddleName,
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => AddInventory(
//                     userName: widget.userName,
//                     userLastName: widget.userLastName,
//                     userEmail: widget.userEmail,
//                     userContactNum: widget.userContactNum,
//                     userMiddleName: widget.userMiddleName,
//                   ),
//                 ),
//               );
//             },
//             child: Icon(
//               Icons.assignment_add,
//               color: Colors.white,
//             ),
//             backgroundColor: Colors.green,
//           ),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         ));
//   }
// }

// class RTV extends StatefulWidget {
//   final String userName;
//   final String userLastName;
//   final String userEmail;
//   String userMiddleName;
//   String userContactNum;

//   RTV({
//     required this.userName,
//     required this.userLastName,
//     required this.userEmail,
//     required this.userContactNum,
//     required this.userMiddleName,
//   });

//   @override
//   _RTVState createState() => _RTVState();
// }

// class _RTVState extends State<RTV> {
//   late Future<List<ReturnToVendor>> _futureRTV;
//   bool _sortByLatest = true; // Default to sorting by latest date

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   void _fetchData() {
//     setState(() {
//       _futureRTV = _fetchRTVData();
//     });
//   }

//   Future<List<ReturnToVendor>> _fetchRTVData() async {
//     try {
//       final db = await mongo.Db.create(MONGO_CONN_URL);
//       await db.open();
//       final collection = db.collection(USER_RTV);

//       final List<Map<String, dynamic>> results =
//           await collection.find({'userEmail': widget.userEmail}).toList();

//       await db.close();

//       List<ReturnToVendor> rtvItems =
//           results.map((data) => ReturnToVendor.fromJson(data)).toList();

//       rtvItems.sort((a, b) {
//         if (_sortByLatest) {
//           return b.date.compareTo(a.date); // Sort by latest to oldest
//         } else {
//           return a.date.compareTo(b.date); // Sort by oldest to latest
//         }
//       });
//       return rtvItems;
//     } catch (e) {
//       print('Error fetching RTV data: $e');
//       throw e;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new WillPopScope(
//         onWillPop: () async => false,
//         child: new Scaffold(
//           body: SideBarLayout(
//             title: "Return To Vendor",
//             mainContent: RefreshIndicator(
//               onRefresh: () async {
//                 _fetchData();
//               },
//               child: FutureBuilder<List<ReturnToVendor>>(
//                   future: _futureRTV,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(
//                           child: CircularProgressIndicator(
//                         color: Colors.green,
//                         backgroundColor: Colors.transparent,
//                       ));
//                     } else if (snapshot.hasError) {
//                       return Center(
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     } else {
//                       List<ReturnToVendor> rtvItems = snapshot.data ?? [];
//                       if (rtvItems.isEmpty) {
//                         return Center(
//                           child: Text(
//                             'No RTV created',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                                 color: Colors.black),
//                           ),
//                         );
//                       } else {
//                         return ListView.builder(
//                             itemCount: rtvItems.length,
//                             itemBuilder: (context, index) {
//                               ReturnToVendor item = rtvItems[index];
//                               bool isEditable = item.quantity == "Pending" &&
//                                   item.driverName == "Pending" &&
//                                   item.plateNumber == "Pending" &&
//                                   item.pullOutReason == "Pending";

//                               return ListTile(
//                                   title: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         '${item.date}',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black),
//                                       ),
//                                       isEditable
//                                           ? IconButton(
//                                               icon: Icon(Icons.edit,
//                                                   color: Colors.black),
//                                               onPressed: () {
//                                                 Navigator.of(context).push(
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         EditRTVScreen(
//                                                             item: item),
//                                                   ),
//                                                 );
//                                               },
//                                             )
//                                           : IconButton(
//                                               icon: Icon(Icons.edit,
//                                                   color: Colors.grey),
//                                               onPressed: null,
//                                             ),
//                                     ],
//                                   ),
//                                   subtitle: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade200,
//                                       border: Border.all(
//                                         color: Colors.black,
//                                         width: 1.0,
//                                       ),
//                                     ),
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Input ID: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.inputId,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Date: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.date,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Outlet: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.outlet,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Category: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.category,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Item: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.item,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Quantity: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.quantity,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Driver\'s Name: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.driverName,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Plate Number: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.plateNumber,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                 text: 'Pull Out Reason: ',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               TextSpan(
//                                                 text: item.pullOutReason,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.normal,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ));
//                             });
//                       }
//                     }
//                   }),
//             ),
//             appBarActions: [
//               IconButton(
//                 icon: Icon(
//                   Icons.refresh,
//                   color: Colors.white,
//                 ),
//                 onPressed: () {
//                   _fetchData();
//                 },
//               ),
//               PopupMenuButton<String>(
//                 onSelected: (value) {
//                   setState(() {
//                     _sortByLatest = value == 'latestToOldest';
//                     _fetchData();
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                   PopupMenuItem<String>(
//                     value: 'latestToOldest',
//                     child: Text('Sort by Latest to Oldest'),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'oldestToLatest',
//                     child: Text('Sort by Oldest to Latest'),
//                   ),
//                 ],
//               ),
//             ],
//             userName: widget.userName,
//             userLastName: widget.userLastName,
//             userEmail: widget.userEmail,
//             userContactNum: widget.userContactNum,
//             userMiddleName: widget.userMiddleName,
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => ReturnVendor(
//                   userName: widget.userName,
//                   userLastName: widget.userLastName,
//                   userEmail: widget.userEmail,
//                   userContactNum: widget.userContactNum,
//                   userMiddleName: widget.userMiddleName,
//                 ),
//               ));
//             },
//             child: Icon(
//               Icons.assignment_add,
//               color: Colors.white,
//             ),
//             backgroundColor: Colors.green,
//           ),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         ));
//   }
// }

class Setting extends StatelessWidget {
  final String userName;
  final String userLastName;
  final String userEmail;
  String userMiddleName; // Add this if you have a middle name
  String userContactNum; // Add this for contact number

  Setting({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
    required this.userMiddleName, // Optional middle name
    required this.userContactNum, // Optional contact number
  });

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: new SideBarLayout(
          title: "Settings",
          mainContent: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Add some padding around the form
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'First Name: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: userName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Middle Name: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: userMiddleName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Last Name: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: userLastName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Contact Number: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: userContactNum,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email Address: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextFormField(
                    initialValue: userEmail,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                      height:
                          210), // Add space between the text fields and the button
                  Center(
                    child: SizedBox(
                      height: 50,
                      width: 350,
                      child: ElevatedButton(
                        onPressed: () {
                          _logout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          'LOG OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          userName: userName,
          userLastName: userLastName,
          userEmail: userEmail,
          userContactNum: userContactNum,
          userMiddleName: userMiddleName,
        ));
  }
}

Future<void> _logout(BuildContext context) async {
  try {
    final attendanceModel =
        Provider.of<AttendanceModel>(context, listen: false);
    attendanceModel.reset();

    final prefs = await SharedPreferences.getInstance();

    // Remove all user-specific data
    await prefs.remove('isLoggedIn');
    await prefs.remove('userName');
    await prefs.remove('userMiddleName');
    await prefs.remove('userLastName');
    await prefs.remove('userContactNum');
    await prefs.remove('userEmail');
    await prefs.remove('loadedSKUs');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    print('Error logging out: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed. Please try again.')),
    );
  }
}

class SideBarLayout extends StatefulWidget {
  final String title;
  final Widget mainContent;
  final List<Widget>? appBarActions;
  String userName;
  String userLastName;
  String userEmail;
  String userMiddleName;
  String userContactNum;

  SideBarLayout({
    required this.title,
    required this.mainContent,
    this.appBarActions,
    required this.userName,
    required this.userLastName,
    required this.userEmail,
    required this.userContactNum,
    required this.userMiddleName,
  });

  @override
  _SideBarLayoutState createState() => _SideBarLayoutState();
}

class _SideBarLayoutState extends State<SideBarLayout> {
  Timer? _accountStatusTimer; // Declare the timer variable
  String userName = '';
  String userLastName = '';
  String userEmail = '';
  String userContactNum = '';
  String userMiddleName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _startAccountStatusChecker();
  }

  @override
  void dispose() {
    _accountStatusTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<bool> checkIfAccountDeactivated() async {
    try {
      final user = await MongoDatabase.getUserDetailsByEmail(userEmail);

      if (user != null) {
        print('Account activation status: ${user.isActivate}');
        return !user.isActivate; // If false, account is deactivated
      } else {
        print('User not found.');
        return false; // Assume not deactivated if not found
      }
    } catch (e) {
      print('Error checking account status: $e');
      return false;
    }
  }

  void _startAccountStatusChecker() {
    _accountStatusTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      print('Checking account status...');

      // // 🔍 Debugging: Print before querying
      // print('Email being checked: "$userEmail"');

      // if (userEmail.isEmpty) {
      //   print('⚠️ Error: userEmail is EMPTY! Fix this before querying.');
      //   return;
      // }

      final isDeactivated = await checkIfAccountDeactivated();
      if (isDeactivated) {
        print('Account deactivated. Logging out...');
        timer.cancel();
        _logoutDueToDeactivation(context);
      }
    });
  }

  Future<void> _logoutDueToDeactivation(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('User data cleared. Logging out...');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Account Deactivated'),
        content: Text('Your account has been deactivated.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUserInfo() async {
    try {
      print('Fetching user info for email: "${widget.userEmail}"'); // Debugging

      final userInfo =
          await MongoDatabase.getUserDetailsByEmail(widget.userEmail);
      if (userInfo != null) {
        print('User info retrieved: ${userInfo.toJson()}'); // Debugging
        setState(() {
          userName = userInfo.firstName;
          userMiddleName = userInfo.middleName;
          userLastName = userInfo.lastName;
          userContactNum = userInfo.contactNum;
          userEmail = userInfo.emailAddress; // ✅ FIXED: Ensure this is set
        });
      } else {
        print('⚠️ Error: User info is NULL.');
      }
    } catch (e) {
      print('⚠️ Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: new FutureBuilder(
          future: _fetchUserInfo(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[900]!,
                        Colors.blue[800]!,
                        Colors.blue[600]!,
                        Colors.blue[400]!,
                      ],
                    ),
                  ),
                ),
                title: Text(
                  widget.title,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                actions: widget.appBarActions,
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(
                        '${widget.userName} ${widget.userLastName}',
                        style: TextStyle(color: Colors.white),
                      ),
                      accountEmail: Text(
                        widget.userEmail,
                        style: TextStyle(color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[900]!,
                            Colors.blue[800]!,
                            Colors.blue[600]!,
                            Colors.blue[400]!,
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.blue,
                      ),
                      title: const Text('Attendance'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => Attendance(
                                    userName: widget.userName,
                                    userLastName: widget.userLastName,
                                    userEmail: widget.userEmail,
                                    userContactNum: widget.userContactNum,
                                    userMiddleName: widget.userMiddleName,
                                  )),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: const Icon(Icons.inventory_2_outlined),
                    //   title: const Text('Inventory'),
                    //   onTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //           builder: (context) => Inventory(
                    //                 userName: widget.userName,
                    //                 userLastName: widget.userLastName,
                    //                 userEmail: widget.userEmail,
                    //                 userContactNum: widget.userContactNum,
                    //                 userMiddleName: widget.userMiddleName,
                    //               )),
                    //     );
                    //   },
                    // ),
                    // ListTile(
                    //   leading: const Icon(Icons.assignment_return_outlined),
                    //   title: const Text('Return To Vendor'),
                    //   onTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //           builder: (context) => RTV(
                    //                 userName: widget.userName,
                    //                 userLastName: widget.userLastName,
                    //                 userEmail: widget.userEmail,
                    //                 userContactNum: widget.userContactNum,
                    //                 userMiddleName: widget.userMiddleName,
                    //               )),
                    //     );
                    //   },
                    // ),
                    const Divider(color: Colors.black),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined,
                          color: Colors.blue),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => Setting(
                                    userName: widget.userName,
                                    userLastName: widget.userLastName,
                                    userEmail: widget.userEmail,
                                    userContactNum: widget.userContactNum,
                                    userMiddleName: widget.userMiddleName,
                                  )),
                        );
                      },
                    ),
                  ],
                ),
              ),
              body: widget.mainContent,
            );
          },
        ));
  }
}

class DateTimeWidget extends StatefulWidget {
  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    // Initialize the current time and start the timer to update it periodically
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    // Update the current time every second
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('h:mm a').format(_currentTime);
    String dayOfWeek = DateFormat('EEEE').format(_currentTime);
    String formattedDate = DateFormat.yMMMMd().format(_currentTime);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // SizedBox(height: 20),
          Text(
            '$formattedDate, $dayOfWeek',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
