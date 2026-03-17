# Mjolnir 💪

Aplicación móvil para gestión de rutinas de gimnasio, desarrollada con Flutter.

## ¿Qué hace?

Permite a trainers y alumnos gestionar ejercicios, rutinas y registrar el progreso de peso a lo largo del tiempo. Los trainers pueden vincularse con sus alumnos, asignarles rutinas personalizadas y visualizar sus pesos registrados.

## Funcionalidades

### Autenticación y perfiles
- Registro e inicio de sesión con email y contraseña
- Perfiles diferenciados: trainer y alumno
- Vinculación trainer-alumno mediante solicitudes

### Trainer
- Gestión de alumnos vinculados
- Asignación de rutinas a alumnos
- Visualización de pesos registrados por el alumno
- Edición de rutinas asignadas
- Eliminación de rutinas sin pesos cargados

### Alumno
- Recepción y gestión de solicitudes de vinculación
- Visualización de rutinas asignadas por el trainer
- Creación de rutinas propias
- Registro de pesos por serie

### Ejercicios y rutinas
- Catálogo global de ejercicios por músculo, equipamiento y variante
- Rutinas con series de repeticiones personalizadas por ejercicio
- Registro de peso individual por serie

### Progreso
- Historial de progreso con gráfico de evolución por ejercicio

### Configuración
- Unidad de peso configurable (kg / lb) sincronizada en la nube

## Tecnologías

- [Flutter](https://flutter.dev/) / Dart
- Firebase Auth — autenticación
- Cloud Firestore — base de datos en la nube
- shared_preferences — preferencias locales del dispositivo
- fl_chart — gráficos de progreso
- Arquitectura por capas: models, screens, components, services, core

## En desarrollo

- Foto de perfil de usuario
- Notificaciones push para solicitudes de vinculación
- Historial de pesos del alumno visible para el trainer
- Múltiples trainers por alumno
- Plantillas de rutinas predefinidas por grupo muscular
- Estadísticas generales de progreso (volumen total, récords personales)
- Modo offline con sincronización automática al reconectarse

## Capturas

![Pantalla de login](login_screen.png)
![Pantalla de inicio](welcome_screen.png)
![Pantalla de rutinas](routine_screen.png)
![Pantalla de detalles de rutinas](routine_detail_screen.png)

## Cómo correrlo

1. Cloná el repositorio
2. Configurá Firebase con tu propio proyecto y generá `firebase_options.dart`:
```
   flutterfire configure
```
3. Instalá las dependencias:
```
   flutter pub get
```
4. Corré la app:
```
   flutter run
```

## Autor

Román Davolio — [LinkedIn](https://www.linkedin.com/in/roman-davolio/)