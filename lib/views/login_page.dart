import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_two_step_auth/api/key_strings.dart';
import 'package:flutter_two_step_auth/views/otp_page.dart';
import 'package:http/http.dart' as http;

String phoneNumber = '';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final phone = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                ),
              ),
              const SizedBox(height: 25,),
              TextField(
                controller: password,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 25,),
              ElevatedButton(
                onPressed: () async {

                  phoneNumber = phone.text;

                  var result = await sendOtp(context);
                  print(result);

                  if(result == null){
                    return;
                  }

                  final value = jsonDecode(result);
                  result = value["Status"];

                  if(result == "Success"){
                    String details = value["Details"];
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OtpPage(details: details,)));
                  }
                },
                child: const Text('Submit'),),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> sendOtp(BuildContext context) async {
    final apiLink = Uri.parse('${KeyString.sendOtpLink}${phone.text}/${password.text}');

    try {
      final response = await http.get(apiLink);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Check network connection', textAlign: TextAlign.center,),
      ));
      return null;
    } on TimeoutException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e', textAlign: TextAlign.center,),
      ));
      return null;
    } on Error catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e', textAlign: TextAlign.center,),
      ));
      return null;
    }
  }

}
