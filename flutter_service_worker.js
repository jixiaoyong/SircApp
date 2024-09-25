'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "ea4468e39f3d397fa0481d593622c627",
"assets/assets/ic_launcher.png": "54cf4970601ecd3df8762475dec3f747",
"assets/assets/imgs/initial_pin_error.png": "bdbcf691cd75cb8629a89ab76cfbf160",
"assets/assets/imgs/bank_chip.png": "3a60a36047cf4d7fd63d702b6f89c9e8",
"assets/assets/imgs/initial_exchange.png": "7ea6a659ee09cffc9d1abed398427202",
"assets/assets/imgs/splash.png": "7df6f10c7ff5fe9cba7a5168235d4dc1",
"assets/assets/imgs/initial_password.png": "8da8e6731365512945ef8106e46c0925",
"assets/assets/imgs/3.0x/initial_pin_error.png": "793d90c21d83639177ea8a7a9b18eca6",
"assets/assets/imgs/3.0x/bank_chip.png": "848e6184deb5b0c038254433df98d707",
"assets/assets/imgs/3.0x/initial_exchange.png": "cd769456d873ef260af69038acc6e830",
"assets/assets/imgs/3.0x/initial_password.png": "549d0577d2f7b4a76a63128f71697fd1",
"assets/assets/imgs/2.0x/initial_pin_error.png": "6b915475d333c3c1eef5129e186831fc",
"assets/assets/imgs/2.0x/bank_chip.png": "672b0876261acb9ff2f695d19ff7133e",
"assets/assets/imgs/2.0x/initial_exchange.png": "94ea315b903938dd3d023a4c0e24bdef",
"assets/assets/imgs/2.0x/initial_password.png": "fa8319300deefb67eff600702e85ac00",
"assets/shaders/ink_sparkle.frag": "bb6af69544daba10b8bb89e60edaa055",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "ca62bb7a05e897c40336990c0aa2bbea",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/packages/toast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/toast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"canvaskit/canvaskit.js": "2bc454a691c631b07a9307ac4ca47797",
"canvaskit/canvaskit.wasm": "bf50631470eb967688cca13ee181af62",
"canvaskit/profiling/canvaskit.js": "38164e5a72bdad0faa4ce740c9b8e564",
"canvaskit/profiling/canvaskit.wasm": "95a45378b69e77af5ed2bc72b2209b94",
"main.dart.js": "ea22f1b7da8071505068777d13e7ea6a",
"icons/ic_launcher.png": "54cf4970601ecd3df8762475dec3f747",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"favicon.png": "54cf4970601ecd3df8762475dec3f747",
"flutter.js": "f85e6fb278b0fd20c349186fb46ae36d",
"index.html": "ce08f58425ce7ad814984f635c2c7169",
"/": "ce08f58425ce7ad814984f635c2c7169",
"version.json": "6e610a922f7f2457d66a6495449a6518",
"manifest.json": "ba8927c3d12ffe4b7047ab854d79c7d4",
"splash/style.css": "db6178791b6369b77311c0ae92809585",
"splash/img/light-2x.png": "56fdb5cefb83985b19aee88ca6d826b3",
"splash/img/dark-4x.png": "e2dd284bb37be026a4dec8ff98313a00",
"splash/img/dark-1x.png": "a284cec7f1dee67df059460b9e3e8313",
"splash/img/light-1x.png": "a284cec7f1dee67df059460b9e3e8313",
"splash/img/dark-2x.png": "56fdb5cefb83985b19aee88ca6d826b3",
"splash/img/dark-3x.png": "4642babac53c569e81bc79e2b16a640e",
"splash/img/light-4x.png": "e2dd284bb37be026a4dec8ff98313a00",
"splash/img/light-3x.png": "4642babac53c569e81bc79e2b16a640e",
"splash/splash.js": "c6a271349a0cd249bdb6d3c4d12f5dcf"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
