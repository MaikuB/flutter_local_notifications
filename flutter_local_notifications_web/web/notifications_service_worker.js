'use strict';

function _handleNotif(event) {
  console.log(`Clicked: ${event}`);
  clients.openWindow("/about");

}

self.addEventListener("notificationclick", _handleNotif);
