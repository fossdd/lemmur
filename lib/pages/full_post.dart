import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/v2.dart';

import '../hooks/logged_in_action.dart';
import '../hooks/refreshable.dart';
import '../hooks/stores.dart';
import '../util/more_icon.dart';
import '../widgets/comment_section.dart';
import '../widgets/post.dart';
import '../widgets/save_post_button.dart';
import '../widgets/write_comment.dart';

/// Displays a post with its comment section
class FullPostPage extends HookWidget {
  final int id;
  final String instanceHost;
  final PostView post;

  const FullPostPage({@required this.id, @required this.instanceHost})
      : assert(id != null),
        assert(instanceHost != null),
        post = null;
  FullPostPage.fromPostView(this.post)
      : id = post.post.id,
        instanceHost = post.instanceHost;

  @override
  Widget build(BuildContext context) {
    final accStore = useAccountsStore();
    final fullPostRefreshable =
        useRefreshable(() => LemmyApiV2(instanceHost).run(GetPost(
              id: id,
              auth: accStore.defaultTokenFor(instanceHost)?.raw,
            )));
    final loggedInAction = useLoggedInAction(instanceHost);
    final newComments = useState(const <CommentView>[]);

    // FALLBACK VIEW
    if (!fullPostRefreshable.snapshot.hasData && this.post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (fullPostRefreshable.snapshot.hasError)
                Text(fullPostRefreshable.snapshot.error.toString())
              else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    // VARIABLES

    final post = fullPostRefreshable.snapshot.hasData
        ? fullPostRefreshable.snapshot.data.postView
        : this.post;

    final fullPost = fullPostRefreshable.snapshot.data;

    // FUNCTIONS

    refresh() async {
      await HapticFeedback.mediumImpact();

      try {
        await fullPostRefreshable.refresh();
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }

    sharePost() => Share.text('Share post', post.post.apId, 'text/plain');

    comment() async {
      final newComment = await showCupertinoModalPopup<CommentView>(
        context: context,
        builder: (_) => WriteComment.toPost(post),
      );
      if (newComment != null) {
        newComments.value = [...newComments.value, newComment];
      }
    }

    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          actions: [
            IconButton(icon: const Icon(Icons.share), onPressed: sharePost),
            SavePostButton(post),
            IconButton(
                icon: Icon(moreIcon),
                onPressed: () => PostWidget.showMoreMenu(context, post)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: loggedInAction((_) => comment()),
            child: const Icon(Icons.comment)),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              PostWidget(post, fullPost: true),
              if (fullPostRefreshable.snapshot.hasData)
                CommentSection(
                    newComments.value.followedBy(fullPost.comments).toList(),
                    postCreatorId: fullPost.postView.creator.id)
              else if (fullPostRefreshable.snapshot.hasError)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  child: Column(
                    children: [
                      const Icon(Icons.error),
                      Text('Error: ${fullPostRefreshable.snapshot.error}')
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ));
  }
}
