//return a formatted date as a string
import 'package:cloud_firestore/cloud_firestore.dart';

String formatData(Timestamp timestamp){
  DateTime dateTime=timestamp.toDate();
  //get year
  String year=dateTime.year.toString();

  //get month
  String month=dateTime.month.toString();

  //get day
  String day=dateTime.day.toString();

  //final formatted date
  String formattedDate='$day/$month/$year';

  return formattedDate;
}