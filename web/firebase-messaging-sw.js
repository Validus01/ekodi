importScripts("https://www.gstatic.com/firebasejs/9.9.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.9.0/firebase-messaging-compat.js");

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
  const messaging = getMessaging();
  onBackgroundMessage(messaging, (payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    const notificationTitle = 'Background Message Title';
    const notificationOptions = {
      body: 'Background Message body.',
      icon: '/firebase-logo.png'
    };
  
    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });
  