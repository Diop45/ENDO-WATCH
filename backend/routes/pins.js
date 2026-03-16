'use strict';
const express    = require('express');
const { body, query, validationResult } = require('express-validator');
const rateLimit  = require('express-rate-limit');
const {
    insertPin,
    getPreviousZone,
    getNeighborhoodPins,
} = require('../services/pinStore');

const router = express.Router();

// ── Rate limits ───────────────────────────────────────────────────────────────

// Strict limit on pin submissions: 1 per minute per IP
const submitLimiter = rateLimit({
    windowMs: 60_000,
    max:      10,
    message:  { error: 'Too many pin submissions' },
});

// ── POST /api/pins  — submit an anonymous zone pin ────────────────────────────

const submitValidators = [
    body('id').isString().notEmpty().isLength({ max: 64 }),
    body('latitude').isFloat({ min: -90,  max: 90  }),
    body('longitude').isFloat({ min: -180, max: 180 }),
    body('zone').isIn(['SUPPORTIVE', 'MODERATE', 'HOSTILE']),
    body('compositeScore').isInt({ min: 0, max: 100 }),
    body('dominantSignal').isString().notEmpty().isLength({ max: 32 }),
    body('timestamp').isISO8601(),
    body('contributorHash').isString().isLength({ min: 16, max: 128 }),
    body('tractID').optional().isString().isLength({ max: 32 }),
];

router.post('/', submitLimiter, submitValidators, (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ error: 'Invalid payload', details: errors.array() });
    }

    try {
        const previousZone = getPreviousZone(req.body.contributorHash);
        insertPin(req.body);
        return res.json({ ok: true, previousZone });
    } catch (err) {
        console.error('[pins] insert error:', err.message);
        return res.status(500).json({ error: 'Internal error' });
    }
});

// ── GET /api/pins/neighborhood — fetch anonymised neighbourhood pins ───────────

const neighborhoodValidators = [
    query('lat').isFloat({ min: -90,  max: 90  }),
    query('lon').isFloat({ min: -180, max: 180 }),
    query('radius').optional().isFloat({ min: 0.1, max: 50 }),
];

router.get('/neighborhood', neighborhoodValidators, (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ error: 'Invalid query params', details: errors.array() });
    }

    const lat    = parseFloat(req.query.lat);
    const lon    = parseFloat(req.query.lon);
    const radius = parseFloat(req.query.radius ?? '5');   // default 5 miles

    try {
        const pins = getNeighborhoodPins(lat, lon, radius);
        return res.json({ pins });
    } catch (err) {
        console.error('[pins] neighborhood error:', err.message);
        return res.status(500).json({ error: 'Internal error' });
    }
});

module.exports = router;
