const db = require('../config/db');

async function log(adminEmail, action, target, category, oldValue, newValue) {
  try {
    await db('admin_logs').insert({
      action, target, category,
      admin_user: adminEmail || 'system',
      old_value: oldValue || null,
      new_value: newValue || null,
      result: 'success',
    });
  } catch { /* non-blocking */ }
}

module.exports = { log };
