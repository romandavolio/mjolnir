class ExerciseCatalog {
  static const Map<String, Map<String, Map<String, List<String>>>> data = {
    'Pecho': {
      'Banco plano': {
        'Barra': ['Press banca', 'Press banca agarre cerrado'],
        'Mancuerna': ['Press banca mancuerna', 'Aperturas planas'],
        'Máquina': ['Press en máquina plano'],
      },
      'Banco inclinado': {
        'Barra': ['Press inclinado barra'],
        'Mancuerna': ['Press inclinado mancuerna', 'Aperturas inclinadas'],
        'Máquina': ['Press en máquina inclinado'],
      },
      'Banco declinado': {
        'Barra': ['Press declinado barra'],
        'Mancuerna': ['Press declinado mancuerna'],
      },
      'Máquina': {
        'Cables': [
          'Cruces en polea alta',
          'Cruces en polea baja',
          'Cruces en polea media',
        ],
        'Peso de máquina': ['Pec deck', 'Press en máquina convergente'],
      },
      'Paralelas': {
        'Peso corporal': ['Fondos en paralelas'],
      },
      'Suelo': {
        'Peso corporal': [
          'Flexiones',
          'Flexiones diamante',
          'Flexiones declinadas',
          'Flexiones con palmada',
        ],
      },
    },
    'Espalda': {
      'Barra fija': {
        'Peso corporal': [
          'Dominadas',
          'Dominadas supinas',
          'Dominadas neutras',
        ],
      },
      'Banco inclinado': {
        'Mancuerna': ['Remo con mancuerna'],
        'Barra': ['Remo en banco inclinado'],
      },
      'De pie': {
        'Barra': [
          'Remo con barra',
          'Peso muerto convencional',
          'Peso muerto sumo',
        ],
        'Mancuerna': ['Remo con mancuerna de pie'],
      },
      'Máquina': {
        'Cables': [
          'Jalón al pecho agarre ancho',
          'Jalón al pecho agarre cerrado',
          'Jalón al pecho agarre neutro',
          'Remo en polea baja',
          'Remo en polea alta',
          'Pull over en polea',
        ],
        'Peso de máquina': [
          'Remo en máquina',
          'Jalón en máquina',
          'Pull over en máquina',
          'Remo en máquina unilateral',
        ],
      },
      'Suelo': {
        'Barra': ['Peso muerto rumano', 'Buenos días'],
      },
      'Banco': {
        'Peso corporal': ['Hiperextensiones'],
        'Barra': ['Hiperextensiones con barra'],
      },
    },
    'Hombros': {
      'De pie': {
        'Barra': ['Press militar de pie'],
        'Mancuerna': [
          'Elevaciones laterales',
          'Elevaciones frontales',
          'Elevaciones laterales inclinado',
        ],
        'Cables': [
          'Elevaciones laterales en polea',
          'Elevaciones frontales en polea',
        ],
      },
      'Sentado': {
        'Mancuerna': ['Press arnold', 'Press con mancuernas sentado'],
        'Barra': ['Press militar sentado'],
        'Máquina': ['Press en máquina de hombros'],
      },
      'Banco inclinado': {
        'Mancuerna': ['Pájaros', 'Elevaciones laterales tumbado'],
      },
      'Máquina': {
        'Cables': [
          'Pájaros en polea',
          'Face pull',
          'Elevaciones laterales en polea cruzada',
        ],
        'Peso de máquina': ['Press en máquina unilateral'],
      },
    },
    'Piernas': {
      'Rack': {
        'Barra': ['Sentadilla', 'Sentadilla frontal', 'Sentadilla búlgara'],
      },
      'De pie': {
        'Barra': ['Peso muerto convencional', 'Peso muerto rumano'],
        'Mancuerna': [
          'Zancadas',
          'Zancadas con mancuernas',
          'Sentadilla goblet',
        ],
        'Peso corporal': ['Zancadas', 'Sentadilla sumo'],
      },
      'Máquina': {
        'Peso de máquina': [
          'Prensa 45°',
          'Prensa horizontal',
          'Extensiones de cuádriceps',
          'Curl femoral tumbado',
          'Curl femoral sentado',
          'Abductores',
          'Aductores',
          'Gemelos en prensa',
          'Gemelos de pie en máquina',
          'Gemelos sentado en máquina',
        ],
      },
      'Suelo': {
        'Peso corporal': ['Sentadilla búlgara', 'Hip thrust sin peso'],
        'Barra': ['Hip thrust con barra'],
      },
      'Banco': {
        'Peso corporal': ['Step up'],
        'Mancuerna': ['Step up con mancuernas'],
      },
    },
    'Bíceps': {
      'De pie': {
        'Barra': ['Curl con barra', 'Curl barra Z', 'Curl 21'],
        'Mancuerna': [
          'Curl alternado',
          'Curl martillo',
          'Curl martillo cruzado',
        ],
      },
      'Sentado': {
        'Mancuerna': ['Curl concentrado', 'Curl en banco inclinado'],
        'Barra': ['Curl en banco Scott'],
      },
      'Máquina': {
        'Cables': [
          'Curl en polea baja',
          'Curl en polea alta',
          'Curl unilateral en polea',
        ],
        'Peso de máquina': ['Curl en máquina'],
      },
      'Banco': {
        'Barra': ['Curl en banco Scott'],
        'Mancuerna': ['Curl en banco Scott con mancuerna'],
      },
    },
    'Tríceps': {
      'Banco plano': {
        'Barra': ['Press francés', 'Press cerrado en banco'],
        'Mancuerna': ['Press francés con mancuerna'],
      },
      'De pie': {
        'Mancuerna': ['Extensión sobre la cabeza'],
        'Barra': ['Extensión sobre la cabeza con barra'],
      },
      'Máquina': {
        'Cables': [
          'Jalón en polea con cuerda',
          'Jalón en polea con barra recta',
          'Jalón en polea con barra V',
          'Extensión unilateral en polea',
          'Extensión sobre cabeza en polea',
        ],
      },
      'Banco': {
        'Peso corporal': ['Fondos en banco'],
      },
      'Banco inclinado': {
        'Mancuerna': ['Patada de tríceps'],
      },
      'Suelo': {
        'Peso corporal': ['Flexiones diamante'],
      },
    },
    'Abdominales': {
      'Suelo': {
        'Peso corporal': [
          'Crunch',
          'Crunch inverso',
          'Plancha',
          'Plancha lateral',
          'Elevación de piernas',
          'Tijeras',
          'Bicicleta',
          'Mountain climbers',
          'Hollow hold',
          'Superman',
          'Rodillo abdominal',
        ],
        'Disco': ['Crunch con disco', 'Oblicuos con disco'],
      },
      'Banco': {
        'Peso corporal': ['Crunch en banco declinado'],
        'Disco': ['Crunch en banco declinado con disco'],
      },
      'Máquina': {
        'Cables': [
          'Crunch en polea',
          'Oblicuos en polea',
          'Elevación de rodillas en polea',
        ],
        'Peso de máquina': ['Crunch en máquina'],
      },
      'Barra fija': {
        'Peso corporal': ['Elevación de piernas en barra'],
      },
    },
    'Glúteos': {
      'Suelo': {
        'Peso corporal': [
          'Hip thrust sin peso',
          'Patada de glúteo',
          'Puente de glúteo',
        ],
        'Banda elástica': [
          'Hip thrust con banda',
          'Patada de glúteo con banda',
          'Clamshell',
        ],
      },
      'Banco': {
        'Barra': ['Hip thrust con barra'],
        'Mancuerna': ['Hip thrust con mancuerna'],
      },
      'Máquina': {
        'Cables': ['Patada de glúteo en polea', 'Abducción en polea'],
        'Peso de máquina': ['Glúteo en máquina', 'Abductores'],
      },
      'Rack': {
        'Barra': ['Sentadilla búlgara con barra'],
      },
    },
    'Trapecio': {
      'De pie': {
        'Barra': ['Encogimientos con barra', 'Remo al mentón'],
        'Mancuerna': ['Encogimientos con mancuernas'],
      },
      'Máquina': {
        'Cables': ['Encogimientos en polea', 'Remo al mentón en polea'],
        'Peso de máquina': ['Encogimientos en máquina'],
      },
    },
    'Antebrazos': {
      'Banco': {
        'Barra': ['Curl de muñeca', 'Curl de muñeca inverso'],
        'Mancuerna': ['Curl de muñeca con mancuerna'],
      },
      'De pie': {
        'Barra': ['Remo inverso agarre cerrado'],
        'Mancuerna': ['Rotación de muñeca'],
      },
    },
  };

  static List<String> get muscles => data.keys.toList();

  static Map<String, Map<String, List<String>>> elementsFor(String muscle) =>
      data[muscle] ?? {};

  static Map<String, List<String>> accompanimentFor(
    String muscle,
    String element,
  ) => data[muscle]?[element] ?? {};

  static List<String> exercisesFor(
    String muscle,
    String element,
    String accompaniment,
  ) => data[muscle]?[element]?[accompaniment] ?? [];
}
