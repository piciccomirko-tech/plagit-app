import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/models/alter_user_response_model.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../models/alter_user.dart';

class ClientAccessControlController extends GetxController {
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find<AppController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers for User Input
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables
  var myAlterUsers = <AlterUser>[].obs;
  var isLoading = true.obs;
  var isAdding = false.obs;

  @override
  void onInit() {
    fetchAlterUsers();
    super.onInit();
  }

  void fetchAlterUsers() async {
    isLoading.value = true;
    final response = await _apiHelper.getAlterUsers();
    isLoading.value = false;

    response.fold((CustomError error) {
      Utils.showSnackBar(message: error.msg, isTrue: false);
    }, (List<AlterUser> users) {
      myAlterUsers.assignAll(users);
    });
  }

  Future<void> addOrUpdateUser({index}) async {
    if (formKey.currentState!.validate()) {
      Get.back();
      Map<String, dynamic> userData = {
        "user": appController.user.value.client?.id ?? '',
        "alterUsers": []
      };
      if(index==null) {
        userData["alterUsers"].insert(0, {
          "name": nameController.value.text.trim(),
          "email": emailController.value.text,
          "password": passwordController.value.text
        });
        if (myAlterUsers.isNotEmpty && myAlterUsers.length < 2) {
          userData["alterUsers"].insert(0, {
            "name": myAlterUsers[0].name ?? "",
            "email": myAlterUsers[0].email ?? "",
            "password": myAlterUsers[0].plainPassword ?? "",
          });
        }
      }else{
        myAlterUsers[index] = AlterUser(
          name: nameController.value.text.trim(),
          email: emailController.value.text,
          password: passwordController.value.text,
        );
        userData["alterUsers"]=myAlterUsers;
      }
      bool isEmailExists = myAlterUsers.any((user) => user.email == emailController.value.text && myAlterUsers.indexOf(user) != index);

      if (isEmailExists) {
        Utils.showSnackBar(message: 'Email already exists!',isTrue: false);
      } else {
      CustomLoader.show(Get.context!);
      isAdding(true);
      await _apiHelper
          .createAlternateUser(userData)
          .then((Either<CustomError, AlterUserResponseModel> response) {
        CustomLoader.hide(Get.context!);
        isAdding(false);
        response.fold((CustomError customError) {
          CustomDialogue.information(
            context: Get.context!,
            title: 'Error',
            description:
            customError.msg,
          );
        }, (AlterUserResponseModel response) async {
          if (response.statusCode == 200) {
            cleanModal();
            fetchAlterUsers();
            Utils.showSnackBar(message: "User Updated Successfully", isTrue: true);
          }
          else {

            CustomDialogue.information(
              context: Get.context!,
              title: 'Error',
              description:
              response.message ?? "",
            );
          }
        });
      });
      }
    }
  }

  void deleteUser( index) async {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: "${MyStrings.confirm.tr}?",
      msg: "${MyStrings.sureWantTo.tr} ${MyStrings.delete.tr} ${MyStrings.all.tr} ?",
      confirmButtonText: "Yes Delete",
      onConfirm: () async {
        Get.back();
        Map<String, dynamic> userData = {
          "user": appController.user.value.client?.id ?? '',
          "alterUsers": []
        };
        myAlterUsers.removeAt(index);
        if (kDebugMode) {
          print(myAlterUsers.toString());
        }
        userData['alterUsers']=myAlterUsers;
        if (kDebugMode) {
          print(userData);
        }

        CustomLoader.show(Get.context!);
        isAdding(true);
        await _apiHelper
            .createAlternateUser(userData)
            .then((Either<CustomError, AlterUserResponseModel> response) {
          CustomLoader.hide(Get.context!);
          isAdding(false);
          response.fold((CustomError customError) {
            CustomDialogue.information(
              context: Get.context!,
              title: 'Error',
              description:
              customError.msg,
            );
          }, (AlterUserResponseModel response) async {
            if (response.statusCode == 200) {
              cleanModal();
              fetchAlterUsers();
              Utils.showSnackBar(message: "User Deleted Successfully", isTrue: true);
            }
            else {

              CustomDialogue.information(
                context: Get.context!,
                title: 'Error',
                description:
                response.message ?? "",
              );
            }
          });
        });
      },
    );
  }

  void cleanModal() {
    nameController.text='';
    emailController.text='';
    passwordController.text='';
  }
}