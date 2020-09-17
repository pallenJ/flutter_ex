
import 'package:flutter/material.dart';
import 'package:http_ex/main.dart';
import 'package:http_ex/methods.dart';

final String _baseURL = 'http://192.168.1.56:8000';

class User {
  final bool admin;
  final createdAt;
  final id; //_id
  final String userId;
  final String nick;

  User({this.admin, this.createdAt, this.id, this.userId, this.nick});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      admin: json['admin'],
      createdAt: json['createdAt'],
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
  final Function refreshMain;

  const LoginPage({Key key, this.refreshMain}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState(refreshMain: this.refreshMain);
}

class _LoginPageState extends State<LoginPage> {
  final Function refreshMain;

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  _LoginPageState({this.refreshMain});

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
                          color: Theme.of(context).primaryColor,
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
                  textColor: Theme.of(context).primaryColor,
                  child: Text('Forgot Password'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Theme.of(context).canvasColor,
                      color: Theme.of(context).primaryColor,
                      child: Text('Login'),
                      onPressed: () async{

                        postRequest('$_baseURL/users/login', body: {
                          'userId': nameController.text,
                          'password': passwordController.text
                        }).
                        then((value) async{
                          ///
                          if (value == null) {

                            scaffoldKey.currentState
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                content:
                                Text('login fail please check your info'),
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {
                                    scaffoldKey.currentState
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              ));
                          } else {
                            await fetchUser(value).then((user) {
                              loginUser = user;
                            });/*.whenComplete(() {
                              success = true;
                              Navigator.pop(context);
                            });*/
                          }
                          return value != null;
                          ///
                        }).then((flag) {
                          if(flag) Navigator.pop(context,refreshMain);
                          if(refreshMain!=null) refreshMain();
                        });
                      },
                    )),
                Container(
                    child: Row(
                      children: <Widget>[
                        Text('Does not have account?'),
                        FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            //sign up screen
                            Navigator.pop(context);
                            registerPageGo(scaffoldKey, context);
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ))
              ],
            )));
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

void registerPageGo(scaffoldKey, BuildContext context) async {
  if (loginUser == null || loginUser.id == null) {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(),
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

void loginPageGo(scaffoldKey, BuildContext context, {Function fnc}) async {
  if (loginUser == null || loginUser.id == null) {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        )).then((value) {});
    if (fnc != null) fnc();
  } else {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        'already login',
        textAlign: TextAlign.left,
      ),
    ));
  }
}

void loginPlease(scaffoldKey, BuildContext context, {Function fnc}) async {
  print('fnc : $fnc');
  scaffoldKey.currentState.showSnackBar(SnackBar(
    content: Text(
      'login please',
      textAlign: TextAlign.left,
    ),
    action: SnackBarAction(
      label: 'login',
      onPressed: () async {
        await scaffoldKey.currentState
            .hideCurrentSnackBar();
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            )).then((value) {
              print(value.runtimeType.toString());
              if(fnc!=null) fnc();
        });

      },
    ),
  ));
}

void logout(scaffoldKey, BuildContext context, {Function fnc}) async {
  print('logout');

  getRequestVoid('$_baseURL/users/logout', fnc: () async {
    loginUser = null;
    loginPlease(scaffoldKey, context,fnc: fnc);
  });
}
