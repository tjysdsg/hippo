import 'package:flutter/material.dart';
import 'package:hippo/utils.dart';

String login(String username, String password) {
  String token;
  return token;
}

class UserInfo {
  String username;
  String token;

  UserInfo({this.username, this.token});
}

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

enum LoginType { login, register }

class UserForm extends StatefulWidget {
  LoginType loginType;

  UserForm({this.loginType});

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<Widget> inputFields = [
      TextFormField(
        decoration: InputDecoration(labelText: 'Username'),
        keyboardType: TextInputType.name,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Password'),
        keyboardType: TextInputType.visiblePassword,
      ),
    ];
    if (widget.loginType == LoginType.register) {
      inputFields.add(TextFormField(
        decoration: InputDecoration(labelText: 'Real Name'),
        keyboardType: TextInputType.name,
      ));
    }
    return Form(
        key: _formKey,
        child: Column(
            children: inputFields +
                [
                  RaisedButton(
                    onPressed: () {
                      // TODO: get token from server
                    },
                    child: Text(widget.loginType == LoginType.login
                        ? 'Login'
                        : 'Register'),
                  ), // submit button
                  RaisedButton(
                    onPressed: () {
                      if (widget.loginType == LoginType.login) {
                        setState(() {
                          widget.loginType = LoginType.register;
                        });
                      } else {
                        setState(() {
                          widget.loginType = LoginType.login;
                        });
                      }
                    },
                    child: Text(widget.loginType == LoginType.login
                        ? 'Wanna Register?'
                        : 'Wanna Login?'),
                  ) // switch register/login button
                ]));
  }
}

class _ProfileState extends State<Profile> {
  UserInfo _userInfo;
  bool _loggedIn = false;
  LoginType _loginType = LoginType.login;
  String _username = '';
  String _password = '';
  String _realName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_loggedIn == true
              ? 'My Profile'
              : (_loginType == LoginType.login ? 'Login' : 'Register'))),
      body: Column(
        children: [UserForm(loginType: LoginType.login)],
      ),
    );
  }
}
