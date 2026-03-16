'use strict';
const express  = require('express');
const { query, validationResult } = require('express-validator');
const { fetchAirQuality } = require('../services/airNow');
const { fetchWeather }    = require('../services/weather');
const { fetchCDCPlaces }  = require('../services/cdc');
const { fetchSAMHSA }     = require('../services/samhsa');

const router = express.Router();

/**
 * GET /api/environmental?lat=&lon=&tractId=
 *
 * Aggregates all public-health signals for a coordinate:
 *   - AQI + PM2.5  (EPA AirNow)
 *   - Temp + Humidity (OpenWeatherMap)
 *   - Diabetes + Obesity prevalence (CDC PLACES)
 *   - Facility count (SAMHSA)
 *
 * All four fetches run concurrently.
 * Returns a single JSON object the iOS/watchOS client can consume directly.
 */

const validators = [
    query('lat').isFloat({ min: -90,  max: 90  }),
    query('lon').isFloat({ min: -180, max: 180 }),
    query('tractId').optional().isString().isLength({ max: 32 }),
];

router.get('/', validators, async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ error: 'Invalid query params', details: errors.array() });
    }

    const lat     = parseFloat(req.query.lat);
    const lon     = parseFloat(req.query.lon);
    const tractId = req.query.tractId ?? '';

    try {
        const [airQuality, weather, cdc, samhsa] = await Promise.allSettled([
            fetchAirQuality(lat, lon),
            fetchWeather(lat, lon),
            fetchCDCPlaces(lat, lon, tractId),
            fetchSAMHSA(lat, lon),
        ]);

        const aq  = airQuality.status === 'fulfilled' ? airQuality.value  : { aqi: 0, pm25: 0 };
        const wx  = weather.status    === 'fulfilled' ? weather.value     : { tempF: 70, humidity: 50, description: '' };
        const cd  = cdc.status        === 'fulfilled' ? cdc.value         : { diabetesPrevalence: 0, obesityPrevalence: 0, tractId: '' };
        const sa  = samhsa.status     === 'fulfilled' ? samhsa.value      : { facilityCount: 0 };

        return res.json({
            aqi:                  aq.aqi,
            pm25:                 aq.pm25,
            tempF:                wx.tempF,
            humidity:             wx.humidity,
            weatherDescription:   wx.description,
            diabetesPrevalence:   cd.diabetesPrevalence,
            obesityPrevalence:    cd.obesityPrevalence,
            tractId:              cd.tractId || tractId,
            facilityCount:        sa.facilityCount,
            fetchedAt:            new Date().toISOString(),
        });
    } catch (err) {
        console.error('[environmental] unexpected error:', err.message);
        return res.status(500).json({ error: 'Internal error' });
    }
});

module.exports = router;
