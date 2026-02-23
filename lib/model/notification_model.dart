class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String notificationtype;
  final String isreaded;
  final String createdat;
  final String userid;

  NotificationModel(
      {required this.id,
      required this.title,
      required this.message,
      required this.notificationtype,
      required this.isreaded,
      required this.createdat,
      required this.userid});
}
