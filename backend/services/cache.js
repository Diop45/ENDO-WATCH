'use strict';
const NodeCache = require('node-cache');

// Separate cache instances per data type with appropriate TTLs
const caches = {
    aqi:      new NodeCache({ stdTTL: 300,       checkperiod: 60  }),  // 5 min
    weather:  new NodeCache({ stdTTL: 300,       checkperiod: 60  }),  // 5 min
    cdc:      new NodeCache({ stdTTL: 86_400,    checkperiod: 3600 }), // 24 hr
    samhsa:   new NodeCache({ stdTTL: 86_400,    checkperiod: 3600 }), // 24 hr
    census:   new NodeCache({ stdTTL: 2_592_000, checkperiod: 3600 }), // 30 days
};

/**
 * Round a coordinate to cache-key precision.
 * 2 decimal places ≈ 1.1 km grid — same API result for nearby requests.
 */
function coordKey(lat, lon, prefix) {
    const la = Math.round(lat * 100) / 100;
    const lo = Math.round(lon * 100) / 100;
    return `${prefix}:${la},${lo}`;
}

function get(type, lat, lon) {
    return caches[type].get(coordKey(lat, lon, type)) ?? null;
}

function set(type, lat, lon, value) {
    caches[type].set(coordKey(lat, lon, type), value);
}

module.exports = { get, set };
