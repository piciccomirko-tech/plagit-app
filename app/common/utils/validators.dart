import 'exports.dart';

class Validators {
  static String? emailValidator(String? email) {
    email ??= "";
    return email.isEmpty
        ? MyStrings.required
        : GetUtils.isEmail(email.trim())
            ? null
            : MyStrings.invalidEmailAddress;
  }

  // static String? dropDownValidator(String? value) {
  //   value ??= "";
  //   return emptyValidator(value, AppStrings.allStrings.dropdownItemIsRequired);
  // }

  static String? passwordValidator(String? password) {
    password ??= "";
    return password.isEmpty
        ? MyStrings.required
        : !password.contains(RegExp(r"[a-z]")) && !password.contains(RegExp(r"[A-Z]"))
            ? MyStrings.atLeast1CharNeeded
            : !password.contains(RegExp("[0-9]"))
                ? MyStrings.atLeast1DigitNeeded
                : password.length < 8
                    ? MyStrings.minimum8Char
                    : null;
  }

  static String? confirmPasswordValidator(String newPassword, String confirmPassword) {
    return newPassword.isEmpty
        ? MyStrings.enterNewPassword
        : newPassword == confirmPassword && confirmPassword.length >= 8
            ? null
            : MyStrings.newPasswordAndConfirmPasswordNotMatch;
  }

  static emptyValidator(String? value, String msg) {
    return (value ?? "").trim().isEmpty ? msg : null;
  }

  static firstNameLastNameValidator(String? value, String formatInvalidMsg, String emptyMsg) {
    return emptyValidator(value, emptyMsg) == null ? (RegExp(r'^[A-Za-z. ]+$').hasMatch((value ?? "").trim())) ? null : formatInvalidMsg : emptyMsg;
  }

  // static String? termsAndConditionValidator(bool isAcceptedCondition) {
  //   return isAcceptedCondition
  //       ? null
  //       :  AppStrings.allStrings.mustBeAcceptedOurTermsAndCondition;
  // }
  //
  // static String? onlyLetterNumberAndUnderScoreValidation(String? value) {
  //   value ??= "";
  //   return value.isEmpty
  //       ? AppStrings.allStrings.roleTypeIsRequired
  //       : value.contains(RegExp(r"[!@#<>?:`~$;/'[\]\\|=+)(*&^%0-9]"))
  //           ? AppStrings.allStrings.roleTypeValidationText
  //           : null;
  // }
}
