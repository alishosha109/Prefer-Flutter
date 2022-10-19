part of 'posts_cubit.dart';

@immutable
abstract class PostsState {}

class PostsInitial extends PostsState {}

class postsLoading extends PostsState {
  final bool loading;

  postsLoading(
    this.loading,
  );
}

class postsEmpty extends PostsState {
  final List<Post> posts;

  postsEmpty(
    this.posts,
  );
}

class postsLoaded extends PostsState {
  final List<Post> posts;

  postsLoaded(
    this.posts,
  );
}

class MorePostsLoaded extends PostsState {
  final List<Post> posts;
  MorePostsLoaded(
    this.posts,
  );
}

class PostsRefresh extends PostsState {
  final List<Post> posts;
  PostsRefresh(
    this.posts,
  );
}

class mypostsLoading extends PostsState {
  final bool loading;

  mypostsLoading(
    this.loading,
  );
}

class mypostsEmpty extends PostsState {
  final List<Personal_Post> myposts;

  mypostsEmpty(
    this.myposts,
  );
}

class MypostsLoaded extends PostsState {
  final List<Personal_Post> myposts;

  MypostsLoaded(
    this.myposts,
  );
}

class MoreMyPostsLoaded extends PostsState {
  final List<Personal_Post> myposts;
  MoreMyPostsLoaded(
    this.myposts,
  );
}

class MyPostsRefresh extends PostsState {
  final List<Personal_Post> myposts;
  MyPostsRefresh(
    this.myposts,
  );
}

class historypostsLoading extends PostsState {
  final bool loading;

  historypostsLoading(
    this.loading,
  );
}

class historypostsEmpty extends PostsState {
  final List<History_Post> historyposts;

  historypostsEmpty(
    this.historyposts,
  );
}

class HistorypostsLoaded extends PostsState {
  final List<History_Post> historyposts;

  HistorypostsLoaded(
    this.historyposts,
  );
}

class MoreHistoryPostsLoaded extends PostsState {
  final List<History_Post> historyposts;
  MoreHistoryPostsLoaded(
    this.historyposts,
  );
}

class HistoryPostsRefresh extends PostsState {
  final List<History_Post> historyposts;
  HistoryPostsRefresh(
    this.historyposts,
  );
}

class percsLoaded extends PostsState {
  final List percs;
  final int index;

  percsLoaded(this.percs, this.index);
}

class reportstatus extends PostsState {
  final bool reported;
  reportstatus(
    this.reported,
  );
}

class changedstatus extends PostsState {
  final bool changed;
  final String postId;
  changedstatus(
    this.changed,
    this.postId,
  );
}

class view_photo extends PostsState {
  final bool showstat;
  final String image_url;
  view_photo(
    this.showstat,
    this.image_url,
  );
}

class photos_uploaded extends PostsState {
  final List<dynamic> urls;
  photos_uploaded(
    this.urls,
  );
}

class photos_upload_loading extends PostsState {
  final bool loading;
  photos_upload_loading(
    this.loading,
  );
}

class post_uploaded extends PostsState {
  final bool uploaded;
  post_uploaded(
    this.uploaded,
  );
}
