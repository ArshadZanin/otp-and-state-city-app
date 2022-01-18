import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_two_step_auth/api/key_strings.dart';
import 'package:flutter_two_step_auth/views/login_page.dart';
import 'package:flutter_two_step_auth/views/select_state_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class OtpPage extends StatefulWidget {
  OtpPage({Key? key, required this.details}) : super(key: key);

  late String details;

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;

  bool timeout = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: otpField(
                context: context,
                onCompleted: (value) async {
                  var result = await verifyOtp(otp: value);
                  print(result);
                  if(result == 'Success'){
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectStatePage()));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('''Don't receive a code? ''', style: TextStyle(color: Colors.black,fontSize: 16),),
                    CountdownTimer(
                      endTime: endTime,
                      widgetBuilder: (context, CurrentRemainingTime? time) {
                        if (time == null) {
                          timeout = true;
                          return TextButton(
                            onPressed: () async {
                              var result = await reSendOtp(context);
                              print(result);

                              if(result == null){
                                return;
                              }

                              final value = jsonDecode(result);
                              result = value["Status"];

                              if(result == "Success"){
                                widget.details = value["Details"];
                              }
                            },
                            child: Text(
                              'Resend Otp',
                              style: TextStyle(color: Colors.blue[500],fontSize: 16),
                            ),
                          );
                        }

                        var min = time.min.toString();
                        var sec = time.sec.toString();

                        if(min.length == 1){
                          min = '0' + min;
                        }else if(min == 'null'){
                          min = '00';
                        }
                        if(sec.length == 1){
                          sec = '0' + sec;
                        }else if(sec == 'null'){
                          sec = '00';
                        }

                        return Text(
                          '$min: $sec',
                          style: TextStyle(color: Colors.blue[500],fontSize: 16),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> verifyOtp({required String otp}) async {
    final apiLink = Uri.parse('${KeyString.verifyOtpLink}${widget.details}/$otp');

    try {
      final response = await http.get(apiLink);
      if (response.statusCode == 200) {
        final value = jsonDecode(response.body);
        return value["Status"];
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

  Future<String?> reSendOtp(BuildContext context) async {
    final apiLink = Uri.parse('${KeyString.sendOtpLink}$phoneNumber/AUTOGEN');

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

  Widget otpField({void Function(String)? onCompleted, BuildContext? context}) {
    final otpController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: PinCodeTextField(
        keyboardType: TextInputType.number,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          inactiveFillColor: Colors.white,
          inactiveColor: const Color(0xFF008FAE),
          activeColor: const Color(0xFF008FAE),
          selectedFillColor: Colors.white,
          selectedColor: Colors.black,
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 40,
          activeFillColor: Colors.white,
        ),
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        // errorAnimationController: errorController,
        controller: otpController,
        onCompleted: onCompleted,
        onChanged: (value) {
          print(value);
        },
        beforeTextPaste: (text) {
          print("Allowing to paste $text");
          return true;
        },
        appContext: context!,
      ),
    );
  }

}
