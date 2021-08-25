// import 'dart:html';

// import 'package:enum_to_string/camel_case_to_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram/cubits/cubits.dart';
import 'package:flutter_instagram/screens/feed/bloc/feed_bloc.dart';
import 'package:flutter_instagram/widgets/widgets.dart';

class FeedScreen extends StatefulWidget {
  static const String routeName = '/feed';

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent &&
            !_scrollController.position.outOfRange &&
            context.read<FeedBloc>().state.status != FeedStatus.paginating) {
          context.read<FeedBloc>().add(FeedPaginatePosts());
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.status == FeedStatus.error) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(content: state.failure.message),
          );
        } else if (state.status == FeedStatus.paginating) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 1),
              content: const Text('Fetching More Posts...'),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.photo_camera,
                  color: Colors.blueAccent[700],
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: 'L ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.red)),
                      TextSpan(
                          text: 'I ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.yellow)),
                      TextSpan(
                          text: '0 ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.green)),
                      TextSpan(
                          text: 'I ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.green.shade200)),
                      TextSpan(
                          text: 'L',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.blue)),
                    ],
                  ),
                ),
                Icon(
                  Icons.message,
                  color: Colors.blueAccent[700],
                )
              ],
            ),
            centerTitle: true,
            actions: [
              if (state.posts.isEmpty && state.status == FeedStatus.loaded)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<FeedBloc>().add(FeedFetchPosts()),
                )
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(FeedState state) {
    switch (state.status) {
      case FeedStatus.loading:
        return const Center(child: CircularProgressIndicator());
      default:
        return RefreshIndicator(
          onRefresh: () async {
            context.read<FeedBloc>().add(FeedFetchPosts());
            context.read<LikedPostsCubit>().clearAllLikedPosts();
            return true;
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.posts.length,
            itemBuilder: (BuildContext context, int index) {
              final post = state.posts[index];
              final likedPostsState = context.watch<LikedPostsCubit>().state;
              final isLiked = likedPostsState.likedPostIds.contains(post.id);
              final recentlyLiked =
                  likedPostsState.recentlyLikedPostIds.contains(post.id);
              return Dismissible(
                key: new Key(index.toString()),
                onDismissed: (direction) {
                  state.posts.remove(index);
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      duration: const Duration(seconds: 1),
                      content: Center(child: const Text('Hidden Posts !!!')),
                    ),
                  );
                },
                child: PostView(
                  post: post,
                  isLiked: isLiked,
                  recentlyLiked: recentlyLiked,
                  onLike: () {
                    if (isLiked) {
                      context.read<LikedPostsCubit>().unlikePost(post: post);
                    } else {
                      context.read<LikedPostsCubit>().likePost(post: post);
                    }
                  },
                ),
              );
            },
          ),
        );
    }
  }
}