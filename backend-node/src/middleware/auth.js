const jwt = require('jsonwebtoken');

function authenticate(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: 'Authentication required.' });
  }
  try {
    req.user = jwt.verify(header.slice(7), process.env.JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ success: false, error: 'Invalid or expired token.' });
  }
}

function requireAdmin(req, res, next) {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ success: false, error: 'Admin access required.' });
  }
  next();
}

// Require specific admin role(s). Usage: requireRole('super_admin', 'moderation_admin')
function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || req.user.role !== 'admin') {
      return res.status(403).json({ success: false, error: 'Admin access required.' });
    }
    if (roles.length > 0 && !roles.includes(req.user.admin_role)) {
      return res.status(403).json({ success: false, error: `Requires role: ${roles.join(' or ')}.` });
    }
    next();
  };
}

module.exports = { authenticate, requireAdmin, requireRole };
