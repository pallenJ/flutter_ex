import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';

Future<http.Response> getResponse(String url) async {
  return await http.get(url);
}

Future<http.Response> postResponse(String url, {body}) async {
  return await http.post(url, body: body);
}

Future<http.Response> patchResponse(String url) async {
  return await http.patch(url);
}

Future<http.Response> deleteResponse(String url) async {
  return await http.delete(url);
}

Future<http.Response> putResponse(String url) async {
  return await http.put(url);
}

Future<List<dynamic>> getJSONList(String url,
    {Function type = getResponse}) async {
  http.Response response = await type(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw new Exception('Failed to load');
  }
}

Future<dynamic> getJSON(String url,
    {Function type = getResponse}) async {
  http.Response response = await type(url);

  print('status code ${response.statusCode}');
  print('aaa:' + response.body.toString());
  if (response.statusCode == 200 || response.isRedirect) {
    return json.decode(response.body);
  } else {
    throw new Exception('Failed to load');
  }
}
Future<dynamic> getRequest(String url,{params}) async{
  var r = await Requests.get(url,headers: params);
  r.raiseForStatus();
  return r.json();
}

void getRequestVoid(String url,{params,Function fnc}) async{
  var r = await Requests.get(url,headers: params);
  r.raiseForStatus();
  fnc();
}

Future<dynamic> postRequest(String url, {body}) async {
  var r = await Requests.post(url,
      body: body, bodyEncoding: RequestBodyEncoding.FormURLEncoded);
  r.raiseForStatus();
  return r.json();
}
