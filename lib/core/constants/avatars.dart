// WHAT THIS FILE DOES:
// Provides a curated list of 30 avatars with league requirements, names, and genders.

enum AvatarGender { male, female }

class AvatarModel {
  final String id;
  final String name;
  final String url;
  final AvatarGender gender;
  final String requiredLeague;
  final String style;

  const AvatarModel({
    required this.id,
    required this.name,
    required this.url,
    required this.gender,
    required this.requiredLeague,
    this.style = 'Casual',
  });
}

class AppAvatars {
  AppAvatars._();

  static const List<AvatarModel> avatars = [
    // --- BRONZE (Starting) ---
    AvatarModel(
      id: 'bronze_m1',
      name: 'Felix',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
      gender: AvatarGender.male,
      requiredLeague: 'Bronze',
      style: 'Casual',
    ),
    AvatarModel(
      id: 'bronze_f1',
      name: 'Aneka',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
      gender: AvatarGender.female,
      requiredLeague: 'Bronze',
      style: 'Casual',
    ),
    AvatarModel(
      id: 'bronze_m2',
      name: 'Buddy',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Buddy',
      gender: AvatarGender.male,
      requiredLeague: 'Bronze',
      style: 'Sporty',
    ),
    AvatarModel(
      id: 'bronze_f2',
      name: 'Kiki',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Kiki',
      gender: AvatarGender.female,
      requiredLeague: 'Bronze',
      style: 'Gamer',
    ),
    AvatarModel(
      id: 'bronze_m3',
      name: 'Max',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Max',
      gender: AvatarGender.male,
      requiredLeague: 'Bronze',
      style: 'Professional',
    ),
    AvatarModel(
      id: 'bronze_f3',
      name: 'Cookie',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Cookie',
      gender: AvatarGender.female,
      requiredLeague: 'Bronze',
      style: 'Casual',
    ),

    // --- SILVER ---
    AvatarModel(
      id: 'silver_m1',
      name: 'Jasper',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Jasper',
      gender: AvatarGender.male,
      requiredLeague: 'Silver',
      style: 'Gamer',
    ),
    AvatarModel(
      id: 'silver_f1',
      name: 'Luna',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Luna',
      gender: AvatarGender.female,
      requiredLeague: 'Silver',
      style: 'Fantasy',
    ),
    AvatarModel(
      id: 'silver_m2',
      name: 'Toby',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Toby',
      gender: AvatarGender.male,
      requiredLeague: 'Silver',
      style: 'Sporty',
    ),
    AvatarModel(
      id: 'silver_f2',
      name: 'Nala',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Nala',
      gender: AvatarGender.female,
      requiredLeague: 'Silver',
      style: 'Professional',
    ),
    AvatarModel(
      id: 'silver_m3',
      name: 'Oliver',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Oliver',
      gender: AvatarGender.male,
      requiredLeague: 'Silver',
      style: 'Casual',
    ),
    AvatarModel(
      id: 'silver_f3',
      name: 'Zoe',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Zoe',
      gender: AvatarGender.female,
      requiredLeague: 'Silver',
      style: 'Gamer',
    ),

    // --- GOLD ---
    AvatarModel(
      id: 'gold_m1',
      name: 'Simba',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Simba',
      gender: AvatarGender.male,
      requiredLeague: 'Gold',
      style: 'Fantasy',
    ),
    AvatarModel(
      id: 'gold_f1',
      name: 'Peanut',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Peanut',
      gender: AvatarGender.female,
      requiredLeague: 'Gold',
      style: 'Sporty',
    ),
    AvatarModel(
      id: 'gold_m2',
      name: 'Milo',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Milo',
      gender: AvatarGender.male,
      requiredLeague: 'Gold',
      style: 'Professional',
    ),
    AvatarModel(
      id: 'gold_f2',
      name: 'Daisy',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Daisy',
      gender: AvatarGender.female,
      requiredLeague: 'Gold',
      style: 'Casual',
    ),
    AvatarModel(
      id: 'gold_m3',
      name: 'Oscar',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Oscar',
      gender: AvatarGender.male,
      requiredLeague: 'Gold',
      style: 'Gamer',
    ),
    AvatarModel(
      id: 'gold_f3',
      name: 'Bella',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Bella',
      gender: AvatarGender.female,
      requiredLeague: 'Gold',
      style: 'Professional',
    ),

    // --- PLATINUM ---
    AvatarModel(
      id: 'plat_m1',
      name: 'Harley',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Harley',
      gender: AvatarGender.male,
      requiredLeague: 'Platinum',
      style: 'Gamer',
    ),
    AvatarModel(
      id: 'plat_f1',
      name: 'Ginger',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Ginger',
      gender: AvatarGender.female,
      requiredLeague: 'Platinum',
      style: 'Fantasy',
    ),
    AvatarModel(
      id: 'plat_m2',
      name: 'Bruno',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Bruno',
      gender: AvatarGender.male,
      requiredLeague: 'Platinum',
      style: 'Sporty',
    ),
    AvatarModel(
      id: 'plat_f2',
      name: 'Penny',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Penny',
      gender: AvatarGender.female,
      requiredLeague: 'Platinum',
      style: 'Professional',
    ),
    AvatarModel(
      id: 'plat_m3',
      name: 'Rex',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Rex',
      gender: AvatarGender.male,
      requiredLeague: 'Platinum',
      style: 'Fantasy',
    ),
    AvatarModel(
      id: 'plat_f3',
      name: 'Ruby',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Ruby',
      gender: AvatarGender.female,
      requiredLeague: 'Platinum',
      style: 'Gamer',
    ),

    // --- DIAMOND ---
    AvatarModel(
      id: 'diamond_m1',
      name: 'Apollo',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Apollo',
      gender: AvatarGender.male,
      requiredLeague: 'Diamond',
      style: 'Fantasy',
    ),
    AvatarModel(
      id: 'diamond_f1',
      name: 'Athena',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Athena',
      gender: AvatarGender.female,
      requiredLeague: 'Diamond',
      style: 'Fantasy',
    ),
    AvatarModel(
      id: 'diamond_m2',
      name: 'Zeus',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Zeus',
      gender: AvatarGender.male,
      requiredLeague: 'Diamond',
      style: 'Professional',
    ),
    AvatarModel(
      id: 'diamond_f2',
      name: 'Hera',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Hera',
      gender: AvatarGender.female,
      requiredLeague: 'Diamond',
      style: 'Professional',
    ),
    AvatarModel(
      id: 'diamond_m3',
      name: 'Thor',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Thor',
      gender: AvatarGender.male,
      requiredLeague: 'Diamond',
      style: 'Fantasy',
    ),
    AvatarModel(
      id: 'diamond_f3',
      name: 'Freya',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Freya',
      gender: AvatarGender.female,
      requiredLeague: 'Diamond',
      style: 'Fantasy',
    ),
  ];
}
