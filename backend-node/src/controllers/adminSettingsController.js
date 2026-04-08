const db = require('../config/db');
const { ok } = require('../utils/response');
const { log } = require('../services/logService');

async function getAll(req, res, next) {
  try {
    const rows = await db('admin_settings').select('*');
    const settings = {};
    rows.forEach((r) => { settings[r.key] = r.value; });
    ok(res, settings);
  } catch (e) { next(e); }
}

async function update(req, res, next) {
  try {
    const entries = Object.entries(req.body);
    for (const [key, value] of entries) {
      await db('admin_settings')
        .insert({ key, value: String(value), updated_at: db.fn.now() })
        .onConflict('key')
        .merge({ value: String(value), updated_at: db.fn.now() });
    }
    await log(req.user.email, 'Updated settings', entries.map(([k]) => k).join(', '), 'Settings');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { getAll, update };
