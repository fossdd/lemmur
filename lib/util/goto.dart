import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/community.dart';
import '../pages/full_post.dart';
import '../pages/instance.dart';
import '../pages/media_view.dart';
import '../pages/user.dart';

/// Pushes onto the navigator stack the given widget
Future<dynamic> goTo(
  BuildContext context,
  Widget Function(BuildContext context) builder,
) =>
    Navigator.of(context).push(CupertinoPageRoute(
      builder: builder,
    ));

/// Replaces the top of the navigator stack with the given widget
Future<dynamic> goToReplace(
  BuildContext context,
  Widget Function(BuildContext context) builder,
) =>
    Navigator.of(context).pushReplacement(CupertinoPageRoute(
      builder: builder,
    ));

void goToInstance(BuildContext context, String instanceHost) =>
    goTo(context, (context) => InstancePage(instanceHost: instanceHost));

// ignore: camel_case_types
abstract class goToCommunity {
  /// Navigates to `CommunityPage`
  static void byId(
          BuildContext context, String instanceHost, int communityId) =>
      goTo(
        context,
        (context) => CommunityPage.fromId(
            instanceHost: instanceHost, communityId: communityId),
      );

  static void byName(
          BuildContext context, String instanceHost, String communityName) =>
      goTo(
        context,
        (context) => CommunityPage.fromName(
            instanceHost: instanceHost, communityName: communityName),
      );
}

// ignore: camel_case_types
abstract class goToUser {
  static void byId(BuildContext context, String instanceHost, int userId) =>
      goTo(context,
          (context) => UserPage(instanceHost: instanceHost, userId: userId));

  static void byName(
          BuildContext context, String instanceHost, String userName) =>
      throw UnimplementedError('need to create UserProfile constructor first');
}

void goToPost(BuildContext context, String instanceHost, int postId) => goTo(
    context, (context) => FullPostPage(instanceHost: instanceHost, id: postId));

void goToMedia(BuildContext context, String url) => Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MediaViewPage(url),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
