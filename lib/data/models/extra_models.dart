class DailyFactModel {
  final String id;
  final String publishDate;
  final String title;
  final String factDescription;
  final String tag;
  final String iconName;

  const DailyFactModel({
    required this.id,
    required this.publishDate,
    required this.title,
    required this.factDescription,
    required this.tag,
    this.iconName = 'science',
  });

  factory DailyFactModel.fromJson(Map<String, dynamic> json) {
    return DailyFactModel(
      id: json['id']?.toString() ?? '',
      publishDate: json['publish_date']?.toString() ?? '',
      title: json['title'] ?? '',
      factDescription: json['fact_description'] ?? '',
      tag: json['tag'] ?? 'Kimia Populer',
      iconName: json['icon_name'] ?? 'science',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'publish_date': publishDate,
        'title': title,
        'fact_description': factDescription,
        'tag': tag,
        'icon_name': iconName,
      };
}

class WeeklyMysteryModel {
  final String id;
  final String title;
  final String storyContent;
  final String imageUrl;
  final int coinCost;
  final String weekDate;

  const WeeklyMysteryModel({
    required this.id,
    required this.title,
    required this.storyContent,
    this.imageUrl = '',
    this.coinCost = 50,
    required this.weekDate,
  });

  factory WeeklyMysteryModel.fromJson(Map<String, dynamic> json) {
    return WeeklyMysteryModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      storyContent: json['story_content'] ?? '',
      imageUrl: json['image_url'] ?? '',
      coinCost: json['coin_cost'] is int
          ? json['coin_cost']
          : int.tryParse(json['coin_cost']?.toString() ?? '50') ?? 50,
      weekDate: json['week_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'story_content': storyContent,
        'image_url': imageUrl,
        'coin_cost': coinCost,
        'week_date': weekDate,
      };
}

class UserProfileModel {
  final String name;
  final int grade;
  final String avatarId;
  final String? customPhotoPath;

  const UserProfileModel({
    required this.name,
    required this.grade,
    required this.avatarId,
    this.customPhotoPath,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? 'Siswa Kimia',
      grade: json['grade'] is int
          ? json['grade']
          : int.tryParse(json['grade']?.toString() ?? '10') ?? 10,
      avatarId: json['avatar_id'] ?? 'dr_erlenmeyer',
      customPhotoPath: json['custom_photo_path'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'grade': grade,
        'avatar_id': avatarId,
        'custom_photo_path': customPhotoPath,
      };

  UserProfileModel copyWith({
    String? name,
    int? grade,
    String? avatarId,
    String? customPhotoPath,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      grade: grade ?? this.grade,
      avatarId: avatarId ?? this.avatarId,
      customPhotoPath: customPhotoPath ?? this.customPhotoPath,
    );
  }
}
