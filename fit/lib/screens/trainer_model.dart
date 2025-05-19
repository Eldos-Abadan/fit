class Trainer {
  final String name;
  final String contactNumber;
  final String email;
  final String imageUrl;
  final List<String> availableDays;
  final Map<String, String> workingHours;

  Trainer({
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.imageUrl,
    required this.availableDays,
    required this.workingHours,
  });
}
