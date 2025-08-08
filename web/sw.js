const CACHE_NAME = 'portfolio-cache-v1';
const STATIC_CACHE = 'static-cache-v1';
const API_CACHE = 'api-cache-v1';

// Resources to cache immediately
const PRECACHE_RESOURCES = [
  '/',
  '/manifest.json',
  'icons/icon-192.png',
  'icons/icon-512.png',
  'icons/apple-touch-icon.png',
  'favicon.ico'
];

// API endpoints to cache with network-first strategy
const API_ENDPOINTS = [
  'https://api.zotero.org',
  'https://api.opencitations.net'
];

// Install event - cache static resources
self.addEventListener('install', event => {
  event.waitUntil(
    Promise.all([
      caches.open(STATIC_CACHE).then(cache => {
        return cache.addAll(PRECACHE_RESOURCES);
      })
    ])
  );
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME && 
              cacheName !== STATIC_CACHE && 
              cacheName !== API_CACHE) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', event => {
  const requestUrl = new URL(event.request.url);
  
  // Handle API requests with network-first strategy
  if (isApiRequest(requestUrl)) {
    event.respondWith(networkFirstStrategy(event.request));
    return;
  }
  
  // Handle static assets with cache-first strategy
  if (isStaticAsset(requestUrl)) {
    event.respondWith(cacheFirstStrategy(event.request));
    return;
  }
  
  // Handle Flutter assets and main app with stale-while-revalidate
  if (isFlutterAsset(requestUrl) || requestUrl.pathname === '/') {
    event.respondWith(staleWhileRevalidateStrategy(event.request));
    return;
  }
  
  // Default: network-only for other requests
  event.respondWith(fetch(event.request));
});

// Check if request is for API endpoints
function isApiRequest(url) {
  return API_ENDPOINTS.some(endpoint => url.href.startsWith(endpoint));
}

// Check if request is for static assets
function isStaticAsset(url) {
  const staticExtensions = ['.png', '.jpg', '.jpeg', '.svg', '.ico', '.css', '.js', '.woff', '.woff2', '.ttf'];
  return staticExtensions.some(ext => url.pathname.endsWith(ext)) ||
         url.pathname.startsWith('/icons/') ||
         url.pathname === '/favicon.ico' ||
         url.pathname === '/manifest.json';
}

// Check if request is for Flutter-generated assets
function isFlutterAsset(url) {
  return url.pathname.startsWith('/assets/') ||
         url.pathname.includes('flutter') ||
         url.pathname.endsWith('.dart.js') ||
         url.pathname.endsWith('.js.map');
}

// Network-first strategy (good for API calls)
async function networkFirstStrategy(request) {
  try {
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      const cache = await caches.open(API_CACHE);
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch (error) {
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    // Return a fallback response for API failures
    return new Response(JSON.stringify({ error: 'Network error, no cached data available' }), {
      status: 503,
      statusText: 'Service Unavailable',
      headers: { 'Content-Type': 'application/json' }
    });
  }
}

// Cache-first strategy (good for static assets)
async function cacheFirstStrategy(request) {
  const cachedResponse = await caches.match(request);
  if (cachedResponse) {
    return cachedResponse;
  }
  
  try {
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      const cache = await caches.open(STATIC_CACHE);
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch (error) {
    // Return a fallback for missing assets
    if (request.destination === 'image') {
      return new Response('', { status: 404, statusText: 'Image not found' });
    }
    throw error;
  }
}

// Stale-while-revalidate strategy (good for app shell)
async function staleWhileRevalidateStrategy(request) {
  const cache = await caches.open(CACHE_NAME);
  const cachedResponse = await cache.match(request);
  
  const fetchPromise = fetch(request).then(networkResponse => {
    if (networkResponse.ok) {
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  }).catch(() => {
    // If network fails, we'll return cached version if available
    return cachedResponse;
  });
  
  // Return cached version immediately if available, otherwise wait for network
  return cachedResponse || fetchPromise;
}

// Background sync for failed API requests
self.addEventListener('sync', event => {
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

async function doBackgroundSync() {
  // Implement background sync logic if needed for your use case
  console.log('Background sync triggered');
}

// Handle push notifications if needed in the future
self.addEventListener('push', event => {
  const options = {
    body: event.data ? event.data.text() : 'New notification',
    icon: 'icons/icon-192.png',
    badge: 'icons/icon-192.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    }
  };
  
  event.waitUntil(
    self.registration.showNotification('Portfolio Update', options)
  );
});