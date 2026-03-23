class ExerciseCatalog {
  static const Map<String, Map<String, Map<String, List<String>>>> data = {
    'Pecho': {
      'Banco plano': {
        'Barra': ['Press banca'],
        'Mancuerna': ['Aperturas'],
      },
      'Banco inclinado': {
        'Mancuerna': ['Press inclinado'],
      },
      'Paralelas': {
        'Peso corporal': ['Fondos'],
      },
      'Máquina': {
        'Cables': ['Cruces'],
      },
    },
    'Espalda': {
      'Barra fija': {
        'Peso corporal': ['Dominadas'],
      },
      'Banco inclinado': {
        'Mancuerna': ['Remo'],
      },
      'Máquina': {
        'Cables': ['Jalón al pecho', 'Remo bajo'],
      },
      'Suelo': {
        'Barra': ['Peso muerto'],
      },
    },
    'Hombros': {
      'De pie': {
        'Barra': ['Press militar'],
        'Mancuerna': ['Elevaciones laterales', 'Elevaciones frontales'],
      },
      'Sentado': {
        'Mancuerna': ['Press arnold'],
      },
      'Banco inclinado': {
        'Mancuerna': ['Pájaros'],
      },
    },
    'Piernas': {
      'Rack': {
        'Barra': ['Sentadilla'],
      },
      'Máquina': {
        'Peso de máquina': ['Prensa', 'Extensiones', 'Curl femoral', 'Gemelos'],
      },
    },
    'Bíceps': {
      'De pie': {
        'Barra': ['Curl bíceps', 'Curl 21'],
        'Mancuerna': ['Curl martillo'],
      },
      'Sentado': {
        'Mancuerna': ['Curl concentrado'],
      },
      'Máquina': {
        'Cables': ['Curl en polea'],
      },
    },
    'Tríceps': {
      'Banco plano': {
        'Barra': ['Press francés'],
      },
      'De pie': {
        'Mancuerna': ['Extensión por encima'],
      },
      'Máquina': {
        'Cables': ['Jalón en polea'],
      },
      'Banco inclinado': {
        'Mancuerna': ['Patada de tríceps'],
      },
      'Banco': {
        'Peso corporal': ['Fondos en banco'],
      },
    },
  };

  static List<String> get muscles => data.keys.toList();

  static Map<String, Map<String, List<String>>> elementsFor(String muscle) =>
      data[muscle] ?? {};

  static Map<String, List<String>> accompanimentFor(
          String muscle, String element) =>
      data[muscle]?[element] ?? {};

  static List<String> exercisesFor(
          String muscle, String element, String accompaniment) =>
      data[muscle]?[element]?[accompaniment] ?? [];
}