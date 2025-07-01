¡Claro\! Aquí tienes el texto completo y formateado para que solo lo copies y lo pegues en el archivo `README.md` de tu repositorio de GitHub.

````markdown
# App de Chat con Flutter y Supabase

Este es un proyecto de una aplicación de chat en tiempo real construida con Flutter para el frontend y Supabase como backend. La aplicación permite a los usuarios registrarse, iniciar sesión y enviar mensajes de texto, imágenes y su ubicación actual.

## ✨ Características

-   **Autenticación de Usuarios:** Inicio de sesión y registro con email y contraseña.
-   **Chat en Tiempo Real:** Los mensajes aparecen instantáneamente sin necesidad de refrescar.
-   **Mensajes Multimedia:** Soporte para enviar texto, imágenes (desde la cámara o galería) y ubicación GPS.
-   **Almacenamiento de Archivos:** Las imágenes se guardan de forma segura en Supabase Storage.
-   **Firma de APK:** El proyecto está configurado para generar APKs de `release` firmados y listos para producción.

---

## 🚀 Guía de Instalación y Despliegue

Sigue estos pasos para configurar el proyecto en un nuevo entorno de desarrollo.

### 1. Clonar el Repositorio

```bash
git clone [https://github.com/Francis230/Firma_FR_Supabase_FL.git](https://github.com/Francis230/Firma_FR_Supabase_FL.git)
cd Firma_FR_Supabase_FL
````

### 2\. Obtener Dependencias de Flutter

Este comando descargará todos los paquetes necesarios definidos en `pubspec.yaml`.

```bash
flutter pub get
```

### 3\. Configuración del Backend en Supabase

#### A. Creación de la Tabla `messages`

Ve al **SQL Editor** en tu panel de Supabase y ejecuta el siguiente script para crear la tabla de mensajes.

```sql
CREATE TABLE IF NOT EXISTS messages (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_email TEXT,
  content TEXT,
  type TEXT NOT NULL,
  image_url TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
```

#### B. Habilitar Realtime

Para que el chat funcione en tiempo real, es **crucial** habilitar la replicación para la tabla `messages`.

1.  Ve a **Database** -\> **Replication**.
2.  Haz clic en **Source** y marca la casilla junto a la tabla `messages`.
3.  Guarda los cambios.

#### C. Configurar Storage

1.  Ve a **Storage** y crea un nuevo bucket llamado `chat-photos`.
2.  Asegúrate de marcar la opción **"Public bucket"**.
3.  Configura las políticas de acceso para permitir que los usuarios suban archivos y que cualquiera pueda verlos (necesario para mostrar las imágenes en la app).

### 4\. Configuración del Entorno Local

#### A. Crear el archivo `.env`

En la raíz del proyecto, crea un archivo `.env` con tus credenciales de Supabase. **Este archivo es ignorado por Git por seguridad.**

```
SUPABASE_URL=https://TU_ID_DE_PROYECTO.supabase.co
SUPABASE_ANON_KEY=TU_LLAVE_ANON
```

#### B. Configurar la Firma de Android

Estos pasos son **obligatorios** para generar un APK de `release`.

1.  **Generar el Keystore:** Abre una terminal en la raíz de tu proyecto y ejecuta este comando. Te pedirá que crees una contraseña y llenes algunos datos.

    ```bash
    keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
    ```

2.  **Mover el Keystore:** Mueve el archivo `my-release-key.jks` que se acaba de crear a la carpeta `android/app/`.

3.  **Crear `key.properties`:** Dentro de la carpeta `android/`, crea un archivo llamado `key.properties` con el siguiente contenido. **Reemplaza las contraseñas con las que creaste en el paso 1.**

    ```properties
    storePassword=TU_CONTRASEÑA_DEL_KEYSTORE
    keyPassword=TU_CONTRASEÑA_DEL_ALIAS
    keyAlias=my-key-alias
    storeFile=my-release-key.jks
    ```

    *Nota: La ruta `storeFile` es correcta porque el `build.gradle.kts` la busca relativa a su propia ubicación.*

### 5\. Construir y Verificar el APK

Con todo configurado, ya puedes generar tu APK firmado.

```bash
flutter build apk --release
```

El APK se encontrará en `build/app/outputs/flutter-apk/app-release.apk`.

Para verificar que está correctamente firmado, usa `apksigner`:

```bash
apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk
```

Deberías ver una salida que confirme que la verificación fue exitosa (`Verified using v1/v2 scheme: true`).

-----

## 🔧 Troubleshooting Común

### Problemas con `sign_in_with_apple`

Si encuentras errores de compilación relacionados con `sign_in_with_apple` (como `Unresolved reference 'Registrar'` o problemas de `namespace`), es debido a una incompatibilidad de versiones. La solución definitiva es:

1.  **Eliminar y reinstalar las dependencias:**

    ```bash
    flutter pub remove supabase_flutter
    flutter pub remove sign_in_with_apple
    flutter pub add supabase_flutter
    ```

2.  **Limpiar y reconstruir:**

    ```bash
    flutter clean
    flutter pub get
    flutter build apk --release
    ```

-----

## Git y Flujo de Trabajo

### Configuración Inicial de Git

Si es la primera vez que usas Git en tu máquina, configura tu nombre y email:

```bash
git config --global user.name "Tu Nombre de Usuario"
git config --global user.email "tu.email@ejemplo.com"
```

### Flujo de Trabajo Básico

1.  **Añadir cambios:** `git add .`
2.  **Guardar cambios (commit):** `git commit -m "Descripción de los cambios"`
3.  **Subir cambios a GitHub:** `git push`

<!-- end list -->

```
```
