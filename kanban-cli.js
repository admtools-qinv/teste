#!/usr/bin/env node
/* kanban-cli.js — Clawdemir task manager
   Usage:
     node kanban-cli.js add <board> <column> <title> [desc] [priority]
     node kanban-cli.js move <board> <id> <to-column>
     node kanban-cli.js list [board]
     node kanban-cli.js remove <board> <id>
*/

var fs = require('fs');
var DATA_PATH = '/home/ubuntu/.npm-global/lib/node_modules/openclaw/dist/control-ui/apps/kanban-data.json';

function load() {
  return JSON.parse(fs.readFileSync(DATA_PATH, 'utf8'));
}

function save(data) {
  data.version = (data.version || 0) + 1;
  fs.writeFileSync(DATA_PATH, JSON.stringify(data, null, 2));
}

var args = process.argv.slice(2);
var cmd = args[0];

if (cmd === 'add') {
  var board = args[1] || 'clawdemir';
  var col = args[2] || 'backlog';
  var title = args[3];
  var desc = args[4] || '';
  var priority = args[5] || 'medium';
  if (!title) { console.log('Usage: add <board> <column> <title> [desc] [priority]'); process.exit(1); }
  var data = load();
  var id = 'clw' + Date.now().toString(36);
  var date = new Date().toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' });
  data[board][col].push({ id: id, title: title, desc: desc, priority: priority, date: date, createdBy: 'clawdemir' });
  save(data);
  console.log('Added "' + title + '" to ' + board + '/' + col + ' (id: ' + id + ')');
}

else if (cmd === 'move') {
  var board = args[1];
  var id = args[2];
  var toCol = args[3];
  var data = load();
  var cols = ['backlog', 'progress', 'validation', 'done'];
  var found = false;
  for (var c = 0; c < cols.length; c++) {
    var tasks = data[board][cols[c]];
    for (var i = 0; i < tasks.length; i++) {
      if (tasks[i].id === id) {
        var task = tasks.splice(i, 1)[0];
        data[board][toCol].push(task);
        save(data);
        console.log('Moved "' + task.title + '" to ' + toCol);
        found = true;
        break;
      }
    }
    if (found) break;
  }
  if (!found) console.log('Task not found: ' + id);
}

else if (cmd === 'list') {
  var board = args[1];
  var data = load();
  var boards = board ? [board] : ['aragorn', 'clawdemir'];
  var cols = ['backlog', 'progress', 'validation', 'done'];
  for (var b = 0; b < boards.length; b++) {
    console.log('\n=== ' + boards[b].toUpperCase() + ' ===');
    for (var c = 0; c < cols.length; c++) {
      var tasks = data[boards[b]][cols[c]];
      if (tasks.length > 0) {
        console.log('\n  ' + cols[c] + ':');
        for (var i = 0; i < tasks.length; i++) {
          console.log('    [' + tasks[i].id + '] ' + tasks[i].title + ' (' + tasks[i].priority + ')');
        }
      }
    }
  }
}

else if (cmd === 'remove') {
  var board = args[1];
  var id = args[2];
  var data = load();
  var cols = ['backlog', 'progress', 'validation', 'done'];
  for (var c = 0; c < cols.length; c++) {
    var tasks = data[board][cols[c]];
    for (var i = 0; i < tasks.length; i++) {
      if (tasks[i].id === id) {
        var removed = tasks.splice(i, 1)[0];
        save(data);
        console.log('Removed "' + removed.title + '"');
        process.exit(0);
      }
    }
  }
  console.log('Task not found: ' + id);
}

else {
  console.log('Commands: add, move, list, remove');
}
