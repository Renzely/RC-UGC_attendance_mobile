// ignore_for_file: prefer_const_constructors
import 'package:mongo_dart/mongo_dart.dart' as M;
import 'package:demo_app/dbHelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/login_screen.dart';
import 'dbHelper/mongodbDraft.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String otp;
  final Map<String, dynamic> userData;

  OTPVerificationScreen({
    required this.email,
    required this.otp,
    required this.userData,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
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
      ),
      body: Center(
        child: Container(
          height: 550,
          width: 320,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              colors: [
                Colors.blue[900]!,
                Colors.blue[800]!,
                Colors.blue[600]!,
                Colors.blue[400]!,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'An OTP has been sent to ${widget.email}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black, fontSize: 18.0),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter OTP',
                  hintStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _verifyOTP();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.0),
                ),
                child: Text(
                  'Verify OTP',
                  style: TextStyle(fontSize: 18.0, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOTP() async {
    String enteredOTP = otpController.text.trim();

    if (enteredOTP == widget.otp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account verified')),
      );

      await _insertData(widget.userData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  Future<void> _insertData(Map<String, dynamic> userData) async {
    try {
      var _id = M.ObjectId();
      final data = MongoDemo(
          id: _id,
          remarks: userData['remarks'],
          firstName: userData['firstName'],
          middleName: userData['middleName'],
          lastName: userData['lastName'],
          emailAddress: userData['emailAddress'],
          contactNum: userData['contactNum'],
          username: userData['username'],
          password: userData['password'],
          accountNameBranchManning: userData['accountNameBranchManning'],
          isActivate: userData['isActivate'],
          type: userData['type']);

      var result = await MongoDatabase.insert(data);
      print(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inserted ID " + _id.toString())),
      );
    } catch (e) {
      print('Error inserting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to insert data. Please try again.')),
      );
    }
  }
}
