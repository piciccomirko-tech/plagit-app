# Storage adapters — voice messages & media

Voice messages (and any future media uploads) go through a pluggable
storage adapter so dev and prod can use different backends without
touching controller code.

This README is the single source of truth for **how to activate
production storage on Railway with Cloudflare R2** (recommended) or
AWS S3.

---

## Current state

| Driver  | Status        | When it runs                                |
| ------- | ------------- | ------------------------------------------- |
| `local` | ✅ active     | Default. Dev / local-only. Disk-backed.     |
| `s3`    | ✅ implemented | Production. S3-compatible (R2 / S3 / etc.). |

The driver is picked from `STORAGE_DRIVER` env (default `local`).

> ⚠️ **Production guard**: when `NODE_ENV=production`, the backend
> refuses to boot with `STORAGE_DRIVER=local` and throws a clear
> error. The local-disk driver is dev-only.

---

## When to use which driver

| Use case                              | Driver | Why                                                       |
| ------------------------------------- | ------ | --------------------------------------------------------- |
| `npm start` on dev laptop             | local  | Zero setup. Files in `./uploads/`.                        |
| Smoke test against MinIO container    | s3     | Same code path as prod, no real cloud creds needed.       |
| Railway production deploy             | s3     | Container disk is ephemeral — local would lose all files. |
| Preview / staging on Railway          | s3     | Same reasoning. Use a separate bucket from prod.          |

---

## Env vars — full reference

### Always

| Var              | Required? | Default        | Notes                                  |
| ---------------- | --------- | -------------- | -------------------------------------- |
| `STORAGE_DRIVER` | optional  | `local`        | Set to `s3` to activate cloud storage. |
| `NODE_ENV`       | optional  | _(unset)_      | When `production`, blocks `local`.     |

### S3 driver only (`STORAGE_DRIVER=s3`)

| Var                            | Required? | Notes                                                                              |
| ------------------------------ | --------- | ---------------------------------------------------------------------------------- |
| `STORAGE_S3_BUCKET`            | ✅ **yes** | Bucket / namespace name. e.g. `plagit-media-prod`.                                |
| `STORAGE_S3_ACCESS_KEY_ID`     | ✅ **yes** | Access key from your provider's IAM / API token UI.                                |
| `STORAGE_S3_SECRET_ACCESS_KEY` | ✅ **yes** | Paired secret. Treat as a password; never commit.                                  |
| `STORAGE_S3_ENDPOINT`          | optional  | R2 / MinIO / Wasabi: full endpoint URL. AWS S3: leave unset.                       |
| `STORAGE_S3_REGION`            | optional  | R2: `auto`. AWS: e.g. `eu-west-1`. Defaults: `auto` if endpoint set, else `us-east-1`. |
| `STORAGE_S3_FORCE_PATH_STYLE`  | optional  | R2 / MinIO: `true`. AWS: usually `false`. Defaults to `true` if endpoint set.       |
| `STORAGE_S3_PUBLIC_READ_ACL`   | optional  | AWS: `true` to set `ACL: public-read` on PUT. R2: leave `false` (use bucket policy).|
| `STORAGE_S3_PUBLIC_BASE_URL`   | optional  | Custom domain / CDN front (e.g. `https://media.plagit.com`). Replaces canonical URL.|

If any required var is missing the constructor throws a clear error
listing the missing vars — boot fails fast, no silent misconfig.

---

## Cloudflare R2 — recommended for Plagit

R2 is S3-compatible and has **zero egress fees**, which matters for an
audio-heavy chat (every play is a GET on the object). Cheaper and simpler
than AWS S3 for media-heavy workloads.

### One-time setup (Cloudflare dashboard)

1. **Create a bucket**
   - Cloudflare → R2 → Create bucket → name `plagit-media-prod`
   - Location: Auto (R2 picks the cheapest region)
   - Default Public Access: **Disabled** (we'll grant via bucket policy)

2. **Create API token (S3-compatible)**
   - R2 → Manage API Tokens → "Create API Token"
   - Permission: **Object Read & Write** for the specific bucket only
   - TTL: long (1+ year) or no expiry
   - Save the access key ID + secret somewhere safe (you can't read the
     secret again after closing the dialog).

3. **Get the endpoint**
   - R2 → Settings → S3 API → "S3 API"
   - URL format: `https://<account-id>.r2.cloudflarestorage.com`
   - Copy this verbatim into `STORAGE_S3_ENDPOINT`.

4. **Public access strategy (audio playback URLs)**
   - **Option A (simple, recommended for MVP)**: enable bucket-level
     public read for the `audio/` prefix. Set up under R2 → bucket →
     Settings → Public Access. UUIDv4 keys make URLs unguessable.
   - **Option B (private, signed URLs, defer)**: keep bucket private,
     generate pre-signed GETs for each playback. Adds a backend call
     per play; not implemented yet — see "Future work" below.

5. **Custom domain (optional)**
   - R2 → bucket → Settings → Custom Domains → add `media.plagit.com`
   - Cloudflare DNS auto-configures.
   - Set `STORAGE_S3_PUBLIC_BASE_URL=https://media.plagit.com` so the
     adapter returns nice URLs to mobile clients.

### Railway env block (R2)

Paste these into Railway → service → Variables (replace placeholders):

```env
NODE_ENV=production
STORAGE_DRIVER=s3
STORAGE_S3_BUCKET=plagit-media-prod
STORAGE_S3_ACCESS_KEY_ID=<R2 access key id>
STORAGE_S3_SECRET_ACCESS_KEY=<R2 secret>
STORAGE_S3_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
STORAGE_S3_REGION=auto
STORAGE_S3_FORCE_PATH_STYLE=true
STORAGE_S3_PUBLIC_READ_ACL=false
# Optional, recommended once the custom domain is wired:
# STORAGE_S3_PUBLIC_BASE_URL=https://media.plagit.com
```

---

## AWS S3 — alternative

If you'd rather use AWS S3 (e.g. existing AWS account, integration
needs):

```env
NODE_ENV=production
STORAGE_DRIVER=s3
STORAGE_S3_BUCKET=plagit-media-prod
STORAGE_S3_ACCESS_KEY_ID=AKIA...
STORAGE_S3_SECRET_ACCESS_KEY=...
STORAGE_S3_REGION=eu-west-1
STORAGE_S3_PUBLIC_READ_ACL=true
# leave STORAGE_S3_ENDPOINT unset
# leave STORAGE_S3_FORCE_PATH_STYLE unset (defaults to false for AWS)
```

### Minimal IAM policy (AWS)

Attach this policy to the IAM user whose keys you put in env. It limits
the keys to the audio prefix on a single bucket — least privilege.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PlagitMediaReadWrite",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::plagit-media-prod/audio/*"
    }
  ]
}
```

> R2's permission model is similar but simpler — when you create the
> token in step 2 above, scope it to "Object Read & Write" on the
> single bucket and you're done.

---

## Railway deploy checklist

Before the first prod deploy that includes voice messages:

- [ ] R2 (or S3) bucket created
- [ ] Access key + secret generated and saved in 1Password
- [ ] All required env vars set on Railway service
- [ ] `STORAGE_DRIVER=s3` (NOT `local`)
- [ ] `NODE_ENV=production` (so the prod guard activates)
- [ ] Deploy succeeds; check Railway logs for the line:
      `[storage] driver=s3 bucket=<name> endpoint=<url>`
- [ ] Smoke test from mobile: send a voice message, both sides play it back
- [ ] (Optional) Set up a custom domain + `STORAGE_S3_PUBLIC_BASE_URL`

If the boot crashes with `Unsafe storage config: STORAGE_DRIVER=local
is not allowed when NODE_ENV=production` — that's the prod guard
catching a misconfig. Fix the env, redeploy.

---

## Security model

What protects an audio file end-to-end:

| Layer                    | Mechanism                                                        |
| ------------------------ | ---------------------------------------------------------------- |
| Upload — auth            | `POST /v1/uploads/audio` requires a valid JWT (multer route).    |
| Upload — declared MIME   | Allowlist: `audio/m4a`, `audio/mp4`, `audio/aac`, `audio/x-m4a`, `audio/mpeg`. |
| Upload — size cap        | Hard 5 MB at multer + controller (60s @ 64kbps ≈ 480KB, 10× headroom). |
| Upload — magic bytes     | `file-type` sniffs the buffer; rejects MIME-spoofed uploads with `INVALID_AUDIO_FILE`. |
| Object key               | `audio/<UUIDv4>.m4a` — random and unguessable.                  |
| Bucket public read       | Public on `audio/*` only (or signed URLs — see "Future work").  |
| Bucket public write      | NEVER. Writes go through authenticated controller only.         |
| Conversation permission  | Enforced in `sendMessage` — only conversation members can attach an audio_url to a message. |

Out-of-scope (future):
- Pre-signed GET URLs for fully private playback.
- Per-conversation key-prefix sharding (e.g. `audio/conv_<id>/<uuid>.m4a`).
- Per-user upload quota.

---

## Test checklist (matches Step C.2-C.6 sub-steps)

Verified in this branch:

- [x] **C.2** Local driver upload still works (`flutter run` smoke).
- [x] **C.2** S3Adapter constructor throws clear error if required env missing.
- [x] **C.2** S3Adapter constructor accepts mock env (boot OK without real cloud).
- [x] **C.3** Valid M4A passes magic-byte sniff.
- [x] **C.3** JPEG bytes with `audio/m4a` header → 400 `INVALID_AUDIO_FILE`.
- [x] **C.3** Random binary → 400 `INVALID_AUDIO_FILE`.
- [x] **C.3** `audio/wav` declared MIME → 400 `INVALID_MEDIA_TYPE`.
- [x] **C.4** `NODE_ENV=production` + `STORAGE_DRIVER=local` → boot throws.
- [ ] **C.6** Real S3 round-trip via MinIO sandbox (next step).
- [ ] **Future** Real R2 round-trip with production credentials (gated on
      bucket setup).

---

## Adding a new driver

Subclass `StorageAdapter`, implement `save`, `delete`, `driverName`,
register in `index.js`'s switch. Keep the public URL contract
identical: the string returned by `save()` MUST be GET-able by mobile
clients without further auth (or via a signed-URL flow if the bucket
is private).

## Future work

- **Orphan cleanup cron**: voice files uploaded but never associated
  with a `messages.audio_url` row should be reaped after 24h. Adapter
  needs a `list(prefix)` method first. Deferred from Step C.
- **Pre-signed GET URLs**: for private buckets, return signed URLs
  with TTL ~1h instead of public ones. Trade-off: extra backend call
  per play.
- **CDN warming**: pre-warm Cloudflare CDN edges on upload by hitting
  the URL once from the backend region.
- **Migration from local → S3**: one-shot script for messages with
  `audio_url LIKE '/uploads/%'` if local files ever exist in prod.
