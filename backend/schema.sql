-- Trashy Database Schema
-- Run this in pgAdmin's Query Tool against your trashy_db database

CREATE TABLE IF NOT EXISTS trash_scans (
    id             SERIAL PRIMARY KEY,
    image_base64   TEXT NOT NULL,
    has_trash       BOOLEAN,
    trash_category  VARCHAR(255),
    confidence      FLOAT,
    scanned_at      TIMESTAMP DEFAULT NOW()
);
