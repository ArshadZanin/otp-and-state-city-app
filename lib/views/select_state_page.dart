import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_two_step_auth/api/key_strings.dart';
import 'package:flutter_two_step_auth/views/home_page.dart';
import 'package:flutter_two_step_auth/views/login_page.dart';
import 'package:http/http.dart' as http;

class SelectStatePage extends StatefulWidget {
  const SelectStatePage({Key? key}) : super(key: key);

  @override
  State<SelectStatePage> createState() => _SelectStatePageState();
}

class _SelectStatePageState extends State<SelectStatePage> {

  String selectedState = 'States';
  String selectedCity = 'Cities';
  List<String> states = ['States'];
  List<String> cities = ['Cities'];
  String token = '';

  final state = TextEditingController();
  final city = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCity(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
          },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            //   TextField(
            //     controller: state,
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText: 'State',
            //   ),
            // ),
              DropdownButtonFormField<String>(
                value: selectedState,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'State',
                  ),
                items: states.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  selectedState = value!;
                  selectedCity = 'Cities';
                  state.text = value;
                  fetchCityWithState(context, value);
                  setState(() {
                  });
                },
              ),
              const SizedBox(height: 25,),
              // TextField(
              //   controller: city,
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'City',
              //   ),
              // ),
              DropdownButtonFormField<String>(
                value: selectedCity,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'City',
                ),
                items: cities.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  selectedCity = value!;
                  city.text = value;
                  setState(() {
                  });
                },
              ),
              const SizedBox(height: 25,),
              TextButton(
                  onPressed: () async {
                    // await fetchCity(context);
                  }, child: const Text('submit')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchCity(BuildContext context) async {

    try {
      var response = await http.get(Uri.parse("https://www.universal-tutorial.com/api/getaccesstoken"), headers: {
        "Accept": "application/json",
        "api-token": "CShMmMnbcoJwZzMO-Gaw1No6Bl3jfNge2PRwv28ei4wYbeFbCiBVBKbiHyKz2vrGV2c",
        "user-email": "arshad@digimogo.com"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        token = result['auth_token'];

        var response1 = await http.get(Uri.parse("https://www.universal-tutorial.com/api/states/India"), headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        });
        print(response1.body);
        var forList = jsonDecode(response1.body);
        states.clear();
        states.add('States');
        cities.clear();
        cities.add('Cities');
        selectedCity = 'Cities';
        for(var state in forList){
          states.add("${state['state_name']}");
          print(state['state_name']);
        }
        setState(() {

        });
      } else {
        print('else');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Check network connection', textAlign: TextAlign.center,),
      ));
    } on TimeoutException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e', textAlign: TextAlign.center,),
      ));
    } on Error catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e', textAlign: TextAlign.center,),
      ));
    }
  }

  Future<void> fetchCityWithState(BuildContext context, String city) async {

    try {
        var response = await http.get(Uri.parse("https://www.universal-tutorial.com/api/cities/$city"), headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        });
        print(response.body);
        if(response.statusCode == 200){
        var forList = jsonDecode(response.body);
        cities.clear();
        cities.add('Cities');
        for(var city in forList){
          cities.add("${city['city_name']}");
          print(city['city_name']);
        }
        setState(() {});
      } else {
        print('else');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Check network connection', textAlign: TextAlign.center,),
      ));
    } on TimeoutException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e', textAlign: TextAlign.center,),
      ));
    } on Error catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e', textAlign: TextAlign.center,),
      ));
    }
  }

}
