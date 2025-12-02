# 🕵️‍♂️ Juego Impostor

![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Core%2BAnalytics-FFCA28?style=flat&logo=firebase&logoColor=black)
![AdMob](https://img.shields.io/badge/AdMob-Monetization-EA4335?style=flat&logo=google-ads&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green.svg)

> **Juego Impostor** es un juego de deducción social local ("Pass & Play") desarrollado en Flutter. Reúne a tus amigos, define los roles y descubre quién miente antes de que sea demasiado tarde.

---

## ✨ Características Principales

* **Multijugador Local Dinámico:** Soporte para grupos de **3 a 12 jugadores**.
* **Gestión de Nombres:** Posibilidad de asignar nombres personalizados a cada jugador para facilitar la identificación durante la partida.
* **Modo +18 (Adultos):**
    * Nueva sección de **Ajustes** para desbloquear contenido explícito.
    * Incluye categorías exclusivas como "Sexo" e "Insultos" (desactivadas por defecto).
* **Gestión Avanzada de Categorías:**
    * Base de datos ampliada con categorías como: *Comida, Bebidas, Animales, Profesiones, Streamers, Animes, Videojuegos*, entre otras.
    * Filtrado automático de categorías según la configuración de edad.
* **Personalización Total:** Editor integrado para crear y guardar tus propias palabras en la base de datos local.
* **Experiencia Visual Mejorada:**
    * **Animaciones:** Efectos de escala y desvanecimiento al revelar roles e impostores.
    * **Interfaz Oscura:** Diseño "Dark Mode" optimizado con paleta de colores rojo/negro (`Colors.red.shade700` y `Color(0xFF121212)`).
* **Persistencia de Datos:** Utiliza **SQLite** (versión 2 de esquema) para guardar palabras, categorías y preferencias de usuario.
* **Monetización Integrada:** Implementación de **Google Mobile Ads** con Banners (Home, Juego, Diálogos) e Intersticiales cada 2 partidas.

---

## 🚀 Instalación (Android)

1.  Descarga el archivo `.apk` de la sección de Releases.
2.  Instálalo en tu dispositivo Android.
3.  ¡A jugar!

---

## 🛠️ Configuración del Entorno de Desarrollo

Para compilar este proyecto, necesitarás configurar algunos servicios externos debido a las nuevas integraciones.

### Prerrequisitos

* Flutter SDK (v3.10 o superior)
* Dart SDK
* Cuenta de Firebase (para Analytics)
* Cuenta de AdMob (para Anuncios)

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

3.  **Configurar Firebase:**
    * El proyecto utiliza `firebase_core` y `firebase_analytics`.
    * Debes generar tu propio archivo `google-services.json` en la consola de Firebase y colocarlo en `android/app/`.

4.  **Configurar AdMob:**
    * El archivo `lib/utils/ad_helper.dart` contiene los IDs de los bloques de anuncios.
    * Por defecto utiliza los **IDs de prueba** de Google.
    * Para producción, actualiza las constantes `_androidHomeRealId`, `_androidGameRealId`, etc. en `AdHelper`.
    * Asegúrate de actualizar el `APPLICATION_ID` en `android/app/src/main/AndroidManifest.xml`.

5.  **Firma de la App (Release):**
    * El archivo `build.gradle` espera un archivo `key.properties` en la raíz de `android/` para firmar la APK de lanzamiento. Crea este archivo con tus claves o elimina la configuración de firma en `build.gradle.kts` para compilaciones de depuración.

6.  **Ejecutar:**
    ```bash
    flutter run
    ```

---

## 🧩 Estructura del Proyecto

El código sigue una arquitectura limpia y modular:

* `lib/models/`: Modelos de datos (`Category`, `WordItem`).
* `lib/db/`: Gestión de base de datos SQLite (`AppDatabase`). Maneja migraciones y carga inicial de `assets/data/words.json`.
* `lib/repositories/`: Lógica de negocio y acceso a datos (`GameRepository`).
* `lib/utils/`:
    * `AdHelper`: Gestión de IDs de anuncios y lógica de plataforma.
    * `Preferences`: Gestión de SharedPreferences (Modo adulto, contador de partidas).
* `lib/screens/`:
    * `HomeScreen`: Configuración de partida, jugadores y carga de anuncios.
    * `SettingsScreen`: Toggle para el **Modo +18** y versión de la app.
    * `GameScreen`: Lógica del juego, animaciones de revelación y distribución de roles.
    * `GameEndDialog`: Pantalla de resultados y revelación final.
    * `CategoriesScreen` & `CustomWordsScreen`: Gestión de contenido.

---

## 🤝 Contribución

1.  Haz un **Fork**.
2.  Crea tu rama (`git checkout -b feature/NuevaMecanica`).
3.  Haz commit de tus cambios.
4.  Haz push a la rama.
5.  Abre un **Pull Request**.

---

**Desarrollado con 💙 y Flutter**