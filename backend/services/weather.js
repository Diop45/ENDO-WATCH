'use strict';
const axios = require('axios');
const cache = require('./cache');

const BASE = 'https://api.openweathermap.org/data/2.5/weather';

/**
 * Fetches current weather from OpenWeatherMap.
 * Results cached for 5 minutes per ~1.1 km grid cell.
 *
 * Returns: { tempF: number, humidity: number, description: string }
 */
async function fetchWeather(lat, lon) {
    const cached = cache.get('weather', lat, lon);
    if (cached) return cached;

    const params = {
        lat,
        lon,
        units:  'imperial',   // Fahrenheit
        appid:  process.env.OPENWEATHER_API_KEY,
    };

    const { data } = await axios.get(BASE, { params, timeout: 8000 });

    const result = {
        tempF:       data?.main?.temp        ?? 70,
        humidity:    data?.main?.humidity    ?? 50,
        description: data?.weather?.[0]?.description ?? '',
    };

    cache.set('weather', lat, lon, result);
    return result;
}

module.exports = { fetchWeather };
