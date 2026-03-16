class MuscleData {
  static const Map<String, List<String>> data = {
    'Pecho': [
      'Banco plano',
      'Banco inclinado',
      'Banco declinado',
      'Con mancuernas',
      'Con barra',
      'Con cables',
      'Calistenia',
    ],
    'Espalda': [
      'Jalón al pecho',
      'Remo',
      'Peso muerto',
      'Con barra',
      'Con mancuernas',
      'Con cables',
      'Calistenia',
    ],
    'Hombros': [
      'Press militar',
      'Elevaciones laterales',
      'Elevaciones frontales',
      'Con barra',
      'Con mancuernas',
      'Con cables',
    ],
    'Bíceps': [
      'Curl',
      'Con barra',
      'Con mancuernas',
      'Con cables',
      'Martillo',
    ],
    'Tríceps': [
      'Press',
      'Extensiones',
      'Con barra',
      'Con mancuernas',
      'Con cables',
      'Calistenia',
    ],
    'Piernas': [
      'Sentadilla',
      'Prensa',
      'Extensiones',
      'Curl femoral',
      'Con barra',
      'Con mancuernas',
      'Máquina',
    ],
    'Glúteos': [
      'Hip thrust',
      'Peso muerto rumano',
      'Con barra',
      'Con mancuernas',
      'Máquina',
    ],
    'Abdomen': [
      'Crunch',
      'Plancha',
      'Elevaciones',
      'Con peso',
      'Calistenia',
    ],
    'Cardio': [
      'Cinta',
      'Bicicleta',
      'Elíptica',
      'Funcional',
    ],
  };

  static List<String> get muscles => data.keys.toList();

  static List<String> typesFor(String muscle) => data[muscle] ?? [];
}