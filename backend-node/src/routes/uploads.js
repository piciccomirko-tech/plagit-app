const router = require('express').Router();
const multer = require('multer');
const { authenticate } = require('../middleware/auth');
const { uploadAudio } = require('../controllers/uploadController');

// In-memory parsing — controller hands the buffer to the storage
// adapter, which writes to disk / S3. Limits guard against oversize
// payloads upstream of the controller's own size check.
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB hard cap
    files: 1,
  },
});

router.use(authenticate);

router.post('/audio', upload.single('file'), uploadAudio);

module.exports = router;
