'use strict';

let AppleMapsSDK = null;
try {
    AppleMapsSDK = require('apple-maps-server-sdk').default;
} catch (_err) {
    AppleMapsSDK = null;
}

let client = null;

function getClient() {
    if (!AppleMapsSDK) {
        throw new Error('apple-maps-server-sdk is not installed');
    }

    const token = process.env.APPLE_MAPS_AUTH_TOKEN;
    if (!token) {
        throw new Error('APPLE_MAPS_AUTH_TOKEN is not configured');
    }

    if (!client) {
        client = new AppleMapsSDK({ authorizationToken: token });
    }
    return client;
}

/**
 * @param {object|null} bounds - Optional visible map rect: { north, south, east, west } in degrees.
 * Apple Maps Server expects searchRegion as: northLat,eastLon,southLat,westLon
 */
function formatSearchRegion(bounds) {
    if (!bounds) return undefined;
    const { north, south, east, west } = bounds;
    if (
        typeof north !== 'number' ||
        typeof south !== 'number' ||
        typeof east !== 'number' ||
        typeof west !== 'number'
    ) {
        return undefined;
    }
    return `${north},${east},${south},${west}`;
}

async function searchHealthPlaces(lat, lon, bounds = null) {
    const appleMaps = getClient();
    const origin = `${lat},${lon}`;
    const searchRegion = formatSearchRegion(bounds);

    const queries = ['hospital', 'clinic', 'pharmacy'];
    const settled = await Promise.allSettled(
        queries.map((q) =>
            appleMaps.search({
                q,
                userLocation: origin,
                searchLocation: origin,
                searchRegion,
                lang: 'en-US',
                limitToCountries: 'US',
                resultTypeFilter: 'Poi'
            })
        )
    );

    const merged = [];
    const seen = new Set();
    for (const result of settled) {
        if (result.status !== 'fulfilled') continue;
        const places = result.value?.results ?? [];
        for (const place of places) {
            const latValue = place?.coordinate?.latitude;
            const lonValue = place?.coordinate?.longitude;
            if (typeof latValue !== 'number' || typeof lonValue !== 'number') continue;
            const key = `${latValue.toFixed(5)},${lonValue.toFixed(5)}`;
            if (seen.has(key)) continue;
            seen.add(key);
            merged.push({
                name: place?.name ?? 'Unknown',
                category: place?.poiCategory ?? 'Health',
                coordinate: {
                    latitude: latValue,
                    longitude: lonValue
                },
                formattedAddressLines: place?.formattedAddressLines ?? []
            });
        }
    }

    const destinations = merged
        .slice(0, 10)
        .map((item) => `${item.coordinate.latitude},${item.coordinate.longitude}`)
        .join('|');

    if (!destinations) {
        return [];
    }

    const etaResponse = await appleMaps.eta({
        origin,
        destinations,
        transportType: 'Automobile'
    });

    const etaByCoordinate = new Map();
    for (const eta of etaResponse?.etas ?? []) {
        const destination = eta?.destination;
        if (!destination) continue;
        const key = `${destination.latitude.toFixed(5)},${destination.longitude.toFixed(5)}`;
        etaByCoordinate.set(key, {
            distanceMeters: eta.distanceMeters ?? null,
            expectedTravelTimeSeconds: eta.expectedTravelTimeSeconds ?? null
        });
    }

    return merged.slice(0, 10).map((item) => {
        const key = `${item.coordinate.latitude.toFixed(5)},${item.coordinate.longitude.toFixed(5)}`;
        const eta = etaByCoordinate.get(key);
        return {
            ...item,
            distanceMeters: eta?.distanceMeters ?? null,
            expectedTravelTimeSeconds: eta?.expectedTravelTimeSeconds ?? null
        };
    });
}

module.exports = { searchHealthPlaces };
