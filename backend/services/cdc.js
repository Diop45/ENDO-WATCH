'use strict';
const axios = require('axios');
const cache = require('./cache');

/**
 * CDC PLACES API — health outcome prevalence for a census tract.
 * https://chronicdata.cdc.gov/resource/cwsq-ngmh.json
 *
 * Results cached for 24 hours (data is updated annually).
 * Returns: { diabetesPrevalence: number, obesityPrevalence: number, tractId: string }
 */

const SOCRATA_ENDPOINT =
    'https://chronicdata.cdc.gov/resource/cwsq-ngmh.json';

async function fetchCDCPlaces(lat, lon, tractId) {
    const cacheKey = `cdc:${tractId || `${Math.round(lat * 100) / 100},${Math.round(lon * 100) / 100}`}`;

    // Use node-cache directly with a composite key (not coord-based for CDC)
    const NodeCache = require('node-cache');

    // Reuse the cache module's internal cache for 'cdc' type
    const cached = cache.get('cdc', lat, lon);
    if (cached) return cached;

    const params = {
        '$where': tractId
            ? `locationid = '${tractId}'`
            : `within_circle(geolocation, ${lat}, ${lon}, 3000)`,
        '$select': 'locationid,measure,data_value',
        '$limit':  50,
    };

    const { data } = await axios.get(SOCRATA_ENDPOINT, { params, timeout: 10000 });

    let diabetesPrevalence = 0;
    let obesityPrevalence  = 0;
    let resolvedTractId    = tractId ?? '';

    if (Array.isArray(data)) {
        for (const row of data) {
            if (!resolvedTractId && row.locationid) resolvedTractId = row.locationid;
            const measure = (row.measure ?? '').toLowerCase();
            const val     = parseFloat(row.data_value) || 0;
            if (measure.includes('diabetes'))      diabetesPrevalence = Math.max(diabetesPrevalence, val);
            if (measure.includes('obesity'))       obesityPrevalence  = Math.max(obesityPrevalence,  val);
        }
    }

    const result = { diabetesPrevalence, obesityPrevalence, tractId: resolvedTractId };
    cache.set('cdc', lat, lon, result);
    return result;
}

module.exports = { fetchCDCPlaces };
