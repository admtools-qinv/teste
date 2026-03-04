const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 7070;
const GATEWAY = 'http://127.0.0.1:18789';
const STATIC_DIR = '/home/ubuntu/.openclaw/workspace';

// Static file routes
const STATIC_ROUTES = {
  '/kanban': 'kanban.html',
  '/kanban.html': 'kanban.html',
};

const MIME = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.woff2': 'font/woff2',
  '.woff': 'font/woff',
};

const server = http.createServer((req, res) => {
  // Check static routes
  const staticFile = STATIC_ROUTES[req.url.split('?')[0]];
  if (staticFile) {
    const filePath = path.join(STATIC_DIR, staticFile);
    const ext = path.extname(filePath);
    fs.readFile(filePath, (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end('Not found');
        return;
      }
      res.writeHead(200, { 'Content-Type': MIME[ext] || 'text/html' });
      res.end(data);
    });
    return;
  }

  // Proxy everything else to gateway
  const opts = {
    hostname: '127.0.0.1',
    port: 18789,
    path: req.url,
    method: req.method,
    headers: { ...req.headers, host: '127.0.0.1:18789' },
  };

  const proxy = http.request(opts, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res, { end: true });
  });

  proxy.on('error', (e) => {
    res.writeHead(502);
    res.end('Gateway unreachable');
  });

  req.pipe(proxy, { end: true });
});

// WebSocket upgrade passthrough
server.on('upgrade', (req, socket, head) => {
  const opts = {
    hostname: '127.0.0.1',
    port: 18789,
    path: req.url,
    method: req.method,
    headers: { ...req.headers, host: '127.0.0.1:18789' },
  };

  const proxy = http.request(opts);

  proxy.on('upgrade', (proxyRes, proxySocket, proxyHead) => {
    socket.write(
      `HTTP/1.1 ${proxyRes.statusCode || 101} ${proxyRes.statusMessage || 'Switching Protocols'}\r\n` +
      Object.entries(proxyRes.headers).map(([k, v]) => `${k}: ${v}`).join('\r\n') +
      '\r\n\r\n'
    );
    if (proxyHead.length) socket.write(proxyHead);
    proxySocket.pipe(socket);
    socket.pipe(proxySocket);
  });

  proxy.on('error', () => socket.end());

  proxy.end();
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Reverse proxy running on http://127.0.0.1:${PORT}`);
  console.log(`  /kanban → static file`);
  console.log(`  /* → gateway (${GATEWAY})`);
});
