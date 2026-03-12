import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../controllers/client_request_for_employee_controller.dart';

class ClientRequestForEmployeeView extends GetView<ClientRequestForEmployeeController> {
  const ClientRequestForEmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "Request Employee",
        context: context,
      ),
      bottomNavigationBar: CustomBottomBar(
        child: CustomButtons.button(
          onTap: controller.onRequestPressed,
          text: "Request",
          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        itemCount: controller.appController.allActivePositions.length,
        itemBuilder: (context, index) {
          return _positionItem(index);
        },
      ),
    );
  }

  Widget _positionItem(int index) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Obx(
                () => Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                        color: controller.selectedEmployee[index] > 0
                            ? Colors.green
                            : Colors.grey.withOpacity(.2),
                        border: Border.all(
                      color: Colors.grey.withOpacity(.3),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),
                  Text(
                    controller.appController.allActivePositions[index].name!,
                    style: MyColors.l111111_dwhite(controller.context!).regular14,
                  ),
                  const Spacer(),

              SizedBox(
                height: 40,
                width: 80,
                child: DropdownButtonFormField<int>(
                  dropdownColor: MyColors.lightCard(controller.context!),
                      value: controller.selectedEmployee[index],
                      icon: const Icon(Icons.arrow_drop_down),
                      isDense: true,
                      style: MyColors.l111111_dwhite(controller.context!).regular14,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: .5, color: MyColors.c_777777),
                          borderRadius: BorderRadius.circular(10.73),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 1, color: MyColors.c_C6A34F),
                          borderRadius: BorderRadius.circular(10.73),
                          gapPadding: 10,
                        ),
                      ),
                      onChanged: (int? newValue) {
                        controller.onDropdownChange(newValue!, index);
                      },
                      items: controller.dropdownValues.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString(),style: MyColors.l111111_dwhite(controller.context!).regular16_5,),
                        );
                      }).toList(),
                    ),
              ),

                ],
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey.withOpacity(.3),
        )
      ],
    ),
  );
}
