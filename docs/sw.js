// My Campus Life - legacy service worker KILL SWITCH.
// Older builds registered this worker with a fixed cache-first strategy that pinned stale
// game files (players never received updates). Godot's own versioned worker
// (index.service.worker.js) now handles offline caching correctly, so this worker
// deletes its old cache and unregisters itself for anyone who still has it installed.
self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
	event.waitUntil((async () => {
		const keys = await caches.keys();
		await Promise.all(keys.filter((k) => k.startsWith('my-campus-life-')).map((k) => caches.delete(k)));
		await self.registration.unregister();
		const clients = await self.clients.matchAll({ type: 'window' });
		clients.forEach((client) => client.navigate(client.url));
	})());
});
