import '../models/golf_models.dart';

class CourseStore {
  List<GolfCourse> loadSeedCourses() => <GolfCourse>[
        GolfCourse(
          id: 'dale',
          name: 'Dale Golf Course',
          city: 'Lerwick, Shetland',
          tees: const <String>['White', 'Yellow', 'Red', 'GPS-only'],
          holes: List<Hole>.generate(18, (int i) {
            final int n = i + 1;
            final List<int> pars = <int>[4, 3, 4, 5, 4, 3, 4, 4, 4, 4, 5, 3, 4, 4, 3, 5, 4, 4];
            final List<int> yards = <int>[356, 162, 382, 487, 331, 146, 397, 344, 368, 372, 505, 155, 402, 348, 171, 492, 385, 361];
            return Hole(number: n, par: pars[i], yards: yards[i], handicap: (i * 2 % 18) + 1, teeLat: 60.167 + (i * .001), teeLng: -1.206 + (i * .001), greenLat: 60.168 + (i * .001), greenLng: -1.204 + (i * .001));
          }),
        ),
      ];

  List<Club> defaultClubs() => const <Club>[
        Club(id: 'driver', name: 'Driver', category: 'Wood', averageYards: 235),
        Club(id: '3w', name: '3 Wood', category: 'Wood', averageYards: 215),
        Club(id: '5i', name: '5 iron', category: 'Iron', averageYards: 175),
        Club(id: '7i', name: '7 iron', category: 'Iron', averageYards: 150),
        Club(id: 'pw', name: 'Pitching wedge', category: 'Wedge', averageYards: 115),
        Club(id: 'sw', name: 'Sand wedge', category: 'Wedge', averageYards: 85),
        Club(id: 'putter', name: 'Putter', category: 'Putter', averageYards: 8),
      ];
}
