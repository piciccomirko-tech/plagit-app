import 'package:flip_card/flip_card.dart';
import 'package:mh/app/modules/client/client_edit_profile/controllers/client_edit_profile_controller.dart';
import '../../../../common/utils/exports.dart';

class BankCardWidgetForClient extends GetWidget<ClientEditProfileController> {
  const BankCardWidgetForClient({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:  (controller.sourceOfFunds.value).isEmpty
          ? CustomButtons.button(
          text: MyStrings.addCard.tr,
          onTap: controller.addCard,
          margin: const EdgeInsets.only(top: 100, right: 30, left: 30),
          backgroundColor: Colors.teal,
          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner)
          :Stack(
        children: [
          FlipCard(
              fill: Fill.fillBack, // Fill the back side of the card to make in the same size as the front.
              direction: FlipDirection.HORIZONTAL, // default
              side: CardSide.FRONT,
              front: _frontSide,
              back: _backSide
          ),
          Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkResponse(
                    onTap: controller.removeCard,
                    child: const Icon(Icons.clear, color: Colors.white, size: 18),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget get _frontSide => Container(
    height: 200.0,
    width: Get.width,
    
    decoration: BoxDecoration(
      
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color.fromARGB(255, 16, 42, 46), Colors.cyan], // Gradient colors
      ),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Text(
              (controller.bankCardModel.provided?.card?.nameOnCard ?? "").toUpperCase(),
              style: MyColors.white.semiBold20,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "${controller.bankCardModel.provided?.card?.fundingMethod ?? ""} CARD",
                style: MyColors.white.semiBold16,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: MyColors.white
                  ),
                  child: Text(controller.bankCardModel.provided?.card?.scheme ?? "", style: Colors.green.semiBold16))
            ],
          ),
          Center(child: Text(controller.formatString(original: controller.bankCardModel.provided?.card?.number ?? ""), style: MyColors.c_C6A34F.semiBold22)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    MyStrings.validTill.tr,
                    style: MyColors.white.semiBold16,
                  ),
                  Text(
                    '${controller.bankCardModel.provided?.card?.expiry?.month ?? ""}/${controller.bankCardModel.provided?.card?.expiry?.year ?? ""}',
                    style: MyColors.white.semiBold16,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
  Widget get _backSide => Container(
    height: 200.0,
    width: Get.width,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.pink, Colors.indigo], // Gradient colors
      ),
      borderRadius: BorderRadius.circular(10.0),
    ), // Change color or add decoration for back side
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25.h),
        Container(height: 25, color: MyColors.black),
        SizedBox(height: 10.h),
        Container(height: 25,
            width: Get.width,
            color: MyColors.white, margin: const EdgeInsets.symmetric(horizontal: 20.0), child: Text("  XXX", style: MyColors.black.semiBold16)),
        SizedBox(height: 15.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(MyStrings.thisIsYourCardNumber.tr, style: MyColors.white.medium16),
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),

          child: Text(MyStrings.customerSignature.tr, style: MyColors.white.semiBold16),
        ),

      ],
    ),
  );
}
