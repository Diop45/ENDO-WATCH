'use strict';
const express  = require('express');
const { body, validationResult } = require('express-validator');
const rateLimit = require('express-rate-limit');
const { upsertToken, getToken } = require('../services/pinStore');
const { sendZoneChangePush }    = require('../services/apns');

const router = express.Router();

// ── Rate limits ───────────────────────────────────────────────────────────────

const registerLimiter = rateLimit({
    windowMs: 60_000,
    max:      5,
    message:  { error: 'Too many registration requests' },
});

const alertLimiter = rateLimit({
    windowMs: 60_000,
    max:      20,
    message:  { error: 'Too many alert requests' },
});

// ── POST /api/alerts/register — store APNs token for a contributor ────────────

const registerValidators = [
    body('contributorHash').isString().isLength({ min: 16, max: 128 }),
    body('deviceToken').isString().isLength({ min: 32, max: 200 }),
    body('bundleId').isString().isLength({ min: 5, max: 100 }),
];

router.post('/register', registerLimiter, registerValidators, (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ error: 'Invalid payload', details: errors.array() });
    }

    const { contributorHash, deviceToken, bundleId } = req.body;

    try {
        upsertToken(contributorHash, deviceToken, bundleId);
        return res.json({ ok: true });
    } catch (err) {
        console.error('[alerts] register error:', err.message);
        return res.status(500).json({ error: 'Internal error' });
    }
});

// ── POST /api/alerts/zone-changed — trigger push if zone changed ──────────────
//
// Called by the iOS/watchOS client after it receives `previousZone` from POST /api/pins.
// The device knows it changed zones and asks the server to push to OTHER registered
// devices for the same contributor hash (i.e., iPad, iPhone, Watch pair).

const zoneChangedValidators = [
    body('contributorHash').isString().isLength({ min: 16, max: 128 }),
    body('zone').isIn(['SUPPORTIVE', 'MODERATE', 'HOSTILE']),
    body('score').isInt({ min: 0, max: 100 }),
];

router.post('/zone-changed', alertLimiter, zoneChangedValidators, async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ error: 'Invalid payload', details: errors.array() });
    }

    const { contributorHash, zone, score } = req.body;

    try {
        const tokenRow = getToken(contributorHash);
        if (!tokenRow) {
            return res.json({ ok: true, pushed: false, reason: 'no_token' });
        }

        await sendZoneChangePush(tokenRow.token, tokenRow.bundle_id, zone, score);
        return res.json({ ok: true, pushed: true });
    } catch (err) {
        console.error('[alerts] zone-changed error:', err.message);
        return res.status(500).json({ error: 'Internal error' });
    }
});

module.exports = router;
