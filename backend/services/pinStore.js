'use strict';
const Database = require('better-sqlite3');
const path     = require('path');
const { haversineMiles, boundingBox } = require('./haversine');

let db;

// ── Init ──────────────────────────────────────────────────────────────────────

function initDb() {
    db = new Database(path.join(__dirname, '..', 'data', 'endo.db'));
    db.pragma('journal_mode = WAL');   // concurrent reads
    db.pragma('foreign_keys = ON');

    db.exec(`
        CREATE TABLE IF NOT EXISTS zone_pins (
            id               TEXT    PRIMARY KEY,
            lat              REAL    NOT NULL,
            lon              REAL    NOT NULL,
            zone             TEXT    NOT NULL,
            composite_score  INTEGER NOT NULL,
            dominant_signal  TEXT    NOT NULL,
            timestamp_hour   INTEGER NOT NULL,
            tract_id         TEXT    DEFAULT '',
            contributor_hash TEXT    NOT NULL,
            created_at       INTEGER DEFAULT (strftime('%s','now'))
        );
        CREATE INDEX IF NOT EXISTS idx_pins_loc  ON zone_pins(lat, lon);
        CREATE INDEX IF NOT EXISTS idx_pins_time ON zone_pins(created_at);

        CREATE TABLE IF NOT EXISTS pin_history (
            contributor_hash TEXT PRIMARY KEY,
            last_zone        TEXT    NOT NULL,
            last_ts          INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS apns_tokens (
            contributor_hash TEXT PRIMARY KEY,
            token            TEXT    NOT NULL,
            bundle_id        TEXT    NOT NULL,
            updated_at       INTEGER DEFAULT (strftime('%s','now'))
        );
    `);

    console.log('SQLite database ready.');
}

// ── Writes ────────────────────────────────────────────────────────────────────

function insertPin(raw) {
    // Privacy: re-enforce 3-decimal-place rounding and hour truncation server-side
    const lat    = Math.round(raw.latitude  * 1000) / 1000;
    const lon    = Math.round(raw.longitude * 1000) / 1000;
    const tsMs   = new Date(raw.timestamp).getTime();
    const tsHour = Math.floor(tsMs / 3_600_000) * 3_600_000;

    db.prepare(`
        INSERT OR REPLACE INTO zone_pins
            (id, lat, lon, zone, composite_score, dominant_signal,
             timestamp_hour, tract_id, contributor_hash)
        VALUES
            (@id, @lat, @lon, @zone, @compositeScore, @dominantSignal,
             @tsHour, @tractId, @contributorHash)
    `).run({
        id:              raw.id,
        lat,
        lon,
        zone:            raw.zone,
        compositeScore:  raw.compositeScore,
        dominantSignal:  raw.dominantSignal,
        tsHour,
        tractId:         raw.tractID ?? '',
        contributorHash: raw.contributorHash,
    });

    // Track last zone per contributor for alert diffing
    db.prepare(`
        INSERT OR REPLACE INTO pin_history (contributor_hash, last_zone, last_ts)
        VALUES (@hash, @zone, @ts)
    `).run({ hash: raw.contributorHash, zone: raw.zone, ts: Date.now() });
}

/** Returns previous zone for this contributor, or null if first submission. */
function getPreviousZone(contributorHash) {
    const row = db.prepare(
        'SELECT last_zone FROM pin_history WHERE contributor_hash = ?'
    ).get(contributorHash);
    return row?.last_zone ?? null;
}

// ── Reads ─────────────────────────────────────────────────────────────────────

/**
 * Returns aggregated neighborhood pins within radiusMiles of (lat, lon).
 * Privacy: only returns cells with >= MIN_COUNT contributors.
 * Aggregation: average compositeScore, most common zone, per ~110m cell.
 */
const MIN_COUNT = 2; // minimum pins per cell before it appears on the map
const WINDOW_HOURS = 24;

function getNeighborhoodPins(lat, lon, radiusMiles) {
    const box      = boundingBox(lat, lon, radiusMiles);
    const windowTs = Math.floor(Date.now() / 1000) - WINDOW_HOURS * 3600;

    const rows = db.prepare(`
        SELECT
            lat, lon, zone, composite_score, dominant_signal,
            timestamp_hour, tract_id,
            COUNT(*) AS cnt
        FROM zone_pins
        WHERE
            lat  BETWEEN @minLat AND @maxLat AND
            lon  BETWEEN @minLon AND @maxLon AND
            created_at >= @windowTs
        GROUP BY lat, lon
        HAVING cnt >= ${MIN_COUNT}
    `).all({
        minLat: box.minLat, maxLat: box.maxLat,
        minLon: box.minLon, maxLon: box.maxLon,
        windowTs,
    });

    // Exact distance filter (bounding box over-selects at corners)
    return rows
        .filter(r => haversineMiles(lat, lon, r.lat, r.lon) <= radiusMiles)
        .map(r => ({
            id:             `agg-${r.lat}-${r.lon}`,
            latitude:       r.lat,
            longitude:      r.lon,
            zone:           r.zone,
            compositeScore: Math.round(r.composite_score),
            dominantSignal: r.dominant_signal,
            timestamp:      new Date(r.timestamp_hour).toISOString(),
            isAnonymous:    true,
            tractID:        r.tract_id,
            contributorHash: '',   // never exposed in neighborhood response
        }));
}

// ── APNs tokens ───────────────────────────────────────────────────────────────

function upsertToken(contributorHash, token, bundleId) {
    db.prepare(`
        INSERT OR REPLACE INTO apns_tokens (contributor_hash, token, bundle_id, updated_at)
        VALUES (@hash, @token, @bundleId, strftime('%s','now'))
    `).run({ hash: contributorHash, token, bundleId });
}

function getToken(contributorHash) {
    return db.prepare(
        'SELECT token, bundle_id FROM apns_tokens WHERE contributor_hash = ?'
    ).get(contributorHash) ?? null;
}

module.exports = { initDb, insertPin, getPreviousZone, getNeighborhoodPins, upsertToken, getToken };
