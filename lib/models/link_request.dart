class LinkRequest {
  final String id;
  final String trainerId;
  final String trainerName;
  final String alumnoId;
  final String alumnoName;
  final String status; // accepted, pending, rejected

  LinkRequest({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.alumnoId,
    required this.alumnoName,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'alumnoId': alumnoId,
      'alumnoName': alumnoName,
      'status': status,
    };
  }

  factory LinkRequest.fromJson(Map<String, dynamic> json) {
    return LinkRequest(
      id: json['id'],
      trainerId: json['trainerId'],
      trainerName: json['trainerName'],
      alumnoId: json['alumnoId'],
      alumnoName: json['alumnoName'],
      status: json['status'],
    );
  }
}