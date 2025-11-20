# 🕵️‍♂️ Juego Impostor

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=flat&logo=flutter&logoColor=white)
![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

> **Juego Impostor** es un juego de deducción social local ("Pass & Play") desarrollado en Flutter. Reúne a tus amigos, define los roles y descubre quién miente antes de que sea demasiado tarde.

---

## ✨ Características Principales

* **Multijugador Local:** Diseñado para jugar en un solo dispositivo pasándolo entre amigos (de 3 a 12 jugadores).
* **Gestión de Categorías:**
    * Incluye categorías predefinidas (Comida, Animales, Cine, etc.).
    * Posibilidad de **activar/desactivar** categorías según los gustos del grupo.
* **Personalización Total:**
    * ¿No te gustan las palabras? ¡Crea las tuyas! Incluye un editor de **palabras personalizadas** que se guardan en el dispositivo.
* **Base de Datos Persistente:** Utiliza **SQLite** para guardar tus preferencias y palabras personalizadas, asegurando que no pierdas tus configuraciones.
* **Interfaz Oscura:** Diseño "Dark Mode" moderno con acentos rojos, ideal para ahorrar batería y jugar de noche.

---

## 🚀 Instalación (Android)

Puedes descargar la última versión compilada (APK) desde la sección de **[Releases](../../releases)** de este repositorio.

1.  Descarga el archivo `.apk`.
2.  Instálalo en tu dispositivo Android (asegúrate de permitir orígenes desconocidos si es necesario).
3.  ¡A jugar!

---

## 🛠️ Cómo compilar el código fuente

Si prefieres compilarlo tú mismo o contribuir al desarrollo:

### Prerrequisitos
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.10 o superior)
* Dart SDK

### Pasos

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/drakko99/juego_impostor.git](https://github.com/drakko99/juego_impostor.git)
    cd juego_impostor
    ```

2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Generar base de datos (si aplica cambios):**
    El proyecto usa `sqflite`. La base de datos se inicializa automáticamente en la primera ejecución con los datos de `assets/data/words.json`.

4.  **Ejecutar:**
    ```bash
    # Para desarrollo
    flutter run

    # Para generar APK
    flutter build apk --release
    ```

---

## 🧩 Estructura del Proyecto

El código sigue una arquitectura limpia y modular:

* `lib/models/`: Modelos de datos (`Category`, `WordItem`).
* `lib/db/`: Gestión de base de datos local (`AppDatabase` con SQLite).
* `lib/repositories/`: Capa de abstracción de datos (`GameRepository`).
* `lib/screens/`:
    * `HomeScreen`: Configuración de jugadores.
    * `GameScreen`: Lógica principal del juego y distribución de roles.
    * `CategoriesScreen`: Gestión de categorías activas.
    * `CustomWordsScreen`: ABM de palabras propias.

---

## 🤝 Contribución

¡Las ideas son bienvenidas! Si quieres añadir nuevas categorías por defecto o mejorar la mecánica:

1.  Haz un **Fork**.
2.  Crea tu rama (`git checkout -b feature/NuevaMecanica`).
3.  Haz commit de tus cambios.
4.  Haz push a la rama.
5.  Abre un **Pull Request**.

---

**Desarrollado con 💙 y Flutter**