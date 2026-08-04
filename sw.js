const CACHE = 'lingo-v3';
const files = ['./','./index.html','./styles.css','./app.js','./manifest.webmanifest','./icon.svg'];
self.addEventListener('install', e => e.waitUntil(caches.open(CACHE).then(c => c.addAll(files))));
self.addEventListener('fetch', e => e.respondWith(
  fetch(e.request).then(response => {
    if (e.request.method === 'GET' && response.ok) {
      const copy = response.clone();
      caches.open(CACHE).then(cache => cache.put(e.request, copy));
    }
    return response;
  }).catch(() => caches.match(e.request))
));
