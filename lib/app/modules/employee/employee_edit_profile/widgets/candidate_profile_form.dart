
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../common/data/data.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/utils/validators.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../controllers/employee_edit_profile_controller.dart';
import 'candidate_profile_picture_widget.dart';

class CandidateProfileFormWidget
    extends GetWidget<EmployeeEditProfileController> {
  const CandidateProfileFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.loading.value == true
        ? Center(child: CustomLoader.loading())
        : SingleChildScrollView(
            child: Column(
              children: [
                CandidateProfileImageUploadWidget(),
                SizedBox(
                  height: 20.h,
                ),
                // First Name and Last Name
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.tecFirstName,
                        style: MyColors.l111111_dwhite(context).regular17,
                        decoration: InputDecoration(
                          labelText: "First Name",
                          labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (String? value) =>
                            Validators.emptyValidator(
                          controller.tecFirstName.text,
                          MyStrings.required.tr,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.tecLastName,
                        style: MyColors.l111111_dwhite(context).regular17,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (String? value) =>
                            Validators.emptyValidator(
                          controller.tecLastName.text,
                          MyStrings.required.tr,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
            
                // Date of Birth and Gender
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.tecDob,
                        style: MyColors.l111111_dwhite(context).regular17,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: "Date of Birth",
                          labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField(
                        style: MyColors.l111111_dwhite(context).regular17,
                        decoration: InputDecoration(
                          labelText: "Gender",
                          labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        value: controller.selectedGender.value,
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (gender) {
                          controller.selectedGender.value=gender??'Male';
                          // setState(() {
                          //   gender = value as String;
                          // });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
            
                // Hourly Rate and Experience
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: MyColors.l111111_dwhite(context).regular17,
                        controller: controller.hourlyRate,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Per Hour Rate",
                          labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                          prefixIcon: Icon(Icons.h_mobiledata_sharp),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        style: MyColors.l111111_dwhite(context).regular17,
                        controller: controller.employeeExperience,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Experience (Years)",
                          labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                          prefixIcon: Icon(Icons.timeline),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
            
                // Position
            
                DropdownButtonFormField<String>(
                  style: MyColors.l111111_dwhite(context).regular17,
                  decoration: InputDecoration(
                    labelText: "Position",
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                    prefixIcon: Icon(Icons.business_center),
                  ),
                  // value: controller.position.value, // The currently selected value
                  value: controller.getNameByIdFromActivePositions(controller.positionObj['id']?.value ?? ''),
                  items: controller.appController.allActivePositions
                      .map((position) => DropdownMenuItem(
                            value: position.name,
                            child: Text(position.name!),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Find the selected position's id based on the name
                      var selectedPosition = controller
                          .appController.allActivePositions
                          .firstWhere(
                              (position) => position.name == newValue);
            
                      // Update both the name and id in positionObj
                      controller.positionObj['name']?.value = newValue;
                      controller.positionObj['id']?.value =
                          selectedPosition.id!;
                    }
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a position';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
            
                // Location and Postcode
                TextFormField(
                  style: MyColors.l111111_dwhite(context).regular17,
                  controller: controller.tecLocation,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                        onTap: () => controller.onClientAddressPressed(
                            module: 'employeeEditProfile'),
                        child: Icon(Icons.pin_drop,
                            color: MyColors.primaryLight)),
                    labelText: "Location",
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                    prefixIcon: Icon(
                      Icons.location_on,
                    ),
                  ),
                ),
                SizedBox(height: 16),
            
                TextFormField(
                  controller: controller.tecPostCode,
                  keyboardType: TextInputType.text,
                  style: MyColors.l111111_dwhite(context).regular17,
                  decoration: InputDecoration(
                    labelText: "Post Code",
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                    prefixIcon: Icon(Icons.mail),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Country",
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                    prefixIcon: Icon(
                        Icons.flag), // Use the same icon style as Nationality
                  ),
                  dropdownColor: MyColors.lightCard(context),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  isExpanded: true,
                  isDense: true, // Makes the dropdown compact
                  value: controller.selectedCountry
                      .value, // Bind this to the selected country
                  items: Data.getAllCountry
                      .map((country) => DropdownMenuItem(
                            value: country.name,
                            child: Text(
                              country.name,
                              style: MyColors.l111111_dwhite(context)
                                  .regular14, // Keep the same text style
                            ),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    controller.selectedCountry.value =
                        newValue!; // Update the controller's selected country value
                        log("selecetd country: ${ controller.selectedCountry.value}");
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a country';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.w),
                // TextFormField(
                //   style: MyColors.l111111_dwhite(context).regular10,
                //   controller: controller.tecNationality,
                //   keyboardType: TextInputType.number,
                //   decoration: InputDecoration(
                //     labelText: "Nationality",
                //     prefixIcon: Icon(Icons.flag),
                //   ),
                // ),
                // Dropdown for Nationality Selection
                Obx(() {
                  // Ensure that the nationalities list is not empty before rendering the dropdown
                  if (controller.nationalities.isEmpty) {
                    return CircularProgressIndicator(); // Show loading indicator or any placeholder
                  }
            
                  // Fetch the current selected nationality value
                  String? selectedNationality =
                      controller.tecNationality.text.isNotEmpty
                          ? controller.tecNationality.text
                          : null;
            
                  // Ensure that the selected nationality is one of the available options
                  bool isValidSelection = controller.nationalities.any(
                      (nationality) =>
                          nationality.nationality == selectedNationality);
            
                  return DropdownButtonFormField<String>(
                    style: MyColors.l111111_dwhite(context).regular17,
                    decoration: InputDecoration(
                      labelText: "Nationality",
                      labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                      prefixIcon: Icon(Icons.flag),
                    ),
                    // If the selected value is valid, use it; otherwise, set to null
                    value: isValidSelection ? selectedNationality : null,
                    items: controller.nationalities.map((nationality) {
                      return DropdownMenuItem<String>(
                        value: nationality
                            .nationality, // Assuming NationalityDetailsModel has a 'nationality' field
                        child: Text(nationality.nationality!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller.tecNationality.text = value ?? '';
                    },
                    isExpanded:
                        true, // Optional: allows the dropdown to expand fully
                  );
                }),
            
                SizedBox(height: 15.w),
                IntlPhoneField(
                  // initialValue: controller.tecPhoneNumber.text+'rahat',
                  style: MyColors.l111111_dwhite(context).regular17,
                  controller: controller.tecPhoneNumber,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(),
                    ),
                  ),
                  dropdownTextStyle:
                      MyColors.l111111_dwhite(context).regular17,
                  initialCountryCode: controller.initialCountryCode.value,
                  onCountryChanged: (country) {
                    controller.initialCountryCode.value = country.code;
                    controller.initialDialCode.value = "+${country.dialCode}";
                    if (kDebugMode) {
                      print(" country dialcode=> +${country.dialCode}");
                    }
                  },
                ),
            
                TextFormField(
                  style: MyColors.l111111_dwhite(context).regular17,
                  controller: controller.tecEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular17,
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 15.w)
              ],
            ),
          ));
  }

  // // Date Picker
  // Future<void> _selectDate(BuildContext context) async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null) {
  //     // Format the picked date to DD/MM/YYYY
  //     String formattedDate = DateFormat('dd/MM/yyyy').format(picked);

  //     // Set the formatted date to the text field
  //     controller.tecDob.text = formattedDate;
  //   }
  // }
  Future<void> _selectDate(BuildContext context) async {
  // Parse the existing dateOfBirth from the ISO 8601 format
  DateTime initialDate = DateTime.now();
  if (controller.tecDob.text.isNotEmpty) {
    try {
      initialDate = DateTime.parse(controller.tecDob.text);
    } catch (e) {
      // Handle parsing error if necessary
      initialDate = DateTime.now();
    }
  }

  // Show the date picker
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    // Format the picked date to DD/MM/YYYY
    String formattedDate = DateFormat('dd/MM/yyyy').format(picked);

    // Convert picked date back to ISO 8601 format and update the TextEditingController
    String isoDate = picked.toIso8601String();

    // Set the formatted date to the text field (for display)
    controller.tecDob.text = formattedDate;

    // Optionally, store the ISO string in another variable if needed
    controller.formattedDateOfBirth = isoDate;
  }
}
}
