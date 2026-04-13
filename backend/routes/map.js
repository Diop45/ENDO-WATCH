'use strict';
const express = require('express');
const { query, validationResult } = require('express-validator');
const { searchHealthPlaces } = require('../services/appleMaps');

const router = express.Router();

const validators = [
    query('lat').isFloat({ min: -90, max: 90 }),
    query('lon').isFloat({ min: -180, max: 180 })
];

router.get('/health-nodes', validators, async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ error: 'Invalid query params', details: errors.array() });
    }

    const lat = parseFloat(req.query.lat);
    const lon = parseFloat(req.query.lon);

    const qNorth = req.query.north;
    const qSouth = req.query.south;
    const qEast = req.query.east;
    const qWest = req.query.west;
    const present = [qNorth, qSouth, qEast, qWest].map((v) => v !== undefined && v !== '');
    const anyBound = present.some(Boolean);
    const allBounds = present.every(Boolean);
    if (anyBound && !allBounds) {
        return res.status(400).json({ error: 'Bounds require all of north, south, east, west' });
    }

    let bounds = null;
    if (allBounds) {
        bounds = {
            north: parseFloat(qNorth),
            south: parseFloat(qSouth),
            east: parseFloat(qEast),
            west: parseFloat(qWest)
        };
        if (
            Number.isNaN(bounds.north) ||
            Number.isNaN(bounds.south) ||
            Number.isNaN(bounds.east) ||
            Number.isNaN(bounds.west)
        ) {
            return res.status(400).json({ error: 'Invalid bounds values' });
        }
    }

    try {
        const places = await searchHealthPlaces(lat, lon, bounds);
        return res.json({
            places,
            fetchedAt: new Date().toISOString()
        });
    } catch (err) {
        const message = err?.message ?? 'Unknown map error';
        const status = message.includes('not configured') || message.includes('not installed') ? 503 : 500;
        return res.status(status).json({ error: message });
    }
});

module.exports = router;
