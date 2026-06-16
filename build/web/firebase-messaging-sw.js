importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDOc9BSny2gHA0s7VsfXzYZnL9ZqiXT4t0",
  authDomain: "gestion-tramites-26754.firebaseapp.com",
  projectId: "gestion-tramites-26754",
  storageBucket: "gestion-tramites-26754.firebasestorage.app",
  messagingSenderId: "345104547307",
  appId: "1:345104547307:web:ff5b568b8331f98b3fedae"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification;
  self.registration.showNotification(title, {
    body,
    icon: '/gestion-tramites/icons/Icon-192.png',
  });
});