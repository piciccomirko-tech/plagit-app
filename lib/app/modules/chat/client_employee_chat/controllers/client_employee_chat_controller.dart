import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/employee_full_details.dart';
import '../../../../repository/api_helper.dart';
import '../../../../repository/send_push.dart';

class ClientEmployeeChatController extends GetxController {

  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper apiHelper = Get.find();

  late String receiverName;

  late String fromId;
  late String toId;

  late String clientId;
  late String employeeId;

  CollectionReference onChatScreenCollection = FirebaseFirestore.instance.collection('onChatScreen');
  CollectionReference employeeClientChatCollection = FirebaseFirestore.instance.collection("employee_client_chat");
  late DocumentReference employeeClientChatDocument;
  late CollectionReference messageCollection;

  RxBool loading = true.obs;

  RxBool isReceiverOnline = false.obs;
  String receiverToken = "";

  RxList massages = [].obs;

  TextEditingController tecController = TextEditingController();
  late ScrollController scrollController;

  bool firstTimeScrollToBottomComplete = false;

  @override
  void onInit() {

    scrollController = ScrollController();

    receiverName = Get.arguments[MyStrings.arg.receiverName];

    fromId = Get.arguments[MyStrings.arg.fromId];
    toId = Get.arguments[MyStrings.arg.toId];

    clientId = Get.arguments[MyStrings.arg.clientId];
    employeeId = Get.arguments[MyStrings.arg.employeeId];

    _getReceiverToken();

    _updateChatScreenStatus(true);

    _trackBothUserAreOnline();

    employeeClientChatCollection.where("employeeId", isEqualTo: employeeId).where("clientId", isEqualTo: clientId).get().then((value) {
      if(value.size > 0) {
        _updateReadAllMsg(value.docs.first.id);
      } else {
        employeeClientChatCollection.add({
          "clientId" : clientId,
          "employeeId" : employeeId,
          "${fromId}_unread" : 0,
          "${toId}_unread" : 0,
        }).then((result) {
          _updateReadAllMsg(result.id);
        });
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    _updateChatScreenStatus(false);
    super.onClose();
  }

  void setMassagePosition() {
    if(firstTimeScrollToBottomComplete) {

      if((scrollController.position.maxScrollExtent - scrollController.offset) < 100) {
        scrollToBottom();
      }

    } else {
      scrollToBottom();

      firstTimeScrollToBottomComplete = true;
    }
  }

  void scrollToBottom() {
    if(scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

  }

  void _updateReadAllMsg(String docId) {
    employeeClientChatDocument = employeeClientChatCollection.doc(docId);
    messageCollection = employeeClientChatDocument.collection("massages");

    employeeClientChatDocument.update({
      "${fromId}_unread" : 0
    });

    loading.value = false;

  }

  Future<void> _getReceiverToken() async {
    await apiHelper.employeeFullDetails(toId).then((response) {

      response.fold((l) {
        Logcat.msg(l.msg);
      }, (EmployeeFullDetails r) {
        receiverToken = r.details?.pushNotificationDetails?.fcmToken ?? "";
      });

    });
  }

  void _updateChatScreenStatus(bool active) {
    onChatScreenCollection.doc(fromId).set({
      "active" : active,
    });
  }

  void _trackBothUserAreOnline() {

    onChatScreenCollection.doc(toId).get().then((DocumentSnapshot<Object?> value) {
      if(value.exists) {
        onChatScreenCollection.doc(toId).snapshots().listen((DocumentSnapshot doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          isReceiverOnline.value = data["active"];
        });
      } else {
        if (kDebugMode) {
          print("user not enter in chat screen");
        }
      }
    });

  }

  Future<void> onSendTap() async {
    if(tecController.text.trim().isEmpty) return;

    Map<String, dynamic> data = {
      "fromId": fromId,
      "toId": toId,
      "text": tecController.text.trim(),
      "time": FieldValue.serverTimestamp(),
    };

    tecController.clear();
    messageCollection.add(data).then((DocumentReference<Object?> value) {
      _sendNotification(data["text"]);
    });

    scrollToBottom();
  }

  void _sendNotification(String text) {
    if(!isReceiverOnline.value) {

      employeeClientChatDocument.update({
        "${toId}_unread" : FieldValue.increment(1)
      });

      if(receiverToken.isNotEmpty) {
        SendPush.sendMsgNotification(
          deviceTokens: [receiverToken],
          title: '${appController.user.value.userName} send a massage',
          body: text,
          payload: <String, dynamic>{
            'click_action': MyStrings.payloadScreen.clientEmployeeChat,
            MyStrings.arg.receiverName: appController.user.value.userName,
            MyStrings.arg.fromId: toId,
            MyStrings.arg.toId: fromId,
            MyStrings.arg.clientId: clientId,
            MyStrings.arg.employeeId: employeeId,
          },
        );
      }
    }
  }
}
