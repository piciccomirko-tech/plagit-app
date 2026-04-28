/**
 * Product catalog (read-only).
 *
 *   GET /v1/business/job-products
 *
 * Returns the active rows of `job_products` so the Business UI can show
 * the boost / credit-pack offer wall. Read-only by design — this
 * endpoint never mutates state, never charges, never debits a wallet.
 *
 * Auth: any authenticated user (mounted on the /business router which
 * already runs `authenticate`). Pricing/product info is not sensitive
 * — exposing it to all logged-in roles is intentional.
 *
 * DTO contract (locked for Phase 1 — Flutter side will wire to these
 * exact keys):
 *   id              uuid
 *   code            stable string key (urgent_24h, top_3d, …)
 *   name            display name
 *   description     long-form copy
 *   product_type    'urgent' | 'top' | 'featured' | 'bundle'
 *                   | 'credit_pack' | 'other'
 *                   (derived: bundles win, then credit packs by
 *                    credits_granted, then boost_type, then 'other')
 *   price           integer minor units (pence). Frontend formats.
 *   currency        ISO-4217 (3-char)
 *   credits_cost    int — how many wallet credits to redeem
 *   duration_hours  int | null
 *   boost_priority  int (0 for non-boost rows)
 *   is_active       bool — always true on this endpoint, surfaced for
 *                   forward-compat when admin lists are added
 *   display_order   int — frontend sort key (renamed from sort_order)
 *
 * Sort: display_order ASC. Empty array if no active rows (safe default).
 */

'use strict';

const db = require('../config/db');
const { ok } = require('../utils/response');

function deriveProductType(row) {
  if (row.is_bundle) return 'bundle';
  if (row.credits_granted && row.credits_granted > 0) return 'credit_pack';
  if (row.boost_type) return row.boost_type;
  return 'other';
}

function toDto(row) {
  return {
    id: row.id,
    code: row.code,
    name: row.name,
    description: row.description,
    product_type: deriveProductType(row),
    price: row.price_minor,
    currency: row.currency,
    credits_cost: row.credits_cost,
    duration_hours: row.duration_hours,
    boost_priority: row.boost_priority,
    is_active: row.is_active,
    display_order: row.sort_order,
  };
}

async function listJobProducts(req, res, next) {
  try {
    const rows = await db('job_products')
      .where({ is_active: true })
      .orderBy('sort_order', 'asc');

    ok(res, rows.map(toDto));
  } catch (e) { next(e); }
}

module.exports = { listJobProducts, toDto, deriveProductType };
