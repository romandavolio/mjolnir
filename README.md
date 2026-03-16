# Mjolnir 💪

Aplicación móvil para gestión de rutinas de gimnasio, desarrollada con Flutter.

## ¿Qué hace?

Permite gestionar ejercicios, rutinas y registrar el progreso de peso a lo largo del tiempo. Diseñada para uso personal o entre un personal trainer y sus alumnos.

## Funcionalidades

- Pantalla de bienvenida con diseño personalizado
- Gestión de ejercicios: crear, editar y eliminar
- Visualización de rutinas con registro de peso por ejercicio
- Historial de progreso con gráfico de evolución por ejercicio
- Configuración de unidad de peso (kg / lb)
- Persistencia de datos local (los cambios sobreviven al cerrar la app)

## En desarrollo

- Perfiles de trainer y alumno
- Asignación de rutinas por alumno
- Registro de progreso histórico ampliado

## Tecnologías

- [Flutter](https://flutter.dev/) / Dart
- shared_preferences — persistencia local
- fl_chart — gráficos de progreso
- Arquitectura por capas: models, screens, components, services, core

## Capturas

![Pantalla de rutinas](routine_screen.png)

## Cómo correrlo

1. Cloná el repositorio
2. Instalá las dependencias:
```
   flutter pub get
```
3. Corré la app:
```
   flutter run
```

## Autor

Román Davolio — [LinkedIn](https://www.linkedin.com/in/roman-davolio/)