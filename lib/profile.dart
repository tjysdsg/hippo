import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hippo/main.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart' as okToast;
import 'package:hippo/base.dart';
import 'dart:convert';

Future<String> login(String url, String username, String password) async {
  String token;
  http.Response res = await http.post(Uri.parse('http://$url/login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}));
  if (res.statusCode == 200) {
    token = json.decode(res.body)['token'];
  } else {
    throw Exception("Failed to login");
  }
  return token;
}

Future<String> register(
    String url, String username, String password, String realName) async {
  String token;
  http.Response res = await http.post(Uri.parse('http://$url/register'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          {'username': username, 'password': password, 'real_name': realName}));
  if (res.statusCode == 200) {
    token = json.decode(res.body)['token'];
  } else {
    throw Exception("Failed to register");
  }
  return token;
}

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

enum LoginType { login, register }

class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final GlobalStateController _gsc = Get.find();
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _realName = '';
  LoginType _loginType = LoginType.login;

  Widget buildAuthForm(BuildContext context) {
    // TODO: validate username, password and realName
    List<Widget> inputFields = [
      /// username
      TextFormField(
        decoration: InputDecoration(labelText: 'Username'),
        keyboardType: TextInputType.name,
        onChanged: (String value) {
          setState(() {
            _username = value;
          });
        },
        validator: (String value) {
          if (value.isEmpty) return 'Username is required';
          return null;
        },
      ),

      /// password
      TextFormField(
        decoration: InputDecoration(labelText: 'Password'),
        keyboardType: TextInputType.visiblePassword,
        onChanged: (String value) {
          setState(() {
            _password = value;
          });
        },
        validator: (String value) {
          if (value.isEmpty) return 'Password is required';
          return null;
        },
      ),
    ];

    /// real name
    if (_loginType == LoginType.register) {
      inputFields.add(TextFormField(
        decoration: InputDecoration(labelText: 'Real Name (Optional)'),
        keyboardType: TextInputType.name,
        onChanged: (String value) {
          setState(() {
            _realName = value;
          });
        },
      ));
    }
    var submitBtn = ElevatedButton(
      onPressed: () async {
        // validate input
        if (!_formKey.currentState.validate()) return;

        /// get token from server
        String token;
        try {
          if (_loginType == LoginType.login) {
            token = await login(_gsc.getServerUrl(), _username, _password);
          } else {
            token = await register(
                _gsc.getServerUrl(), _username, _password, _realName);
          }
        } catch (e) {
          okToast.showToast('Cannot login: $e');
          return;
        }
        if (token == '') {
          okToast.showToast('Cannot login');
          return;
        }
        _gsc.setUserInfo(_username, token);

        /// save login token to cache
        debugPrint('Login/register success, token: $token');

        /// FIXME: force redraw, since GetX doesn't seem to update
        setState(() {});
      },
      child: Text(_loginType == LoginType.login ? 'Login' : 'Register'),
    );

    /// login/register form
    var form = Form(
        key: _formKey,
        child: Column(
            children: inputFields +
                [
                  /// login/register button
                  FractionallySizedBox(
                    widthFactor: 1.0,
                    child: submitBtn,
                  ),

                  /// switch between register/login
                  FractionallySizedBox(
                      widthFactor: 1.0,
                      child: MaterialButton(
                        onPressed: () {
                          if (_loginType == LoginType.login) {
                            setState(() {
                              _loginType = LoginType.register;
                            });
                          } else {
                            setState(() {
                              _loginType = LoginType.login;
                            });
                          }
                        },
                        child: Text(_loginType == LoginType.login
                            ? 'Want to register?'
                            : 'Want to login?'),
                      )) // switch register/login button
                ]));
    return form;
  }

  Widget buildProfileDisplay(BuildContext context) {
    return Column(
      children: [
        Text('Logged in'),
        ElevatedButton(
          child: Text('Logout'),
          onPressed: () {
            _gsc.clearUserInfo();
            _username = '';
            _password = '';
            _realName = '';

            /// Force redraw, since GetX doesn't seem to update
            setState(() {});
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_gsc.loginToken.value == '')
        return buildAuthForm(context);
      else
        return buildProfileDisplay(context);
    });
  }
}

class _ProfileState extends PageState<Profile> {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [UserForm()],
        ),
      ),
    );
  }
}
