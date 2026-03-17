class AssignedRoutine {
  final String id;
  final String trainerId;
  final String alumnoId;
  final String rutinaId;
  final DateTime fechaAsignacion;

  AssignedRoutine({
    required this.id,
    required this.trainerId,
    required this.alumnoId,
    required this.rutinaId,
    required this.fechaAsignacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'alumnoId': alumnoId,
      'rutinaId': rutinaId,
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
    };
  }

  factory AssignedRoutine.fromJson(Map<String, dynamic> json) {
    return AssignedRoutine(
      id: json['id'],
      trainerId: json['trainerId'],
      alumnoId: json['alumnoId'],
      rutinaId: json['rutinaId'],
      fechaAsignacion: DateTime.parse(json['fechaAsignacion']),
    );
  }
}