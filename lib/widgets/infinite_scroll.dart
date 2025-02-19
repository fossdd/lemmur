import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../hooks/ref.dart';
import 'bottom_safe.dart';

class InfiniteScrollController {
  VoidCallback clear;

  InfiniteScrollController() {
    usedBeforeCreation() => throw Exception(
        'Tried to use $runtimeType before it being initialized');

    clear = usedBeforeCreation;
  }

  void dispose() {
    clear = null;
  }
}

/// `ListView.builder` with asynchronous data fetching
class InfiniteScroll<T> extends HookWidget {
  final int batchSize;
  final Widget loadingWidget;
  final Widget Function(T data) builder;
  final Future<List<T>> Function(int page, int batchSize) fetchMore;
  final InfiniteScrollController controller;
  final Widget prepend;
  final EdgeInsetsGeometry padding;

  const InfiniteScroll({
    this.batchSize = 10,
    this.prepend = const SizedBox.shrink(),
    this.padding,
    this.loadingWidget =
        const ListTile(title: Center(child: CircularProgressIndicator())),
    @required this.builder,
    @required this.fetchMore,
    this.controller,
  })  : assert(builder != null),
        assert(fetchMore != null),
        assert(batchSize > 0);

  @override
  Widget build(BuildContext context) {
    final data = useState<List<T>>([]);
    final hasMore = useRef(true);
    final isFetching = useRef(false);

    useEffect(() {
      if (controller != null) {
        controller.clear = () {
          data.value = [];
          hasMore.current = true;
        };
        return controller.dispose;
      }

      return null;
    }, []);

    final page = data.value.length ~/ batchSize + 1;

    return RefreshIndicator(
      onRefresh: () async {
        controller.clear();
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: padding,
        // +2 for the loading widget and prepend widget
        itemCount: data.value.length + 2,
        itemBuilder: (_, i) {
          if (i == 0) {
            return prepend;
          }
          i -= 1;

          // reached the bottom, fetch more
          if (i == data.value.length) {
            // if there are no more, skip
            if (!hasMore.current) {
              return const BottomSafe();
            }

            // if it's already fetching more, skip
            if (!isFetching.current) {
              isFetching.current = true;
              fetchMore(page, batchSize).then((newData) {
                // if got less than the batchSize, mark the list as done
                if (newData.length < batchSize) {
                  hasMore.current = false;
                }
                // append new data
                data.value = [...data.value, ...newData];
              }).whenComplete(() => isFetching.current = false);
            }

            return SafeArea(
              top: false,
              child: loadingWidget,
            );
          }

          // not last element, render list item
          return builder(data.value[i]);
        },
      ),
    );
  }
}
