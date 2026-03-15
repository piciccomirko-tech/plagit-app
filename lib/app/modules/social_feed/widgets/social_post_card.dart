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
    final liked = controller.isLikedByMe(post);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header with "..." menu
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 8.h),
            child: Row(
              children: [
                _buildAvatar(),
                SizedBox(width: 10.w),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          post.user?.name ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '  \u00B7  ${controller.timeAgo(post.createdAt)}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: Colors.grey.shade600, size: 22),
                  onSelected: (value) {
                    if (value == 'delete' && post.id != null) {
                      controller.deletePost(post.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),

          // Content text
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Text(
                post.content!,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.4),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Media image
          if (post.media != null && post.media!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: CachedNetworkImage(
                imageUrl: post.media!.first.uniformImageUrl,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200.h,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: CircularProgressIndicator(color: MyColors.c_C6A34F, strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200.h,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

          // Stats + actions bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              children: [
                Divider(height: 1, color: Colors.grey.shade200),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    // Like
                    InkWell(
                      onTap: () {
                        if (post.id != null) controller.likeUnlike(post.id!);
                      },
                      child: Row(
                        children: [
                          Icon(
                            liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 18,
                            color: liked ? MyColors.c_C6A34F : Colors.grey.shade500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatCount(post.likeCount),
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24.w),
                    // Comment
                    InkWell(
                      onTap: () => _showCommentDialog(context),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 18, color: MyColors.c_C6A34F),
                          SizedBox(width: 4.w),
                          Text(
                            _formatCount(post.commentCount),
                            style: TextStyle(fontSize: 13.sp, color: MyColors.c_C6A34F),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24.w),
                    // Share
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(Icons.ios_share_outlined, size: 18, color: Colors.grey.shade500),
                          SizedBox(width: 4.w),
                          Text(
                            'Share',
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Comment', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            TextField(
              controller: textController,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = textController.text.trim();
                  if (text.isNotEmpty && post.id != null) {
                    Navigator.pop(ctx);
                    controller.addComment(post.id!, text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.c_C6A34F,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('Post Comment', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = post.user?.profilePicture;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: CachedNetworkImageProvider(url.uniformImageUrl),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: MyColors.c_C6A34F,
      child: Text(
        (post.user?.name ?? 'U')[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
