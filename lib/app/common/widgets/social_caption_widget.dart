import 'package:flutter/gestures.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialCaptionWidget extends StatefulWidget {
  final String text;
  final Color? textColor;
  const SocialCaptionWidget({super.key, required this.text, this.textColor});

  @override
  SocialCaptionWidgetState createState() => SocialCaptionWidgetState();
}

class SocialCaptionWidgetState extends State<SocialCaptionWidget> {
  bool isExpanded = false; // To track if content is expanded

  @override
  Widget build(BuildContext context) {
    final RegExp urlRegExp = RegExp(
      r'(http|https)://\S+',
      caseSensitive: false,
    );

    // Split the text into segments of normal text and URLs
    final List<TextSpan> textSpans = [];
    final Iterable<RegExpMatch> matches = urlRegExp.allMatches(widget.text);
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add normal text before the match
      if (match.start > lastMatchEnd) {
        textSpans.add(TextSpan(
          text: widget.text.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontFamily: MyAssets.fontMontserrat,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: widget.textColor ?? MyColors.l111111_dwhite(context),
          ),
        ));
      }

      // Add the matched URL as a clickable text span
      final url = match.group(0);
      if (url != null) {
        textSpans.add(TextSpan(
          text: url,
          style: TextStyle(
            fontFamily: MyAssets.fontMontserrat,
            fontSize: Get.width > 600 ? 13.sp : 15.sp,
            color: Colors.blue,
            fontWeight: FontWeight.w400,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              try {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                Utils.showSnackBar(message: "$e", isTrue: false);
              }
            },
        ));
      }

      lastMatchEnd = match.end;
    }

    // Add any remaining text after the last match
    if (lastMatchEnd < widget.text.length) {
      textSpans.add(TextSpan(
        text: widget.text.substring(lastMatchEnd),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: widget.textColor ?? MyColors.l111111_dwhite(context),
          // color: Color(0xFF1C1C1E), // Dark gray (caption text)
          fontFamily: MyAssets.fontMontserrat,
        ),
        // style: TextStyle(
        //   fontFamily: MyAssets.fontKlavika,
        //   fontSize: 15,
        //   fontWeight: FontWeight.w300,
        //   color: MyColors.l111111_dwhite(context),
        // ),
      ));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Create a TextPainter to measure the rendered text
        final textPainter = TextPainter(
          text: TextSpan(children: textSpans),
          maxLines: 2, // Max lines to check if it's overflowing
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        // Check if the text exceeds the 4 lines
        final isOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(children: textSpans),
              maxLines:
                  isExpanded ? 100 : 2, // Toggle between 4 lines and full text
              overflow: TextOverflow.ellipsis,
              strutStyle: StrutStyle(
                  fontFamily: MyAssets.fontMontserrat,
                  fontWeight: FontWeight.normal),
              // Show ellipsis if text overflows
            ),
            if (isOverflowing ||
                isExpanded) // Show button only if text is overflowing or expanded
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded; // Toggle expanded/collapsed state
                  });
                },
                child: Text(
                  isExpanded
                      ? MyStrings.showLess.tr
                      : MyStrings.showMore.tr, // Toggle button text
                  style: TextStyle(
                    fontFamily: MyAssets.fontMontserrat,
                    fontSize: 12,
                    color: MyColors.primaryLight,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
