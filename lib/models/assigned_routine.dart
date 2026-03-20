class AssignedRoutine {
  final String id;
  final String trainerId;
  final String trainerName;
  final String alumnoId;
  final String alumnoName;
  final String rutinaId;
  final DateTime fechaAsignacion;
  final bool sharedByAlumno;

  AssignedRoutine({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.alumnoId,
    required this.alumnoName,
    required this.rutinaId,
    required this.fechaAsignacion,
    this.sharedByAlumno = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'alumnoId': alumnoId,
      'alumnoName': alumnoName,
      'rutinaId': rutinaId,
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
      'sharedByAlumno': sharedByAlumno,
    };
  }

  factory AssignedRoutine.fromJson(Map<String, dynamic> json) {
    return AssignedRoutine(
      id: json['id'],
      trainerId: json['trainerId'],
      trainerName: json['trainerName'] ?? '',
      alumnoId: json['alumnoId'],
      alumnoName: json['alumnoName'] ?? '',
      rutinaId: json['rutinaId'],
      fechaAsignacion: DateTime.parse(json['fechaAsignacion']),
      sharedByAlumno: json['sharedByAlumno'] ?? false,
    );
  }
}
