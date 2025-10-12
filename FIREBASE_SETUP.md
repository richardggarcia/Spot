# 🔥 Configuración de Firebase

## ⚠️ IMPORTANTE: Archivos que NUNCA deben subirse a GitHub

Los siguientes archivos contienen API keys y secrets. **NUNCA** los subas a Git:

- ❌ `ios/Runner/GoogleService-Info.plist`
- ❌ `android/app/google-services.json`
- ❌ `.env` (si lo usas)

Estos archivos ya están en `.gitignore` ✅

---

## 📝 Pasos para configurar Firebase

### 1️⃣ Crear proyecto Firebase

1. Ve a: https://console.firebase.google.com
2. Click en **"Add project"** / **"Agregar proyecto"**
3. Nombre: **Buy The Dip** (o el que prefieras)
4. Seguir los pasos (Analytics: opcional)

### 2️⃣ Configurar app iOS

1. En el proyecto, click en **iOS** (ícono de Apple)
2. **Bundle ID:** `com.spottrading.app`
3. **App nickname:** `Buy The Dip`
4. Click **"Register app"**
5. **Descargar** `GoogleService-Info.plist`
6. **Colocar** el archivo en: `ios/Runner/GoogleService-Info.plist`

### 3️⃣ Configurar app Android

1. En el proyecto, click en **Android** (ícono de Android)
2. **Package name:** `com.spottrading.app`
3. **App nickname:** `Buy The Dip`
4. Click **"Register app"**
5. **Descargar** `google-services.json`
6. **Colocar** el archivo en: `android/app/google-services.json`

### 4️⃣ Verificar que los archivos NO se suban a Git

Después de colocar los archivos, verifica:

```bash
git status
```

**NO deberías ver** los archivos de Firebase. Si los ves, significa que algo salió mal con el `.gitignore`.

---

## ✅ Checklist final

- [ ] Proyecto Firebase creado
- [ ] App iOS configurada
- [ ] App Android configurada
- [ ] `GoogleService-Info.plist` colocado en `ios/Runner/`
- [ ] `google-services.json` colocado en `android/app/`
- [ ] Verificado que `git status` NO muestra estos archivos
- [ ] API key antigua revocada en Google Cloud Console

---

## 🆘 Si algo sale mal

Si accidentalmente subes un archivo con API keys:

1. **Revocar la key inmediatamente** en Google Cloud Console
2. **Regenerar** una nueva key en Firebase
3. **Descargar** los nuevos archivos de configuración
4. **Cerrar la alerta** en GitHub Security

---

## 📚 Recursos

- Firebase Console: https://console.firebase.google.com
- Google Cloud Console: https://console.cloud.google.com
- Documentación Firebase: https://firebase.google.com/docs
