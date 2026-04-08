// Standardized API response helpers

function ok(res, data, meta) {
  const body = { success: true, data };
  if (meta) body.meta = meta;
  return res.json(body);
}

function created(res, data) {
  return res.status(201).json({ success: true, data });
}

function noContent(res) {
  return res.status(204).end();
}

function paginated(res, data, { page, limit, total }) {
  return res.json({
    success: true,
    data,
    meta: { page, limit, total, pages: Math.ceil(total / limit) },
  });
}

module.exports = { ok, created, noContent, paginated };
