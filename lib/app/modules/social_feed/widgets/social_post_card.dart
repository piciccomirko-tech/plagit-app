import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import '../controllers/social_feed_controller.dart';
import '../models/social_feed_model.dart';

class SocialPostCard extends StatelessWidget {
  final SocialPost post;
  final SocialFeedController controller;

  const SocialPostCard({
    super.key,
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: MyColors.lightCard(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                _buildAvatar(),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user?.name ?? 'Unknown',
                        style: MyColors.l111111_dwhite(context).semiBold15,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          if (post.user?.positionName != null) ...[
                            Flexible(
                              child: Text(
                                post.user!.positionName!,
                                style: MyColors.c_A6A6A6.regular12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.user?.countryName != null)
                              Text(' · ', style: MyColors.c_A6A6A6.regular12),
                          ],
                          if (post.user?.countryName != null)
                            Text(
                              post.user!.countryName!,
                              style: MyColors.c_A6A6A6.regular12,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  controller.timeAgo(post.createdAt),
                  style: MyColors.c_A6A6A6.regular11,
                ),
              ],
            ),
          ),

          // Content text
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                post.content!,
                style: MyColors.l111111_dwhite(context).regular14,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Media image
          if (post.media != null && post.media!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: post.media!.first.uniformImageUrl,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200.h,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: MyColors.c_C6A34F,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200.h,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),

          // Stats bar (likes, comments, views)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                _statItem(Icons.thumb_up_outlined, post.likeCount, context),
                SizedBox(width: 20.w),
                _statItem(Icons.comment_outlined, post.commentCount, context),
                SizedBox(width: 20.w),
                _statItem(Icons.visibility_outlined, post.views ?? 0, context),
                const Spacer(),
              ],
            ),
          ),

          // Divider + action buttons
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.thumb_up_outlined, 'Like', context),
                _actionButton(Icons.comment_outlined, 'Comment', context),
                _actionButton(Icons.share_outlined, 'Share', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final url = post.user?.profilePicture;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: MyColors.c_C6A34F,
        child: CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(url.uniformImageUrl),
        ),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: MyColors.c_C6A34F,
      child: Text(
        (post.user?.name ?? 'U')[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, int count, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: MyColors.c_A6A6A6),
        SizedBox(width: 4.w),
        Text(
          _formatCount(count),
          style: MyColors.c_A6A6A6.regular12,
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: MyColors.c_A6A6A6),
      label: Text(label, style: MyColors.c_A6A6A6.regular12),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
