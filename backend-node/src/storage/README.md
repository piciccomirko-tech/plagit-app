# Storage adapters — what runs where

Voice messages (and any future media uploads) go through a pluggable
storage interface so dev and prod can use different backends without
touching controller code.

## Current state

| Driver  | Status      | Notes                                                   |
| ------- | ----------- | ------------------------------------------------------- |
| `local` | ✅ active    | Default. Files at `./uploads/<kind>/<uuid>.<ext>`.       |
| `s3`    | 🟠 stub      | Throws on construction. Activation steps below.         |

The driver is picked from `STORAGE_DRIVER` env (default `local`).

## Local driver — works out of the box

- Files saved to `<repo>/uploads/audio/<uuid>.m4a`.
- Served publicly at `GET /uploads/audio/<uuid>.m4a` via
  `express.static` mounted in `src/app.js`.
- `uploads/` is in `.gitignore` so dev artefacts never get committed.

⚠️ **Not safe for Railway / any container-based prod**: Railway's
filesystem is ephemeral, so files vanish on every redeploy. Local is
strictly a dev driver.

## S3 driver — activation checklist

When prod ships with voice messages enabled:

1. Install AWS SDK
   ```bash
   npm install @aws-sdk/client-s3
   ```

2. Replace the `S3Adapter` constructor stub with a real client + bucket
   wiring (`PutObjectCommand` for save, `DeleteObjectCommand` for delete).

3. Set the following env vars in Railway (or your deploy target):
   - `STORAGE_DRIVER=s3`
   - `AWS_REGION=eu-west-1` (or wherever the bucket lives)
   - `AWS_ACCESS_KEY_ID=…`
   - `AWS_SECRET_ACCESS_KEY=…`
   - `S3_BUCKET=plagit-media-prod` (or your name)
   - *(optional)* `S3_PUBLIC_BASE_URL=https://media.plagit.com`
     for CloudFront / custom domain. Without it the adapter should
     return the canonical `https://<bucket>.s3.<region>.amazonaws.com/<key>`.

4. Bucket policy: enable public-read on `audio/*` objects (or use signed
   URLs and add a `getSignedUrl` flow on the message fetch path —
   trade-off between latency and access control).

5. Migrate existing local files? For dev → prod first deploy this
   isn't needed (no real users yet). For later migrations write a
   one-shot script that walks `messages.audio_url LIKE '/uploads/%'`
   and re-uploads + rewrites.

## Adding a new driver

Subclass `StorageAdapter`, implement `save`, `delete`, `driverName`,
register in `index.js`'s switch. Keep the public URL contract
identical (string returned by `save()` must be GET-able by mobile
clients).
