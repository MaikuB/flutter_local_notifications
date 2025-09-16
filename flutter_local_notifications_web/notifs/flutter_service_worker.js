'use strict';

function saveMessage(message) {
  let request = indexedDB.open("flutter_local_notifications", 1);
  request.onupgradeneeded = (event) => {
    let db = event.target.result;
    db.createObjectStore("notifications", {keyPath: "idb_id"});
  }
  request.onsuccess = (event) => {
    let db = event.target.result;
    let transaction = db.transaction(["notifications"], "readwrite");
    transaction.objectStore("notifications").add(message);
  }
}

async function _handleNotif(event) {
  let allClientsPromise = clients.matchAll({includeUncontrolled: true});
  event.waitUntil(allClientsPromise);
  let allClients = await allClientsPromise;
  let message = {
    id: event.notification.tag,
    payload: event.notification.data.payload,
    action: event.action,
    reply: event.reply,
    idb_id: "flutter_local_notifications",
  };

  if (allClients.length == 0) {
    let url = `/?notification_id=${encodeURIComponent(message.id)}`
      + `&notification_payload=${encodeURIComponent(message.payload)}`
      + `&notification_action=${encodeURIComponent(message.action)}`
      + `&notification_reply=${encodeURIComponent(message.reply)}`;
    await clients.openWindow(url);
  } else {
    let client = allClients[0];
    await client.postMessage(message);
  }
}

self.addEventListener("notificationclick", _handleNotif);
self.addEventListener("install", event => { self.skipWaiting(); });
self.addEventListener("activate", event => { event.waitUntil(clients.claim()); });
