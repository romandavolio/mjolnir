## Decisiones de arquitectura
- Lógica en screens (no controllers) — válido para escala actual
- WorkoutMixin para compartir lógica de timer, selector de peso e historial entre pantallas
- Catálogo de ejercicios hardcodeado en el cliente — sin posibilidad de edición por usuarios
- Firestore como fuente de verdad — shared_preferences solo para preferencias locales
- Modo offline habilitado con persistencia automática de Firestore
- Reglas de seguridad de Firestore configuradas por colección
- Notas privadas por usuario almacenadas en subcolección separada

## Tecnologías

- [Flutter](https://flutter.dev/) / Dart
- Firebase Auth — autenticación
- Cloud Firestore — base de datos en la nube con reglas de seguridad y modo offline
- Firebase Cloud Messaging — notificaciones push
- shared_preferences — preferencias locales
- fl_chart — gráficos de progreso
- vibration — vibración del dispositivo

## En desarrollo

- Foto de perfil — requiere plan de pago en Firebase Storage
- Sección de alimentación

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

Román Davolio — [LinkedIn](https://www.linkedin.com/in/roman-davolio/) — [GitHub](https://github.com/romandavolio/mjolnir)