'use strict';

// Experimental function to save a notification to the IndexedDB database
//
// This function isn't currently used but left because it may be helpful in other
// implementations of this plugin or custom needs for some apps.
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

// Handles a clicked notification.
//
// If the site is open, sends the information to the site using postMessage().
// Otherwise, open the site with notification details as query parameters.
async function _handleNotif(event) {
  // We have to use `event.waitUntil()` to tell the browser that we're still
  // processing this event. Without this, the event "expires" after the first
  // `await`, and trying to call `clients.openWindow()` later results in a
  // permission error, because the browser thinks they are unrelated events.
  let allClientsPromise = clients.matchAll({includeUncontrolled: true});
  event.waitUntil(allClientsPromise);
  let allClients = await allClientsPromise;

  let message = {
    id: event.notification.tag,
    payload: event.notification.data.payload,
    action: event.action,
    reply: event.reply,
    // This is only used for saveMessage() above.
    idb_id: "flutter_local_notifications",
  };
  // If you need to hold onto the message:
  // saveMessage(message)

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

// Listen for notification events.
self.addEventListener("notificationclick", _handleNotif);

// Normally, a service worker only takes effect the _next_ time it is installed.
// These next lines make sure it takes effect the first time,
self.addEventListener("install", event => { self.skipWaiting(); });
self.addEventListener("activate", event => { event.waitUntil(clients.claim()); });
