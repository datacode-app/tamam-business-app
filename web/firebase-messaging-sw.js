importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDFN-73p8zKVZbA0i5DtO215XzAb-xuGSE",
  authDomain: "ammart-8885e.firebaseapp.com",
  projectId: "ammart-8885e",
  storageBucket: "ammart-8885e.appspot.com",
  messagingSenderId: "1000163153346",
  appId: "1:1000163153346:web:4f702a4b5adbd5c906b25b",
  measurementId: "G-L1GNL2YV61"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});