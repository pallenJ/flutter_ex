import 'package:flutter/material.dart';
import 'package:http_ex/main.dart';
import 'package:http_ex/methods.dart';
import 'package:http_ex/user.dart';

final String _baseURL = 'http://192.168.1.56:8000';

class Article {
  final createdAt;
  final updatedAt;
  final deletedAt;
  final int id; //_id
  final String title;
  final String content;
  final User creator; //_creator

  Article(
      {this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.id,
        this.title,
        this.content,
        this.creator});

  factory Article.fromJson(Map<String, dynamic> json) {
    print(json['_creator']);
    return Article(
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      creator: User.fromJson(json['_creator']),
    );
  }
}

Future<Article> fetchArticle(articleJSON) async {
  return Article.fromJson(articleJSON);
}


class ArticleDetail extends StatelessWidget {
  final Article articleInfo;
  final Function refreshFNC;
  bool isMyArticle;

  ArticleDetail({this.articleInfo, this.refreshFNC});

  @override
  Widget build(BuildContext context) {
    isMyArticle = loginUser != null &&
        (loginUser.userId == articleInfo.creator.userId || (loginUser.admin!=null&&loginUser.admin));
    if (articleInfo == null)
      return Container(
        child: Center(
          child: Text('Value is null'),
        ),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Detail'),
      ),
      body: Container(
        padding: EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.blue,
              child: Text(
                '  ' + articleInfo.title,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    articleInfo.creator.nick,
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    'created at ${DateTime.parse(articleInfo.createdAt).toString()}',
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Visibility(
                    visible: articleInfo.updatedAt != articleInfo.createdAt,
                    child: Text(
                      'updated at ${DateTime.parse(articleInfo.updatedAt).toString()}',
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(articleInfo.content,
                        style: TextStyle(fontSize: 17)),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey)),
            )
          ],
        ),
      ),
      persistentFooterButtons: [
        Visibility(
          visible: isMyArticle,
          child: IconButton(
            icon: Icon(Icons.mode_edit),
            onPressed: () {
              Navigator.pop(context);
              editArticlePageGo(mainScaffoldKey, context, articleInfo, fnc: () {
                refreshFNC();
              });
            },
          ),
        ),
        Visibility(
          visible: isMyArticle,
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deleteArticle(articleInfo.id, fnc: () {
                refreshFNC();
              });
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

class ArticleWrite extends StatefulWidget {
  @override
  _ArticleWriteState createState() => _ArticleWriteState();
}

class _ArticleWriteState extends State<ArticleWrite> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var _titleController = TextEditingController();
  var _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Write Article'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'TITLE'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 10,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'CONTENT',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: OutlineButton(
                    textColor: Theme.of(context).primaryColor,
                    borderSide: BorderSide.none,
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
              Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: RaisedButton(
                    textColor: Theme.of(context).canvasColor,
                    color: Theme.of(context).primaryColor,
                    child: Text('ADD'),
                    onPressed: () async {
                      if (_titleController.text == null ||
                          _titleController.text.length == 0) {
                        scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                              SnackBar(content: Text('check title')));
                      } else if (_contentController.text == null ||
                          _contentController.text.length == 0) {
                        scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                              SnackBar(content: Text('check content')));
                      } else {
                        await postRequest('$_baseURL/articles/add', body: {
                          'title': _titleController.text,
                          'content': _contentController.text,
                        }).whenComplete(() {
                          Navigator.pop(context);
                        });
                      }
                    },
                  )),
            ],
          )
        ],
      ),
    );
  }
}

class ArticleEdit extends StatefulWidget {
  final Article articleInfo;

  ArticleEdit(this.articleInfo);

  @override
  _ArticleEditState createState() => _ArticleEditState(articleInfo);
}

class _ArticleEditState extends State<ArticleEdit> {
  final Article articleInfo;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var _titleController = TextEditingController();
  var _contentController = TextEditingController();

  _ArticleEditState(this.articleInfo);

  @override
  Widget build(BuildContext context) {
    _titleController.text = articleInfo.title;
    _contentController.text = articleInfo.content;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Write Article'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'TITLE'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 10,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'CONTENT',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: OutlineButton(
                    textColor: Colors.lightBlue,
                    borderSide: BorderSide.none,
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
              Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: RaisedButton(
                    textColor: Colors.white,
                    color: Colors.lightBlue,
                    child: Text('EDIT'),
                    onPressed: () async {
                      if (_titleController.text == null ||
                          _titleController.text.length == 0) {
                        scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                              SnackBar(content: Text('check title')));
                      } else if (_contentController.text == null ||
                          _contentController.text.length == 0) {
                        scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                              SnackBar(content: Text('check content')));
                      } else {
                        await patchRequest(
                            '$_baseURL/articles/${articleInfo.id}',
                            body: {
                              'title': _titleController.text,
                              'content': _contentController.text,
                            }).whenComplete(() {
                          Navigator.pop(context);
                        });
                      }
                    },
                  )),
            ],
          )
        ],
      ),
    );
  }
}

void editArticlePageGo(scaffoldKey, BuildContext context, Article articleInfo,
    {Function fnc}) async {
  if (loginUser == null || loginUser.id == null) {
    loginPlease(scaffoldKey, context);
  } else {
    await Navigator.push(context,
            MaterialPageRoute(builder: (context) => ArticleEdit(articleInfo)))
        .then((value) {
      if (fnc != null) fnc();
    });
  }
}

void writeArticlePageGo(scaffoldKey, BuildContext context,
    {Function fnc}) async {
  if (loginUser == null || loginUser.id == null) {
    loginPlease(scaffoldKey, context);
  } else {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleWrite(),
        )).then((value) {
      if (fnc != null) fnc();
    });
  }
}

void setFutureArticles(Function fnc) {
  futureArticles = [];
  getJSONList('$_baseURL/$pageUrl', type: getResponse).then((e) {
    e.forEach((elt) {
      futureArticles.add(fetchArticle(elt));
    });
    futureArticles = List.from(futureArticles);
  }).whenComplete(() {
    if (fnc != null) fnc();
    /*setState(() {
      mainLoadCpt = true;
    });*/
  });
}

void deleteArticle(int _id, {Function fnc}) async {
  var deleteRS = await deleteRequest('$_baseURL/articles/$_id');
  print(deleteRS);
  if (fnc != null) fnc();
}

