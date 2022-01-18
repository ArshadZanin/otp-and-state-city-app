import 'package:flutter/material.dart';
import 'package:flutter_two_step_auth/views/login_page.dart';
import 'package:flutter_two_step_auth/views/select_state_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginPage(),
      // body: SelectStatePage(),
    );
  }
}
