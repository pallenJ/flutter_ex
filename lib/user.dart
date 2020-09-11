import 'package:flutter/material.dart';
import 'package:http_ex/main.dart';
import 'package:http_ex/methods.dart';

final String _baseURL = 'http://192.168.1.56:8000';

class User {
  final bool admin;
  final createAt;
  final id; //_id
  final String userId;
  final String nick;

  User({this.admin, this.createAt, this.id, this.userId, this.nick});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      admin: json['admin'],
      createAt: json['createAt'],
      id: json['_id'],
      userId: json['userId'],
      nick: json['nick'],
    );
  }
}

Future<User> fetchUser(userJSON) async {
  return User.fromJson(userJSON);
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('Login Screen App'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User ID',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    //forgot password screen
                  },
                  textColor: Colors.blue,
                  child: Text('Forgot Password'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Login'),
                      onPressed: () {
                        postRequest('$_baseURL/users/login', body: {
                          'userId': nameController.text,
                          'password': passwordController.text
                        }).then((value) {
                          fetchUser(value).then((user) {
                            loginUser = user;
                          });
                        });
                        Navigator.pop(context);
                      },
                    )),
                Container(
                    child: Row(
                  children: <Widget>[
                    Text('Does not have account?'),
                    FlatButton(
                      textColor: Colors.blue,
                      child: Text(
                        'Sign in',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        //signup screen
                        Navigator.pop(context);
                        signInPageGo(scaffoldKey, context);
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ))
              ],
            )));
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('SingIn Screen App'),
      ),
      body: Container(),
    );
  }
}

void signInPageGo(scaffoldKey, BuildContext context) async {
  if (loginUser == null || loginUser.id == null) {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ));
  } else {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        'already login',
        textAlign: TextAlign.left,
      ),
      backgroundColor: Colors.redAccent,
    ));
  }
}

void loginPageGo(scaffoldKey, BuildContext context) async {
  if (loginUser == null || loginUser.id == null) {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
  } else {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        'already login',
        textAlign: TextAlign.left,
      ),
    ));
  }
}

void loginPlease(scaffoldKey, BuildContext context)async{
  scaffoldKey.currentState.showSnackBar(SnackBar(
    content: Text(
      'login please',
      textAlign: TextAlign.left,
    ),
    action: SnackBarAction(
      label: 'login',
      onPressed: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
      },
    ),
  ));
}

void logout(scaffoldKey, BuildContext context) async {
  print('logout');
  getRequestVoid('$_baseURL/users/logout', fnc: () async {
    loginUser = null;
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        'logout',
        textAlign: TextAlign.left,
      ),
      action: SnackBarAction(
        label: 'login',
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
        },
      ),
    ));
  });
}
