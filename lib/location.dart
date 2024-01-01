import 'package:flutter/cupertino.dart';

class Location{
  final String city;
  final String country;

  Location({this.city = "", this.country = ""});

  factory Location.fromString(String location) => Location(
    city: location.split(",")[0],
    country: location.split(", ")[1]
  );

  factory Location.fromList(List location) => Location(
      city: location[0],
      country: location[1]
  );

  bool isValid(){
    return (city != "" && country != "");
  }

}