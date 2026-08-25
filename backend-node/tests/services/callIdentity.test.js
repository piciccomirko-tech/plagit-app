'use strict';

/**
 * Call participant identity resolution.
 *
 * These pin the rules that decide what a user sees about the person they are
 * calling. Every one of them exists because the alternative was a plausible
 * lie on screen: a badge from the wrong verification source, a recruiting
 * requirement presented as somebody's job title, or an account enum shown
 * where a profession belongs.
 */

const test = require('node:test');
const assert = require('node:assert/strict');

const { identityFromRow } = require('../../src/services/callIdentity');

const candidateRow = (over = {}) => ({
  user_id: 'u-cand',
  user_type: 'candidate',
  user_name: 'Legal Name',
  user_initials: 'LN',
  user_avatar_hue: 0.1,
  photo_url: 'https://cdn.example/photo.jpg',
  candidate_name: 'Marco Bianchi',
  candidate_initials: 'MB',
  candidate_avatar_hue: 0.4,
  candidate_primary_role: 'Restaurant Manager',
  candidate_role: 'Waiter',
  candidate_verification_status: 'verified',
  ...over,
});

const businessRow = (over = {}) => ({
  user_id: 'u-biz',
  user_type: 'business',
  user_name: 'Owner Person',
  user_initials: 'OP',
  photo_url: null,
  business_name: 'The Garden Bistro',
  business_initials: 'GB',
  business_avatar_hue: 0.7,
  business_venue_type: 'Restaurant',
  business_contact: 'Giulia Rossi',
  business_is_verified: true,
  ...over,
});

test('candidate: name and profession come from the candidate profile', () => {
  const id = identityFromRow(candidateRow());
  assert.equal(id.name, 'Marco Bianchi');
  assert.equal(id.initials, 'MB');
  assert.equal(id.role, 'candidate');
  assert.equal(id.title, 'Restaurant Manager');
});

test('candidate: primary_role wins, legacy role is the fallback', () => {
  assert.equal(
    identityFromRow(candidateRow({ candidate_primary_role: null })).title,
    'Waiter',
  );
  assert.equal(
    identityFromRow(
      candidateRow({ candidate_primary_role: '   ', candidate_role: 'Chef' }),
    ).title,
    'Chef',
  );
});

test('candidate: every real hospitality role passes through verbatim', () => {
  for (const role of [
    'Waiter',
    'Kitchen Porter',
    'Chef',
    'Bartender',
    'Restaurant Manager',
  ]) {
    assert.equal(
      identityFromRow(candidateRow({ candidate_primary_role: role })).title,
      role,
    );
  }
});

test('candidate: no role at all leaves the line empty, never guessed', () => {
  const id = identityFromRow(
    candidateRow({ candidate_primary_role: null, candidate_role: null }),
  );
  assert.equal(id.title, null);
});

test('candidate: verification comes from verification_status only', () => {
  assert.equal(identityFromRow(candidateRow()).verified, true);
  for (const status of ['pending_review', 'suspended', 'new', null, undefined]) {
    assert.equal(
      identityFromRow(candidateRow({ candidate_verification_status: status }))
        .verified,
      false,
      `status "${status}" must not be treated as verified`,
    );
  }
});

test('candidate: the ACCOUNT flag can never grant a badge', () => {
  // users.is_verified is a different concept and is not the source the rest of
  // the app displays. A verified account with an unverified profile must not
  // show a badge.
  const id = identityFromRow(
    candidateRow({
      is_verified: true,
      candidate_verification_status: 'pending_review',
    }),
  );
  assert.equal(id.verified, false);
});

test('business: the venue is the identity, category is the line under it', () => {
  const id = identityFromRow(businessRow());
  assert.equal(id.name, 'The Garden Bistro');
  assert.equal(id.title, 'Restaurant');
  assert.equal(id.role, 'business');
});

test('business: the recruiting role is NEVER shown as a job title', () => {
  const id = identityFromRow(
    businessRow({
      business_venue_type: null,
      // The role this venue is hiring for. Presenting it as the contact's
      // profession would invent a fact about a real person.
      main_role_needed: 'Restaurant Manager',
      business_main_role_needed: 'Restaurant Manager',
    }),
  );
  assert.equal(id.title, null);
});

test('business: the raw account enum never reaches the title line', () => {
  const id = identityFromRow(businessRow({ business_venue_type: null }));
  assert.notEqual(id.title, 'business');
  assert.notEqual(id.title, 'Business');
  assert.equal(id.title, null);
});

test('business: verification comes from businesses.is_verified only', () => {
  assert.equal(identityFromRow(businessRow()).verified, true);
  for (const v of [false, null, undefined, 'true', 1]) {
    assert.equal(
      identityFromRow(businessRow({ business_is_verified: v })).verified,
      false,
      `is_verified "${v}" must not be treated as verified`,
    );
  }
});

test('business: the contact person is carried but is not the title', () => {
  const id = identityFromRow(businessRow());
  assert.equal(id.contact, 'Giulia Rossi');
  assert.notEqual(id.title, 'Giulia Rossi');
});

test('candidates carry no contact person', () => {
  assert.equal(identityFromRow(candidateRow()).contact, null);
});

test('a missing profile row falls back to the user record', () => {
  const id = identityFromRow({
    user_id: 'u-1',
    user_type: 'candidate',
    user_name: 'Fallback Name',
    user_initials: 'FN',
    candidate_name: null,
    candidate_initials: null,
  });
  assert.equal(id.name, 'Fallback Name');
  assert.equal(id.initials, 'FN');
  assert.equal(id.title, null);
  assert.equal(id.verified, false);
});

test('an unknown user type gets identity but no title and no badge', () => {
  const id = identityFromRow({
    user_id: 'u-admin',
    user_type: 'admin',
    user_name: 'Ops',
    user_initials: 'OP',
  });
  assert.equal(id.name, 'Ops');
  assert.equal(id.title, null);
  assert.equal(id.verified, false);
});

test('an empty or missing row yields no identity', () => {
  for (const row of [null, undefined, {}, { user_type: 'candidate' }]) {
    assert.equal(identityFromRow(row), null);
  }
});

test('whitespace-only values are treated as absent', () => {
  const id = identityFromRow(
    businessRow({ business_venue_type: '   ', business_contact: '\t' }),
  );
  assert.equal(id.title, null);
  assert.equal(id.contact, null);
});
