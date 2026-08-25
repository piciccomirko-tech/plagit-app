'use strict';

/**
 * Call participant identity resolution.
 *
 * One place decides what the call screen shows about the other person, so the
 * rule cannot drift between the SSE payload, the REST responses and whatever
 * reads it next. Extracted from the db query on purpose: the interesting part
 * is the mapping, and it is worth testing without a database.
 *
 * Every field is real profile data or null. Nothing is inferred, defaulted to
 * something plausible, or borrowed from a neighbouring concept.
 */

const str = (v) => {
  const s = String(v === null || v === undefined ? '' : v).trim();
  return s.length > 0 ? s : null;
};

/**
 * Map one joined `users + candidates + businesses` row onto the identity the
 * client renders.
 *
 * Display name follows the profile-level table so brand names that diverge
 * from the owner's legal name ("Nobu Restaurant" vs the person who signed up)
 * render correctly.
 *
 * `title` is the single line under the name:
 *   • candidate → COALESCE(primary_role, role), the same effective role the
 *     rest of the app computes. `primary_role` is canonical (migration 012);
 *     `role` is the legacy column it was back-filled from.
 *   • business  → the venue CATEGORY. A business participant IS the venue, so
 *     the category sits correctly under the venue name. There is no genuine
 *     job-title column for the contact person, and `main_role_needed` is the
 *     role the business is RECRUITING for — presenting either as the
 *     contact's title would invent a fact, so the line stays empty instead.
 *
 * `verified` is role-specific. `users.is_verified` is the account flag and is
 * deliberately not consulted: candidates are verified through
 * `candidates.verification_status` and businesses through
 * `businesses.is_verified`, which is what every other surface in the app
 * displays. Using the account flag would show a badge nobody granted.
 */
function identityFromRow(row) {
  if (!row || !row.user_id) return null;

  const isBusiness = row.user_type === 'business';
  const isCandidate = row.user_type === 'candidate';

  const name =
    (isBusiness && str(row.business_name)) ||
    (isCandidate && str(row.candidate_name)) ||
    str(row.user_name) ||
    null;

  const initials =
    (isBusiness && str(row.business_initials)) ||
    (isCandidate && str(row.candidate_initials)) ||
    str(row.user_initials) ||
    null;

  const avatarHue =
    (isBusiness && row.business_avatar_hue) ??
    (isCandidate && row.candidate_avatar_hue) ??
    row.user_avatar_hue ??
    null;

  const title = isCandidate
    ? str(row.candidate_primary_role) || str(row.candidate_role)
    : isBusiness
      ? str(row.business_venue_type)
      : null;

  const verified = isCandidate
    ? row.candidate_verification_status === 'verified'
    : isBusiness
      ? row.business_is_verified === true
      : false;

  return {
    id: row.user_id,
    role: row.user_type || null,
    name,
    initials,
    photoUrl: row.photo_url || null,
    avatarHue,
    title,
    verified,
    // The person behind a business account. Carried for the identity model;
    // the current call layout has no line for it.
    contact: isBusiness ? str(row.business_contact) : null,
  };
}

module.exports = { identityFromRow };
