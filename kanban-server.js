var http = require('http');
var fs = require('fs');
var path = require('path');
var Database = require('better-sqlite3');

// ── Config ──
var PORT = 9090;
var DB_PATH = '/home/ubuntu/.openclaw/workspace/kanban.db';
var STATIC_DIR = '/home/ubuntu/.openclaw/workspace/kanban-app';

// ── Database ──
var db = new Database(DB_PATH);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

db.exec([
  'CREATE TABLE IF NOT EXISTS tasks (',
  '  id TEXT PRIMARY KEY,',
  '  board TEXT NOT NULL DEFAULT "clawdemir",',
  '  col TEXT NOT NULL DEFAULT "backlog",',
  '  title TEXT NOT NULL,',
  '  description TEXT DEFAULT "",',
  '  priority TEXT DEFAULT "medium",',
  '  created_by TEXT DEFAULT "user",',
  '  created_at TEXT DEFAULT "",',
  '  updated_at TEXT DEFAULT "",',
  '  sort_order INTEGER DEFAULT 0',
  ')',
].join('\n'));

// ── Prepared Statements ──
var stmts = {
  list: db.prepare('SELECT * FROM tasks WHERE board = ? ORDER BY col, sort_order, created_at'),
  get: db.prepare('SELECT * FROM tasks WHERE id = ?'),
  insert: db.prepare("INSERT INTO tasks (id, board, col, title, description, priority, created_by, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))"),
  update: db.prepare("UPDATE tasks SET title=?, description=?, priority=?, updated_at=datetime('now') WHERE id=?"),
  move: db.prepare("UPDATE tasks SET col=?, sort_order=?, updated_at=datetime('now') WHERE id=?"),
  remove: db.prepare('DELETE FROM tasks WHERE id=?'),
  maxOrder: db.prepare('SELECT COALESCE(MAX(sort_order), 0) as max_order FROM tasks WHERE board=? AND col=?'),
};

function genId(prefix) {
  return (prefix || 't') + Date.now().toString(36) + Math.random().toString(36).slice(2, 5);
}

function formatBoard(board) {
  var cols = { backlog: [], progress: [], validation: [], done: [] };
  var rows = stmts.list.all(board);
  for (var i = 0; i < rows.length; i++) {
    var r = rows[i];
    if (!cols[r.col]) cols[r.col] = [];
    cols[r.col].push({
      id: r.id,
      title: r.title,
      desc: r.description,
      priority: r.priority,
      date: formatDateBR(r.created_at),
      createdBy: r.created_by,
      sortOrder: r.sort_order
    });
  }
  return cols;
}

function formatDateBR(isoStr) {
  if (!isoStr) return '';
  var d = new Date(isoStr + 'Z');
  return d.toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' });
}

// ── HTTP Server ──
var MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf',
  '.woff2': 'font/woff2',
};

function readBody(req, cb) {
  var chunks = [];
  req.on('data', function(c) { chunks.push(c); });
  req.on('end', function() {
    try { cb(null, JSON.parse(Buffer.concat(chunks).toString())); }
    catch(e) { cb(e); }
  });
}

function json(res, data, status) {
  res.writeHead(status || 200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data));
}

var server = http.createServer(function(req, res) {
  var url = req.url.split('?')[0];

  // ── API Routes ──

  if (req.method === 'GET' && url === '/api/boards') {
    return json(res, { aragorn: formatBoard('aragorn'), clawdemir: formatBoard('clawdemir') });
  }

  if (req.method === 'GET' && url.match(/^\/api\/boards\/(aragorn|clawdemir)$/)) {
    return json(res, formatBoard(url.split('/')[3]));
  }

  if (req.method === 'POST' && url === '/api/tasks') {
    return readBody(req, function(err, body) {
      if (err) return json(res, { error: 'Invalid JSON' }, 400);
      var id = genId(body.createdBy === 'clawdemir' ? 'clw' : 'u');
      var board = body.board || 'clawdemir';
      var col = body.col || 'backlog';
      var maxOrder = stmts.maxOrder.get(board, col).max_order;
      stmts.insert.run(id, board, col, body.title || '', body.desc || '', body.priority || 'medium', body.createdBy || 'user', maxOrder + 1);
      return json(res, stmts.get.get(id), 201);
    });
  }

  if (req.method === 'PUT' && url.match(/^\/api\/tasks\/.+$/)) {
    var id = url.split('/')[3];
    return readBody(req, function(err, body) {
      if (err) return json(res, { error: 'Invalid JSON' }, 400);
      stmts.update.run(body.title || '', body.desc || '', body.priority || 'medium', id);
      return json(res, stmts.get.get(id));
    });
  }

  if (req.method === 'PATCH' && url.match(/^\/api\/tasks\/.+\/move$/)) {
    var id = url.split('/')[3];
    return readBody(req, function(err, body) {
      if (err) return json(res, { error: 'Invalid JSON' }, 400);
      var task = stmts.get.get(id);
      if (!task) return json(res, { error: 'Not found' }, 404);
      var targetCol = body.col || 'backlog';
      var maxOrder = stmts.maxOrder.get(task.board, targetCol).max_order;
      stmts.move.run(targetCol, body.sortOrder != null ? body.sortOrder : maxOrder + 1, id);
      return json(res, stmts.get.get(id));
    });
  }

  if (req.method === 'DELETE' && url.match(/^\/api\/tasks\/.+$/)) {
    var id = url.split('/')[3];
    var task = stmts.get.get(id);
    if (!task) return json(res, { error: 'Not found' }, 404);
    stmts.remove.run(id);
    return json(res, { ok: true, removed: task.title });
  }

  // ── Static Files ──
  var filePath = (url === '/' || url === '/kanban') ? '/index.html' : url;
  var fullPath = path.join(STATIC_DIR, filePath);
  var ext = path.extname(fullPath);

  if (fullPath.indexOf(STATIC_DIR) !== 0) { res.writeHead(403); res.end('Forbidden'); return; }

  fs.readFile(fullPath, function(err, data) {
    if (err) { res.writeHead(404); res.end('Not found'); return; }
    res.writeHead(200, { 'Content-Type': MIME[ext] || 'application/octet-stream' });
    res.end(data);
  });
});

server.listen(PORT, '127.0.0.1', function() {
  console.log('Kanban server on http://127.0.0.1:' + PORT);
});
