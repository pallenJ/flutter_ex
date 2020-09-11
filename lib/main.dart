import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http_ex/article.dart';
import 'package:http_ex/methods.dart';
import 'package:http_ex/user.dart';
//TODO:

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: super.key,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

final String _baseURL = 'http://192.168.1.56:8000';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

User loginUser;
List<Future<Article>> futureArticles;
bool mainLoadCpt = false;

class _MyHomePageState extends State<MyHomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setFutureArticles(
        () =>setState(() {
          mainLoadCpt = true;
        })
    );
    setLoginUser();
/*    futureArticles = List<Future<Article>>.generate(
        3, (index) => fetchArticle(i: index));*/
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 10, right: 50),
          child: Column(

            children: [
              Row(
                children: [
                  Container(
                    child: RaisedButton(
                      child: Text('My nick'),
                      textColor: Colors.white,
                      color: Colors.indigo,
                      onPressed: () {
                        if (loginUser == null || loginUser.nick == null) {
                          print('login please');

                          scaffoldKey.currentState..hideCurrentSnackBar()..showSnackBar(SnackBar(
                            content: Text(
                              'login please',
                              textAlign: TextAlign.left,
                            ),
                            action: SnackBarAction(
                              label: 'login',
                              onPressed: () => loginPageGo(scaffoldKey, context),
                            ),
                          ));
                        } else {
                          print('Hello ${loginUser.nick}');
                          scaffoldKey.currentState..hideCurrentSnackBar()..showSnackBar(SnackBar(
                            backgroundColor: Colors.lightBlueAccent,
                            content: Text(
                              'Hello ${loginUser.nick}',
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.indigoAccent),
                            ),
                            action: SnackBarAction(
                              label: 'logout',
                              textColor: Colors.deepPurple,
                              onPressed: () => logout(scaffoldKey, context),
                            ),
                          ));
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlineButton(
                      textColor: Colors.blueAccent,
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),

                      child: Icon(
                        Icons.refresh,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          setFutureArticles(
                              ()=>setState(() {
                              })
                          );
                          setLoginUser();
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: Colors.blueAccent, width: 2)),
                    ),
                  ),
                ],
              ),

              loadArticles(mainLoadCpt),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'add',
        child: Icon(Icons.add),
        onPressed: () => writeArticlePageGo(scaffoldKey, context),
      ),
    );
  }

  void setLoginUser() async {
    try {
      await getJSON('$_baseURL/users/myInfo').then((value) {
        print('ddd:' + value.toString());
        if (value != null) {
          fetchUser(value).then((user) {
            loginUser = user;
          });
        } else {
          getRequestVoid('$_baseURL/users/logout');
        }
      }).whenComplete(() {
        setState(() {
          print('loginUser is null: ${loginUser == null}');
        });
      });
      /*postRequest('$_baseURL/users/login',body: {
            'userId':'admin','password':'wnsah1'
          }).then((value) => print(value));*/

    } catch (e) {}
  }



  loadArticles(bool load) {
    if (!load) {
      return CircularProgressIndicator();
    }
    return Stack(
      children: [
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: futureArticles.length,
          itemBuilder: (context, index) => FutureBuilder(
            future: futureArticles[index],
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print('success');
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    child: ListTile(
                      title: Text('${snapshot.data.title}'),
                      subtitle: Text(
                        '${snapshot.data.creator.userId}',
                        textAlign: TextAlign.right,
                      ),
                      onTap: () {
                        print('${snapshot.data.content}');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ArticleDetail(
                                      articleInfo: snapshot.data,
                                    )));
                      },
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(217, 247, 255, 120),
                        border: Border.all(
                          color: Colors.grey,
                        )),
                  ),
                );
              } else if (snapshot.hasError) {
                print('err');
                return Text('${snapshot.error}');
              }
              return Text('not connect');
            },
          ),
        ),
      ],
    );
  }
}

void setFutureArticles(Function fnc) {
  futureArticles = [];
  getJSONList('$_baseURL/articles', type: getResponse).then((e) {
    e.forEach((elt) {
      futureArticles.add(fetchArticle(elt));
    });
    futureArticles = List.from(futureArticles);
  }).whenComplete(() {
    fnc();
    /*setState(() {
      mainLoadCpt = true;
    });*/
  });
}
