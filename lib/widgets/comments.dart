import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lemmy_api_client/lemmy_api_client.dart';

import '../comment.dart';
import 'comment_tree.dart';

/// Manages comments section, sorts them
class Comments extends HookWidget {
  final List<CommentView> rawComments;
  final List<CommentTree> comments;
  final int postCreatorId;

  Comments(this.rawComments, {@required this.postCreatorId})
      : comments = CommentTree.fromList(rawComments),
        assert(postCreatorId != null);

  @override
  Widget build(BuildContext context) {
    var sorting = useState(SortType.active);
    return Column(children: [
      // sorting menu goes here
      if (comments.isEmpty)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: Text(
            'no comments yet',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      for (var com in comments) Comment(com, postCreatorId: postCreatorId),
    ]);
  }
}
