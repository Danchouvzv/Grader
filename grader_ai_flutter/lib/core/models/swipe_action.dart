enum SwipeAction {
  like('like'),
  dislike('dislike'),
  superlike('superlike');

  const SwipeAction(this.value);
  final String value;

  static SwipeAction fromString(String value) {
    return SwipeAction.values.firstWhere(
      (action) => action.value == value,
      orElse: () => SwipeAction.like,
    );
  }
}
