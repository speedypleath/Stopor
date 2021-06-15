import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var notificationlist =[];
class Notifications extends StatefulWidget {

  @override
  _NotificationsState createState() => _NotificationsState();


}

class _NotificationsState extends State<Notifications> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
            itemCount: notificationlist.length,
          itemBuilder:(context,index){
              return Card(
                child:ListTile(
                  title:Text(notificationlist[index]),
                  subtitle:Text('There are 24 hours left until this event starts!'),

                )

              );
          }
      ),
    );
  }
}
int id=0;
void Notify(DateTime time,String name,String eventImage) async {
  print("Notification Start");
  id++;
  print(id);
  String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  await AwesomeNotifications().createNotification(
      content: NotificationContent(

          id: id,
          channelKey: 'scheduled',
          title:name,
          body: 'There are 24 hours left until this event starts!',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture:eventImage

      ),
      schedule: NotificationCalendar(
          year:time.year,
          month:time.month,
          day: time.subtract(new Duration(days: 1)).day,
          hour:time.hour,
          minute:time.minute,
          second:
         time.second,
          millisecond:
          time.microsecond,
          timeZone: localTimeZone,
          repeats: false
      ));
  DateTime initialtime=new DateTime(time.year,time.month,time.subtract(new Duration(days: 1)).day,time.hour,time.minute,time.second,time.microsecond);
  DateTime now=new DateTime.now();
  DateTime newtime=new DateTime(now.year,now.month,now.day,now.hour,now.minute,now.second,now.microsecond);
int finaltime=initialtime.difference(newtime).inDays;
print(finaltime);
  Timer(Duration(days: finaltime), () {
    notificationlist.add(name);
  });
  print("Notification End");
}
