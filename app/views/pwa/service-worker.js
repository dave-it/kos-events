// Service Worker der installierten App.
// - Statische Dateien (mit Fingerabdruck im Namen) kommen aus dem Cache.
// - Seiten kommen immer aus dem Netz; ohne Verbindung erscheint die Offline-Seite.
//   Seiten werden bewusst nicht gespeichert, damit keine persönlichen Daten auf dem Gerät liegen bleiben.
const VERSION = "ice-cross-v1"
const PRECACHE = ["/offline.html", "/icons/icon-192.png"]

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(VERSION).then((cache) => cache.addAll(PRECACHE)).then(() => self.skipWaiting()))
})

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== VERSION).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  )
})

self.addEventListener("fetch", (event) => {
  const request = event.request
  const url = new URL(request.url)
  if (request.method !== "GET" || url.origin !== self.location.origin) return

  if (request.mode === "navigate") {
    event.respondWith(fetch(request).catch(() => caches.match("/offline.html")))
  } else if (url.pathname.startsWith("/assets/") || url.pathname.startsWith("/icons/")) {
    event.respondWith(
      caches.match(request).then((cached) => cached || fetch(request).then((response) => {
        if (response.ok) {
          const copy = response.clone()
          caches.open(VERSION).then((cache) => cache.put(request, copy))
        }
        return response
      }))
    )
  }
})
