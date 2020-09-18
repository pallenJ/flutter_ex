import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http_ex/article.dart';
import 'package:http_ex/methods.dart';
import 'package:http_ex/user.dart';
import 'package:settings_ui/settings_ui.dart';
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

        primaryColor: Colors.redAccent,
        accentColor: Colors.deepOrangeAccent,
        primaryColorDark: Colors.yellowAccent,
        backgroundColor: Colors.white,
        primaryColorLight: Colors.redAccent,

      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

final String _baseURL = 'http://192.168.1.56:8000';
String pageUrl = 'articles';
User loginUser;
List<Future<Article>> futureArticles;
bool mainLoadCpt = false;

final mainScaffoldKey = GlobalKey<ScaffoldState>();

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

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIdx = 0;
  Widget _bodyWidget = Container();
  bool _forTestSwitch = false;
  bool lockInBackground = true, notificationsEnabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setFutureArticles(() => setState(() {
          mainLoadCpt = true;
          setBody();
        }));
    _setLoginUser();

/*    futureArticles = List<Future<Article>>.generate(
        3, (index) => fetchArticle(i: index));*/
  }
  
  
  @override
  void dispose() {
    // TODO: implement dispose
    //logout(mainScaffoldKey, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mainScaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: buildHeader(context),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      drawerEnableOpenDragGesture: true,
      drawerScrimColor: Colors.lightBlueAccent,
      primary: true,
      drawer: Drawer(
        child: ListView(
          children: [
            SwitchListTile(
                secondary: Icon(Icons.wallpaper),
                title: Text('Switch Test'),
                value: _forTestSwitch,
                onChanged: (value) {
                  setState(() {
                    _forTestSwitch = value;
                  });
                }),
          ],
        ),
      ),
      body: Container(
        child: _bodyWidget,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'add',
        child: Icon(Icons.add),
        onPressed: () =>
            writeArticlePageGo(mainScaffoldKey, context,fnc: _mainReturnRefresh),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIdx,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text('my info')),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text('setting')),
        ],
        onTap: (selectIdx) => setState(() {
          _selectedIdx = selectIdx;
          setBody();
        }),
      ),
    );
  }

  SingleChildScrollView buildArticleList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(2),
      child: Column(
        children: [loadArticles(mainLoadCpt)],
      ),
    );
  }

  Row buildHeader(BuildContext context) {
    return Row(
      children: [
        RaisedButton(
          textTheme: ButtonTextTheme.primary,
          color: Theme.of(context).primaryColor,
          child: Text('My nick',style: Theme.of(context).primaryTextTheme.button,),
          onPressed: () {
            if (loginUser == null || loginUser.nick == null) {
              print('login please');

              loginPlease(mainScaffoldKey, context, fnc: _mainReturnRefresh);
            } else {
              print('Hello ${loginUser.nick}');
              mainScaffoldKey.currentState
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  content: Text(
                    'Hello ${loginUser.nick}',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).primaryTextTheme.bodyText1,
                  ),
                  action: SnackBarAction(
                    label: 'logout',
                    textColor: Theme.of(context).primaryColorDark,
                    onPressed: () {
                      logout(mainScaffoldKey, context, fnc: _mainReturnRefresh);
                      _mainReturnRefresh();
                    },
                  ),
                ));
            }
          },
        ),
        SizedBox(

          width: 52,
          height: 52,
          child: OutlineButton(
            textTheme: ButtonTextTheme.accent,

            borderSide: BorderSide(
              width: 2,
              color: Theme.of(context).accentColor
            ),
            child: Icon(
              Icons.refresh,
            ),
            onPressed: () {
              _mainReturnRefresh();
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(width: 2)),
          ),
        ),
      ],
    );
  }

  void _setLoginUser() async {
    try {
      await getRequest('$_baseURL/users/myInfo').then((value) {
        print('ddd:' + value.toString());
        setState(() {
          if (value != null) {
            fetchUser(value).then((user) {
              loginUser = user;
            });
          } else {
            loginUser = null;
          }
        });
        /*else {
          getRequestVoid('$_baseURL/users/logout');
        }*/
      }).whenComplete(() {
        setState(() {
          print(
              'loginUser is null: ${loginUser == null || loginUser.userId == null}');
        });
      });
      /*postRequest('$_baseURL/users/login',body: {
            'userId':'admin','password':'wnsah1'
          }).then((value) => print(value));*/

    } catch (e) {}
  }

  void setBody() {
    switch (_selectedIdx) {
      case 0:
        setState(() {
          _bodyWidget = buildArticleList();
        });
        break;
      case 1:
        if (loginUser == null || loginUser.userId == null) {
          _selectedIdx = 0;
          setState(() {
            setBody();
          });
          loginPlease(mainScaffoldKey, context, fnc: _mainReturnRefresh);
          return;
        }
        _bodyWidget = showMyInfo();
        break;
      case 2:
        _bodyWidget = settingsList();
        break;
    }
  }

  ListView showMyInfo() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        Text.rich(TextSpan(
            text: 'ID:',
            style: TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: loginUser.userId,
                  style: TextStyle(fontWeight: FontWeight.normal))
            ])),
        Text.rich(TextSpan(
            text: 'NICK:',
            style: TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: loginUser.nick,
                  style: TextStyle(fontWeight: FontWeight.normal))
            ])),
        Text.rich(TextSpan(
            text: 'ADMIN:',
            style: TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: loginUser.admin.toString(),
                  style: TextStyle(fontWeight: FontWeight.normal))
            ])),
        Text.rich(TextSpan(
            text: 'SIGN UP DATE:',
            style: TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: loginUser.createdAt.toString(),
                  style: TextStyle(fontWeight: FontWeight.normal))
            ])),
      ],
    );
  }

  loadArticles(bool load) {
    if (!load) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
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
                  title: Text.rich(TextSpan(children: [
                    TextSpan(text: '${snapshot.data.title}'),
                    TextSpan(
                        text: snapshot.data.createdAt != snapshot.data.updatedAt
                            ? '[edited]'
                            : '',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).accentColor))
                  ])),
                  subtitle: Text(
                    '${snapshot.data.creator.nick}',
                    textAlign: TextAlign.right,
                  ),
                  trailing: Wrap(
                    children: [
                      Visibility(
                        visible: loginUser != null &&
                            (loginUser.userId == snapshot.data.creator.userId ||
                                (loginUser.admin != null && loginUser.admin)),
                        child: SizedBox(
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              editArticlePageGo(
                                  mainScaffoldKey, context, snapshot.data,
                                  fnc: () {
                                _mainReturnRefresh();
                              });
                            },
                            iconSize: 15,
                          ),
                          height: 20,
                          width: 20,
                        ),
                      ),
                      Visibility(
                        visible: loginUser != null &&
                            (loginUser.userId == snapshot.data.creator.userId ||
                                (loginUser.admin != null && loginUser.admin)),
                        child: SizedBox(
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              asyncConfirmDialog(context, 'DELETE?', okFnc: () {
                                deleteArticle(snapshot.data.id,
                                    fnc: () => {_mainReturnRefresh()});
                              });
                            },
                            iconSize: 15,
                          ),
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    print('${snapshot.data.content}');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ArticleDetail(
                                  articleInfo: snapshot.data,
                                  refreshFNC: _mainReturnRefresh,
                                ))).then((value) {
                      _mainReturnRefresh();
                    });
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
    );
  }

  void _mainReturnRefresh() async {
    print('main refresh $_selectedIdx');
    setFutureArticles(() => setState(() {
          mainLoadCpt = true;
          _setLoginUser();
          setBody();
        }));
  }

  Widget settingsList() {
    return SettingsList(
      // backgroundColor: Colors.orange,
      sections: [
        SettingsSection(
          title: 'Common',
          // titleTextStyle: TextStyle(fontSize: 30),
          tiles: [
            SettingsTile(
              title: 'Language',
              subtitle: 'English',
              leading: Icon(Icons.language),
              onTap: () {
                /*Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => LanguagesScreen()));*/
              },
            ),
            SettingsTile(
              title: 'Environment',
              subtitle: 'Production',
              leading: Icon(Icons.cloud_queue),
              onTap: () => print('e'),
            ),
          ],
        ),
        SettingsSection(
          title: 'Account',
          tiles: [
            SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
            SettingsTile(title: 'Email', leading: Icon(Icons.email)),
            SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
          ],
        ),
        SettingsSection(
          title: 'Security',
          tiles: [
            SettingsTile.switchTile(
              title: 'Lock app in background',
              leading: Icon(Icons.phonelink_lock),
              switchValue: lockInBackground,
              onToggle: (bool value) {
                setState(() {
                  lockInBackground = value;
                  notificationsEnabled = value;
                  setBody();
                });
              },
            ),
            SettingsTile.switchTile(
                title: 'Use fingerprint',
                leading: Icon(Icons.fingerprint),
                onToggle: (bool value) {},
                switchValue: false),
            SettingsTile.switchTile(
              title: 'Change password',
              leading: Icon(Icons.lock),
              switchValue: true,
              onToggle: (bool value) {},
            ),
            SettingsTile.switchTile(
              title: 'Enable Notifications',
              enabled: notificationsEnabled,
              leading: Icon(Icons.notifications_active),
              switchValue: true,
              onToggle: (value) {},
            ),
          ],
        ),
        SettingsSection(
          title: 'Misc',
          tiles: [
            SettingsTile(
                title: 'Terms of Service', leading: Icon(Icons.description)),
            SettingsTile(
                title: 'Open source licenses',
                leading: Icon(Icons.collections_bookmark)),
          ],
        ),
        CustomSection(
          child: Column(
            children: [
              /*Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 8),
                child: Image.asset(
                  'assets/settings.png',
                  height: 50,
                  width: 50,
                  color: Color(0xFF777777),
                ),
              ),*/
              Text(
                'Version: 2.4.0 (287)',
                style: TextStyle(color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
      ],
    );
/*    return Container(
      child: ListView(
        children: [
          ListTile(
            title: Text(
              'Common',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  subtitle: Text('English'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    print('Language');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cloud_queue),
                  title: Text('Production'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    print('Production');
                  },
                ),

              ],
            ),
          ),
          ListTile(
            title: Text(
              'Security',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [

              ],
            ),
          ),
        ],
      ),
    );*/
  }
}
