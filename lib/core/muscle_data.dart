class MuscleData {
  static const Map<String, List<String>> equipment = {
    'Pecho': ['Barra', 'Mancuernas', 'Cables', 'Máquina', 'Peso corporal'],
    'Espalda': ['Barra', 'Mancuernas', 'Cables', 'Máquina', 'Peso corporal'],
    'Hombros': ['Barra', 'Mancuernas', 'Cables', 'Máquina'],
    'Bíceps': ['Barra', 'Mancuernas', 'Cables', 'Máquina'],
    'Tríceps': ['Barra', 'Mancuernas', 'Cables', 'Máquina', 'Peso corporal'],
    'Piernas': ['Barra', 'Mancuernas', 'Cables', 'Máquina', 'Peso corporal'],
    'Glúteos': ['Barra', 'Mancuernas', 'Cables', 'Máquina'],
    'Abdomen': ['Barra', 'Mancuernas', 'Máquina', 'Peso corporal'],
    'Cardio': ['Máquina', 'Peso corporal'],
  };

  static const Map<String, List<String>> variants = {
    'Pecho': ['Banco plano', 'Banco inclinado', 'Banco declinado', 'De pie', 'En polea'],
    'Espalda': ['Jalón al pecho', 'Jalón tras nuca', 'Remo', 'Peso muerto', 'Dominadas'],
    'Hombros': ['Press militar', 'Elevaciones laterales', 'Elevaciones frontales', 'Pájaro'],
    'Bíceps': ['Curl estándar', 'Curl martillo', 'Curl concentrado', 'Curl predicador'],
    'Tríceps': ['Press', 'Extensión', 'Fondos', 'Patada de tríceps'],
    'Piernas': ['Sentadilla', 'Prensa', 'Extensión', 'Curl femoral', 'Zancada', 'Peso muerto rumano'],
    'Glúteos': ['Hip thrust', 'Peso muerto rumano', 'Patada trasera', 'Abducción'],
    'Abdomen': ['Crunch', 'Plancha', 'Elevación de piernas', 'Rueda abdominal'],
    'Cardio': ['Cinta', 'Bicicleta', 'Elíptica', 'Salto a la cuerda', 'Escaladora'],
  };

  static List<String> get muscles => equipment.keys.toList();

  static List<String> equipmentFor(String muscle) =>
      equipment[muscle] ?? [];

  static List<String> variantsFor(String muscle) =>
      variants[muscle] ?? [];
}