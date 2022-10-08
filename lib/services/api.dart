import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../global.dart' as global;

Future<List>login(mobileNo,deviceID,forceLogin) async{
 try{
    var response = await http.post(Uri.parse(global.baseUrl),
        body: {'mobile_no':mobileNo,'device_id':deviceID,'force_login':forceLogin,'purpose':'login'},
        headers: {'Accept':'application/json'}
    );
    var jsonResponse = jsonDecode(response.body);
    return [jsonResponse['status'],jsonResponse['msg'],jsonResponse['id']];
  }catch($e){
    return [123,$e];
  }
}

Future<List>addData(stateCode,rtoCode,vehicleNo) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var response = await http.post(Uri.parse(global.baseUrl),
    body: {
      'user_id':prefs.getString('id'),
      'mobile_no':prefs.getString('mobile_no'),
      'state_code':stateCode,
      'rto_no':rtoCode,
      'vehicle_no':vehicleNo,
      'purpose':'addData'
    }
  );
  var jsonResponse = jsonDecode(response.body);
  return [jsonResponse['status'],jsonResponse['msg']];
}

Future<List> getIdList(fileId) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var response = await http.post(Uri.parse(global.baseUrl),
      body: {
        'user_id':prefs.getString('id'),
        'purpose':'getData',
        'id':fileId.toString()
      }
  );
  var jsonResponse = jsonDecode(response.body);
  return [jsonResponse['status'],jsonResponse['data']];
}

Future<List> getTodayList() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print(prefs.getString('id'));
  var response = await http.post(Uri.parse(global.baseUrl),
      body: {
        'user_id':prefs.getString('id'),
        'purpose':'getData'
      }
  );
  var jsonResponse = jsonDecode(response.body);
  return [jsonResponse['status'],jsonResponse['data']];
}

Future<List> updateData(stateCode,rtoCode,vehicleNo,id) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var response = await http.post(Uri.parse(global.baseUrl),
      body: {
        'id':id.toString(),
        'state_code':stateCode,
        'rto_no':rtoCode,
        'vehicle_no':vehicleNo,
        'purpose':'updateData'
      }
  );
  var jsonResponse = jsonDecode(response.body);
  return [jsonResponse['status'],jsonResponse['msg']];
}


Future <bool> removeSecretKey() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("id");
  prefs.remove("mobile_no");
  return true;
}