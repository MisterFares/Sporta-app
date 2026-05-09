import 'package:fit/classes/community/posts.dart';

final List<Post> posts = [
  Post(
    id: '1',
    authorName: 'Michael Jenkins',
    authorAvatar: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=100&auto=format&fit=crop',
    authorRole: 'Coach',
    timeAgo: '2 hours ago',
    content: 'Weekly Challenge: Focus on the eccentric phase (lowering) of your squats this week. 3 seconds down, explode up. This builds control and connective tissue strength. Who\'s in?',
    likes: 142,
    comments: 24,
    reposts: 10,
    isLiked: false,
    isReposted: false,
    isCoachPost: true,
    imageUrl: null,
    imageBytes: null,  // Add this
    imagePath: null,   // Add this
  ),
  Post(
    id: '2',
    authorName: 'Sarah Williams',
    authorAvatar: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=100&auto=format&fit=crop',
    authorRole: 'Trainee',
    timeAgo: '5 hours ago',
    content: 'Finally hit a new PR on deadlifts today! 100kg for 3 reps. The 12-week power program is really paying off. 💪',
    likes: 56,
    comments: 8,
    reposts: 5,
    isLiked: false,
    isReposted: false,
    isCoachPost: false,
    imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=800&auto=format&fit=crop',
    imageBytes: null,  // Add this
    imagePath: null,   // Add this
  ),
  Post(
    id: '3',
    authorName: 'David Chen',
    authorAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=100&auto=format&fit=crop',
    authorRole: 'Trainee',
    timeAgo: '1 day ago',
    content: 'Quick question for the nutrition group: What\'s your go-to pre-workout meal for early morning sessions? I\'m struggling with energy levels around 6 AM.',
    likes: 12,
    comments: 15,
    reposts: 3,
    isLiked: false,
    isReposted: false,
    isCoachPost: false,
    imageUrl: null,
    imageBytes: null,  // Add this
    imagePath: null,   // Add this
  ),
];