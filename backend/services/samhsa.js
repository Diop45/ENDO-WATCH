'use strict';
const axios = require('axios');
const cache = require('./cache');

/**
 * SAMHSA Treatment Locator — counts nearby substance-use treatment facilities.
 * Endpoint: https://findtreatment.gov/locator/search (returns JSON when Accept header is set).
 *
 * Results cached for 24 hours.
 * Returns: { facilityCount: number }
 */

const BASE = 'https://findtreatment.gov/locator/search';

async function fetchSAMHSA(lat, lon) {
    const cached = cache.get('samhsa', lat, lon);
    if (cached) return cached;

    const params = {
        sAddr:    `${lat},${lon}`,
        distance: 10,   // miles
        pageSize: 1,    // we only need the total count
        page:     1,
    };

    const headers = { Accept: 'application/json' };

    let facilityCount = 0;
    try {
        const { data } = await axios.get(BASE, { params, headers, timeout: 10000 });
        // Response shape: { total: number, rows: [...] }
        facilityCount = data?.total ?? (Array.isArray(data?.rows) ? data.rows.length : 0);
    } catch {
        // SAMHSA endpoint is best-effort; default to 0 on any failure
        facilityCount = 0;
    }

    const result = { facilityCount };
    cache.set('samhsa', lat, lon, result);
    return result;
}

module.exports = { fetchSAMHSA };
