import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:uuid/uuid.dart';
import '../../../../common/data/data.dart';
import '../../../../common/widgets/custom_dropdown.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../controllers/employee_edit_profile_controller.dart';
import '../models/candidate_certificate_model.dart';
import 'FileThumbNailWidget.dart';
import 'PDFThumbnail.dart';

class CandidateAdditionalFormWidget
    extends GetWidget<EmployeeEditProfileController> {
  const CandidateAdditionalFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.loading.value == true
        ? Center(child: CustomLoader.loading())
        : SingleChildScrollView(
            // padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skills Section with Dropdown
                _buildDropdownForSkills(),
                SizedBox(height: 20),

                // Languages Section with Dropdown
                _buildDropdownForLanguages(),
                SizedBox(height: 20),

                //             // Dress Size and Height
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<String>(
                            style: MyColors.l111111_dwhite(context).regular17,
                            decoration: InputDecoration(
                              labelText: "Dress Size",
                              labelStyle:
                                  MyColors.lC6A34F_primaryLight(context).regular14,
                              errorText: controller
                                          .selectedDressSize.value.isNotEmpty &&
                                      !['S', 'M', 'L', 'XL', 'XXL'].contains(
                                          controller.selectedDressSize.value)
                                  ? 'Invalid dress size selected'
                                  : null,
                            ),
                            value: [
                              'S',
                              'M',
                              'L',
                              'XL',
                              'XXL'
                            ].contains(controller.selectedDressSize.value)
                                ? controller.selectedDressSize.value
                                : null, // Set to null if invalid value
                            items: ['S', 'M', 'L', 'XL', 'XXL']
                                .map((size) => DropdownMenuItem(
                                      value: size,
                                      child: Text(size),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedDressSize.value = value;
                              }
                            },
                          )),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        style: MyColors.l111111_dwhite(context).regular17,
                        controller: controller.employeeHeightController,
                        decoration: InputDecoration(
                          labelText: "Height (cm)",
                          labelStyle:
                              MyColors.lC6A34F_primaryLight(context).regular14,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Emergency Contact Number
                // TextFormField(
                //   style: MyColors.l111111_dwhite(context).regular10,
                //   controller: controller.emergencyContactController,
                //   decoration: InputDecoration(
                //     labelText: "Emergency Contact Number",
                //     labelStyle: MyColors.l111111_dwhite(context).regular10,
                //     prefixIcon: Icon(Icons.phone),
                //   ),
                //   keyboardType: TextInputType.phone,
                // ),
                // SizedBox(height: 20),

                // Higher Education
                TextFormField(
                  style: MyColors.l111111_dwhite(context).regular17,
                  controller: controller.employeeHigherEducationController,
                  decoration: InputDecoration(
                    labelText: "Higher Education",
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular14,
                    prefixIcon: Icon(Icons.school),
                  ),
                  keyboardType: TextInputType.text,
                ),

                SizedBox(height: 20),

                // Bio
                TextFormField(
                  style: MyColors.l111111_dwhite(context).regular17,
                  controller: controller.bioController,
                  decoration: InputDecoration(
                    labelText: "Bio",
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular14,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),

                // Current Organization
                TextFormField(
                  style: MyColors.l111111_dwhite(context).regular17,
                  controller: controller.organizationController,
                  decoration: InputDecoration(
                    labelText: "Current Organization",
                    labelStyle: MyColors.lC6A34F_primaryLight(context).regular14,
                  ),
                ),
                SizedBox(height: 20),
// cv section
                _buildCVSection(context),
                // Documents Section
                _buildDocumentSection(context),
              ],
            ),
          ));
  }

  Widget _buildDropdownForSkills() {
    return Obx(() => Column(
          children: [
            CustomDropdown(
              padding: EdgeInsets.all(3),
              prefixIcon: Icons.supervised_user_circle_outlined,
              hints: MyStrings.skills.tr,
              value: '', // Default value
              items: controller.skillList
                  .map((skill) => skill['skillName'] ?? '')
                  .toList(),

              onChange: (String? selectedSkillName) {
                if (selectedSkillName != null && selectedSkillName.isNotEmpty) {
                  final selectedSkill = controller.skillList.firstWhere(
                    (skill) => skill['skillName'] == selectedSkillName,
                  );
                  controller.onSkillsChange(selectedSkill['skillId']!,
                      selectedSkill['skillName'] ?? "");
                }
              },
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Wrap(
                children: List.generate(controller.selectedSkills.length,
                    (int index) {
                  var skill = controller.selectedSkills[index];
                  return Container(
                    margin: EdgeInsets.only(right: 10.w, bottom: 10.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 8.h),
                    decoration: BoxDecoration(
                        color: MyColors.c_C6A34F.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Text(skill['skillName'] ?? '',
                              style: MyColors.black.medium14),
                        ),
                        SizedBox(width: 5.w),
                        InkWell(
                          onTap: () =>
                              controller.onSkillClearClick(index: index),
                          child: const Icon(Icons.clear,
                              color: MyColors.black, size: 18),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ));
  }

  Widget _buildDropdownForLanguages() {
    return Obx(() => Column(
          children: [
            CustomDropdown(
              padding: EdgeInsets.all(3),
              prefixIcon: Icons.supervised_user_circle_outlined,
              hints: MyStrings.language.tr,
              value: '',
              items: Data.language.toList(),
              onChange: controller.onLanguageChange,
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Wrap(
                children:
                    List.generate(controller.languageList.length, (int index) {
                  String skill = controller.languageList[index];
                  return Container(
                    margin: EdgeInsets.only(right: 10.w, bottom: 10.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 8.h),
                    decoration: BoxDecoration(
                        color: MyColors.c_C6A34F.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(skill, style: MyColors.black.medium14),
                        SizedBox(width: 5.w),
                        InkWell(
                            onTap: () =>
                                controller.onLanguageClearClick(index: index),
                            child: const Icon(Icons.clear,
                                color: MyColors.black, size: 18))
                      ],
                    ),
                  );
                }),
              ),
            )
          ],
        ));
  }

// Method to select a single CV (PDF only)
void _selectCV() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: false, // Only allow single file for CV
    type: FileType.custom,
    allowedExtensions: ['pdf','jpg','png','jpeg'], // Only allow PDF files
  );

  if (result != null) {
    File cvFile = File(result.files.single.path!);
    controller.cv.value = [cvFile]; // Store the selected CV file
    controller.cvUrl.value = cvFile.path; // Set file path in controller

    // Show the progress dialog before initiating the upload
    _showProgressDialog(Get.context!,false);

    // Trigger the isolate-based upload for the CV
    bool uploadSuccess = await controller.updateEmployeeCvAndCertificates();

    // Close the progress dialog after upload completes
    //Get.back();

    if (uploadSuccess) {
      if (kDebugMode) {
        print("CV uploaded successfully.");
      }
    } else {
      if (kDebugMode) {
        print("CV upload failed.");
      }
    }
  }
}

// Method to select a single CV (PDF and Image only)
void _selectCVNew() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: false, // Only allow single file for CV
    type: FileType.custom,
    allowedExtensions: ['pdf','jpg','png','jpeg'], // Only allow PDF files
  );

  if (result != null) {
    File cvFile = File(result.files.single.path!);
    controller.cv.value = [cvFile]; // Store the selected CV file
    controller.cvUrl.value = cvFile.path; // Set file path in controller
    print(controller.cvUrl.value);
    controller.uploadEmployeeUpdate(file:cvFile);
  // Show the progress dialog before initiating the upload
  // _showProgressDialog(Get.context!,false);
  //
  // // Trigger the isolate-based upload for the CV
  // bool uploadSuccess = await controller.updateEmployeeCvAndCertificates();
  //
  // // Close the progress dialog after upload completes
  // //Get.back();
  //
  // if (uploadSuccess) {
  //   if (kDebugMode) {
  //     print("CV uploaded successfully.");
  //   }
  // } else {
  //   if (kDebugMode) {
  //     print("CV upload failed.");
  //   }
  // }
  }
}

// Method to select multiple documents (PDF, DOC, DOCX)
void _selectCertificates() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true, // Allow multiple files for documents
    type: FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx'], // Allow PDF, DOC, DOCX
  );

  if (result != null) {
    // Temporary variable to hold selected certificates for upload
    List<Certificate> certificatesToBeUploaded = [];

    for (String? path in result.paths) {
      if (path != null) {
        // Prompt the user to enter a name for the certificate
        String? certificateName = await _showCertificateNameDialog();
        if (certificateName != null && certificateName.isNotEmpty) {
          certificatesToBeUploaded.add(
            Certificate(
              certificateName: certificateName,
              attachment: path,
              certificateId: Uuid().v4(), // Unique ID for tracking
            ),
          );
        }
      }
    }

    // Add the new certificates to the main controller list only if confirmed
    if (certificatesToBeUploaded.isNotEmpty) {
      controller.certificates.addAll(certificatesToBeUploaded);

      // Show the progress dialog and initiate the upload
      _showProgressDialog(Get.context!, true);

      bool uploadSuccess = await controller.updateEmployeeCvAndCertificates();

      // Close the progress dialog after upload completes
      //Get.back();

      if (uploadSuccess) {
        if (kDebugMode) {
          print("Certificates uploaded successfully.");
        }
      } else {
        if (kDebugMode) {
          print("Certificate upload failed.");
        }
      }
    } else {
      if (kDebugMode) {
        print("No new certificates selected for upload.");
      }
    }
  }
}


// Helper function to prompt the user for a certificate name
  Future<String?> _showCertificateNameDialog() async {
    String? certificateName;
    await Get.defaultDialog(
      // backgroundColor: MyColors.primaryLight,
      title: "Enter Certificate Name",
      titleStyle: TextStyle(
          color: MyColors.primaryLight, fontFamily: MyAssets.fontKlavika),
      titlePadding: EdgeInsets.all(25),
      content: TextField(
        style: TextStyle(
            color: MyColors.primaryLight, fontFamily: MyAssets.fontKlavika),
        onChanged: (value) {
          certificateName = value;
        },
        decoration: InputDecoration(
            hintText: "Certificate Name",
            hintStyle: TextStyle(
                color: MyColors.primaryLight,
                fontFamily: MyAssets.fontKlavika)),
      ),
      textConfirm: "OK",
      textCancel: "Cancel",

      onConfirm: () {
        Get.back();
      },
    );
    return certificateName;
  }

  Future<void> _showProgressDialog(BuildContext context,bool? isCertificate) {
    // Use Get.defaultDialog for better integration with GetX and to prevent accidental dismissals
    return Get.defaultDialog(
      title: "Uploading...",
      barrierDismissible: false,
      // backgroundColor: MyColors.primaryLight,

      titleStyle: TextStyle(
          color: MyColors.primaryLight, fontFamily: MyAssets.fontKlavika),
      content: Obx(() => Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(MyColors.primaryLight),
                  value: controller.uploadPercent.value / 100,
                ),
                SizedBox(height: 15),
                Text(
                  "${isCertificate==true? 'Certificate upload progress:':'CV upload progress:'} ${controller.uploadPercent.value}%",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MyColors.primaryLight,
                      fontFamily: MyAssets.fontKlavika),
                ),
              ],
            ),
          )),
    );
  }

// Widget to build the CV upload section (single PDF)
  Widget _buildCVSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload CV (PDF, JPG, JPEG, PNG)",
            style: MyColors.lC6A34F_primaryLight(context)
                .regular11
                .copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),

        // Select File Button for CV
        GestureDetector(
          onTap: _selectCVNew, // Select a single CV file when tapped
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 15),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal),
              borderRadius: BorderRadius.circular(10),
              color: Colors.teal.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: Colors.teal,
                  size: 30.sp,
                ),
                SizedBox(height: 10),
                Text(
                  "Tap to select a PDF file for CV",
                  style: MyColors.l111111_dwhite(context)
                      .regular17
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // Text("${controller.cvUrl.value}"),
        Obx(() =>
            controller.cv.isNotEmpty && controller.cv.first.path.isNotEmpty
                ? Container(
                    child: FileThumbnailWidget(
                      fileUrl: controller.cv.first.path,
                      fileName:
                          controller.cv.first.path.split('/').last.isNotEmpty
                              ? controller.cv.first.path.split('/').last
                              : 'Unknown',
                      fileId: '',
                      onDelete: (id) async {
                        // controller.removeCv(file);
                        controller.cv.removeAt(0);
                      },
                    ),
                  )
                : controller.cvUrl.value.isNotEmpty
                    ? Container(
                        child: FileThumbnailWidget(
                          fileUrl: controller.cvUrl.value,
                          fileName:
                              controller.cvUrl.value.split('/').last.isNotEmpty
                                  ? controller.cvUrl.value.split('/').last
                                  : 'Unknown',
                          fileId: '',
                          onDelete: (id) async {
                            // controller.removeCv(id);
                            controller.cvUrl.value = '';
                          },
                        ),
                      )
                    : Container()),

        // Upload Button for CV
        SizedBox(height: 20),
        // ElevatedButton(
        //   onPressed: () {
        //     // Upload CV logic here
        //   },
        //   child: Text("Upload CV"),
        // ),
      ],
    );
  }

// Widget to build the Document upload section (multiple files)
  Widget _buildDocumentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload Certificates (PDF, DOC, DOCX)",
            style: MyColors.lC6A34F_primaryLight(context)
                .regular11
                .copyWith(fontWeight: FontWeight.bold)),

        SizedBox(height: 10.h),

        // Select File Button for Documents
        GestureDetector(
          onTap: _selectCertificates, // Select multiple documents when tapped
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 15),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal),
              borderRadius: BorderRadius.circular(10),
              color: Colors.teal.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: Colors.teal,
                  size: 30.sp,
                ),
                SizedBox(height: 10),
                Text(
                  "Tap to select file for upload",
                  style: MyColors.l111111_dwhite(context)
                      .regular17
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20),
// Text("certificate count: ${controller.certificates.length}"),
        Obx(() => Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: controller.certificates.map((certificate) {
                // Ensure certificate.attachment and other fields are non-null before accessing them
                final pdfUrl = certificate.attachment;
                final certificateName =
                    certificate.certificateName ?? 'Unknown';
                final certificateId = certificate.certificateId;

                if (pdfUrl != null) {
                  return PdfThumbnailWidget(
                    pdfUrl: pdfUrl,
                    certificateName: certificateName,
                    certificateId: certificateId ?? '',
                    isRemoveIcon:true,
                    onDelete: (id) async {
                      await controller.removeCertificate(id);
                    },
                  );
                } else {
                  // Return an empty container or placeholder widget if data is incomplete
                  return Container();
                }
              }).toList(),
            )),

        // Upload Button for Documents
        SizedBox(height: 20),
      ],
    );
  }

// Dialog to prompt the user for the certificate name
// Future<String?> _showCertificateNameDialog() async {
//   String? name;
//   await Get.defaultDialog(
//     title: "Enter Certificate Name",
//     content: Column(
//       children: [
//         TextField(
//           onChanged: (value) {
//             name = value;
//           },
//           decoration: InputDecoration(
//             labelText: "Certificate Name",
//           ),
//         ),
//       ],
//     ),
//     textConfirm: "OK",
//     textCancel: "Cancel",
//     onConfirm: () {
//       Get.back();
//     },
//     onCancel: () {
//       name = null; // Set name to null if user cancels
//     },
//   );
//   return name;
// }
}
