/**
 * Video Messages — extends `messages` with video-attachment metadata.
 *
 * Pure metadata: actual video bytes live on the storage adapter under
 * kind='video' via POST /v1/uploads/video. Mirrors image/document
 * attachment migrations so chat rows can persist and list video
 * messages without overloading image/document fields.
 */
exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);

  if (!(await has('video_url'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.text('video_url').nullable();
    });
  }
  if (!(await has('video_size_bytes'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('video_size_bytes').nullable();
    });
  }
  if (!(await has('video_mime_type'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.string('video_mime_type', 50).nullable();
    });
  }
  if (!(await has('video_duration_ms'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('video_duration_ms').nullable();
    });
  }
  if (!(await has('video_width'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('video_width').nullable();
    });
  }
  if (!(await has('video_height'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('video_height').nullable();
    });
  }
};

exports.down = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);
  for (const col of [
    'video_height',
    'video_width',
    'video_duration_ms',
    'video_mime_type',
    'video_size_bytes',
    'video_url',
  ]) {
    if (await has(col)) {
      await knex.schema.alterTable('messages', (t) => {
        t.dropColumn(col);
      });
    }
  }
};
