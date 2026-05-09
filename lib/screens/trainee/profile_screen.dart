import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String fullname;
  final String email;
  final String password;
  final String gender;
  final DateTime birthdate;
  const ProfileScreen({super.key, required this.fullname, required this.email, required this.password, required this.gender, required this.birthdate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Profile'),
      drawer: AppDrawer(selectedIndex: 0, role: 'trainee'),
      body: Column(
        children: [
          Text('Your name is ${widget.fullname}'),
          Text('Your email is ${widget.email}'),
          Text('Your password is ${widget.password}'),
          Text('Your birthdate is ${widget.birthdate}'),
          Text('Your gender is ${widget.gender}'),
          Text('Your role is ')
        ],
      ),
    );
  }
}
