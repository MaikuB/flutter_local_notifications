'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

function _handleNotif(event) {
  console.log(`Clicked: ${event}`);
  clients.openWindow("/about");

}

self.addEventListener("notificationclick", _handleNotif);
