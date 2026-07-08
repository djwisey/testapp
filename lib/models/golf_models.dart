import 'dart:convert';

import 'package:flutter/foundation.dart';

enum ScoringMode { strokePlay, matchPlay, stableford, gpsOnly }
enum RoundStatus { setup, inProgress, completed }

String enumName(Object value) => value.toString().split('.').last;

@immutable
class UserProfile {
  const UserProfile({required this.id, required this.name, required this.homeCourse, required this.handicapIndex, required this.favoriteClub});
  final String id;
  final String name;
  final String homeCourse;
  final double handicapIndex;
  final String favoriteClub;
  factory UserProfile.defaultProfile() => const UserProfile(id: 'local-player', name: 'Local Golfer', homeCourse: 'Dale Golf Course', handicapIndex: 14.2, favoriteClub: '7 iron');
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'homeCourse': homeCourse, 'handicapIndex': handicapIndex, 'favoriteClub': favoriteClub};
  factory UserProfile.fromJson(Map<dynamic, dynamic> json) => UserProfile(id: '${json['id']}', name: '${json['name']}', homeCourse: '${json['homeCourse']}', handicapIndex: (json['handicapIndex'] as num?)?.toDouble() ?? 18, favoriteClub: '${json['favoriteClub'] ?? '7 iron'}');
}

@immutable
class Club {
  const Club({required this.id, required this.name, required this.category, required this.averageYards});
  final String id;
  final String name;
  final String category;
  final int averageYards;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'category': category, 'averageYards': averageYards};
  factory Club.fromJson(Map<dynamic, dynamic> json) => Club(id: '${json['id']}', name: '${json['name']}', category: '${json['category']}', averageYards: (json['averageYards'] as num?)?.round() ?? 0);
}

@immutable
class Hole {
  const Hole({required this.number, required this.par, required this.yards, required this.handicap, required this.teeLat, required this.teeLng, required this.greenLat, required this.greenLng});
  final int number;
  final int par;
  final int yards;
  final int handicap;
  final double teeLat;
  final double teeLng;
  final double greenLat;
  final double greenLng;
  Map<String, dynamic> toJson() => {'number': number, 'par': par, 'yards': yards, 'handicap': handicap, 'teeLat': teeLat, 'teeLng': teeLng, 'greenLat': greenLat, 'greenLng': greenLng};
  factory Hole.fromJson(Map<dynamic, dynamic> json) => Hole(number: (json['number'] as num).round(), par: (json['par'] as num).round(), yards: (json['yards'] as num).round(), handicap: (json['handicap'] as num).round(), teeLat: (json['teeLat'] as num).toDouble(), teeLng: (json['teeLng'] as num).toDouble(), greenLat: (json['greenLat'] as num).toDouble(), greenLng: (json['greenLng'] as num).toDouble());
}

@immutable
class GolfCourse {
  const GolfCourse({required this.id, required this.name, required this.city, required this.tees, required this.holes});
  final String id;
  final String name;
  final String city;
  final List<String> tees;
  final List<Hole> holes;
  int get par => holes.fold(0, (int total, Hole h) => total + h.par);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'city': city, 'tees': tees, 'holes': holes.map((Hole h) => h.toJson()).toList()};
  factory GolfCourse.fromJson(Map<dynamic, dynamic> json) => GolfCourse(id: '${json['id']}', name: '${json['name']}', city: '${json['city']}', tees: List<String>.from(json['tees'] as List? ?? const []), holes: (json['holes'] as List? ?? const []).map((dynamic h) => Hole.fromJson(h as Map)).toList());
}

@immutable
class Shot {
  const Shot({required this.id, required this.holeNumber, required this.clubId, required this.clubName, required this.latitude, required this.longitude, required this.distanceYards, required this.lie, required this.result, required this.timestamp});
  final String id; final int holeNumber; final String clubId; final String clubName; final double latitude; final double longitude; final int distanceYards; final String lie; final String result; final DateTime timestamp;
  Map<String, dynamic> toJson() => {'id': id, 'holeNumber': holeNumber, 'clubId': clubId, 'clubName': clubName, 'latitude': latitude, 'longitude': longitude, 'distanceYards': distanceYards, 'lie': lie, 'result': result, 'timestamp': timestamp.toIso8601String()};
  factory Shot.fromJson(Map<dynamic, dynamic> json) => Shot(id: '${json['id']}', holeNumber: (json['holeNumber'] as num).round(), clubId: '${json['clubId']}', clubName: '${json['clubName']}', latitude: (json['latitude'] as num).toDouble(), longitude: (json['longitude'] as num).toDouble(), distanceYards: (json['distanceYards'] as num?)?.round() ?? 0, lie: '${json['lie']}', result: '${json['result']}', timestamp: DateTime.tryParse('${json['timestamp']}') ?? DateTime.now());
}

@immutable
class HoleScore {
  const HoleScore({required this.holeNumber, this.strokes = 0, this.putts = 0, this.penalties = 0, this.fairwayHit = false, this.greenInRegulation = false, this.sandSave = false, this.upAndDown = false, this.matchResult = 'AS'});
  final int holeNumber; final int strokes; final int putts; final int penalties; final bool fairwayHit; final bool greenInRegulation; final bool sandSave; final bool upAndDown; final String matchResult;
  HoleScore copyWith({int? strokes, int? putts, int? penalties, bool? fairwayHit, bool? greenInRegulation, bool? sandSave, bool? upAndDown, String? matchResult}) => HoleScore(holeNumber: holeNumber, strokes: strokes ?? this.strokes, putts: putts ?? this.putts, penalties: penalties ?? this.penalties, fairwayHit: fairwayHit ?? this.fairwayHit, greenInRegulation: greenInRegulation ?? this.greenInRegulation, sandSave: sandSave ?? this.sandSave, upAndDown: upAndDown ?? this.upAndDown, matchResult: matchResult ?? this.matchResult);
  Map<String, dynamic> toJson() => {'holeNumber': holeNumber, 'strokes': strokes, 'putts': putts, 'penalties': penalties, 'fairwayHit': fairwayHit, 'greenInRegulation': greenInRegulation, 'sandSave': sandSave, 'upAndDown': upAndDown, 'matchResult': matchResult};
  factory HoleScore.fromJson(Map<dynamic, dynamic> json) => HoleScore(holeNumber: (json['holeNumber'] as num).round(), strokes: (json['strokes'] as num?)?.round() ?? 0, putts: (json['putts'] as num?)?.round() ?? 0, penalties: (json['penalties'] as num?)?.round() ?? 0, fairwayHit: json['fairwayHit'] == true, greenInRegulation: json['greenInRegulation'] == true, sandSave: json['sandSave'] == true, upAndDown: json['upAndDown'] == true, matchResult: '${json['matchResult'] ?? 'AS'}');
}

@immutable
class GolfRound {
  const GolfRound({required this.id, required this.courseId, required this.courseName, required this.tee, required this.scoringMode, required this.isGroupRound, required this.createdAt, this.completedAt, required this.status, required this.scores, required this.shots, this.shareCode});
  final String id; final String courseId; final String courseName; final String tee; final ScoringMode scoringMode; final bool isGroupRound; final DateTime createdAt; final DateTime? completedAt; final RoundStatus status; final List<HoleScore> scores; final List<Shot> shots; final String? shareCode;
  int get totalStrokes => scores.fold(0, (int total, HoleScore s) => total + s.strokes);
  int get totalPutts => scores.fold(0, (int total, HoleScore s) => total + s.putts);
  int get totalPenalties => scores.fold(0, (int total, HoleScore s) => total + s.penalties);
  GolfRound copyWith({RoundStatus? status, List<HoleScore>? scores, List<Shot>? shots, DateTime? completedAt}) => GolfRound(id: id, courseId: courseId, courseName: courseName, tee: tee, scoringMode: scoringMode, isGroupRound: isGroupRound, createdAt: createdAt, completedAt: completedAt ?? this.completedAt, status: status ?? this.status, scores: scores ?? this.scores, shots: shots ?? this.shots, shareCode: shareCode);
  Map<String, dynamic> toJson() => {'id': id, 'courseId': courseId, 'courseName': courseName, 'tee': tee, 'scoringMode': enumName(scoringMode), 'isGroupRound': isGroupRound, 'createdAt': createdAt.toIso8601String(), 'completedAt': completedAt?.toIso8601String(), 'status': enumName(status), 'scores': scores.map((HoleScore s) => s.toJson()).toList(), 'shots': shots.map((Shot s) => s.toJson()).toList(), 'shareCode': shareCode};
  factory GolfRound.fromJson(Map<dynamic, dynamic> json) => GolfRound(id: '${json['id']}', courseId: '${json['courseId']}', courseName: '${json['courseName']}', tee: '${json['tee']}', scoringMode: ScoringMode.values.firstWhere((ScoringMode m) => enumName(m) == json['scoringMode'], orElse: () => ScoringMode.strokePlay), isGroupRound: json['isGroupRound'] == true, createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(), completedAt: json['completedAt'] == null ? null : DateTime.tryParse('${json['completedAt']}'), status: RoundStatus.values.firstWhere((RoundStatus s) => enumName(s) == json['status'], orElse: () => RoundStatus.inProgress), scores: (json['scores'] as List? ?? const []).map((dynamic s) => HoleScore.fromJson(s as Map)).toList(), shots: (json['shots'] as List? ?? const []).map((dynamic s) => Shot.fromJson(s as Map)).toList(), shareCode: json['shareCode'] as String?);
  String encodeShare() => base64Url.encode(utf8.encode(jsonEncode(toJson())));
}

@immutable
class Friend { const Friend({required this.id, required this.name, required this.handicap, required this.status}); final String id; final String name; final double handicap; final String status; }
@immutable
class SocialPost { const SocialPost({required this.id, required this.author, required this.text, required this.createdAt, required this.likes, required this.comments}); final String id; final String author; final String text; final DateTime createdAt; final int likes; final List<String> comments; }
