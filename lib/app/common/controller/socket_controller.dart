import 'package:get/get.dart';
import 'package:mh/app/modules/employee/employee_home/models/socket_location_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as skt;

class SocketController extends GetxController {
  skt.Socket? socket;
  Rx<SocketLocationModel> socketLocationModel = SocketLocationModel().obs;


  @override
  void onInit() {
    connectToSocket();
    super.onInit();
  }
  @override
  void onClose() {
    socket?.disconnect();
    socket?.dispose();
    super.onClose();
  }

  void connectToSocket() {
    socket = skt.io("wss://server.mhpremierstaffingsolutions.com", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });
  }
}
