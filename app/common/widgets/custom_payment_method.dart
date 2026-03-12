import '../../enums/selected_payment_method.dart';
import '../utils/exports.dart';

class CustomPaymentMethod extends StatefulWidget {
  final List<SelectedPaymentMethod> availablePaymentMethods;
  final Function(SelectedPaymentMethod selectedPaymentMethod) onChange;

  const CustomPaymentMethod({
    super.key,
    required this.availablePaymentMethods,
    required this.onChange,
  });

  @override
  State<CustomPaymentMethod> createState() => _CustomPaymentMethodState();
}

class _CustomPaymentMethodState extends State<CustomPaymentMethod> {

  SelectedPaymentMethod selectedPaymentMethod = SelectedPaymentMethod.card;

  @override
  void initState() {

    if(widget.availablePaymentMethods.isNotEmpty) {
      if(!widget.availablePaymentMethods.contains(selectedPaymentMethod)) {
        selectedPaymentMethod = widget.availablePaymentMethods.first;
      }

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _updateOnChange();
      });
    }


    super.initState();
  }

  void _onChange(SelectedPaymentMethod paymentMethod) {
    if(selectedPaymentMethod != paymentMethod) {
      selectedPaymentMethod = paymentMethod;
      _updateOnChange();
    }

  }

  void _updateOnChange() {
    setState(() {
      widget.onChange(selectedPaymentMethod);
    });
  }


  @override
  Widget build(BuildContext context) {

    if(widget.availablePaymentMethods.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 23.w),
      padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 20.h),
      decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            width: .5,
            color: MyColors.c_A6A6A6,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Options",
            style: MyColors.l111111_dwhite(context).semiBold18,
          ),
          SizedBox(
            height: 15.h,
          ),
          Column(
            children: [
              _paymentMethodItem(
                method: SelectedPaymentMethod.card,
                name: "Card",
                selectedImage: MyAssets.paymentMethod.visaSelect,
                unselectedImage: MyAssets.paymentMethod.visaUnSelect,
                valid: widget.availablePaymentMethods.contains(SelectedPaymentMethod.card)
              ),

              const SizedBox(height: 10),

              _paymentMethodItem(
                method: SelectedPaymentMethod.bank,
                name: "Bank",
                selectedImage: MyAssets.paymentMethod.bankSelect,
                unselectedImage: MyAssets.paymentMethod.bankUnSelect,
                valid: widget.availablePaymentMethods.contains(SelectedPaymentMethod.bank)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodItem({
    required SelectedPaymentMethod method,
    required String name,
    required String selectedImage,
    required String unselectedImage,
    required bool valid,
  }) {
    return Visibility(
      visible: valid,
      child: GestureDetector(
        onTap: () {
          _onChange(method);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: method == selectedPaymentMethod ? 1 : .3,
              color:  method == selectedPaymentMethod
                  ? MyColors.c_C6A34F
                  : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Container(
                width: 15,
                height: 15,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: method == selectedPaymentMethod
                        ? MyColors.c_C6A34F
                        : Colors.grey,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: method == selectedPaymentMethod
                        ? MyColors.c_C6A34F
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Text(
                name,
                style: MyColors.l111111_dffffff(context).semiBold14,
              ),
              const Spacer(),

              Image.asset(
                valid
                    ? method == selectedPaymentMethod
                        ? selectedImage
                        : unselectedImage
                    : unselectedImage,
                width: 30.w,
                height: 30.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
