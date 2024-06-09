String buildDateTimeString(String remoteTime) {
  print("Converting Time: $remoteTime");
  DateTime now = DateTime.now();
  //
  List<String> timeParts = remoteTime.split(':');
  int hours = int.parse(timeParts[0]);
  int minutes = int.parse(timeParts[1]);
  int seconds = int.parse(timeParts[2]);
  //
  DateTime fullDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    hours,
    minutes,
    seconds,
    now.millisecond,
    now.microsecond,
  );
  //
  String formattedDateTime = fullDateTime.toIso8601String();
  return formattedDateTime;
}