import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/client_self_profile/controllers/client_self_profile_controller.dart';

class BankCardWidget extends GetWidget<ClientSelfProfileController> {
  const BankCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (controller.employee.value.details?.sourceOfFunds ?? "").isEmpty
          ? CustomButtons.button(
              text: 'Add Card',
              onTap: controller.addCard,
              margin: const EdgeInsets.only(top: 100, right: 30, left: 30),
              backgroundColor: Colors.teal,
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner)
          : Stack(
              children: [
                Container(
                  height: 200.0,
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CARD NUMBER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          controller.bankCardModel.provided?.card?.number ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CARDHOLDER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  controller.bankCardModel.provided?.card?.nameOnCard ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'EXPIRES',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  '${controller.bankCardModel.provided?.card?.expiry?.month ?? ""}/${controller.bankCardModel.provided?.card?.expiry?.year ?? ""}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                    child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: InkResponse(
                      onTap: controller.removeCard,
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.clear, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ))
              ],
            ),
    );
  }
}
