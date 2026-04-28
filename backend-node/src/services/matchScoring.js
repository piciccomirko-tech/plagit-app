/**
 * Match scoring service.
 *
 * Pure, side-effect-free scoring used by Quick Jobs (candidate sees jobs)
 * and Quick Plug (business sees candidates) decks. The same component
 * weights drive both surfaces so a high score on one side implies a
 * high score on the other — keeping the mutual-match modal honest.
 *
 * Total = 100 across six components:
 *
 *   role          40   primary/additional role overlap, role-family fallback
 *   location      25   same city > same country > different > unknown
 *   job_type      15   employment_type / candidate.job_type alignment
 *   experience    10   parsed years vs job seniority hints (junior/senior/exec)
 *   availability   5   candidate.start_date null/past = available now
 *   salary         5   both sides have salary info = small bonus
 *
 * Levels:
 *   high    >= 70
 *   medium  >= 40
 *   low     <  40
 *
 * Reasons are short EN strings keyed off the components that scored
 * meaningfully. Flutter renders them verbatim for now (UI redesign is
 * out of scope for this step).
 */

const ROLE_FAMILIES = [
  ['chef', 'cook', 'sous chef', 'line cook', 'head chef', 'executive chef', 'commis', 'kitchen'],
  ['bartender', 'bar manager', 'mixologist', 'sommelier', 'barback', 'bar'],
  ['waitstaff', 'waiter', 'waitress', 'server', 'host', 'hostess', 'runner', 'busser', 'front of house'],
  ['restaurant manager', 'general manager', 'floor manager', 'duty manager', 'shift manager'],
  ['housekeeper', 'concierge', 'receptionist', 'front desk', 'porter', 'bellboy'],
];

function normalizeStr(s) {
  return (s || '').toString().trim().toLowerCase();
}

// Normalize role list — primary + additional, deduplicated, lowercased.
function candidateRoles(candidate) {
  const primary = normalizeStr(candidate?.primary_role || candidate?.role);
  const addl = Array.isArray(candidate?.additional_roles) ? candidate.additional_roles : [];
  const set = new Set();
  if (primary) set.add(primary);
  for (const r of addl) {
    const v = normalizeStr(r);
    if (v) set.add(v);
  }
  return { primary, all: Array.from(set) };
}

function jobRoles(job) {
  const main = normalizeStr(job?.main_role_needed || job?.title);
  const addl = Array.isArray(job?.additional_roles_needed) ? job.additional_roles_needed : [];
  const set = new Set();
  if (main) set.add(main);
  for (const r of addl) {
    const v = normalizeStr(r);
    if (v) set.add(v);
  }
  return { main, all: Array.from(set) };
}

function sameFamily(a, b) {
  if (!a || !b) return false;
  for (const fam of ROLE_FAMILIES) {
    const aIn = fam.some((k) => a.includes(k));
    const bIn = fam.some((k) => b.includes(k));
    if (aIn && bIn) return true;
  }
  return false;
}

function rolesOverlap(a, b) {
  if (!a || !b) return false;
  if (a === b) return true;
  return a.includes(b) || b.includes(a);
}

// Returns { points (0-40), reason | null }
function scoreRole(candidate, job) {
  const c = candidateRoles(candidate);
  const j = jobRoles(job);

  if (!c.primary && c.all.length === 0) return { points: 0, reason: null };
  if (!j.main && j.all.length === 0) return { points: 0, reason: null };

  // Strongest: candidate primary == job main
  if (c.primary && j.main && c.primary === j.main) {
    return { points: 40, reason: `Role match: ${capitalize(j.main)}` };
  }

  // Strong: any of candidate's roles matches job's main role exactly
  if (j.main && c.all.includes(j.main)) {
    return { points: 32, reason: `You list ${capitalize(j.main)} among your roles` };
  }

  // Medium: candidate's primary appears in job's additional roles
  if (c.primary && j.all.includes(c.primary)) {
    return { points: 25, reason: `${capitalize(c.primary)} listed as a needed role` };
  }

  // Medium-low: substring overlap on main roles (e.g. "chef" ↔ "executive chef")
  if (c.primary && j.main && rolesOverlap(c.primary, j.main)) {
    return { points: 18, reason: `Related role: ${capitalize(c.primary)} ↔ ${capitalize(j.main)}` };
  }

  // Low: same role family (chef ↔ sous chef ↔ line cook)
  if (sameFamily(c.primary, j.main)) {
    return { points: 10, reason: `Similar role family` };
  }

  // Any cross-overlap on the additional sets
  for (const cr of c.all) {
    for (const jr of j.all) {
      if (rolesOverlap(cr, jr) || sameFamily(cr, jr)) {
        return { points: 8, reason: `Some role overlap` };
      }
    }
  }

  return { points: 0, reason: null };
}

function parseLocation(loc) {
  const s = normalizeStr(loc);
  if (!s) return { city: '', country: '' };
  const parts = s.split(',').map((p) => p.trim()).filter(Boolean);
  if (parts.length >= 2) {
    return { city: parts[0], country: parts[parts.length - 1] };
  }
  return { city: parts[0] || '', country: '' };
}

// Returns { points (0-25), reason | null }
function scoreLocation(candidate, job) {
  const candLoc = parseLocation(candidate?.location);
  const jobLoc = parseLocation(job?.location);

  if (!candLoc.city && !jobLoc.city) {
    return { points: 8, reason: null };
  }
  if (!candLoc.city || !jobLoc.city) {
    return { points: 8, reason: null };
  }

  if (candLoc.city === jobLoc.city) {
    return { points: 25, reason: `Same city: ${capitalize(candLoc.city)}` };
  }

  const candCountry = (candidate?.country_code || candLoc.country || '').toString().toLowerCase();
  const jobCountry = (jobLoc.country || '').toLowerCase();
  if (candCountry && jobCountry && candCountry === jobCountry) {
    return { points: 15, reason: `Same country` };
  }

  if (candidate?.available_to_relocate === true) {
    return { points: 12, reason: `Open to relocation` };
  }

  return { points: 3, reason: null };
}

function scoreJobType(candidate, job) {
  const c = normalizeStr(candidate?.job_type);
  const j = normalizeStr(job?.employment_type);
  if (!c && !j) return { points: 8, reason: null };
  if (!c || !j) return { points: 8, reason: null };
  if (c === j) {
    return { points: 15, reason: `${capitalize(j)} availability` };
  }
  // 'flexible' / 'any' — candidates that say so are compatible with any
  if (c.includes('flex') || c.includes('any') || c.includes('open')) {
    return { points: 10, reason: `Flexible on job type` };
  }
  return { points: 0, reason: null };
}

function parseExperienceYears(exp) {
  const s = normalizeStr(exp);
  if (!s) return null;
  const m = s.match(/(\d+(\.\d+)?)/);
  if (!m) return null;
  const n = parseFloat(m[1]);
  if (Number.isNaN(n)) return null;
  return n;
}

function scoreExperience(candidate, job) {
  const years = parseExperienceYears(candidate?.experience);
  const titleLc = normalizeStr(job?.title);
  const reqLc = normalizeStr(job?.requirements);
  const blob = `${titleLc} ${reqLc}`;

  const wantsSenior = /\b(senior|head|executive|lead|chief|principal)\b/.test(blob);
  const wantsJunior = /\b(junior|entry|trainee|commis|apprentice)\b/.test(blob);

  if (years == null) return { points: 5, reason: null };

  if (wantsSenior) {
    if (years >= 7) return { points: 10, reason: `${years}+ yrs experience fits senior role` };
    if (years >= 4) return { points: 6, reason: null };
    return { points: 2, reason: null };
  }
  if (wantsJunior) {
    return { points: 9, reason: years > 0 ? `${years} yrs experience` : null };
  }
  if (years >= 5) return { points: 9, reason: `${years} yrs experience` };
  if (years >= 2) return { points: 7, reason: null };
  return { points: 5, reason: null };
}

function scoreAvailability(candidate /* , job */) {
  const sd = candidate?.start_date;
  if (!sd) return { points: 5, reason: `Available now` };
  const t = Date.parse(sd);
  if (Number.isNaN(t)) return { points: 3, reason: null };
  if (t <= Date.now()) return { points: 5, reason: `Available now` };
  // Future start date: small penalty
  return { points: 2, reason: null };
}

function scoreSalary(candidate, job) {
  const j = normalizeStr(job?.salary);
  if (!j) return { points: 3, reason: null };
  return { points: 5, reason: null };
}

function levelFor(score) {
  if (score >= 70) return 'high';
  if (score >= 40) return 'medium';
  return 'low';
}

function capitalize(s) {
  if (!s) return '';
  return s
    .split(' ')
    .filter(Boolean)
    .map((w) => w[0].toUpperCase() + w.slice(1))
    .join(' ');
}

/**
 * Compute the match between a candidate and a single job.
 * Returns { score, level, reasons, topReason }.
 *
 * `score` is 0..100, deterministic for the same input. Reasons are
 * compact EN strings the UI can render verbatim. `topReason` is the
 * highest-impact reason (role > location > job_type > rest).
 */
function scoreCandidateForJob(candidate, job) {
  const role = scoreRole(candidate, job);
  const loc = scoreLocation(candidate, job);
  const jobType = scoreJobType(candidate, job);
  const exp = scoreExperience(candidate, job);
  const avail = scoreAvailability(candidate, job);
  const sal = scoreSalary(candidate, job);

  const score = role.points + loc.points + jobType.points + exp.points + avail.points + sal.points;
  const reasons = [role.reason, loc.reason, jobType.reason, exp.reason, avail.reason, sal.reason].filter(Boolean);
  const level = levelFor(score);
  // For low matches the top-reason would highlight a peripheral
  // attribute (e.g. "15 yrs experience" on a Bar Manager job for an
  // Executive Chef). That's misleading on the card so we suppress it
  // and let the UI render no headline reason.
  const topReason = level === 'low'
    ? null
    : (role.reason || loc.reason || jobType.reason || exp.reason || avail.reason || sal.reason || null);

  return {
    score: Math.min(100, Math.max(0, Math.round(score))),
    level,
    reasons,
    topReason,
    breakdown: {
      role: role.points,
      location: loc.points,
      job_type: jobType.points,
      experience: exp.points,
      availability: avail.points,
      salary: sal.points,
    },
  };
}

/**
 * Score a candidate against the *best fit* among a business's active
 * jobs. Used by the Quick Plug deck where the business swipes through
 * candidates without a per-card job context — we pick the highest
 * score across the business's open jobs and surface that single best
 * match. If the business has no active jobs we score against an empty
 * job (zero on the role/location/etc components, neutral defaults).
 */
function scoreCandidateAgainstBusinessJobs(candidate, jobs) {
  if (!Array.isArray(jobs) || jobs.length === 0) {
    const empty = scoreCandidateForJob(candidate, {});
    return { ...empty, bestJobId: null, bestJobTitle: null };
  }
  let best = null;
  let bestJob = null;
  for (const j of jobs) {
    const m = scoreCandidateForJob(candidate, j);
    if (!best || m.score > best.score) {
      best = m;
      bestJob = j;
    }
  }
  return {
    ...best,
    bestJobId: bestJob?.id || null,
    bestJobTitle: bestJob?.title || null,
  };
}

module.exports = {
  scoreCandidateForJob,
  scoreCandidateAgainstBusinessJobs,
  // Exported for tests / potential reuse
  _internals: {
    scoreRole,
    scoreLocation,
    scoreJobType,
    scoreExperience,
    scoreAvailability,
    scoreSalary,
    levelFor,
    parseExperienceYears,
    parseLocation,
  },
};
