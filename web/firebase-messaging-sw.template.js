// Firebase Cloud Messaging Service Worker - TEMPLATE
// 
// 📝 CONFIGURACIÓN:
// 1. Copia este archivo a: web/firebase-messaging-sw.js
// 2. Reemplaza las XXX con tus credenciales de Firebase Console
// 3. NUNCA hagas commit del archivo firebase-messaging-sw.js
//
// ⚠️ IMPORTANTE: firebase-messaging-sw.js está en .gitignore

importScripts('https://www.gstatic.com/firebasejs/11.15.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.15.0/firebase-messaging-compat.js');

// Configuración de Firebase (obtener de Firebase Console)
const firebaseConfig = {
  apiKey: "XXX-REEMPLAZA-CON-TU-API-KEY-XXX",
  authDomain: "tu-proyecto.firebaseapp.com",
  projectId: "tu-proyecto-id",
  storageBucket: "tu-proyecto.firebasestorage.app",
  messagingSenderId: "XXX-SENDER-ID-XXX",
  appId: "XXX-APP-ID-XXX"
};

// Inicializar Firebase
firebase.initializeApp(firebaseConfig);

// Obtener instancia de Firebase Messaging
const messaging = firebase.messaging();

// Manejar notificaciones en segundo plano
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);

  const notificationTitle = payload.notification?.title || 'Spot Trading Alert';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.symbol || 'price-alert',
    data: payload.data,
    requireInteraction: true,
    vibrate: [200, 100, 200],
    actions: [
      {
        action: 'view',
        title: 'Ver Detalles'
      },
      {
        action: 'close',
        title: 'Cerrar'
      }
    ]
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});

// Manejar clics en las notificaciones
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification clicked:', event);

  event.notification.close();

  if (event.action === 'view' || !event.action) {
    const symbol = event.notification.data?.symbol;

    event.waitUntil(
      clients.matchAll({ type: 'window', includeUncontrolled: true })
        .then((clientList) => {
          for (const client of clientList) {
            if (client.url.includes(self.registration.scope) && 'focus' in client) {
              return client.focus().then(() => {
                if (symbol) {
                  client.postMessage({
                    type: 'NOTIFICATION_CLICK',
                    symbol: symbol,
                    data: event.notification.data
                  });
                }
              });
            }
          }

          if (clients.openWindow) {
            return clients.openWindow('/');
          }
        })
    );
  }
});

console.log('[firebase-messaging-sw.js] Service Worker loaded successfully');
