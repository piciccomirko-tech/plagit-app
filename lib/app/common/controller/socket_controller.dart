import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as skt;

class SocketController extends GetxController {
  skt.Socket? socket;

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
  }

  void connectToSocket() {
    socket = skt.io("wss://server.mhpremierstaffingsolutions.com", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket?.connect();
  }
}
