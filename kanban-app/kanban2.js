/* ═══════════════════════════════════════════
   Kanban JS — Apple HIG Interactions
   ═══════════════════════════════════════════ */

var COLUMNS = [
  { id: 'backlog', title: 'Backlog', icon: 'inbox', emptyMsg: 'Nenhuma tarefa pendente' },
  { id: 'progress', title: 'Em Progresso', icon: 'bolt', emptyMsg: 'Arraste tarefas para cá' },
  { id: 'validation', title: 'Em Validação', icon: 'search', emptyMsg: 'Aguardando revisão' },
  { id: 'done', title: 'Concluído', icon: 'check', emptyMsg: 'Nada concluído ainda' }
];

var SVG_ICONS = {
  inbox: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12H16L14 15H10L8 12H2"/><path d="M5.45 5.11L2 12V18A2 2 0 0 0 4 20H20A2 2 0 0 0 22 18V12L18.55 5.11A2 2 0 0 0 16.76 4H7.24A2 2 0 0 0 5.45 5.11Z"/></svg>',
  bolt: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
  search: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>',
  check: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>',
  bot: '<svg viewBox="0 0 16 16"><rect x="3" y="5" width="10" height="8" rx="2" fill="currentColor"/><circle cx="6" cy="9" r="1" fill="var(--bg-secondary)"/><circle cx="10" cy="9" r="1" fill="var(--bg-secondary)"/><line x1="8" y1="2" x2="8" y2="5" stroke="currentColor" stroke-width="1.5"/><circle cx="8" cy="1.5" r="1" fill="currentColor"/></svg>'
};

var API = window.location.origin + '/api';
var currentBoard = 'clawdemir';
var addingToColumn = null;
var dragSource = null;
var selectedPriority = 'medium';
var pendingDelete = null;
var boardData = { aragorn: emptyBoard(), clawdemir: emptyBoard() };

function emptyBoard() { return { backlog: [], progress: [], validation: [], done: [] }; }

/* ── API ── */

function api(method, path, body, cb) {
  var xhr = new XMLHttpRequest();
  xhr.open(method, API + path, true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.onload = function () {
    try { cb(null, JSON.parse(xhr.responseText)); }
    catch (e) { cb(e); }
  };
  xhr.onerror = function () { cb(new Error('Network error')); };
  xhr.send(body ? JSON.stringify(body) : null);
}

function fetchBoards(cb) {
  api('GET', '/boards', null, function (err, data) {
    if (!err && data) boardData = data;
    if (cb) cb();
  });
}

/* ── Helpers ── */

function esc(s) {
  var d = document.createElement('div');
  d.textContent = s;
  return d.innerHTML;
}

function greeting() {
  var h = new Date().getHours();
  return h < 12 ? 'Bom dia' : h < 18 ? 'Boa tarde' : 'Boa noite';
}

function formatDate(ds) {
  if (!ds) return '';
  var now = new Date();
  var t = now.toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' });
  var y = new Date(now - 864e5).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' });
  if (ds === t) return 'Hoje';
  if (ds === y) return 'Ontem';
  return ds;
}

function todayLong() {
  var s = new Date().toLocaleDateString('pt-BR', { weekday: 'long', day: 'numeric', month: 'long' });
  return s.charAt(0).toUpperCase() + s.slice(1);
}

/* ── Toast ── */

function toast(color, msg) {
  var c = document.getElementById('toasts');
  var el = document.createElement('div');
  el.className = 'toast';
  el.innerHTML = '<span class="toast-dot" style="background:' + color + '"></span>' + esc(msg);
  c.appendChild(el);
  setTimeout(function () {
    el.classList.add('out');
    setTimeout(function () { el.remove(); }, 300);
  }, 2500);
}

/* ── Render ── */

function render(animate) {
  var board = boardData[currentBoard] || emptyBoard();
  var owner = currentBoard === 'aragorn' ? 'Aragorn' : 'Clawdemir';

  // Header
  document.getElementById('subtitle').textContent = greeting() + ' \u2014 ' + todayLong();

  // Stats
  var total = 0;
  for (var k in board) total += board[k].length;
  var done = board.done.length;
  var pct = total > 0 ? Math.round((done / total) * 100) : 0;

  document.getElementById('progressFill').style.width = pct + '%';

  document.getElementById('stats').innerHTML =
    statBlock(total, 'Total', false) +
    statBlock(board.progress.length, 'Progresso', false) +
    statBlock(board.validation.length, 'Validação', false) +
    statBlock(done, 'Concluído', true);

  // Board
  var h = '';
  for (var c = 0; c < COLUMNS.length; c++) {
    var col = COLUMNS[c];
    var tasks = board[col.id] || [];

    h += '<section class="column">';
    h += '<div class="col-header"><span class="col-title">' + col.title + '</span><div class="col-header-right">';
    if (col.id === 'backlog') h += '<button class="add-btn">+ Criar task</button>';
    h += '<span class="col-count' + (tasks.length > 0 ? ' has-items' : '') + '">' + tasks.length + '</span>';
    h += '</div></div>';
    h += '<div class="col-body" data-column="' + col.id + '">';

    if (tasks.length === 0) {
      h += '<div class="empty-state"><div class="empty-icon">' + SVG_ICONS[col.icon] + '</div><span class="empty-text">' + col.emptyMsg + '</span></div>';
    } else {
      for (var i = 0; i < tasks.length; i++) {
        var t = tasks[i];
        var delay = animate ? (i * 35) : 0;
        var botBadge = t.createdBy === 'clawdemir' ? '<span class="task-bot">' + SVG_ICONS.bot + '</span>' : '';

        h += '<article class="task-card" draggable="true" data-id="' + t.id + '" style="animation-delay:' + delay + 'ms">';
        h += '<span class="task-priority p-' + t.priority + '"></span>';
        h += '<button class="task-delete" data-id="' + t.id + '">\u2715</button>';
        h += '<div class="task-title">' + esc(t.title) + '</div>';
        if (t.desc) h += '<div class="task-desc">' + esc(t.desc) + '</div>';
        h += '<div class="task-meta"><span class="task-date">' + formatDate(t.date) + '</span>' + botBadge + '</div>';
        h += '</article>';
      }
    }

    h += '</div>';
    h += '</section>';
  }
  document.getElementById('board').innerHTML = h;
}

function statBlock(value, label, accent) {
  return '<div class="stat-block' + (accent ? ' stat-accent' : '') + '"><span class="stat-value">' + value + '</span><span class="stat-label">' + label + '</span></div>';
}

/* ── Segmented Control ── */

function switchBoard(board) {
  if (board === currentBoard) return;
  currentBoard = board;
  var segs = document.querySelectorAll('.segment');
  var pill = document.getElementById('segmentPill');
  for (var i = 0; i < segs.length; i++) {
    segs[i].classList.toggle('active', segs[i].getAttribute('data-board') === board);
  }
  pill.classList.toggle('right', board !== 'clawdemir');
  render(true);
}

/* ── Modal ── */

function openModal(colId) {
  addingToColumn = colId;
  selectedPriority = 'medium';
  document.getElementById('taskTitle').value = '';
  document.getElementById('taskDesc').value = '';
  updatePriority();
  var m = document.getElementById('modal');
  m.classList.remove('closing');
  m.classList.add('open');
  setTimeout(function () { document.getElementById('taskTitle').focus(); }, 150);
}

function closeModal() {
  var m = document.getElementById('modal');
  m.classList.add('closing');
  setTimeout(function () { m.classList.remove('open', 'closing'); }, 250);
  addingToColumn = null;
}

function updatePriority() {
  var opts = document.querySelectorAll('.priority-option');
  for (var i = 0; i < opts.length; i++) {
    opts[i].classList.toggle('selected', opts[i].getAttribute('data-priority') === selectedPriority);
  }
}

function saveTask() {
  var inp = document.getElementById('taskTitle');
  var title = inp.value.trim();
  if (!title) {
    inp.classList.add('shake');
    setTimeout(function () { inp.classList.remove('shake'); }, 400);
    return;
  }
  var desc = document.getElementById('taskDesc').value.trim();
  api('POST', '/tasks', {
    board: currentBoard, col: addingToColumn,
    title: title, desc: desc, priority: selectedPriority, createdBy: 'user'
  }, function (err) {
    if (err) { toast('var(--red)', 'Erro ao criar'); return; }
    closeModal();
    fetchBoards(function () { render(true); });
    toast('#30D158', 'Tarefa criada');
  });
}

/* ── Delete ── */

function showDeleteConfirm(card, taskId) {
  if (pendingDelete) return;
  pendingDelete = taskId;
  var el = document.createElement('div');
  el.className = 'delete-confirm';
  el.innerHTML = '<span class="dc-text">Remover?</span><button class="dc-btn dc-yes" data-action="yes">Sim</button><button class="dc-btn dc-no" data-action="no">N\u00e3o</button>';
  card.appendChild(el);
}

function confirmDelete(yes) {
  if (!pendingDelete) return;
  if (yes) {
    api('DELETE', '/tasks/' + pendingDelete, null, function (err) {
      if (err) { toast('#FF453A', 'Erro ao remover'); return; }
      fetchBoards(function () { render(false); });
      toast('#FF453A', 'Tarefa removida');
    });
  } else {
    var el = document.querySelector('.delete-confirm');
    if (el) el.remove();
  }
  pendingDelete = null;
}

/* ── Detail Modal ── */

var editingTask = null;
var editPriority = 'medium';

function openDetail(taskId) {
  var board = boardData[currentBoard] || emptyBoard();
  var task = null;
  var cols = ['backlog', 'progress', 'validation', 'done'];
  for (var c = 0; c < cols.length; c++) {
    var tasks = board[cols[c]] || [];
    for (var i = 0; i < tasks.length; i++) {
      if (tasks[i].id === taskId) { task = tasks[i]; break; }
    }
    if (task) break;
  }
  if (!task) return;

  editingTask = task;
  editPriority = task.priority;

  document.getElementById('detailTitle').textContent = task.title;
  document.getElementById('detailDesc').textContent = task.desc || 'Sem descrição';
  document.getElementById('detailDate').textContent = 'Criado: ' + formatDate(task.date);
  document.getElementById('detailAuthor').textContent = task.createdBy === 'clawdemir' ? 'Por: Clawdemir' : 'Por: Aragorn';

  var dp = document.getElementById('detailPriority');
  dp.className = 'task-priority p-' + task.priority;

  document.getElementById('editTitle').value = task.title;
  document.getElementById('editDesc').value = task.desc || '';
  updateEditPriority();

  var m = document.getElementById('detailModal');
  m.classList.remove('closing');
  m.classList.add('open');
}

function closeDetail() {
  var m = document.getElementById('detailModal');
  m.classList.add('closing');
  setTimeout(function () { m.classList.remove('open', 'closing'); }, 250);
  editingTask = null;
}

function updateEditPriority() {
  var opts = document.querySelectorAll('[data-edit-priority]');
  for (var i = 0; i < opts.length; i++) {
    opts[i].classList.toggle('selected', opts[i].getAttribute('data-edit-priority') === editPriority);
  }
}

function saveDetail() {
  if (!editingTask) return;
  var title = document.getElementById('editTitle').value.trim();
  if (!title) return;
  var desc = document.getElementById('editDesc').value.trim();

  api('PUT', '/tasks/' + editingTask.id, {
    title: title, desc: desc, priority: editPriority
  }, function (err) {
    if (err) { toast('#FF453A', 'Erro ao salvar'); return; }
    closeDetail();
    fetchBoards(function () { render(false); });
    toast('#30D158', 'Tarefa atualizada');
  });
}

/* ── Events ── */

document.addEventListener('click', function (e) {
  var dc = e.target.closest('.dc-btn');
  if (dc) { confirmDelete(dc.getAttribute('data-action') === 'yes'); return; }

  var seg = e.target.closest('.segment');
  if (seg) { switchBoard(seg.getAttribute('data-board')); return; }

  var add = e.target.closest('.add-btn');
  if (add) {
    openModal('backlog');
    return;
  }

  var del = e.target.closest('.task-delete');
  if (del) {
    e.stopPropagation();
    showDeleteConfirm(del.closest('.task-card'), del.getAttribute('data-id'));
    return;
  }

  // Edit priority in detail modal
  var ep = e.target.closest('[data-edit-priority]');
  if (ep) { editPriority = ep.getAttribute('data-edit-priority'); updateEditPriority(); return; }

  // Detail modal actions
  if (e.target.closest('.btn-detail-close')) { closeDetail(); return; }
  if (e.target.closest('.btn-detail-save')) { saveDetail(); return; }
  if (e.target.id === 'detailModal') { closeDetail(); return; }

  // Click on task card to open detail
  var card = e.target.closest('.task-card');
  if (card && !e.target.closest('.task-delete') && !e.target.closest('.delete-confirm')) {
    openDetail(card.getAttribute('data-id'));
    return;
  }

  var po = e.target.closest('.priority-option:not([data-edit-priority])');
  if (po) { selectedPriority = po.getAttribute('data-priority'); updatePriority(); return; }

  if (e.target.closest('.btn-cancel')) { closeModal(); return; }
  if (e.target.closest('.btn-save')) { saveTask(); return; }
  if (e.target.id === 'modal') closeModal();
});

document.addEventListener('keydown', function (e) {
  if (e.key === 'Escape') {
    if (pendingDelete) { confirmDelete(false); return; }
    if (document.getElementById('detailModal').classList.contains('open')) { closeDetail(); return; }
    closeModal();
  }
  if (e.key === 'Enter' && document.getElementById('modal').classList.contains('open')) {
    if (document.activeElement.tagName !== 'TEXTAREA') saveTask();
  }
});

/* ── Drag & Drop ── */

document.addEventListener('dragstart', function (e) {
  var card = e.target.closest('.task-card');
  if (!card) return;
  dragSource = { col: card.parentElement.getAttribute('data-column'), id: card.getAttribute('data-id') };
  setTimeout(function () { card.classList.add('dragging'); }, 0);
  e.dataTransfer.effectAllowed = 'move';
});

document.addEventListener('dragend', function (e) {
  var card = e.target.closest('.task-card');
  if (card) card.classList.remove('dragging');
  var all = document.querySelectorAll('.drag-over');
  for (var i = 0; i < all.length; i++) all[i].classList.remove('drag-over');
  dragSource = null;
});

document.addEventListener('dragover', function (e) {
  var body = e.target.closest('.col-body');
  if (body) { e.preventDefault(); body.classList.add('drag-over'); }
});

document.addEventListener('dragleave', function (e) {
  if (e.target.classList && e.target.classList.contains('col-body')) {
    e.target.classList.remove('drag-over');
  }
});

document.addEventListener('drop', function (e) {
  var body = e.target.closest('.col-body');
  if (!body || !dragSource) return;
  e.preventDefault();
  body.classList.remove('drag-over');
  var target = body.getAttribute('data-column');
  if (target === dragSource.col) { dragSource = null; return; }

  // Optimistic update — move locally first
  var board = boardData[currentBoard];
  var srcTasks = board[dragSource.col];
  var taskIdx = -1;
  for (var j = 0; j < srcTasks.length; j++) {
    if (srcTasks[j].id === dragSource.id) { taskIdx = j; break; }
  }
  if (taskIdx >= 0) {
    var task = srcTasks.splice(taskIdx, 1)[0];
    board[target].push(task);
    render(true);
  }

  var name = target;
  for (var i = 0; i < COLUMNS.length; i++) {
    if (COLUMNS[i].id === target) { name = COLUMNS[i].title; break; }
  }
  toast('#E8453C', 'Movida para ' + name);

  // Then sync with API
  api('PATCH', '/tasks/' + dragSource.id + '/move', { col: target }, function (err) {
    if (err) {
      // Revert on error
      fetchBoards(function () { render(false); });
      toast('#FF453A', 'Erro ao sincronizar');
    }
  });
  dragSource = null;
});

/* ── Auto-refresh ── */
setInterval(function () { fetchBoards(function () { render(false); }); }, 30000);

/* ── Init ── */
fetchBoards(function () { render(true); });
