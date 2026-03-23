
import '../../../../common/utils/exports.dart';
import '../controllers/common_job_posts_cntroller.dart';
import '../widgets/common_job_posts_widget.dart';

class CommonJobPostsView extends GetView<CommonJobPostsController> {
  final String? clientId;
  final bool? isMyJobPost;
  final bool? isSocketCall;
  final String? clientName;
  final String userType;

  const CommonJobPostsView({
    super.key,
    this.clientId,
    this.isSocketCall,
    this.isMyJobPost,
    this.clientName,
  required  this.userType,
  });
  @override
  Widget build(BuildContext context) {
    // Initialize the controller with parameters if necessary
    Get.put(
        CommonJobPostsController(clientId: clientId, isMyJobPost: isMyJobPost, isSocketCall: isSocketCall, userType: userType, clientName: clientName));
    return const CommonJobPostsWidget();
  }
}
