importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyAGz6yr0SkQI-MjSMiBZKoRd4SIEFhW4QA",
    authDomain: "e-kodi-202ba.firebaseapp.com",
    databaseURL: "https://e-kodi-202ba.firebaseio.com",
    projectId: "e-kodi-202ba",
    storageBucket: "e-kodi-202ba.appspot.com",
    messagingSenderId: "275250872466",
    appId: "1:275250872466:web:893e86a68475dc9db3a64b",
    measurementId: "G-07KCRHYHR6"
  });

  // Necessary to receive background message
  const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});