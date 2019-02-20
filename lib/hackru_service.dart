import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:HackRU/models.dart';

const _lcsUrl = 'https://7c5l6v7ip3.execute-api.us-west-2.amazonaws.com/lcs-test'; // prod
//const _lcsUrl = 'https://7c5l6v7ip3.execute-api.us-west-2.amazonaws.com/lcs-test'; // test
const _miscUrl = 'http://hackru-misc.s3-website-us-west-2.amazonaws.com';

var client = new http.Client();

Future<http.Response> getMisc(String endpoint) {
  return client.get(_miscUrl + endpoint);
}

String toParam(LcsCredential credential) {
  var param = "";
  if (credential != null) {
    if (credential.isExpired()) {
      throw CredentialExpired();
    }
    param = "?token="+credential.token;
  }
  return param;
}

Future<http.Response> getLcs(String endpoint, [LcsCredential credential]) {
  return client.get(_lcsUrl + endpoint + toParam(credential));
}

Future<http.Response> postLcs(String endpoint, dynamic body, [LcsCredential credential]) async {
  var encodedBody = jsonEncode(body);
  var result = await client.post(_lcsUrl + endpoint + toParam(credential),
    headers: {"content-Type": "applicationi/json"},
    body: encodedBody
  );
  var decoded = jsonDecode(result.body);
  if(decoded["statusCode"] != result.statusCode) {
    print(decoded);
    print("!!!!!!!!!!!!WARNING");
    print("body and container status code dissagree actual ${result.statusCode} body: ${decoded['statusCode']}");
    print(endpoint);
  }
  return result;
}

// misc functions
Future<List<String>> sitemap() async {
  var response = await getMisc("/");
  return await response.body.split("\n");
}

Future<List<String>> events() async {
  var response = await getMisc("/events.txt");
  return await response.body.split("\n");
}

Future<String> labelUrl() async {
  var response = await getMisc("/label-url.txt");
  return response.body;
}

Future<List<HelpResource>> helpResources() async {
  var response =  await getMisc("/resources.json");
  var resources = json.decode(response.body);
  return resources.map<HelpResource>(
    (resource) => new HelpResource.fromJson(resource)
  ).toList();
}

// lcs functions

// /authorize can give wrong status codes
Future<LcsCredential> login(String email, String password) async {
  var result = await postLcs("/authorize", {
      "email": email,
      "password": password,
  });
  var body = jsonDecode(result.body);
  // quirk with lcs where it puts the actual result as a string
  // inside the normal body
  if (body["statusCode"] == 200) {
    var auth = jsonDecode(body["body"])["auth"];
    return LcsCredential.fromJson(auth);
  } else if (body["statusCode"] == 403) {
    throw LcsLoginFailed();
  } else {
    throw LcsError(result);
  }
}

Future<User> getUser(LcsCredential credential, [String targetEmail]) async {
  if (targetEmail == null) {
    targetEmail = credential.email;
  }
  var result = await postLcs("/read", {
      "email": credential.email,
      "token": credential.token,
      "query": {"email": targetEmail}
  }, credential);
  if (result.statusCode == 200) {
    var users = jsonDecode(result.body)["body"];
    if (users.length < 1) {
      throw NoSuchUser();
    }
    return User.fromJson(users[0]);
  } else {
    throw LcsError(result);
  }
}

// /update can give wrong status codes
// check if the user credential belongs to is role.director first. or else it will break :(
void updateUserDayOf(LcsCredential credential, User user, String event) async {
  print(event);
  var result = await postLcs("/update", {
      "updates": {"\$set":{"day_of.$event": true}},
      "user_email": user.email,
      "auth_email": credential.email,
      "auth": credential.token,
  }, credential);

  var decoded = jsonDecode(result.body);
  if (decoded["statusCode"] == 400) {
    throw UpdateError(decoded["body"]);
  } else if (decoded["statusCode"] == 403) {
    // BROKEN BECAUSE LCS
    throw PermissionError();
  } else if (decoded["statusCode"] != 200){
    throw LcsError(result);
  }
}