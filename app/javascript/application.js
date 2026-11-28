// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Installierbare App: Service Worker anmelden und das Installationsangebot des Browsers merken.
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service-worker").catch(() => {})
}

window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault()
  window.deferredInstall = event
  window.dispatchEvent(new CustomEvent("app:installable"))
})
