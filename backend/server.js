'use strict';
require('dotenv').config();

const express      = require('express');
const rateLimit    = require('express-rate-limit');
const { initDb }   = require('./services/pinStore');
const pins         = require('./routes/pins');
const environmental = require('./routes/environmental');
const alerts       = require('./routes/alerts');
const map          = require('./routes/map');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ────────────────────────────────────────────────────────────────

app.use(express.json({ limit: '16kb' }));

// Force HTTPS in production (behind a proxy that sets x-forwarded-proto)
app.use((req, res, next) => {
    if (
        process.env.NODE_ENV === 'production' &&
        req.headers['x-forwarded-proto'] !== 'https'
    ) {
        return res.redirect(301, `https://${req.headers.host}${req.url}`);
    }
    next();
});

// Global rate limit — prevents abuse across all endpoints
app.use(rateLimit({
    windowMs: 60_000,      // 1 minute window
    max:      120,         // 120 req / min per IP
    standardHeaders: true,
    legacyHeaders:   false,
    message: { error: 'Too many requests' }
}));

// ── Routes ────────────────────────────────────────────────────────────────────

app.use('/api/pins',          pins);
app.use('/api/environmental', environmental);
app.use('/api/alerts',        alerts);
app.use('/api/map',           map);

app.get('/health', (_req, res) =>
    res.json({ status: 'ok', ts: new Date().toISOString() })
);

// ── Boot ──────────────────────────────────────────────────────────────────────

initDb();
app.listen(PORT, () => console.log(`ENDO backend listening on :${PORT}`));
