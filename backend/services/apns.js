'use strict';

/**
 * Apple Push Notification service (APNs) — HTTP/2 provider API.
 *
 * SETUP REQUIRED:
 *   1. Generate an APNs Auth Key (.p8) in Apple Developer portal.
 *   2. Set environment variables:
 *        APNS_KEY_ID        — 10-char key ID from Apple Developer
 *        APNS_TEAM_ID       — 10-char Team ID from Apple Developer
 *        APNS_KEY_PATH      — absolute path to AuthKey_XXXXXXXXXX.p8
 *        APNS_PRODUCTION    — "true" for production, omit/false for sandbox
 *   3. npm install @parse/node-apn   (add to package.json dependencies)
 *
 * This file is a STUB. Push sending is a no-op until credentials are configured.
 */

let provider = null;

function getProvider() {
    if (provider) return provider;

    const keyId   = process.env.APNS_KEY_ID;
    const teamId  = process.env.APNS_TEAM_ID;
    const keyPath = process.env.APNS_KEY_PATH;

    if (!keyId || !teamId || !keyPath) {
        console.warn('[apns] Missing credentials — push notifications disabled.');
        return null;
    }

    try {
        // Lazy-require so the server starts even without @parse/node-apn installed
        const apn = require('@parse/node-apn');    // eslint-disable-line
        provider = new apn.Provider({
            token: { key: keyPath, keyId, teamId },
            production: process.env.APNS_PRODUCTION === 'true',
        });
    } catch (err) {
        console.warn('[apns] @parse/node-apn not installed — push disabled:', err.message);
    }

    return provider;
}

/**
 * Sends a zone-change push notification to a single device token.
 *
 * @param {string} deviceToken  — APNs hex device token
 * @param {string} bundleId     — App bundle ID (e.g. "com.endoworld.app")
 * @param {string} zone         — "SUPPORTIVE" | "MODERATE" | "HOSTILE"
 * @param {number} score        — composite score 0–100
 */
async function sendZoneChangePush(deviceToken, bundleId, zone, score) {
    const p = getProvider();
    if (!p) return;   // graceful no-op

    const apn  = require('@parse/node-apn');   // eslint-disable-line
    const note = new apn.Notification();

    note.topic           = bundleId;
    note.expiry          = Math.floor(Date.now() / 1000) + 3600;   // 1-hour TTL
    note.badge           = 1;
    note.sound           = 'default';
    note.alert           = {
        title: `Zone changed to ${zone.charAt(0) + zone.slice(1).toLowerCase()}`,
        body:  `Your ENDO score is ${score}. Tap to view details.`,
    };
    note.payload = { zone, score };

    try {
        const result = await p.send(note, deviceToken);
        if (result.failed.length > 0) {
            console.error('[apns] Push failed:', result.failed[0].response);
        }
    } catch (err) {
        console.error('[apns] Send error:', err.message);
    }
}

module.exports = { sendZoneChangePush };
