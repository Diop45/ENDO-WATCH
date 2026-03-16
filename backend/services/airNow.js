'use strict';
const axios  = require('axios');
const cache  = require('./cache');

const BASE = 'https://www.airnowapi.org/aq/observation/latLong/current/';

/**
 * Fetches AQI and PM2.5 from EPA AirNow for the given coordinates.
 * Results cached for 5 minutes per ~1.1 km grid cell.
 *
 * Returns: { aqi: number, pm25: number }
 */
async function fetchAirQuality(lat, lon) {
    const cached = cache.get('aqi', lat, lon);
    if (cached) return cached;

    const params = {
        format:        'application/json',
        latitude:      lat,
        longitude:     lon,
        distance:      25,                          // miles search radius
        API_KEY:       process.env.AIRNOW_API_KEY,
    };

    const { data } = await axios.get(BASE, { params, timeout: 8000 });

    let aqi  = 0;
    let pm25 = 0;

    if (Array.isArray(data)) {
        for (const obs of data) {
            if (obs.ParameterName === 'O3' || obs.ParameterName === 'PM2.5') {
                aqi = Math.max(aqi, obs.AQI ?? 0);
            }
            if (obs.ParameterName === 'PM2.5') {
                pm25 = obs.AQI ?? 0; // AirNow returns AQI-equivalent for PM2.5
            }
        }
    }

    const result = { aqi, pm25 };
    cache.set('aqi', lat, lon, result);
    return result;
}

module.exports = { fetchAirQuality };
