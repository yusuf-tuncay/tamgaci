// Firebase Messaging Service Worker
// Bu dosya web bildirimleri için gerekli

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Firebase config - gerçek değerlerle değiştirilmeli
const firebaseConfig = {
    apiKey: "AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    authDomain: "tamgaci.firebaseapp.com",
    projectId: "tamgaci",
    storageBucket: "tamgaci.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:abcdef1234567890abcdef"
};

// Firebase'i başlat
try {
    firebase.initializeApp(firebaseConfig);
    console.log('Firebase initialized in service worker');
} catch (error) {
    console.log('Firebase already initialized or error:', error);
}

// Messaging instance'ı al
const messaging = firebase.messaging();

// Background message handler
messaging.onBackgroundMessage(function (payload) {
    console.log('Background message received:', payload);

    const notificationTitle = payload.notification?.title || 'TAMGACI';
    const notificationOptions = {
        body: payload.notification?.body || 'Yeni bir bildirim var',
        icon: '/assets/images/logos/192x192logo.png',
        badge: '/assets/images/logos/192x192logo.png',
        tag: 'tamgaci-notification',
        requireInteraction: true,
        actions: [
            {
                action: 'open',
                title: 'Aç',
                icon: '/assets/images/logos/192x192logo.png'
            },
            {
                action: 'close',
                title: 'Kapat'
            }
        ]
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Notification click handler
self.addEventListener('notificationclick', function (event) {
    console.log('Notification clicked:', event);

    event.notification.close();

    if (event.action === 'open' || !event.action) {
        // Uygulamayı aç
        event.waitUntil(
            clients.openWindow('/')
        );
    }
});

// Service worker install
self.addEventListener('install', function (event) {
    console.log('Service worker installed');
    self.skipWaiting();
});

// Service worker activate
self.addEventListener('activate', function (event) {
    console.log('Service worker activated');
    event.waitUntil(self.clients.claim());
});