import 'package:fit/classes/coaches_program.dart';

final List<CoachesProgram> programs = [
    CoachesProgram(
      title: 'Hybrid Performance',
      description: 'Build muscle and endurance simultaneously. 12-week block focusing on compound lifts and zone 2 cardio.',
      duration: '12 Weeks',
      level: 'Intermediate',
      price: 150,
      isBestSeller: true,
    ),
    CoachesProgram(
      title: 'Pure Strength 5x5',
      description: 'The classic strength builder. Focus on Squat, Bench, and Deadlift mastery.',
      duration: '8 Weeks',
      level: 'Beginner',
      price: 120,
      isBestSeller: false,
    ),
  ];
  
  final List<Review> reviews = [
    Review(
      initials: 'DK',
      name: 'David K.',
      program: 'Hybrid Performance',
      timeAgo: '2 days ago',
      rating: 5.0,
      text: '"Michael\'s programming is intense but incredibly effective. Added 30lbs to my deadlift in 8 weeks. Highly recommended for anyone stuck at a plateau."',
    ),
    Review(
      initials: 'JM',
      name: 'Jessica M.',
      program: 'Fat Loss & Nutrition',
      timeAgo: '1 week ago',
      rating: 5.0,
      text: '"The nutrition guidance changed everything for me. Finally seeing abs! The weekly check-ins kept me accountable when I wanted to quit."',
    ),
  ];
  
  final List<Transformation> transformations = [
    Transformation(
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=400&auto=format&fit=crop',
      label: 'Alex: -15kg Fat',
    ),
    Transformation(
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=400&auto=format&fit=crop',
      label: 'Sarah: +20kg Squat',
    ),
  ];
  
  final List<String> certifications = [
    'NSCA-CSCS',
    'NASM-CPT',
    'Precision Nutrition L1',
  ];