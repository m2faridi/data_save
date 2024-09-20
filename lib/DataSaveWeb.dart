
import 'dart:html' as html;

bool? DBTest;

Future<void> Init() async {


}
Future<void> SetString(String key,String value) async {
  CreateCookie(key, value.toString(), 30);
  await 0;
}
 Future<void> SetBool(String key,bool value) async {
   CreateCookie(key, value.toString(), 30);
   await 0;//
 }
 Future<void> SetInt(String key,int value) async {
   CreateCookie(key, value.toString(), 30);
   await 0;
 }
 Future<void> SetDouble(String key,double value) async {
   CreateCookie(key, value.toString(), 30);
   await 0;
 }
 String? GetString(String key) {
   String value = GetCookie(key).toString();
   if (value.isEmpty) return null;


   return value;
 }
 bool? GetBool(String key) {
   String value = GetCookie(key).toString();

   if (value.isEmpty) return null;


   return (value.toLowerCase() == "true" || value.toLowerCase() == "1");
 }
int? GetInt(String key) {
  String value = GetCookie(key).toString();

  if (value.isEmpty) return 0;

  return int.parse(value);
}
 void RemoveAll() async {
    String? cookies = html.document.cookie!;
    List<String> listValues = cookies.isNotEmpty ? cookies.split(";") : [];
    for (int i = 0; i < listValues.length; i++) {
      List<String> map = listValues[i].split("=");
      String _key = map[0].trim();
      String _val = map[1].trim();
      CreateCookie(_key,_val,0);

    }

}
double? GetDouble(String key) {
  String value = GetCookie(key).toString();

  if (value.isEmpty) return null;

  return double.parse(value);
}
void CreateCookie(String key, String value, int days) {
  int time = days * 86400;
  final hostname = html.window.location.hostname; // you probably need this one

  String domain = ".${hostname!}"; // دامنه به صورت خودکار گرفته می‌شود

  if (days == 0) {
    html.document.cookie = "$key=; max-age=$time; path=/; domain=$domain;";
  } else {
    html.document.cookie = "$key=$value; max-age=$time; path=/; domain=$domain;";
  }
}
String GetCookie(String key) {
  String? cookies = html.document.cookie!;
  List<String> listValues = cookies.isNotEmpty ? cookies.split(";") : [];
  String matchVal = "";
  for (int i = 0; i < listValues.length; i++) {
    List<String> map = listValues[i].split("=");
    String _key = map[0].trim();
    String _val = map[1].trim();

    if (key == _key) {
      matchVal = _val;
      break;
    }
  }
  return matchVal;
}




