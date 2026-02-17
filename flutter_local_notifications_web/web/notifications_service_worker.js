'use strict';

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

// Listen for notification events.
self.addEventListener("notificationclick", _handleNotif);

// Normally, a service worker only takes effect the _next_ time it is installed.
// These next lines make sure it takes effect the first time,
self.addEventListener("install", event => { self.skipWaiting(); });
self.addEventListener("activate", event => { event.waitUntil(clients.claim()); });
