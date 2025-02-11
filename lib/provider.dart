import 'package:flutter/foundation.dart';

class AttendanceModel extends ChangeNotifier {
  Map<String, String> _selfieUrls =
      {}; // Store selfie URLs for both Time In and Time Out
  Map<String, String> _timeOutSelfieUrls =
      {}; // Separate map for Time Out selfies
  String? _timeIn;
  String? _timeOut;
  bool _isTimeInRecorded = false;
  bool _isTimeOutRecorded = false;

  String _timeInLocation = 'No location';
  String _timeOutLocation = 'No location';

  String? get timeIn => _timeIn;
  String? get timeOut => _timeOut;

  String? get timeInLocation => _timeInLocation;
  String? get timeOutLocation => _timeOutLocation;

  bool get isTimeInRecorded => _isTimeInRecorded;
  bool get isTimeOutRecorded => _isTimeOutRecorded;

  // Get selfie URL for Time In for a specific branch
  String? getSelfieUrlForBranch(String branch) {
    return _selfieUrls[branch];
  }

  // Get selfie URL for Time Out for a specific branch
  String? getTimeOutSelfieUrlForBranch(String branch) {
    return _timeOutSelfieUrls[branch];
  }

  // Set selfie URL for Time In for a specific branch
  void setSelfieUrlForBranch(String branch, String selfieUrl) {
    _selfieUrls[branch] = selfieUrl;
    notifyListeners();
  }

  // Set selfie URL for Time Out for a specific branch
  void setTimeOutSelfieUrlForBranch(String branch, String selfieUrl) {
    _timeOutSelfieUrls[branch] = selfieUrl;
    notifyListeners();
  }

  // Update the location for Time In
  void updateTimeInLocation(String location) {
    _timeInLocation = location;
    notifyListeners();
  }

  // Update the location for Time Out
  void updateTimeOutLocation(String location) {
    _timeOutLocation = location;
    notifyListeners();
  }

  // Update the Time In value
  void updateTimeIn(String? timeIn) {
    _timeIn = timeIn;
    notifyListeners();
  }

  // Update the Time Out value
  void updateTimeOut(String? timeOut) {
    _timeOut = timeOut;
    notifyListeners();
  }

  // Set whether Time In has been recorded or not
  void setIsTimeInRecorded(bool isRecorded) {
    _isTimeInRecorded = isRecorded;
    notifyListeners();
  }

  // Set whether Time Out has been recorded or not
  void setIsTimeOutRecorded(bool isRecorded) {
    _isTimeOutRecorded = isRecorded;
    notifyListeners();
  }

  // Reset all attendance-related values to initial state
  void reset() {
    _timeIn = null;
    _timeOut = null;
    _isTimeInRecorded = false;
    _isTimeOutRecorded = false;
    _timeInLocation = 'No location';
    _timeOutLocation = 'No location';
    notifyListeners();
  }
}
