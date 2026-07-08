import '../models/golf_models.dart';

class MockSocialService {
  List<Friend> friends() => const <Friend>[
        Friend(id: 'f1', name: 'Avery Links', handicap: 8.4, status: 'Played 74 yesterday'),
        Friend(id: 'f2', name: 'Sam Fairway', handicap: 17.1, status: 'Needs a fourth Saturday'),
        Friend(id: 'f3', name: 'Riley Green', handicap: 3.2, status: 'Shared a new PB'),
      ];

  List<SocialPost> seedPosts() => <SocialPost>[
        SocialPost(id: 'p1', author: 'Avery Links', text: 'Windy nine but hit 7 greens. Who is in for a match play rematch?', createdAt: DateTime.now().subtract(const Duration(hours: 4)), likes: 6, comments: const <String>['Great round!', 'Count me in.']),
      ];
}
