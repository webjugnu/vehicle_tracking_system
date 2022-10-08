import 'package:device_info_plus/device_info_plus.dart';
Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.androidId.toString();
}
String baseUrl = 'https://mascotengineers.in/vts_api/api.php';