// // ignore_for_file: prefer_final_fields, avoid_print, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, depend_on_referenced_packages, non_constant_identifier_names, unused_local_variable, use_build_context_synchronously, unused_element, avoid_unnecessary_containers, must_be_immutable

// import 'dart:convert';
// import 'dart:math';
// import 'package:demo_app/dbHelper/constant.dart';
// import 'package:demo_app/dbHelper/mongodb.dart';
// import 'package:demo_app/dbHelper/mongodbDraft.dart';
// import 'package:flutter/services.dart';
// import 'package:demo_app/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:bson/bson.dart';
// import 'package:mongo_dart/mongo_dart.dart' as mongo;
// import 'package:shared_preferences/shared_preferences.dart';

// class AddInventory extends StatefulWidget {
//   final String userName;
//   final String userLastName;
//   final String userEmail;
//   String userContactNum;
//   String userMiddleName;

//   AddInventory({
//     required this.userName,
//     required this.userLastName,
//     required this.userEmail,
//     required this.userContactNum,
//     required this.userMiddleName,
//   });

//   @override
//   _AddInventoryState createState() => _AddInventoryState();
// }

// class _AddInventoryState extends State<AddInventory> {
//   late TextEditingController _dateController;
//   late DateTime _selectedDate;
//   String? _selectedAccount;
//   String? _selectedPeriod;
//   late GlobalKey<FormState> _formKey;
//   bool _isSaveEnabled = false;
//   bool _showAdditionalInfo = false;
//   TextEditingController _monthController = TextEditingController();
//   TextEditingController _weekController = TextEditingController();
//   String _selectedWeek = '';
//   String _selectedMonth = '';
//   List<DropdownMenuItem<String>> _periodItems = [];
//   DateTime _currentWeekStart = DateTime.now();

//   List<String> _branchList = [];

//   @override
//   void initState() {
//     super.initState();
//     _updatePeriodItems();

//     _formKey = GlobalKey<FormState>();
//     _selectedDate =
//         DateTime.now(); // Initialize _selectedDate to the current date
//     _dateController = TextEditingController(
//       text: DateFormat('yyyy-MM-dd')
//           .format(_selectedDate), // Set initial text of controller
//     );
//     _weekController.addListener(() {
//       setState(() {
//         _selectedWeek = _weekController.text;
//       });
//     });
//     _monthController.addListener(() {
//       setState(() {
//         _selectedMonth = _monthController.text;
//       });
//     });
//     fetchBranches();
//   }

//   Future<void> fetchBranches() async {
//     try {
//       final db = await mongo.Db.create(INVENTORY_CONN_URL);
//       await db.open();
//       final collection = db.collection(USER_COLLECTION);
//       final List<Map<String, dynamic>> branchDocs = await collection
//           .find(mongo.where.eq('emailAddress', widget.userEmail))
//           .toList();
//       setState(() {
//         // Extract accountNameBranchManning from branchDocs and handle both single string and list cases
//         _branchList = branchDocs
//             .map((doc) => doc['accountNameBranchManning'])
//             .where((branch) => branch != null)
//             .expand((branch) => branch is List ? branch : [branch])
//             .map((branch) => branch.toString())
//             .toList();
//         _selectedAccount = _branchList.isNotEmpty ? _branchList.first : '';
//       });
//       await db.close();
//     } catch (e) {
//       print('Error fetching branch data: $e');
//     }
//   }

//   Future<void> fetchBranchForUser(String userEmail) async {
//     try {
//       final db = await mongo.Db.create(INVENTORY_CONN_URL);
//       await db.open();
//       final collection = db.collection(USER_COLLECTION);
//       final Map<String, dynamic>? userData =
//           await collection.findOne(mongo.where.eq('emailAddress', userEmail));
//       if (userData != null) {
//         final branchData = userData['accountNameBranchManning'];
//         setState(() {
//           _selectedAccount = branchData is List
//               ? branchData.first.toString()
//               : branchData.toString();
//           _branchList = branchData is List
//               ? branchData.map((branch) => branch.toString()).toList()
//               : [branchData.toString()];
//         });
//       }
//       await db.close();
//     } catch (e) {
//       print('Error fetching branch data for user: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _dateController.dispose();
//     _monthController.dispose();
//     _weekController.dispose();
//     super.dispose();
//   }

//   // String generateInputID() {
//   //   var timestamp = DateTime.now().millisecondsSinceEpoch;
//   //   var random =
//   //       Random().nextInt(10000); // Generate a random number between 0 and 9999
//   //   var paddedRandom =
//   //       random.toString().padLeft(4, '0'); // Ensure it has 4 digits
//   //   return '2000$paddedRandom';
//   // }
//   void _updatePeriodItems() {
//     setState(() {
//       _periodItems = _getFilteredPeriodItems();
//     });
//   }

// // Method to get filtered period items
//   List<DropdownMenuItem<String>> _getFilteredPeriodItems() {
//     List<DropdownMenuItem<String>> items = [];

//     // Get the current date
//     DateTime currentDate = DateTime.now();

//     // Find the most recent Friday
//     DateTime mostRecentFriday = currentDate.subtract(
//         Duration(days: (currentDate.weekday - DateTime.friday + 7) % 7));

//     // Calculate the start of the delayed week (Saturday to Friday)
//     DateTime startOfDelayedWeek = mostRecentFriday.subtract(Duration(days: 6));

//     // Format the period string
//     String periodString =
//         '${DateFormat('MMMdd').format(startOfDelayedWeek)}-${DateFormat('MMMdd').format(mostRecentFriday)}';

//     // Add the period to the dropdown items
//     items.add(DropdownMenuItem(child: Text(periodString), value: periodString));

//     print(
//         "Selected period: ${DateFormat('MMM dd').format(startOfDelayedWeek)} - ${DateFormat('MMM dd').format(mostRecentFriday)}");

//     return items;
//   }

// // Method to get the current week start date
//   DateTime getCurrentWeekStartDate({DateTime? overrideDate}) {
//     // Use the overrideDate if provided, otherwise use the actual current date
//     var now = overrideDate ?? DateTime.now();
//     var today = DateTime(now.year, now.month, now.day);
//     var firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
//     return firstDayOfWeek;
//   }

// // Helper function to generate periods dynamically based on a reference date
//   List<List<DateTime>> _generatePeriods(DateTime startDate) {
//     List<List<DateTime>> periods = [];

//     // Generate 5 periods based on the start date
//     for (int i = 0; i < 5; i++) {
//       DateTime periodStart =
//           startDate.add(Duration(days: i * 7)); // Start of each week
//       DateTime periodEnd =
//           periodStart.add(Duration(days: 6)); // End of each week
//       periods.add([periodStart, periodEnd]);
//     }

//     return periods;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new WillPopScope(
//         onWillPop: () async => false,
//         child: new MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(
//               appBar: AppBar(
//                 backgroundColor: Colors.green[600],
//                 elevation: 0,
//                 title: Text(
//                   'INVENTORY Process',
//                   style: TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               body: SingleChildScrollView(
//                 child: Center(
//                   child: Container(
//                     padding: EdgeInsets.all(20.0),
//                     width: MediaQuery.of(context).size.width * 1.0,
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Date',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Container(
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: TextFormField(
//                                       controller: _dateController,
//                                       readOnly: true,
//                                       decoration: InputDecoration(
//                                         border: OutlineInputBorder(),
//                                         contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 12),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // SizedBox(height: 16),
//                             // Text(
//                             //   'Input ID',
//                             //   style: TextStyle(
//                             //       fontWeight: FontWeight.bold, fontSize: 16),
//                             // ),
//                             // SizedBox(height: 8),
//                             // TextFormField(
//                             //   initialValue: generateInputID(),
//                             //   readOnly: true,
//                             //   decoration: InputDecoration(
//                             //     border: OutlineInputBorder(),
//                             //     contentPadding:
//                             //         EdgeInsets.symmetric(horizontal: 12),
//                             //     hintText: 'Auto-generated Input ID',
//                             //   ),
//                             // ),
//                             SizedBox(height: 16),
//                             Text(
//                               'Merchandiser',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                             SizedBox(height: 8),
//                             TextFormField(
//                               initialValue:
//                                   '${widget.userName} ${widget.userLastName}',
//                               readOnly: true,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(),
//                                 contentPadding:
//                                     EdgeInsets.symmetric(horizontal: 12),
//                               ),
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               'Branch/Outlet',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                             SizedBox(height: 10),
//                             Container(
//                               decoration: BoxDecoration(
//                                 border: Border(
//                                   bottom: BorderSide(
//                                     color: Colors.black,
//                                     width: 1.0,
//                                   ),
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Stack(
//                                       alignment: Alignment.centerRight,
//                                       children: [
//                                         DropdownButtonFormField<String>(
//                                           isExpanded: true,
//                                           value: _selectedAccount,
//                                           items: _branchList.map((branch) {
//                                             return DropdownMenuItem<String>(
//                                               value: branch,
//                                               child: Text(branch),
//                                             );
//                                           }).toList(),
//                                           onChanged: _branchList.length > 1
//                                               ? (value) {
//                                                   setState(() {
//                                                     _selectedAccount = value;
//                                                     _isSaveEnabled =
//                                                         _selectedAccount !=
//                                                                 null &&
//                                                             _selectedPeriod !=
//                                                                 null;
//                                                   });
//                                                 }
//                                               : null, // Disable onChange when there is only one branch
//                                           decoration: InputDecoration(
//                                             hintText: 'Select',
//                                             border: OutlineInputBorder(),
//                                             contentPadding:
//                                                 EdgeInsets.symmetric(
//                                                     horizontal: 12),
//                                           ),
//                                         ),
//                                         // Conditionally show clear button
//                                         if (_selectedAccount != null)
//                                           Positioned(
//                                             right: 8.0,
//                                             child: IconButton(
//                                               icon: Icon(Icons.clear),
//                                               onPressed: () {
//                                                 setState(() {
//                                                   _selectedAccount = null;
//                                                   _selectedPeriod = null;
//                                                   _showAdditionalInfo = false;
//                                                   _isSaveEnabled = false;
//                                                 });
//                                               },
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             if (_selectedAccount != null) ...[
//                               SizedBox(height: 16),
//                               Text(
//                                 'Additional Information',
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'Weeks Covered',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   border: Border(
//                                     bottom: BorderSide(
//                                       color: Colors.black,
//                                       width: 1.0,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Stack(
//                                         alignment: Alignment.centerRight,
//                                         children: [
//                                           DropdownButtonFormField<String>(
//                                             value: _selectedPeriod,
//                                             items: _periodItems,
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 _selectedPeriod = value;
//                                                 _isSaveEnabled =
//                                                     _selectedAccount != null &&
//                                                         _selectedPeriod != null;

//                                                 // Null check before splitting
//                                                 if (value != null) {
//                                                   String actualValue = value
//                                                           .split('-')[
//                                                       1]; // Get the second part of the date
//                                                   print(
//                                                       'Selected period: $value');

//                                                   // Adjust the period for month and week
//                                                   switch (value) {
//                                                     case 'Dec14-Dec20': // Handle the Dec 14 - Dec 20 range
//                                                       _monthController.text =
//                                                           'December';
//                                                       _weekController.text =
//                                                           'Week 50';
//                                                       break;
//                                                     case 'Dec21-Dec27': // Handle the Dec 21 - Dec 27 range
//                                                       _monthController.text =
//                                                           'December';
//                                                       _weekController.text =
//                                                           'Week 51';
//                                                       break;
//                                                     case 'Dec28-Jan03': // Handle the Dec 28 - Jan 3 range
//                                                       _monthController.text =
//                                                           'December';
//                                                       _weekController.text =
//                                                           'Week 1';
//                                                       break;
//                                                     case 'Jan04-Jan10': // Handle the Jan 04 - Jan 10 range
//                                                       _monthController.text =
//                                                           'January';
//                                                       _weekController.text =
//                                                           'Week 2';
//                                                       break;
//                                                     case 'Jan11-Jan17':
//                                                       _monthController.text =
//                                                           'January';
//                                                       _weekController.text =
//                                                           'Week 3';
//                                                       break;
//                                                     case 'Jan18-Jan24':
//                                                       _monthController.text =
//                                                           'January';
//                                                       _weekController.text =
//                                                           'Week 4';
//                                                       break;
//                                                     case 'Jan25-Jan31':
//                                                       _monthController.text =
//                                                           'January';
//                                                       _weekController.text =
//                                                           'Week 5';
//                                                       break;
//                                                     case 'Feb01-Feb07':
//                                                       _monthController.text =
//                                                           'February';
//                                                       _weekController.text =
//                                                           'Week 6';
//                                                       break;
//                                                     case 'Feb08-Feb14':
//                                                       _monthController.text =
//                                                           'February';
//                                                       _weekController.text =
//                                                           'Week 7';
//                                                       break;
//                                                     case 'Feb15-Feb21':
//                                                       _monthController.text =
//                                                           'February';
//                                                       _weekController.text =
//                                                           'Week 8';
//                                                       break;
//                                                     case 'Feb22-Feb28':
//                                                       _monthController.text =
//                                                           'February';
//                                                       _weekController.text =
//                                                           'Week 9';
//                                                       break;
//                                                     case 'Mar01-Mar07':
//                                                       _monthController.text =
//                                                           'March';
//                                                       _weekController.text =
//                                                           'Week 10';
//                                                       break;
//                                                     case 'Mar08-Mar14':
//                                                       _monthController.text =
//                                                           'March';
//                                                       _weekController.text =
//                                                           'Week 11';
//                                                       break;
//                                                     case 'Mar15-Mar21':
//                                                       _monthController.text =
//                                                           'March';
//                                                       _weekController.text =
//                                                           'Week 12';
//                                                       break;
//                                                     case 'Mar22-Mar28':
//                                                       _monthController.text =
//                                                           'March';
//                                                       _weekController.text =
//                                                           'Week 13';
//                                                       break;
//                                                     case 'Mar29-Apr04':
//                                                       _monthController.text =
//                                                           'March';
//                                                       _weekController.text =
//                                                           'Week 14';
//                                                       break;
//                                                     case 'Apr05-Apr11':
//                                                       _monthController.text =
//                                                           'April';
//                                                       _weekController.text =
//                                                           'Week 15';
//                                                       break;
//                                                     case 'Apr12-Apr18':
//                                                       _monthController.text =
//                                                           'April';
//                                                       _weekController.text =
//                                                           'Week 16';
//                                                       break;
//                                                     case 'Apr19-Apr25':
//                                                       _monthController.text =
//                                                           'April';
//                                                       _weekController.text =
//                                                           'Week 17';
//                                                       break;
//                                                     case 'Apr26-May02':
//                                                       _monthController.text =
//                                                           'April';
//                                                       _weekController.text =
//                                                           'Week 18';
//                                                       break;
//                                                     case 'May03-May09':
//                                                       _monthController.text =
//                                                           'May';
//                                                       _weekController.text =
//                                                           'Week 19';
//                                                       break;
//                                                     case 'May10-May16':
//                                                       _monthController.text =
//                                                           'May';
//                                                       _weekController.text =
//                                                           'Week 20';
//                                                       break;
//                                                     case 'May17-May23':
//                                                       _monthController.text =
//                                                           'May';
//                                                       _weekController.text =
//                                                           'Week 21';
//                                                       break;
//                                                     case 'May24-May30':
//                                                       _monthController.text =
//                                                           'May';
//                                                       _weekController.text =
//                                                           'Week 22';
//                                                       break;
//                                                     case 'May31-Jun06':
//                                                       _monthController.text =
//                                                           'May';
//                                                       _weekController.text =
//                                                           'Week 23';
//                                                       break;
//                                                     case 'Jun07-Jun13':
//                                                       _monthController.text =
//                                                           'June';
//                                                       _weekController.text =
//                                                           'Week 24';
//                                                       break;
//                                                     case 'Jun14-Jun20':
//                                                       _monthController.text =
//                                                           'June';
//                                                       _weekController.text =
//                                                           'Week 25';
//                                                       break;
//                                                     case 'Jun21-Jun27':
//                                                       _monthController.text =
//                                                           'June';
//                                                       _weekController.text =
//                                                           'Week 26';
//                                                       break;
//                                                     case 'Jun28-Jul04':
//                                                       _monthController.text =
//                                                           'June';
//                                                       _weekController.text =
//                                                           'Week 27';
//                                                       break;
//                                                     case 'Jul05-Jul11':
//                                                       _monthController.text =
//                                                           'July';
//                                                       _weekController.text =
//                                                           'Week 28';
//                                                       break;
//                                                     case 'Jul12-Jul18':
//                                                       _monthController.text =
//                                                           'July';
//                                                       _weekController.text =
//                                                           'Week 29';
//                                                       break;
//                                                     case 'Jul19-Jul25':
//                                                       _monthController.text =
//                                                           'July';
//                                                       _weekController.text =
//                                                           'Week 30';
//                                                       break;
//                                                     case 'Jul26-Aug01':
//                                                       _monthController.text =
//                                                           'July';
//                                                       _weekController.text =
//                                                           'Week 31';
//                                                       break;
//                                                     case 'Aug02-Aug08':
//                                                       _monthController.text =
//                                                           'August';
//                                                       _weekController.text =
//                                                           'Week 32';
//                                                       break;
//                                                     case 'Aug09-Aug15':
//                                                       _monthController.text =
//                                                           'August';
//                                                       _weekController.text =
//                                                           'Week 33';
//                                                       break;
//                                                     case 'Aug16-Aug22':
//                                                       _monthController.text =
//                                                           'August';
//                                                       _weekController.text =
//                                                           'Week 34';
//                                                       break;
//                                                     case 'Aug23-Aug29':
//                                                       _monthController.text =
//                                                           'August';
//                                                       _weekController.text =
//                                                           'Week 35';
//                                                       break;
//                                                     case 'Aug30-Sep05':
//                                                       _monthController.text =
//                                                           'August';
//                                                       _weekController.text =
//                                                           'Week 36';
//                                                       break;
//                                                     case 'Sep06-Sep12':
//                                                       _monthController.text =
//                                                           'September';
//                                                       _weekController.text =
//                                                           'Week 37';
//                                                       break;
//                                                     case 'Sep13-Sep19':
//                                                       _monthController.text =
//                                                           'September';
//                                                       _weekController.text =
//                                                           'Week 38';
//                                                       break;
//                                                     case 'Sep20-Sep26':
//                                                       _monthController.text =
//                                                           'September';
//                                                       _weekController.text =
//                                                           'Week 39';
//                                                       break;
//                                                     case 'Sep27-Oct03':
//                                                       _monthController.text =
//                                                           'September';
//                                                       _weekController.text =
//                                                           'Week 40';
//                                                       break;
//                                                     case 'Oct04-Oct10':
//                                                       _monthController.text =
//                                                           'October';
//                                                       _weekController.text =
//                                                           'Week 41';
//                                                       break;
//                                                     case 'Oct11-Oct17':
//                                                       _monthController.text =
//                                                           'October';
//                                                       _weekController.text =
//                                                           'Week 42';
//                                                       break;
//                                                     case 'Oct18-Oct24':
//                                                       _monthController.text =
//                                                           'October';
//                                                       _weekController.text =
//                                                           'Week 43';
//                                                       break;
//                                                     case 'Oct25-Oct31':
//                                                       _monthController.text =
//                                                           'October';
//                                                       _weekController.text =
//                                                           'Week 44';
//                                                       break;
//                                                     case 'Nov01-Nov07':
//                                                       _monthController.text =
//                                                           'November';
//                                                       _weekController.text =
//                                                           'Week 45';
//                                                       break;
//                                                     case 'Nov08-Nov14':
//                                                       _monthController.text =
//                                                           'November';
//                                                       _weekController.text =
//                                                           'Week 46';
//                                                       break;
//                                                     case 'Nov15-Nov21':
//                                                       _monthController.text =
//                                                           'November';
//                                                       _weekController.text =
//                                                           'Week 47';
//                                                       break;
//                                                     case 'Nov22-Nov28':
//                                                       _monthController.text =
//                                                           'November';
//                                                       _weekController.text =
//                                                           'Week 48';
//                                                       break;
//                                                     case 'Nov29-Dec05':
//                                                       _monthController.text =
//                                                           'November';
//                                                       _weekController.text =
//                                                           'Week 49';
//                                                       break;
//                                                     case 'Dec06-Dec12':
//                                                       _monthController.text =
//                                                           'December';
//                                                       _weekController.text =
//                                                           'Week 50';
//                                                       break;
//                                                     case 'Dec13-Dec19':
//                                                       _monthController.text =
//                                                           'December';
//                                                       _weekController.text =
//                                                           'Week 51';
//                                                       break;
//                                                     case 'Dec20-Dec26':
//                                                       _monthController.text =
//                                                           'December';
//                                                       _weekController.text =
//                                                           'Week 52';
//                                                       break;
//                                                     case 'Dec27-Jan02':
//                                                       _monthController.text =
//                                                           'December';
//                                                       _weekController.text =
//                                                           'Week 1';
//                                                       break;
//                                                     case 'Jan03-Jan09':
//                                                       _monthController.text =
//                                                           'January';
//                                                       _weekController.text =
//                                                           'Week 2';
//                                                       break;

//                                                     default:
//                                                       _monthController.clear();
//                                                       _weekController.clear();
//                                                       break;
//                                                   }
//                                                 } else {
//                                                   // Handle null value case
//                                                   _monthController.clear();
//                                                   _weekController.clear();
//                                                 }
//                                                 _showAdditionalInfo = true;
//                                               });
//                                             },
//                                             decoration: InputDecoration(
//                                               hintText: 'Select Period',
//                                               border: OutlineInputBorder(),
//                                               contentPadding:
//                                                   EdgeInsets.symmetric(
//                                                       horizontal: 12),
//                                             ),
//                                           ),
//                                           if (_selectedPeriod != null)
//                                             Positioned(
//                                               right: 8.0,
//                                               child: IconButton(
//                                                 icon: Icon(Icons.clear),
//                                                 onPressed: () {
//                                                   setState(() {
//                                                     _selectedPeriod = null;
//                                                     _showAdditionalInfo = false;
//                                                     _isSaveEnabled = false;
//                                                   });
//                                                 },
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               if (_showAdditionalInfo) ...[
//                                 SizedBox(height: 16),
//                                 Text('Month',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     )),
//                                 SizedBox(height: 8),
//                                 TextFormField(
//                                   decoration: InputDecoration(
//                                     hintText: 'Select Period',
//                                     border: OutlineInputBorder(),
//                                     contentPadding:
//                                         EdgeInsets.symmetric(horizontal: 12),
//                                   ),
//                                   controller: _monthController,
//                                   readOnly: true,
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Week',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16),
//                                 ),
//                                 TextFormField(
//                                   decoration: InputDecoration(
//                                     hintText: 'Select Period',
//                                     border: OutlineInputBorder(),
//                                     contentPadding:
//                                         EdgeInsets.symmetric(horizontal: 12),
//                                   ),
//                                   controller: _weekController,
//                                   readOnly: true,
//                                 ),
//                               ],
//                             ],
//                             SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     // Perform cancel action

//                                     Navigator.of(context).pushReplacement(
//                                       MaterialPageRoute(
//                                         builder: (context) => Inventory(
//                                           userName: widget.userName,
//                                           userLastName: widget.userLastName,
//                                           userEmail: widget.userEmail,
//                                           userContactNum: widget.userContactNum,
//                                           userMiddleName: widget.userMiddleName,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   style: ButtonStyle(
//                                       padding: MaterialStateProperty.all<
//                                           EdgeInsetsGeometry>(
//                                         const EdgeInsets.symmetric(
//                                             vertical: 15),
//                                       ),
//                                       minimumSize:
//                                           MaterialStateProperty.all<Size>(
//                                         const Size(150, 50),
//                                       ),
//                                       backgroundColor:
//                                           MaterialStateProperty.all<Color>(
//                                               Colors.green)),
//                                   child: const Text(
//                                     'Cancel',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: _isSaveEnabled
//                                       ? () {
//                                           Navigator.of(context).pushReplacement(
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       SKUInventory(
//                                                         userName:
//                                                             widget.userName,
//                                                         userLastName:
//                                                             widget.userLastName,
//                                                         userEmail:
//                                                             widget.userEmail,
//                                                         userContactNum: widget
//                                                             .userContactNum,
//                                                         userMiddleName: widget
//                                                             .userMiddleName,
//                                                         selectedAccount:
//                                                             _selectedAccount ??
//                                                                 '',
//                                                         SelectedPeriod:
//                                                             _selectedPeriod!,
//                                                         selectedWeek:
//                                                             _selectedWeek,
//                                                         selectedMonth:
//                                                             _selectedMonth,
//                                                         // inputid: generateInputID(),
//                                                       )));
//                                         }
//                                       : null,
//                                   style: ButtonStyle(
//                                     padding: MaterialStateProperty.all<
//                                         EdgeInsetsGeometry>(
//                                       const EdgeInsets.symmetric(vertical: 15),
//                                     ),
//                                     minimumSize:
//                                         MaterialStateProperty.all<Size>(
//                                       const Size(150, 50),
//                                     ),
//                                     backgroundColor: _isSaveEnabled
//                                         ? MaterialStateProperty.all<Color>(
//                                             Colors.green)
//                                         : MaterialStateProperty.all<Color>(
//                                             Colors.grey),
//                                   ),
//                                   child: const Text(
//                                     'Next',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ]),
//                     ),
//                   ),
//                 ),
//               ),
//             )));
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2101),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         _selectedDate = pickedDate;
//         _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//       });
//     }
//   }
// }

// class SKUInventory extends StatefulWidget {
//   final String userName;
//   final String userLastName;
//   final String userEmail;
//   final String selectedAccount;
//   final String SelectedPeriod;
//   final String selectedWeek;
//   final String selectedMonth;
//   //final String inputid;
//   String userContactNum;
//   String userMiddleName;

//   SKUInventory({
//     required this.userName,
//     required this.userLastName,
//     required this.userEmail,
//     required this.selectedAccount,
//     required this.SelectedPeriod,
//     required this.selectedWeek,
//     required this.selectedMonth,
//     // required this.inputid,
//     required this.userContactNum,
//     required this.userMiddleName,
//   });

//   @override
//   _SKUInventoryState createState() => _SKUInventoryState();
// }

// class _SKUInventoryState extends State<SKUInventory> {
//   bool _isDropdownVisible = false;
//   String? _selectedaccountname;
//   String? _selectedDropdownValue;
//   String? _productDetails;
//   String? _skuCode;
//   String? _versionSelected;
//   String? _statusSelected;
//   String? _selectedPeriod;
//   String? _remarksOOS;
//   String? _reasonOOS;
//   String? _selectedNoDeliveryOption;
//   String _inputid = '';
//   int? _selectedNumberOfDaysOOS;
//   bool _showCarriedTextField = false;
//   bool _showNotCarriedTextField = false;
//   bool _showDelistedTextField = false;
//   bool _isSaveEnabled = false;
//   bool _isEditing = true;
//   List<String> _delistedSkus = [];
//   List<String> _disabledSkus = [];

//   TextEditingController _beginningSAController = TextEditingController();
//   TextEditingController _beginningWAController = TextEditingController();
//   TextEditingController _endingSAController = TextEditingController();
//   TextEditingController _endingWAController = TextEditingController();
//   TextEditingController _beginningController = TextEditingController();
//   TextEditingController _deliveryController = TextEditingController();
//   TextEditingController _endingController = TextEditingController();
//   TextEditingController _offtakeController = TextEditingController();
//   TextEditingController _inventoryDaysLevelController = TextEditingController();
//   TextEditingController _accountNameController = TextEditingController();
//   TextEditingController _productsController = TextEditingController();
//   TextEditingController _skuCodeController = TextEditingController();
//   TextEditingController _noPOController = TextEditingController();
//   TextEditingController _unservedController = TextEditingController();
//   TextEditingController _nodeliveryController = TextEditingController();
//   List<Widget> _expiryFields = [];
//   List<Map<String, dynamic>> _expiryFieldsValues = [];
//   bool _showNoPOTextField = false;
//   bool _showUnservedTextField = false;
//   bool _showNoDeliveryDropdown = false;
//   String selectedBranch = 'BranchName'; // Get this from user input or selection
//   List<String> _availableSkuDescriptions = [];
//   bool _disabledDropdown = false;

//   String generateInputID() {
//     var timestamp = DateTime.now().millisecondsSinceEpoch;
//     var random =
//         Random().nextInt(10000); // Generate a random number between 0 and 9999
//     var paddedRandom =
//         random.toString().padLeft(4, '0'); // Ensure it has 4 digits
//     return '2000$paddedRandom';
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

//   void _saveInventoryItem() async {
//     try {
//       String inputid = _inputid;
//       String AccountManning = _selectedaccountname ?? '';
//       String period = _selectedPeriod ?? '';
//       String Version = _versionSelected ?? '';
//       String status = _statusSelected ?? '';
//       String SKUDescription = _selectedDropdownValue ?? '';
//       String product = _productDetails ?? '';
//       String skucode = _skuCode ?? '';
//       String remarksOOS = _remarksOOS ?? '';
//       String reasonOOS = _reasonOOS ?? '';
//       bool edit = _isEditing;
//       int numberOfDaysOOS = _selectedNumberOfDaysOOS ?? 0;

//       int beginningSA = int.tryParse(_beginningSAController.text) ?? 0;
//       int beginningWA = int.tryParse(_beginningWAController.text) ?? 0;
//       int newBeginning = beginningSA + beginningWA;

//       int endingSA = int.tryParse(_endingSAController.text) ?? 0;
//       int endingWA = int.tryParse(_endingWAController.text) ?? 0;
//       int newEnding = endingSA + endingWA;

//       int beginning = int.tryParse(_beginningController.text) ?? 0;
//       int delivery = int.tryParse(_deliveryController.text) ?? 0;
//       int ending = int.tryParse(_endingController.text) ?? 0;
//       int offtake = beginning + delivery - ending;

//       double inventoryDaysLevel = 0;
//       if (status != "Not Carried" && status != "Delisted") {
//         if (offtake != 0 && ending != double.infinity && !ending.isNaN) {
//           inventoryDaysLevel = ending / (offtake / 7);
//         }
//       }

//       dynamic ncValue = 'NC';
//       dynamic delistedValue = 'Delisted';
//       dynamic beginningValue = beginning;
//       dynamic beginningSAValue = beginningSA;
//       dynamic beginningWAValue = beginningWA;
//       dynamic deliveryValue = delivery;
//       dynamic endingValue = ending;
//       dynamic endingSAValue = endingSA;
//       dynamic endingWAValue = endingWA;
//       dynamic offtakeValue = offtake;
//       dynamic noOfDaysOOSValue = numberOfDaysOOS;

//       if (status == 'Delisted') {
//         beginningValue = delistedValue;
//         beginningSAValue = deliveryValue;
//         beginningWAValue = delistedValue;
//         deliveryValue = delistedValue;
//         endingValue = delistedValue;
//         endingSAValue = delistedValue;
//         endingWAValue = deliveryValue;
//         offtakeValue = delistedValue;
//         noOfDaysOOSValue = delistedValue;
//         _expiryFieldsValues = [
//           {'expiryMonth': delistedValue, 'expiryPcs': delistedValue}
//         ];
//       } else if (status == 'Not Carried') {
//         beginningValue = ncValue;
//         beginningSAValue = ncValue;
//         beginningWAValue = ncValue;
//         deliveryValue = ncValue;
//         endingValue = ncValue;
//         endingSAValue = ncValue;
//         endingWAValue = ncValue;
//         offtakeValue = ncValue;
//         noOfDaysOOSValue = ncValue;
//         _expiryFieldsValues = [
//           {'expiryMonth': ncValue, 'expiryPcs': ncValue}
//         ];
//       }

//       // Create new inventory item
//       InventoryItem newItem = InventoryItem(
//         id: ObjectId(),
//         userEmail: widget.userEmail,
//         date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//         inputId: inputid,
//         name: '${widget.userName} ${widget.userLastName}',
//         accountNameBranchManning: widget.selectedAccount,
//         period: widget.SelectedPeriod,
//         month: widget.selectedMonth,
//         week: widget.selectedWeek,
//         category: Version,
//         skuDescription: SKUDescription,
//         // products: product,
//         skuCode: skucode,
//         status: status,
//         beginning: beginningValue,
//         beginningSA: beginningSAValue,
//         beginningWA: beginningWAValue,
//         delivery: deliveryValue,
//         ending: endingValue,
//         endingSA: endingSAValue,
//         endingWA: endingWAValue,
//         offtake: offtakeValue,
//         inventoryDaysLevel: inventoryDaysLevel.toDouble(),
//         noOfDaysOOS: noOfDaysOOSValue,
//         expiryFields: _expiryFieldsValues,
//         remarksOOS: remarksOOS,
//         reasonOOS: reasonOOS,
//         isEditing: true,
//       );

//       // Save the new item to the database
//       await _saveToDatabase(newItem);

//       // If the SKU is delisted, remove it from the dropdown list

//       if (status == 'Delisted') {
//         setState(() {
//           _categoryToSkuDescriptions[_versionSelected]?.remove(SKUDescription);
//         });
//       }

//       // Update the dropdown after saving
//       updateDropdown(); // Refresh the dropdown list after saving the item

//       // Update status of the original item if editing
//       if (_isEditing) {
//         await _updateEditingStatus(inputid, widget.userEmail, false);
//       }
//     } catch (e) {
//       print('Error saving inventory item: $e');
//     }
//   }

//   Future<void> _saveToDatabase(InventoryItem item) async {
//     try {
//       final db = await mongo.Db.create(INVENTORY_CONN_URL);
//       await db.open();
//       final collection = db.collection(USER_INVENTORY);
//       final Map<String, dynamic> itemMap = item.toJson();
//       await collection.insert(itemMap);
//       await db.close();
//       print('Inventory item saved to database');
//     } catch (e) {
//       print('Error saving inventory item: $e');
//     }
//   }

//   Future<List<InventoryItem>> getUserInventoryItems(
//       String userEmail, String selectedAccountName) async {
//     List<InventoryItem> items = [];
//     try {
//       final db = await mongo.Db.create(INVENTORY_CONN_URL);
//       await db.open();
//       final collection = db.collection(USER_INVENTORY);

//       // Fetch items where the SKU is not delisted and belongs to the selected account
//       final result = await collection.find({
//         'userEmail': userEmail,
//         'accountNameBranchManning': selectedAccountName,
//         'status': {'\$ne': 'Delisted'}, // Exclude delisted items
//       }).toList();

//       for (var doc in result) {
//         items.add(InventoryItem.fromJson(doc));
//       }

//       await db.close();
//     } catch (e) {
//       print('Error fetching inventory items: $e');
//     }
//     return items;
//   }

//   void _addExpiryField() {
//     setState(() {
//       if (_expiryFields.length < 6) {
//         int index = _expiryFields.length;
//         _expiryFields.add(
//           ExpiryField(
//             index: index,
//             onExpiryFieldChanged: (month, pcs, index) {
//               _updateExpiryField(
//                   index, {'expiryMonth': month, 'expiryPcs': pcs});
//             },
//             onDeletePressed: () {
//               _removeExpiryField(index);
//             },
//           ),
//         );
//         _expiryFieldsValues.add({'expiryMonth': '', 'expiryPcs': 0});
//       }
//     });
//   }

//   void _removeExpiryField(int index) {
//     setState(() {
//       _expiryFields.removeAt(index);
//       _expiryFieldsValues.removeAt(index);

//       // Update the index of remaining fields
//       for (int i = index; i < _expiryFields.length; i++) {
//         _expiryFields[i] = ExpiryField(
//           index: i,
//           onExpiryFieldChanged: (month, pcs, index) {
//             _updateExpiryField(index, {'expiryMonth': month, 'expiryPcs': pcs});
//           },
//           onDeletePressed: () {
//             _removeExpiryField(i);
//           },
//         );
//       }
//     });
//   }

//   void _updateExpiryField(int index, Map<String, dynamic> newValue) {
//     setState(() {
//       _expiryFieldsValues[index] = newValue;
//     });
//   }

//   Map<String, List<String>> _categoryToSkuDescriptions = {
//     'V1': [
//       "BENG BENG CHOCOLATE 12 X 10 X 26.5G",
//       "BENG BENG SHARE IT 16 X 95G",
//       "CAL CHEESE 10X20X8.5G",
//       "CAL CHEESE 20 X 10 X 20G",
//       "CAL CHEESE 20 X 20 X 8.5G",
//       "CAL CHEESE 60 X 48G",
//       "CAL CHEESE 60X35G",
//       "CAL CHEESE 60X53.5G",
//       "CAL CHEESE CHOCO 20 X 10 X 20.5G",
//       "CAL CHEESE CHOCO 60 X 48G",
//       "DANISA BUTTER COOKIES 12X454G",
//       "MALKIST CAPPUCCINO 30X10X18G PH",
//       "MALKIST CHOCOLATE 30X10X18G",
//       "ROMA Cream Crackers",
//       "SUPERSTAR TRIPLE CHOCOLATE 12 X10 X 18G",
//       "VALMER CHOCOLATE 12X10X54G",
//       "VALMER SANDWICH CHOCOLATE 12X10X36G",
//       "WAFELLO BUTTER CARAMEL 20.5G X 10 X 20",
//       "WAFELLO BUTTER CARAMEL 48G X 60",
//       "WAFELLO CHOCOLATE 21G X 10 X 20",
//       "WAFELLO CHOCOLATE 48G X 60",
//       "WAFELLO COCO CRÈME 48G X 60",
//       "WAFELLO COCO CREME 60X35G",
//       "WAFELLO COCO CREME 60X53.5G",
//       "WAFELLO COCONUT CRÈME 20.5G X 10 X 20",
//       "WAFELLO CREAMY VANILLA 60X48G PH",
//       "WAFELLO CREAMY VANILLA 20X10X20.5G PH",
//       "FRES APPLE PEACH 24 X 50 X 3G",
//       "FRES BARLEY MINT 24X50X3G",
//       "FRES CHERRY CANDY, 24 X 50 X 3G",
//       "FRES CHERRY JAR, 12X 200 X 3G",
//       "FRES GRAPE CANDY, 24 X 50 X 3G",
//       "FRES GRAPE JAR, 12 X 200 X 3G",
//       "FRES MINT BARLEY JAR 12X200X3G",
//       "FRES MIXED CANDY JAR 12 X 600G",
//       "KOPIKO CAPPUCCINO CANDY 24X175G",
//       "KOPIKO COFFEE CANDY 24X175G",
//       "KOPIKO COFFEE CANDY JAR 6X560G",
//       "MALKIST SWEET GLAZED 12X10X28G PH",
//       "MALKIST BARBECUE 12X10X28G PH",
//       "WOW PASTA CARBONARA",
//       "WOW PASTA SPAGHETTI",
//     ],
//     'V2': [
//       "Kopiko Blanca hanger 24x10x30g",
//       "Kopiko Blanca Twinpack 12 X 10 X 2 X 29G",
//       "KOPIKO BLANCA, BAG 8 X 30 X 30G",
//       "KOPIKO BLANCA, POUCH 24 X 10 X 30G",
//       "Kopiko Brown Promo Twin 12 x 10 x 53g",
//       "Kopiko Brown Coffee Bag 8x30x27.5g",
//       "Kopiko Black 3 in One Promo Twin 12 x 10 x 2 x 30g",
//       "Kopiko Black 3 in One Hanger 24 x 10 x 30g",
//       "ENERGEN VANILLA HANGER 24 X 10 X 40G",
//       "Kopiko Brown Coffee hg 27.5g 24x10x27.5g",
//       "Kopiko Brown Coffee Pouch 24x10x27.5g",
//       "KOPIKO BLACK 3-IN-1 BAG 8 X 30 X 30G",
//       "KOPIKO BLACK 3-IN-1 POUCH 24 X 10 X 30G",
//       "KOPIKO BLACK 3IN1 TWINPACK 12X10X2X28G",
//       "Kopiko Cappuccino Bag 8x30x25g",
//       "Kopiko Cappuccino Hanger 24 x 10 x 25g",
//       "Kopiko Cappuccino Pouch 24x10x25g",
//       "Kopiko Double Cups 24 x 10 x 36g",
//       "Kopiko L.A. Coffee hanger 24x10x25g",
//       "Kopiko LA Coffee Pouch 24x10x25g",
//       "Energen Chocolate Bag 8x30x40g",
//       "ENERGEN CHOCOLATE HANGER 24 X 10 X 40G",
//       "Energen Chocolate Pouch 24x10x40g",
//       "Energen Vanilla Bag 8x30x40g",
//       "Energen Vanilla Pouch 24x10x40g",
//       "Energen Pandesal Mate 24 x 10 x 30g",
//       "ENERGEN CHAMPION 12X10X2X35G PH",
//       "Energen Champion NBA Hanger 24 x 10 x 35g",
//       "Energen Champion NBA TP 15 x 8 x 2 x30g ph",
//       "Kopiko Creamy Caramelo 12 x (10 x 2) x 25g",
//       "Toracafe White and Creamy 12 X (10 X 2) X 26G",
//       "Kopiko Cafe Mocha TP 12X10X(2X25.5G) PH",
//       "ENERGEN CHAMPION 40X345G",
//       "KOPIKO VOLCANIC DRIP- JAVA 24X10X8G PH",
//       "KOPIKO VOLCANIC DRIP - MANDHELING 24X10X8G PH",
//       "KOPIKO VOLCANIC DRIP - TORAJA 24X10X8G PH",
//     ],
//     'V3': [
//       "KOPIKO LUCKY DAY 24BTL X 180ML",
//       "Le Minerale 12x1500ml",
//       "Le Minerale 24x330ml",
//       "Le Minerale 24x600ml",
//       "LE MINERALE 4 X 5000ML",
//     ],
//   };

//   Map<String, Map<String, String>> _skuToProductSkuCode = {
//     //CATEGORY V1

//     'BENG BENG CHOCOLATE 12 X 10 X 26.5G': {
//       'Product': '',
//       'SKU Code': '329067'
//     },
//     'BENG BENG SHARE IT 16 X 95G': {'Product': '', 'SKU Code': '322583'},
//     'CAL CHEESE 10X20X8.5G': {'Product': '', 'SKU Code': '330071'},
//     'CAL CHEESE 20 X 10 X 20G': {'Product': '', 'SKU Code': '330053'},
//     'CAL CHEESE 20 X 20 X 8.5G': {'Product': '', 'SKU Code': '330071'},
//     'CAL CHEESE 60 X 48G': {'Product': '', 'SKU Code': '330052'},
//     'CAL CHEESE 60X35G': {'Product': '', 'SKU Code': '322571'},
//     'CAL CHEESE 60X53.5G': {'Product': '', 'SKU Code': '329808'},
//     'CAL CHEESE CHOCO 20 X 10 X 20.5G': {'Product': '', 'SKU Code': '330055'},
//     'CAL CHEESE CHOCO 60 X 48G': {'Product': '', 'SKU Code': '330054'},
//     'DANISA BUTTER COOKIES 12X454G': {'Product': '', 'SKU Code': '329650'},
//     'MALKIST CAPPUCCINO 30X10X18G PH': {'Product': '', 'SKU Code': '31446'},
//     'MALKIST CHOCOLATE 30X10X18G': {'Product': '', 'SKU Code': '321036'},
//     'ROMA Cream Crackers': {'Product': '', 'SKU Code': 'NC'},
//     'SUPERSTAR TRIPLE CHOCOLATE 12 X10 X 18G': {
//       'Product': '',
//       'SKU Code': '322894'
//     },
//     'VALMER CHOCOLATE 12X10X54G': {'Product': '', 'SKU Code': '321038'},
//     'VALMER SANDWICH CHOCOLATE 12X10X36G': {
//       'Product': '',
//       'SKU Code': '321475'
//     },
//     'WAFELLO BUTTER CARAMEL 20.5G X 10 X 20': {
//       'Product': '',
//       'SKU Code': '330057'
//     },
//     'WAFELLO BUTTER CARAMEL 48G X 60': {'Product': '', 'SKU Code': '330056'},
//     'WAFELLO CHOCOLATE 21G X 10 X 20': {'Product': '', 'SKU Code': '330051'},
//     'WAFELLO CHOCOLATE 48G X 60': {'Product': '', 'SKU Code': '330050'},
//     'WAFELLO COCO CRÈME 48G X 60': {'Product': '', 'SKU Code': '330058'},
//     'WAFELLO COCO CREME 60X35G': {'Product': '', 'SKU Code': '322868'},
//     'WAFELLO COCO CREME 60X53.5G': {'Product': '', 'SKU Code': '322869'},
//     'WAFELLO COCONUT CRÈME 20.5G X 10 X 20': {
//       'Product': '',
//       'SKU Code': '330059'
//     },
//     'WAFELLO CREAMY VANILLA 60X48G PH': {'Product': '', 'SKU Code': '330060'},
//     'WAFELLO CREAMY VANILLA 20X10X20.5G PH': {
//       'Product': '',
//       'SKU Code': '330073'
//     },
//     'FRES APPLE PEACH 24 X 50 X 3G': {'Product': '', 'SKU Code': '329545'},
//     'FRES BARLEY MINT 24X50X3G': {'Product': '', 'SKU Code': '326446'},
//     'FRES CHERRY CANDY, 24 X 50 X 3G': {'Product': '', 'SKU Code': '326447'},
//     'FRES CHERRY JAR, 12X 200 X 3G': {'Product': '', 'SKU Code': '329135'},
//     'FRES GRAPE CANDY, 24 X 50 X 3G': {'Product': '', 'SKU Code': '326448'},
//     'FRES GRAPE JAR, 12 X 200 X 3G': {'Product': '', 'SKU Code': '329137'},
//     'FRES MINT BARLEY JAR 12X200X3G': {'Product': '', 'SKU Code': '329136'},
//     'FRES MIXED CANDY JAR 12 X 600G': {'Product': '', 'SKU Code': '320015'},
//     'KOPIKO CAPPUCCINO CANDY 24X175G': {'Product': '', 'SKU Code': '326925'},
//     'KOPIKO COFFEE CANDY 24X175G': {'Product': '', 'SKU Code': '326924'},
//     'KOPIKO COFFEE CANDY JAR 6X560G': {'Product': '', 'SKU Code': '329106'},
//     'MALKIST SWEET GLAZED 12X10X28G PH': {'Product': '', 'SKU Code': '420559'},
//     'MALKIST BARBECUE 12X10X28G PH': {'Product': '', 'SKU Code': '420558'},
//     'WOW PASTA CARBONARA': {'Product': '', 'SKU Code': '420917'},
//     'WOW PASTA SPAGHETTI': {'Product': '', 'SKU Code': '421111'},
//     //CATEGORY V2

//     'Kopiko Blanca hanger 24x10x30g': {'Product': '', 'SKU Code': '328888'},
//     'Kopiko Blanca Twinpack 12 X 10 X 2 X 29G': {
//       'Product': '',
//       'SKU Code': '322711'
//     },
//     'KOPIKO BLANCA, BAG 8 X 30 X 30G': {'Product': '', 'SKU Code': '328889'},
//     'KOPIKO BLANCA, POUCH 24 X 10 X 30G': {'Product': '', 'SKU Code': '328887'},
//     'Kopiko Brown Promo Twin 12 x 10 x 53g': {
//       'Product': '',
//       'SKU Code': '329479'
//     },
//     'Kopiko Brown Coffee Bag 8x30x27.5g': {'Product': '', 'SKU Code': '328882'},
//     'Kopiko Black 3 in One Promo Twin 12 x 10 x 2 x 30g': {
//       'Product': '',
//       'SKU Code': '322627'
//     },
//     'Kopiko Black 3 in One Hanger 24 x 10 x 30g': {
//       'Product': '',
//       'SKU Code': '322628'
//     },
//     'ENERGEN VANILLA HANGER 24 X 10 X 40G': {
//       'Product': '',
//       'SKU Code': '328494'
//     },
//     'Kopiko Brown Coffee hg 27.5g 24x10x27.5g': {
//       'Product': '',
//       'SKU Code': '328890'
//     },
//     'Kopiko Brown Coffee Pouch 24x10x27.5g': {
//       'Product': '',
//       'SKU Code': '328883'
//     },
//     'KOPIKO BLACK 3-IN-1 BAG 8 X 30 X 30G': {
//       'Product': '',
//       'SKU Code': '322629'
//     },
//     'KOPIKO BLACK 3-IN-1 POUCH 24 X 10 X 30G': {
//       'Product': '',
//       'SKU Code': '322630'
//     },
//     'KOPIKO BLACK 3IN1 TWINPACK 12X10X2X28G': {
//       'Product': '',
//       'SKU Code': '420011'
//     },
//     'Kopiko Cappuccino Bag 8x30x25g': {'Product': '', 'SKU Code': '329704'},
//     'Kopiko Cappuccino Hanger 24 x 10 x 25g': {
//       'Product': '',
//       'SKU Code': '329701'
//     },
//     'Kopiko Cappuccino Pouch 24x10x25g': {'Product': '', 'SKU Code': '329703'},
//     'Kopiko Double Cups 24 x 10 x 36g': {'Product': '', 'SKU Code': '329744'},
//     'Kopiko L.A. Coffee hanger 24x10x25g': {
//       'Product': '',
//       'SKU Code': '325666'
//     },
//     'Kopiko LA Coffee Pouch 24x10x25g': {'Product': '', 'SKU Code': '325667'},
//     'Energen Chocolate Bag 8x30x40g': {'Product': '', 'SKU Code': '328493'},
//     'ENERGEN CHOCOLATE HANGER 24 X 10 X 40G': {
//       'Product': '',
//       'SKU Code': '328497'
//     },
//     'Energen Chocolate Pouch 24x10x40g': {'Product': '', 'SKU Code': '328492'},
//     'Energen Vanilla Bag 8x30x40g': {'Product': '', 'SKU Code': '328496'},
//     'Energen Vanilla Pouch 24x10x40g': {'Product': '', 'SKU Code': '328495'},
//     'Energen Pandesal Mate 24 x 10 x 30g': {
//       'Product': '',
//       'SKU Code': '325899'
//     },
//     'ENERGEN CHAMPION 12X10X2X35G PH': {'Product': '', 'SKU Code': '325934'},
//     'Energen Champion NBA Hanger 24 x 10 x 35g': {
//       'Product': '',
//       'SKU Code': '325945'
//     },
//     'Energen Champion NBA TP 15 x 8 x 2 x30g ph': {
//       'Product': '',
//       'SKU Code': '325965'
//     },
//     'Kopiko Creamy Caramelo 12 x (10 x 2) x 25g': {
//       'Product': '',
//       'SKU Code': '322725'
//     },
//     'Toracafe White and Creamy 12 X (10 X 2) X 26G': {
//       'Product': '',
//       'SKU Code': '322731'
//     },
//     'Kopiko Cafe Mocha TP 12X10X(2X25.5G) PH': {
//       'Product': '',
//       'SKU Code': '324149'
//     },
//     'ENERGEN CHAMPION 40X345G': {'Product': '', 'SKU Code': '420373'},
//     'KOPIKO VOLCANIC DRIP- JAVA 24X10X8G PH': {
//       'Product': '',
//       'SKU Code': '420237'
//     },
//     'KOPIKO VOLCANIC DRIP - MANDHELING 24X10X8G PH': {
//       'Product': '',
//       'SKU Code': '420238'
//     },
//     'KOPIKO VOLCANIC DRIP - TORAJA 24X10X8G PH': {
//       'Product': '',
//       'SKU Code': '420236'
//     },

//     //CATEGORY V3

//     'KOPIKO LUCKY DAY 24BTL X 180ML': {'Product': '', 'SKU Code': '324046'},
//     'Le Minerale 12x1500ml': {'Product': '', 'SKU Code': '326770'},
//     'Le Minerale 24x330ml': {'Product': '', 'SKU Code': '328566'},
//     'Le Minerale 24x600ml': {'Product': '', 'SKU Code': '328565'},
//     'LE MINERALE 4 X 5000ML': {'Product': '', 'SKU Code': '324045'},
//   };

//   // List<String> getSkuDescriptions(List<String> savedSkus) {
//   //   List<String> matchedDescriptions = [];
//   //   for (String sku in savedSkus) {
//   //     _categoryToSkuDescriptions.forEach((category, SKUDescription) {
//   //       if (SKUDescription.contains(sku)) {
//   //         matchedDescriptions.add(sku);
//   //       }
//   //     });
//   //   }
//   //   return matchedDescriptions;
//   // }

//   // List<String> getFilteredSkuDescriptions(List<String> savedSkus) {
//   //   List<String> matchedDescriptions = [];
//   //   _categoryToSkuDescriptions.forEach((category, SKUDescription) {
//   //     matchedDescriptions.addAll(SKUDescription.where(
//   //         (SKUDescription) => savedSkus.contains(SKUDescription)));
//   //   });
//   //   return matchedDescriptions;
//   // }

//   // void loadSkuDescriptions(String branchName, String category) async {
//   //   List<Map<String, dynamic>> skus =
//   //       await MongoDatabase.getSkusByBranchAndCategory(branchName, category);

//   //   print('SKUs by Branch and Category: $skus');

//   //   if (skus.isNotEmpty) {
//   //     List<String> savedSkus =
//   //         skus.map((sku) => sku['SKUs'] as String).toList();
//   //     print('Saved SKUs: $savedSkus');

//   //     List<String> skuDescriptions = getSkuDescriptions(savedSkus);
//   //     print('SKU Descriptions: $skuDescriptions');

//   //     setState(() {
//   //       _availableSkuDescriptions = skuDescriptions;
//   //       _selectedDropdownValue =
//   //           skuDescriptions.isNotEmpty ? skuDescriptions.first : null;
//   //     });
//   //   } else {
//   //     setState(() {
//   //       _availableSkuDescriptions = [];
//   //       _selectedDropdownValue = null;
//   //     });
//   //     print('No SKUs found for this branch and category.');
//   //   }
//   // }

//   void _toggleDropdown(String version) {
//     setState(() {
//       if (_versionSelected == version) {
//         // If the same dropdown is clicked again, hide it
//         _versionSelected = null;
//         _isDropdownVisible = false; // Hide the dropdown
//       } else {
//         // Otherwise, show the clicked dropdown
//         _versionSelected = version;
//         _isDropdownVisible = true; // Show the dropdown
//       }

//       // Reset remarks, reason, and their dropdown visibility
//       _remarksOOS = null; // Hide the Remarks dropdown
//       _selectedNoDeliveryOption = null; // Reset No Delivery option
//       _reasonOOS = null; // Reset Reason for OOS
//       _showNoDeliveryDropdown = false; // Hide No Delivery reason dropdown

//       // Reset No. of Days OOS
//       _selectedNumberOfDaysOOS = 0; // Reset Number of Days OOS to 0

//       // Reset other fields and visibility states
//       _selectedDropdownValue = null;
//       _productDetails = null; // Clear product details
//       _skuCode = null; // Clear SKU code
//       _expiryFields.clear(); // Clear expiry fields when switching categories

//       // Hide buttons and text fields when a category is deselected
//       _showCarriedTextField = false;
//       _showNotCarriedTextField = false;
//       _showDelistedTextField = false;

//       // Reset text controllers (optional)
//       _beginningController.clear();
//       _deliveryController.clear();
//       _endingController.clear();
//       _offtakeController.clear();
//     });
//   }

//   void _selectSKU(String? newValue) {
//     if (newValue != null && _skuToProductSkuCode.containsKey(newValue)) {
//       setState(() {
//         _selectedDropdownValue = newValue;
//         _productDetails = _skuToProductSkuCode[newValue]!['Product'];
//         _skuCode = _skuToProductSkuCode[newValue]!['SKU Code'];
//       });
//     }
//   }

//   void _confirmSave() {
//     if (_selectedDropdownValue != null) {
//       _saveSelectedSku(_selectedDropdownValue!);
//       // Optionally, show a confirmation dialog or message here
//     }
//   }

//   void _toggleCarriedTextField(String status) {
//     setState(() {
//       _statusSelected = status;
//       _showCarriedTextField = true;
//       _showNotCarriedTextField = false;
//       _showDelistedTextField = false;
//       _beginningController.clear();
//       _deliveryController.clear();
//       _endingController.clear();
//       _offtakeController.clear();
//       _expiryFields.clear(); // Clear expiry fields when switching categories
//     });
//   }

//   void _toggleNotCarriedTextField(String status) {
//     setState(() {
//       _statusSelected = status;
//       _showCarriedTextField = false;
//       _showNotCarriedTextField = true;
//       _showDelistedTextField = false;
//       _showNoDeliveryDropdown = false;
//       _showNoPOTextField = false;
//       _showUnservedTextField = false;
//       _beginningController.clear();
//       _beginningSAController.clear();
//       _beginningWAController.clear();
//       _deliveryController.clear();
//       _endingController.clear();
//       _endingSAController.clear();
//       _endingWAController.clear();
//       _offtakeController.clear();
//       _expiryFields.clear(); // Clear expiry fields when switching categories

//       if (status == 'Not Carried' || status == 'Delisted') {
//         _selectedNumberOfDaysOOS = 0;
//       }
//     });
//   }

//   void _toggleDelistedTextField(String status) {
//     setState(() {
//       _statusSelected = status;
//       _showCarriedTextField = false;
//       _showNotCarriedTextField = false;
//       _showDelistedTextField = true;
//       _showNoDeliveryDropdown = false;
//       _showNoPOTextField = false;
//       _showUnservedTextField = false;
//       _beginningSAController.clear();
//       _beginningWAController.clear();
//       _beginningController.clear();
//       _deliveryController.clear();
//       _endingController.clear();
//       _endingSAController.clear();
//       _endingWAController.clear();
//       _offtakeController.clear();
//       _expiryFields.clear(); // Clear expiry fields when switching categories
//       if (status == 'Not Carried' || status == 'Delisted') {
//         _selectedNumberOfDaysOOS = 0;
//       }
//     });
//   }

//   DateTime _getNextFriday() {
//     DateTime now = DateTime.now();
//     int daysUntilNextFriday = (DateTime.friday - now.weekday + 7) % 7;

//     // Return the next Friday at exactly 12:00 AM
//     DateTime nextFriday = DateTime(now.year, now.month, now.day)
//         .add(Duration(days: daysUntilNextFriday));

//     return DateTime(
//         nextFriday.year, nextFriday.month, nextFriday.day, 0, 0, 0); // 12:00 AM
//   }

//   Future<void> _saveSelectedSku(String selectedSku,
//       {bool isDelisted = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String branch = widget.selectedAccount;
//       String key = 'disabledSkus_$branch';

//       // Load current SKUs
//       String? disabledSkusData = prefs.getString(key);
//       Map<String, dynamic> storedData =
//           disabledSkusData != null ? jsonDecode(disabledSkusData) : {};
//       List<String> currentDisabledSkus =
//           List<String>.from(storedData['skus'] ?? []);
//       List<String> currentDelistedSkus =
//           List<String>.from(storedData['Delisted'] ?? []);

//       // Update SKU lists
//       if (isDelisted) {
//         if (!currentDelistedSkus.contains(selectedSku)) {
//           currentDelistedSkus.add(selectedSku);
//           print("SKU $selectedSku marked as Delisted.");
//         }
//       } else {
//         if (!currentDisabledSkus.contains(selectedSku) &&
//             !currentDelistedSkus.contains(selectedSku)) {
//           currentDisabledSkus.add(selectedSku);
//           print("SKU $selectedSku added to Disabled list.");
//         }
//       }

//       // Prepare data to store
//       Map<String, dynamic> dataToStore = {
//         'expiration':
//             _getNextFriday().toIso8601String(), // Set expiration to next Friday
//         'skus': currentDisabledSkus,
//         'Delisted': currentDelistedSkus,
//       };

//       // Save to SharedPreferences
//       await prefs.setString(key, jsonEncode(dataToStore));
//       print("Saved Data to SharedPreferences: $dataToStore");

//       // Update state
//       setState(() {
//         _disabledSkus = currentDisabledSkus;
//         _delistedSkus = currentDelistedSkus;
//       });

//       print(
//           "Updated State - Disabled SKUs: $_disabledSkus, Delisted SKUs: $_delistedSkus");

//       await _loadDisabledSkus(); // Reload to ensure everything is updated
//     } catch (e) {
//       print("Error saving SKU: $e");
//     }
//   }

//   Future<void> _loadDisabledSkus() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String branch = widget.selectedAccount;
//       String key = 'disabledSkus_$branch';

//       String? disabledSkusData = prefs.getString(key);
//       List<String> allSkus = _categoryToSkuDescriptions[_versionSelected] ?? [];
//       List<String> savedDisabledSkus = [];
//       _delistedSkus = []; // Reset before loading

//       if (disabledSkusData == null) {
//         print("No disabled SKUs found for branch: $branch");
//         _disabledSkus = []; // No SKUs disabled initially
//         return;
//       }

//       Map<String, dynamic> storedData = jsonDecode(disabledSkusData);
//       DateTime now = DateTime.now();
//       DateTime expirationDate = DateTime.parse(storedData['expiration']);
//       savedDisabledSkus = List<String>.from(storedData['skus'] ?? []);
//       _delistedSkus = List<String>.from(storedData['Delisted'] ?? []);

//       print("Loaded Data from SharedPreferences: $storedData");

//       // Check if SKUs have expired (i.e., if the current date is after the expiration date)
//       if (now.isAfter(expirationDate)) {
//         print(
//             "The SKUs have expired, resetting them (excluding delisted SKUs).");
//         savedDisabledSkus
//             .clear(); // Clear disabled SKUs, but keep delisted SKUs
//       }

//       // Determine which SKUs to load based on the day of the week
//       if (now.weekday >= DateTime.friday || now.weekday <= DateTime.thursday) {
//         // From Friday to Thursday, load saved disabled and delisted SKUs
//         _disabledSkus = [...savedDisabledSkus, ..._delistedSkus];
//       }

//       // Update state
//       setState(() {
//         print("Disabled SKUs loaded: $_disabledSkus");
//         print("Delisted SKUs loaded: $_delistedSkus");
//       });
//     } catch (e) {
//       print("Error loading disabled SKUs: $e");
//       _disabledSkus = []; // Fallback: No SKUs disabled
//       _delistedSkus = []; // Fallback: No SKUs delisted
//     }
//   }

//   bool _checkIfDelisted(String selectedSku) {
//     // Example logic to check if the SKU should be delisted
//     if (selectedSku.contains("Delisted")) {
//       // Replace with your actual condition
//       return true;
//     }
//     return false;
//   }

//   Future<void> updateDropdown() async {
//     List<InventoryItem> inventoryItems =
//         await getUserInventoryItems(widget.userEmail, widget.selectedAccount);

//     // Initialize a map to group SKUs by category
//     Map<String, List<String>> categoryToSkuDescriptions = {};

//     for (var item in inventoryItems) {
//       // Check if the category exists, and then add the SKU description to that category
//       if (categoryToSkuDescriptions.containsKey(item.category)) {
//         categoryToSkuDescriptions[item.category]!.add(item.skuDescription);
//       } else {
//         categoryToSkuDescriptions[item.category] = [item.skuDescription];
//       }
//     }

//     setState(() {
//       _categoryToSkuDescriptions =
//           categoryToSkuDescriptions; // Update the dropdown items
//     });
//   }

//   void _updateDropdownState() {
//     // Get the current weekday (1 = Monday, ..., 7 = Sunday)
//     final int today = DateTime.now().weekday;

//     // Enable dropdown only from Friday to Sunday
//     setState(() {
//       _disabledDropdown = !(today == 5 || today == 6 || today == 7);
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _inputid = generateInputID();
//     _updateDropdownState();

//     // Load disabled SKUs after the frame is built
//     WidgetsBinding.instance!.addPostFrameCallback((_) {
//       _loadDisabledSkus();
//     });

//     // Keep other listeners intact
//     _beginningController.addListener(_calculateBeginning);
//     _beginningController.addListener(_calculateOfftake);
//     _deliveryController.addListener(_calculateOfftake);
//     _endingController.addListener(_calculateOfftake);
//     _offtakeController.addListener(_calculateInventoryDaysLevel);
//     checkSaveEnabled();

//     // Add this method call at the end of initState
//     _setupAccountChangeListener();
//   }

// // New method to handle account changes
//   void _setupAccountChangeListener() {
//     // Assuming widget.selectedAccount is a String property
//     String currentAccount = widget.selectedAccount;

//     // Create a ValueNotifier to track account changes
//     final accountNotifier = ValueNotifier<String>(currentAccount);

//     // Listen for changes in the selected account
//     accountNotifier.addListener(() {
//       setState(() {
//         _loadDisabledSkus();
//       });
//     });

//     // Update the accountNotifier when widget.selectedAccount changes
//     WidgetsBinding.instance!.addPostFrameCallback((_) {
//       if (currentAccount != widget.selectedAccount) {
//         currentAccount = widget.selectedAccount;
//         accountNotifier.value = currentAccount;
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _beginningController.dispose();
//     _deliveryController.dispose();
//     _endingController.dispose();
//     _offtakeController.dispose();
//     _inventoryDaysLevelController.dispose();
//     _noPOController.dispose();
//     _unservedController.dispose();
//     _nodeliveryController.dispose();
//     super.dispose();
//   }

//   void _calculateBeginning() {
//     try {
//       // Parse input values, default to 0 if empty
//       int beginningSA = int.tryParse(_beginningSAController.text) ?? 0;
//       int beginningWA = int.tryParse(_beginningWAController.text) ?? 0;

//       // Calculate new beginning value
//       int newBeginning = beginningSA + beginningWA;

//       // Update the beginning controller with formatted integer value
//       _beginningController.text = newBeginning.toString();
//     } catch (e) {
//       print('Error calculating beginning: $e');
//       // Handle error appropriately (e.g., show an error message to the user)
//     }
//   }

//   void _calculateEnding() {
//     try {
//       // Parse input values, default to 0 if empty
//       int endingSA = int.tryParse(_endingSAController.text) ?? 0;
//       int endingWA = int.tryParse(_endingWAController.text) ?? 0;

//       // Calculate new beginning value
//       int newEnding = endingSA + endingWA;

//       // Update the beginning controller with formatted integer value
//       _endingController.text = newEnding.toString();
//     } catch (e) {
//       print('Error calculating beginning: $e');
//       // Handle error appropriately (e.g., show an error message to the user)
//     }
//   }

//   void _calculateOfftake() {
//     double beginning = double.tryParse(_beginningController.text) ?? 0;
//     double delivery = double.tryParse(_deliveryController.text) ?? 0;
//     double ending = double.tryParse(_endingController.text) ?? 0;
//     double offtake = beginning + delivery - ending;
//     _offtakeController.text = offtake.toStringAsFixed(2);
//   }

//   void _calculateInventoryDaysLevel() {
//     double ending = double.tryParse(_endingController.text) ?? 0;
//     double offtake = double.tryParse(_offtakeController.text) ?? 0;

//     double inventoryDaysLevel = 0; // Default to 0

//     if (offtake != 0 && ending != double.infinity && !ending.isNaN) {
//       inventoryDaysLevel = ending / (offtake / 7);
//     }

//     if (inventoryDaysLevel.isNaN || inventoryDaysLevel.isInfinite) {
//       inventoryDaysLevel = 0; // Assign 0 if the result is NaN or infinite
//     }

//     _inventoryDaysLevelController.text = inventoryDaysLevel == 0
//         ? '' // Leave it empty if the value is 0
//         : inventoryDaysLevel.toStringAsFixed(2);
//   }

//   void checkSaveEnabled() {
//     setState(() {
//       if (_statusSelected == 'Carried') {
//         if (_selectedNumberOfDaysOOS == 0) {
//           // Enable Save button when "0" is selected, but only if other fields are filled
//           _isSaveEnabled = _endingController.text.isNotEmpty &&
//               _deliveryController.text.isNotEmpty &&
//               _beginningSAController.text.isNotEmpty &&
//               _beginningWAController.text.isNotEmpty &&
//               _endingSAController.text.isNotEmpty &&
//               _endingWAController.text.isNotEmpty;
//         } else {
//           // Existing logic for when _selectedNumberOfDaysOOS is not 0
//           _isSaveEnabled = _endingController.text.isNotEmpty &&
//               _deliveryController.text.isNotEmpty &&
//               _beginningSAController.text.isNotEmpty &&
//               _beginningWAController.text.isNotEmpty &&
//               _endingSAController.text.isNotEmpty &&
//               _endingWAController.text.isNotEmpty;
//           (_remarksOOS == "No P.O" ||
//               _remarksOOS == "Unserved" ||
//               (_remarksOOS == "No Delivery" &&
//                   _selectedNoDeliveryOption != null));
//         }
//       } else {
//         // Enable Save button for "Not Carried" and "Delisted" categories
//         _isSaveEnabled = true;
//       }
//     });
//   }

//   void RemarkSaveEnable() {
//     setState(() {
//       // Enable the Save button only if a reason is selected when No Delivery dropdown is shown
//       if (_showNoDeliveryDropdown) {
//         _isSaveEnabled = _selectedNoDeliveryOption != null;
//       } else {
//         _isSaveEnabled = true; // or other conditions based on your app logic
//       }
//     });
//   }

//   bool isSaveEnabled = false;

//   @override
//   Widget build(BuildContext context) {
//     return new WillPopScope(
//         onWillPop: () async => false,
//         child: new MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(
//               appBar: AppBar(
//                   backgroundColor: Colors.green[600],
//                   elevation: 0,
//                   title: Text(
//                     'INVENTORY Process',
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                   leading: IconButton(
//                     icon: Icon(Icons.arrow_back),
//                     color: Colors.white,
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => AddInventory(
//                                   userName: widget.userName,
//                                   userLastName: widget.userLastName,
//                                   userEmail: widget.userEmail,
//                                   userContactNum: widget.userContactNum,
//                                   userMiddleName: widget.userMiddleName,
//                                 )),
//                       );
//                     },
//                   )),
//               body: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: SingleChildScrollView(
//                   // Wrap with SingleChildScrollView
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       SizedBox(height: 10),
//                       Text(
//                         'Input ID',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       SizedBox(height: 8),
//                       TextFormField(
//                         initialValue: generateInputID(),
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                           hintText: 'Auto-generated Input ID',
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'Week Number',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       TextField(
//                         controller: _accountNameController,
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                           hintText: widget.selectedWeek,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'Month',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       TextField(
//                         controller: _accountNameController,
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                           hintText: widget.selectedMonth,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'Branch/Outlet',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       TextField(
//                         controller: _accountNameController,
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           hintText: widget.selectedAccount,
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         'Category',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Expanded(
//                             child: OutlinedButton(
//                               onPressed: _versionSelected == 'V1' ||
//                                       _versionSelected == null
//                                   ? () => _toggleDropdown('V1')
//                                   : null,
//                               style: OutlinedButton.styleFrom(
//                                 side: BorderSide(
//                                     width: 2.0,
//                                     color: _versionSelected == 'V1'
//                                         ? Colors.green
//                                         : Colors.blueGrey.shade200),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                               child: Text(
//                                 'V1',
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                               width:
//                                   8), // Add spacing between buttons if needed
//                           Expanded(
//                             child: OutlinedButton(
//                               onPressed: _versionSelected == 'V2' ||
//                                       _versionSelected == null
//                                   ? () => _toggleDropdown('V2')
//                                   : null,
//                               style: OutlinedButton.styleFrom(
//                                 side: BorderSide(
//                                     width: 2.0,
//                                     color: _versionSelected == 'V2'
//                                         ? Colors.green
//                                         : Colors.blueGrey.shade200),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                               child: Text(
//                                 'V2',
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                               width:
//                                   8), // Add spacing between buttons if needed
//                           Expanded(
//                             child: OutlinedButton(
//                               onPressed: _versionSelected == 'V3' ||
//                                       _versionSelected == null
//                                   ? () => _toggleDropdown('V3')
//                                   : null,
//                               style: OutlinedButton.styleFrom(
//                                 side: BorderSide(
//                                     width: 2.0,
//                                     color: _versionSelected == 'V3'
//                                         ? Colors.green
//                                         : Colors.blueGrey.shade200),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                               child: Text(
//                                 'V3',
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       // Add text fields where user input is expected, and assign controllers
//                       if (_isDropdownVisible && _versionSelected != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 4.0),
//                               child: Text(
//                                 'SKU Description',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16, // Adjust as needed
//                                 ),
//                               ),
//                             ),
//                             DropdownButtonFormField<String>(
//                               onChanged: (String? newValue) {
//                                 if (newValue != null &&
//                                     !_disabledSkus.contains(newValue) &&
//                                     !_delistedSkus.contains(newValue)) {
//                                   _selectSKU(newValue);
//                                 }
//                               },
//                               items: _categoryToSkuDescriptions[
//                                       _versionSelected]!
//                                   .where((sku) =>
//                                       !_disabledSkus.contains(sku) &&
//                                       !_delistedSkus.contains(
//                                           sku)) // Filter out disabled and delisted SKUs
//                                   .toSet() // Ensure no duplicates
//                                   .map<DropdownMenuItem<String>>(
//                                       (String value) {
//                                 bool isDisabled = _disabledSkus.contains(value);
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   enabled: !isDisabled,
//                                   child: Container(
//                                     width: 320,
//                                     child: Text(
//                                       isDisabled ? "$value (DISABLED)" : value,
//                                       overflow: TextOverflow.ellipsis,
//                                       softWrap: false,
//                                       style: TextStyle(
//                                         color: isDisabled
//                                             ? Colors.red
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               decoration: InputDecoration(
//                                 labelText: 'Select SKU Description',
//                                 border: OutlineInputBorder(),
//                                 contentPadding:
//                                     EdgeInsets.symmetric(horizontal: 12),
//                               ),
//                             ),

//                             // SizedBox(
//                             //     height: 8), // Add some space below the dropdown
//                             // Text(
//                             //   _disabledDropdown
//                             //       ? 'The dropdown is disabled from Monday to Thursday and will enable on Friday.'
//                             //       : 'You can select SKUs now.',
//                             //   style: TextStyle(
//                             //     color: Colors
//                             //         .red, // Style for the informational text
//                             //     fontSize: 14,
//                             //   ),
//                             // ),

//                             if (_productDetails != null) ...[
//                               SizedBox(height: 10),
//                               Text(
//                                 'Products',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               TextField(
//                                 controller:
//                                     _productsController, // Assigning controller
//                                 readOnly: true,
//                                 decoration: InputDecoration(
//                                   border:
//                                       OutlineInputBorder(), // Apply border to the TextField
//                                   contentPadding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           12), // Padding inside the TextField
//                                   hintText: _productDetails,
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//                               Text(
//                                 'SKU Code',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               TextField(
//                                 readOnly: true,
//                                 controller:
//                                     _skuCodeController, // Assigning controller
//                                 decoration: InputDecoration(
//                                   border:
//                                       OutlineInputBorder(), // Apply border to the TextField
//                                   contentPadding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           12), // Padding inside the TextField
//                                   hintText: _skuCode,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),

//                       SizedBox(height: 15),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           if (_productDetails != null)
//                             SizedBox(
//                               width: 115, // Same fixed width
//                               child: OutlinedButton(
//                                 onPressed: () {
//                                   _toggleCarriedTextField('Carried');
//                                   checkSaveEnabled(); // Call checkSaveEnabled when category changes
//                                 },
//                                 style: OutlinedButton.styleFrom(
//                                   side: BorderSide(
//                                     width: 2.0,
//                                     color: _statusSelected == 'Carried'
//                                         ? Colors.green
//                                         : Colors.blueGrey.shade200,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'Carried',
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                               ),
//                             ),
//                           if (_productDetails != null)
//                             SizedBox(
//                               width: 130, // Same fixed width
//                               child: OutlinedButton(
//                                 onPressed: () {
//                                   _toggleNotCarriedTextField('Not Carried');
//                                   checkSaveEnabled(); // Call checkSaveEnabled when category changes
//                                 },
//                                 style: OutlinedButton.styleFrom(
//                                   side: BorderSide(
//                                     width: 2.0,
//                                     color: _statusSelected == 'Not Carried'
//                                         ? Colors.green
//                                         : Colors.blueGrey.shade200,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'Not Carried',
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                               ),
//                             ),
//                           if (_productDetails != null)
//                             SizedBox(
//                               width: 115, // Same fixed width
//                               child: OutlinedButton(
//                                 onPressed: () {
//                                   _toggleDelistedTextField('Delisted');
//                                   checkSaveEnabled(); // Call checkSaveEnabled when category changes
//                                 },
//                                 style: OutlinedButton.styleFrom(
//                                   side: BorderSide(
//                                     width: 2.0,
//                                     color: _statusSelected == 'Delisted'
//                                         ? Colors.green
//                                         : Colors.blueGrey.shade200,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'Delisted',
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 15),
//                       // Conditionally showing the 'Beginning' field with its label
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Beginning PCS (Selling Area)',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _beginningSAController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           onChanged: (_) {
//                             _calculateBeginning(); // Calculate on change
//                             checkSaveEnabled();
//                           },
//                         ),
//                         SizedBox(height: 10),
//                       ],
//                       SizedBox(height: 15),
//                       // Conditionally showing the 'BeginningWA' field with its label
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Beginning PCS (Warehouse Area)',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _beginningWAController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           onChanged: (_) {
//                             _calculateBeginning(); // Calculate on change
//                             checkSaveEnabled();
//                           },
//                         ),
//                         SizedBox(height: 10),
//                       ],
//                       SizedBox(height: 15),
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Ending PCS (Selling Area)',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _endingSAController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           onChanged: (_) {
//                             _calculateEnding(); // Calculate on change
//                             checkSaveEnabled();
//                           },
//                         ),
//                         SizedBox(height: 10),
//                       ],
//                       SizedBox(height: 15),
//                       // Conditionally showing the 'BeginningWA' field with its label
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Ending PCS (Warehouse Area)',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _endingWAController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           onChanged: (_) {
//                             _calculateEnding(); // Calculate on change
//                             checkSaveEnabled();
//                           },
//                         ),
//                         SizedBox(height: 10),
//                       ],
//                       SizedBox(height: 15),
//                       // Conditionally showing the 'Beginning' field with its label
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Beginning',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           readOnly: true,
//                           controller: _beginningController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           onChanged: (_) => checkSaveEnabled(),
//                         ),
//                         SizedBox(height: 10),
//                       ],

// // Conditionally showing the 'Delivery' field with its label
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Delivery PCS',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _deliveryController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           onChanged: (_) => checkSaveEnabled(),
//                         ),
//                         SizedBox(height: 10),
//                       ],
// // Conditionally showing the 'Ending' field with its label
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Ending',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           readOnly: true,
//                           controller: _endingController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           onChanged: (_) => checkSaveEnabled(),
//                         ),
//                         SizedBox(height: 10),
//                       ],
//                       SizedBox(height: 20),
//                       if (_showCarriedTextField) ...[
//                         Center(
//                           child: SizedBox(
//                             width: 450, // Set the width of the button
//                             child: OutlinedButton(
//                               onPressed: _addExpiryField,
//                               style: OutlinedButton.styleFrom(
//                                 side:
//                                     BorderSide(width: 2.0, color: Colors.green),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Add Expiry',
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         if (_expiryFields.isNotEmpty)
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               for (int i = 0; i < _expiryFields.length; i++)
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment
//                                       .center, // Align rows to center
//                                   children: [
//                                     Expanded(child: _expiryFields[i]),
//                                     IconButton(
//                                       icon: Icon(Icons.delete),
//                                       onPressed: () {
//                                         _removeExpiryField(i);
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                             ],
//                           ),
//                       ],

//                       SizedBox(height: 16),
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Offtake',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _offtakeController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           readOnly: true,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                       ],
// // Conditionally showing the 'Inventory Days Level' field with its label
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'Inventory Days Level',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _inventoryDaysLevelController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           readOnly: true,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                       ],

//                       SizedBox(height: 10),
// // Conditionally display 'No. of Days OOS' and the DropdownButtonFormField
//                       if (_showCarriedTextField) ...[
//                         Text(
//                           'No. of Days OOS',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         DropdownButtonFormField<int>(
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 12),
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           value: _selectedNumberOfDaysOOS,
//                           onChanged: (newValue) {
//                             setState(() {
//                               _selectedNumberOfDaysOOS = newValue;

//                               // Reset the remarks and reason when OOS changes
//                               _remarksOOS = null;
//                               _selectedNoDeliveryOption = null;
//                               _reasonOOS = null;

//                               // Hide the No Delivery dropdown if OOS Days is 0
//                               if (_selectedNumberOfDaysOOS == 0) {
//                                 _showNoDeliveryDropdown = false;
//                               }

//                               // Check if Save button should be enabled
//                               checkSaveEnabled();
//                             });
//                           },
//                           items: List.generate(8, (index) {
//                             return DropdownMenuItem<int>(
//                               value: index,
//                               child: Text(index.toString()),
//                             );
//                           }),
//                         ),
//                         SizedBox(height: 10),
//                       ],
//                       SizedBox(height: 10),
//                       if (_selectedNumberOfDaysOOS != null &&
//                           _selectedNumberOfDaysOOS! > 0) ...[
//                         Text(
//                           'Remarks',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         DropdownButtonFormField<String>(
//                           decoration: _statusSelected == 'Carried'
//                               ? InputDecoration(
//                                   border: OutlineInputBorder(),
//                                   contentPadding:
//                                       EdgeInsets.symmetric(horizontal: 12),
//                                   labelStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 )
//                               : null, // No border or padding when status is not 'Carried'
//                           value: _remarksOOS, // Ensure the value is not null
//                           onChanged: (newValue) {
//                             setState(() {
//                               _remarksOOS = newValue;

//                               // Show or hide the Select Reason dropdown based on the Remarks selection
//                               if (_remarksOOS == 'No Delivery' &&
//                                   _selectedNumberOfDaysOOS! > 0) {
//                                 _showNoDeliveryDropdown = true;
//                               } else {
//                                 _showNoDeliveryDropdown = false;
//                                 _selectedNoDeliveryOption = null;
//                                 _reasonOOS = null;
//                               }

//                               // Check if Save button should be enabled
//                               checkSaveEnabled();
//                             });
//                           },
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: 'No P.O',
//                               child: Text('No P.O'),
//                             ),
//                             DropdownMenuItem<String>(
//                               value: 'Unserved',
//                               child: Text('Unserved'),
//                             ),
//                             DropdownMenuItem<String>(
//                               value: 'No Delivery',
//                               child: Text('No Delivery'),
//                             ),
//                           ],
//                         ),
//                       ],
//                       SizedBox(height: 10),
// // Conditionally display the Reason dropdown if OOS days is greater than 0 and No Delivery is selected
//                       if (_showNoDeliveryDropdown &&
//                           _selectedNumberOfDaysOOS! > 0) ...[
//                         Text(
//                           'Reason',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         SizedBox(height: 10),
//                         DropdownButtonFormField<String>(
//                           decoration: _statusSelected == 'Carried'
//                               ? InputDecoration(
//                                   border: OutlineInputBorder(),
//                                   contentPadding:
//                                       EdgeInsets.symmetric(horizontal: 12),
//                                   labelStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 )
//                               : null, // No border or padding when status is not 'Carried'
//                           value: _selectedNoDeliveryOption,
//                           onChanged: (newValue) {
//                             setState(() {
//                               _selectedNoDeliveryOption = newValue;
//                               _reasonOOS =
//                                   newValue; // Set the ReasonOOS value based on selection
//                               checkSaveEnabled(); // Check if Save button should be enabled
//                             });
//                           },
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: 'With S.O but without P.O',
//                               child: Text('With S.O but without P.O'),
//                             ),
//                             DropdownMenuItem<String>(
//                               value: 'With P.O but without Delivery',
//                               child: Text('With P.O but without Delivery'),
//                             ),
//                             DropdownMenuItem<String>(
//                               value: 'AR ISSUES',
//                               child: Text('AR ISSUES'),
//                             ),
//                           ],
//                         ),
//                       ],
//                       SizedBox(height: 20),
//                       if (_showCarriedTextField ||
//                           _showNotCarriedTextField ||
//                           _showDelistedTextField)
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             ElevatedButton(
//                               onPressed: _isSaveEnabled
//                                   ? () async {
//                                       // Show confirmation dialog with preview
//                                       bool confirmed = await showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) {
//                                           return AlertDialog(
//                                             title: Text('Save Confirmation'),
//                                             content: SingleChildScrollView(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: <Widget>[
//                                                   Text(
//                                                       'Preview Inventory Item:'),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Date: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text: DateFormat(
//                                                                   'yyyy-MM-dd')
//                                                               .format(DateTime
//                                                                   .now()),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Input ID: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text: _inputid),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Name: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${widget.userName} ${widget.userLastName}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Account Name Branch ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text: widget
//                                                                 .selectedAccount),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Period: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text: widget
//                                                                 .SelectedPeriod),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Month: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text: widget
//                                                                 .selectedMonth),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Week: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text: widget
//                                                                 .selectedWeek),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Category: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text:
//                                                                 _versionSelected),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'SKU Description: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text:
//                                                                 _selectedDropdownValue),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Products: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text:
//                                                                 _productDetails),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'SKU Code: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text: _skuCode),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Status: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text:
//                                                                 _statusSelected),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Beginning (Selling Area): ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${int.tryParse(_beginningSAController.text) ?? 0}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Beginning (Warehouse Area): ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${int.tryParse(_beginningWAController.text) ?? 0}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Ending (Selling Area): ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${int.tryParse(_endingSAController.text) ?? 0}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Ending (WAREHOUSE AREA): ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${int.tryParse(_endingWAController.text) ?? 0}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Beginning Value: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${int.tryParse(_beginningController.text) ?? 0}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Delivery Value: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${int.tryParse(_deliveryController.text) ?? 0}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Ending Value: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${int.tryParse(_endingController.text) ?? 0}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Offtake Value: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${double.tryParse(_offtakeController.text)?.toStringAsFixed(2) ?? '0.00'}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Inventory Days Level: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                           text:
//                                                               '${double.tryParse(_inventoryDaysLevelController.text)?.toStringAsFixed(2) ?? '0.00'}',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'No of Days OOS: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text:
//                                                                 '$_selectedNumberOfDaysOOS'),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text:
//                                                               'Expiry Fields: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text:
//                                                                 '$_expiryFieldsValues'),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Remarks OOS: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text:
//                                                                 '$_remarksOOS'),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 10),
//                                                   Text.rich(
//                                                     TextSpan(
//                                                       children: [
//                                                         TextSpan(
//                                                           text: 'Reason OOS: ',
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                         TextSpan(
//                                                             text:
//                                                                 '$_reasonOOS'),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             actions: <Widget>[
//                                               TextButton(
//                                                 onPressed: () {
//                                                   Navigator.of(context).pop(
//                                                       false); // Close dialog without saving
//                                                 },
//                                                 child: Text('Cancel'),
//                                               ),
//                                               TextButton(
//                                                 onPressed: () {
//                                                   Navigator.of(context).pop(
//                                                       true); // Confirm saving
//                                                 },
//                                                 child: Text('Confirm'),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       );

//                                       if (confirmed ?? false) {
//                                         _saveInventoryItem(); // Call your save function here

//                                         // Disable or Delist the selected SKU after saving the inventory item
//                                         if (_selectedDropdownValue != null) {
//                                           // Check the status of the SKU before deciding its category
//                                           bool isDelisted = (_statusSelected ==
//                                               "Delisted"); // Assuming _selectedStatus tracks the SKU's status
//                                           if (isDelisted) {
//                                             _delistedSkus
//                                                 .add(_selectedDropdownValue!);
//                                           } else {
//                                             _disabledSkus
//                                                 .add(_selectedDropdownValue!);
//                                           }
//                                           _saveSelectedSku(
//                                               _selectedDropdownValue!,
//                                               isDelisted: isDelisted);
//                                         }

//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                             content:
//                                                 Text('Inventory item saved'),
//                                             duration: Duration(seconds: 2),
//                                           ),
//                                         );

//                                         Navigator.of(context).push(
//                                           MaterialPageRoute(
//                                             builder: (context) => AddInventory(
//                                               userName: widget.userName,
//                                               userLastName: widget.userLastName,
//                                               userEmail: widget.userEmail,
//                                               userContactNum:
//                                                   widget.userContactNum,
//                                               userMiddleName:
//                                                   widget.userMiddleName,
//                                             ),
//                                           ),
//                                         ); // Close the current screen after saving
//                                       }
//                                     }
//                                   : null, // Disable button if !_isSaveEnabled
//                               style: ButtonStyle(
//                                 padding: MaterialStateProperty.all<
//                                     EdgeInsetsGeometry>(
//                                   const EdgeInsets.symmetric(vertical: 15),
//                                 ),
//                                 minimumSize: MaterialStateProperty.all<Size>(
//                                   const Size(150, 50),
//                                 ),
//                                 backgroundColor:
//                                     MaterialStateProperty.all<Color>(
//                                         _isSaveEnabled
//                                             ? Colors.green
//                                             : Colors.grey),
//                               ),
//                               child: const Text(
//                                 'Save',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             )));
//   }

//   Widget _buildDropdown(
//     String title,
//     ValueChanged<String?> onSelect,
//     List<String> options,
//     InputDecoration Decoration,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 12.0),
//           child: Text(
//             title,
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         DropdownButton<String>(
//           value: _selectedDropdownValue,
//           isExpanded: true,
//           onChanged: onSelect,
//           items: options.map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }

// class ExpiryField extends StatefulWidget {
//   final int index;
//   final Function(String, int, int) onExpiryFieldChanged;
//   final VoidCallback onDeletePressed;
//   final String? initialMonth; // Initial value for the dropdown
//   final int? initialPcs; // Nullable initial value for the TextField

//   ExpiryField({
//     required this.index,
//     required this.onExpiryFieldChanged,
//     required this.onDeletePressed,
//     this.initialMonth,
//     this.initialPcs, // Make this nullable to allow an empty state
//   });

//   @override
//   _ExpiryFieldState createState() => _ExpiryFieldState();
// }

// class _ExpiryFieldState extends State<ExpiryField> {
//   String? _selectedMonth;
//   final TextEditingController _expiryController = TextEditingController();
//   bool _isMonthSelected = false; // New flag to track dropdown selection

//   @override
//   void initState() {
//     super.initState();

//     _selectedMonth = widget.initialMonth;
//     if (widget.initialPcs != null) {
//       _expiryController.text = widget.initialPcs.toString();
//     }
//     _expiryController.addListener(_onExpiryFieldChanged);
//   }

//   @override
//   void dispose() {
//     _expiryController.removeListener(_onExpiryFieldChanged);
//     _expiryController.dispose();
//     super.dispose();
//   }

//   void _onExpiryFieldChanged() {
//     if (_isMonthSelected) {
//       widget.onExpiryFieldChanged(
//         _selectedMonth!,
//         int.tryParse(_expiryController.text) ?? 0,
//         widget.index,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 10),
//         Text(
//           'Month of Expiry',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         SizedBox(height: 10),
//         DropdownButtonFormField<String>(
//           value: _selectedMonth,
//           onChanged: (String? newValue) {
//             setState(() {
//               _selectedMonth = newValue;
//               _isMonthSelected = newValue != null && newValue.isNotEmpty;
//             });
//             _onExpiryFieldChanged();
//           },
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.symmetric(horizontal: 12),
//             border: OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//           ),
//           hint: Text('Select Month'),
//           items: [
//             DropdownMenuItem<String>(
//               value: '1 Month',
//               child: Text('1 month'),
//             ),
//             DropdownMenuItem<String>(
//               value: '2 Months',
//               child: Text('2 months'),
//             ),
//             DropdownMenuItem<String>(
//               value: '3 Months',
//               child: Text('3 months'),
//             ),
//             DropdownMenuItem<String>(
//               value: '4 Months',
//               child: Text('4 months'),
//             ),
//             DropdownMenuItem<String>(
//               value: '5 Months',
//               child: Text('5 months'),
//             ),
//             DropdownMenuItem<String>(
//               value: '6 Months',
//               child: Text('6 months'),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Text(
//           'PCS of Expiry',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         SizedBox(height: 8),
//         TextField(
//           controller: _expiryController,
//           enabled:
//               _isMonthSelected, // Enable TextField only when a month is selected
//           decoration: InputDecoration(
//             hintText: 'Enter PCS of expiry',
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12),
//           ),
//           keyboardType: TextInputType.number,
//           onChanged: (value) {
//             _onExpiryFieldChanged();
//           },
//         ),
//       ],
//     );
//   }
// }
