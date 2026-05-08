const router = require('express').Router();
const multer = require('multer');
const { authenticate } = require('../middleware/auth');
const {
  uploadAudio,
  uploadImage,
  uploadDocument,
} = require('../controllers/uploadController');

// In-memory parsing — controller hands the buffer to the storage
// adapter, which writes to disk / S3. Limits guard against oversize
// payloads upstream of the controller's own size check.
const audioUpload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB hard cap
    files: 1,
  },
});

// Image cap is 10MB to fit HEIC/JPEG straight from iPhone camera roll.
const imageUpload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 1,
  },
});

// Document cap is 20MB — covers a long CV or contract PDF. Same
// pattern as audio/image, controller does the strict gating.
const documentUpload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 20 * 1024 * 1024,
    files: 1,
  },
});

router.use(authenticate);

router.post('/audio', audioUpload.single('file'), uploadAudio);
router.post('/image', imageUpload.single('file'), uploadImage);
router.post('/document', documentUpload.single('file'), uploadDocument);

module.exports = router;
