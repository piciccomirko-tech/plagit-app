import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/all_admins.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/employee_full_details.dart';
import '../../../../repository/api_helper.dart';
import '../../../../repository/send_push.dart';

class SupportChatController extends GetxController {
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  late String receiverName;

  late String fromId;
  late String toId; // toId == allAdmin means client/employee send massage to admin

  late String docId;

  CollectionReference onChatScreenCollection = FirebaseFirestore.instance.collection('onChatScreen');
  CollectionReference supportChatCollection = FirebaseFirestore.instance.collection("support_chat");
  late DocumentReference supportChatDocument;
  late CollectionReference massageCollection;

  RxBool loading = true.obs;

  // client/employee is online or offline
  RxBool isReceiverOnline = false.obs;
  String receiverToken = "";
  String receiverRole = "";

  RxList<String> adminsOffline = <String>[].obs;
  RxList<String> adminsOnline = <String>[].obs;

  RxList massages = [].obs;

  TextEditingController tecController = TextEditingController();
  late ScrollController scrollController;

  Rx<AllAdmins> allAdmins = AllAdmins().obs;

  bool firstTimeScrollToBottomComplete = false;

  @override
  Future<void> onInit() async {
    scrollController = ScrollController();

    receiverName = Get.arguments[MyStrings.arg.receiverName];

    fromId = Get.arguments[MyStrings.arg.fromId];
    toId = Get.arguments[MyStrings.arg.toId];

    docId = Get.arguments[MyStrings.arg.supportChatDocId];

    _updateChatScreenStatus(true);

    supportChatDocument = supportChatCollection.doc(docId);
    massageCollection = supportChatDocument.collection("massages");

    // admin send massage to client/employee
    if (toId == "allAdmin") {
      await _getAllAdmins();
    } else {
      await _getReceiverToken();
    }

    await supportChatDocument.get().then((value) {
      if (!value.exists) {
        supportChatCollection.doc(docId).set({
          "allAdmin_unread": 0,
          "${docId}_unread": 0,
          "role": toId == "allAdmin" ? appController.user.value.userRole : receiverRole
        });
      }
    });

    _trackSenderAndReceiversOnline();

    _updateReadAllMsg();

    super.onInit();
  }

  @override
  void onClose() {
    _updateChatScreenStatus(false);
    super.onClose();
  }

  void setMassagePosition() {
    if (firstTimeScrollToBottomComplete) {
      if ((scrollController.position.maxScrollExtent - scrollController.offset) < 100) {
        scrollToBottom();
      }
    } else {
      scrollToBottom();

      firstTimeScrollToBottomComplete = true;
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _getAllAdmins() async {
    await _apiHelper.getAllAdmins().then((response) {
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _getAllAdmins);
      }, (AllAdmins allAdmins) {
        this.allAdmins.value = allAdmins;
        this.allAdmins.refresh();
      });
    });
  }

  void _trackSenderAndReceiversOnline() {
    // client/employee send msg to admin
    if (toId == "allAdmin") {
      onChatScreenCollection.snapshots().listen((QuerySnapshot<Object?> event) {
        adminsOffline.clear();
        adminsOnline.clear();
        for (Users admin in allAdmins.value.users ?? []) {
          for (var element in event.docs) {
            Map<String, dynamic> data = element.data() as Map<String, dynamic>;

            if (admin.sId == element.id) {
              if (data["active"]) {
                adminsOnline.add(admin.sId!);
              } else {
                adminsOffline.add(admin.sId!);
              }
            }
          }
        }
      });
    }
    // admin send msg to client/employee
    else {
      onChatScreenCollection.doc(toId).get().then((value) {
        if (value.exists) {
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
  }

  Future<void> _getReceiverToken() async {
    await _apiHelper.employeeFullDetails(toId).then((response) {
      response.fold((l) {
        Logcat.msg(l.msg);
      }, (EmployeeFullDetails r) {
        receiverToken = r.details?.pushNotificationDetails?.fcmToken ?? "";
        receiverRole = r.details?.role ?? "";
      });
    });
  }

  void _updateChatScreenStatus(bool active) {
    onChatScreenCollection.doc(fromId).set({
      "active": active,
    });
  }

  void _updateReadAllMsg() {
    // client/employee logged in
    if (toId == "allAdmin") {
      supportChatDocument.update({"${fromId}_unread": 0});
    }
    // admin logged in
    else {
      supportChatDocument.update({"allAdmin_unread": 0});
    }

    loading.value = false;
  }

  Future<void> onSendTap() async {
    if (tecController.text.trim().isEmpty) return;

    Map<String, dynamic> data = {
      "fromId": fromId,
      "toId": toId,
      "text": tecController.text.trim(),
      "senderName": appController.user.value.userName,
      "time": FieldValue.serverTimestamp(),
    };

    tecController.clear();

    massageCollection.add(data).then((value) {
      _sendNotification(data["text"]);
    });

    scrollToBottom();
  }

  void _sendNotification(String text) {
    // client/employee logged in
    if (toId == "allAdmin") {
      if (adminsOnline.isEmpty) {
        supportChatDocument.update({"allAdmin_unread": FieldValue.increment(1)});
      }

      List<String> adminTokens = [];

      for (Users admin in allAdmins.value.users ?? []) {
        if (adminsOffline.contains(admin.sId)) {
          if ((admin.pushNotificationDetails?.fcmToken ?? "").isNotEmpty) {
            adminTokens.add(admin.pushNotificationDetails!.fcmToken!);
          }
        }
      }

      if (adminTokens.isNotEmpty) {
        SendPush.sendMsgNotification(
          deviceTokens: adminTokens,
          title: '${appController.user.value.userName} send a massage',
          body: text,
          payload: <String, dynamic>{
            'click_action': MyStrings.payloadScreen.supportChat,
            MyStrings.arg.receiverName: appController.user.value.userName,
            MyStrings.arg.fromId: "allAdmin",
            MyStrings.arg.toId: fromId,
            MyStrings.arg.supportChatDocId: docId,
          },
        );
      }
    }
    // admin logged in
    else {
      if (!isReceiverOnline.value) {
        supportChatDocument.update({"${toId}_unread": FieldValue.increment(1)});

        if (receiverToken.isNotEmpty) {
          SendPush.sendMsgNotification(
            deviceTokens: [receiverToken],
            title: 'New massage from MH support',
            body: text,
            payload: <String, dynamic>{
              'click_action': MyStrings.payloadScreen.supportChat,
              MyStrings.arg.receiverName: "Support",
              MyStrings.arg.fromId: toId,
              MyStrings.arg.toId: "allAdmin",
              MyStrings.arg.supportChatDocId: docId,
            },
          );
        }
      }
    }
  }
}
