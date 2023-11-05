class Time {
  final List data;

  Time({
    required this.data,
  });

  factory Time.fromJson(Map<String, dynamic> json) => Time(
    data: json['data']
  );

}