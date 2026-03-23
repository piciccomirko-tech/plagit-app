import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/foundation.dart';
import 'package:mh/app/common/utils/exports.dart';

class DialogFlowController extends GetxController {
  late DialogFlowtter dialogFlowtter;
  late final TextEditingController controller;
  late final ScrollController scrollController;
  final isLoading = false.obs;
  final isResponding = true.obs;

  final messages = <Map<String, dynamic>>[].obs;
  BuildContext? context;

  @override
  void onInit() {
    controller = TextEditingController();
    scrollController = ScrollController();
    initializeDialogFlowtter();
    super.onInit();
  }

  Future<void> initializeDialogFlowtter() async {
    try {
      isLoading.value = true;

      dialogFlowtter = await DialogFlowtter.fromFile();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing DialogFlowtter: $e');
      }
      showDialog(
        context: context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Initialization Error'),
            content: const Text('Failed to initialize DialogFlowtter.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle initialization error gracefully
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    controller.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) {
      if (kDebugMode) {
        print('Message is empty');
      }
    } else {
      isResponding(true);
      addMessage(Message(text: DialogText(text: [text])), true);
      await Future.delayed(Duration(milliseconds: 500));
      addMessage(Message(text: DialogText(text: ['Typing...'])), false);

      try {
        final response = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)),
        );
        isResponding(false);
        if (response.message != null) {
          messages.removeLast();
          addMessage(response.message!);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error sending message to DialogFlowtter: $e');
        }
        showDialog(
          context: context!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to send message to DialogFlowtter.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle error gracefully
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({'message': message, 'isUserMessage': isUserMessage});
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void disableSendButton(bool bool) {
    isResponding.value=bool;
  }
}
