importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

   /*Update with yours config*/
const firebaseConfig = {
  apiKey: "AIzaSyBejXTk5KYKEInPViVikHz9WOnoAuvNeJI",
          authDomain: "discover-destination.firebaseapp.com",
          projectId: "discover-destination",
          storageBucket: "discover-destination.appspot.com",
          messagingSenderId: "579061873435",
          appId: "1:579061873435:web:6bfd3e2a55ba4a55a271be",
          measurementId: "G-7VKE5ZQLQ5"
};
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });
