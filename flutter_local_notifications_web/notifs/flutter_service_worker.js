'use strict';

async function _handleNotif(event) {
  let allClients = await clients.matchAll({includeUncontrolled: true});
  if (allClients.length == 0) {
    // TODO: Background notification click
    console.log("TODO: Background click")
  } else {
    let client = allClients[0];
    let message = {
      action: event.action,
      id: event.notification.tag,
      payload: event.notification.data.payload,
      reply: event.reply,
    };
    client.postMessage(message);
  }
}

self.addEventListener("notificationclick", _handleNotif);
self.addEventListener("install", event => { self.skipWaiting(); });
self.addEventListener("activate", event => { event.waitUntil(clients.claim()); });
