const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET all events
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT de.*, bb.name AS bank_name 
             FROM donation_events de 
             JOIN blood_banks bb ON de.bank_id = bb.bank_id 
             ORDER BY de.event_date DESC`
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET single event
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT de.*, bb.name AS bank_name 
             FROM donation_events de 
             JOIN blood_banks bb ON de.bank_id = bb.bank_id 
             WHERE de.event_id = ?`,
            [req.params.id]
        );
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST add new event
router.post('/', async (req, res) => {
    try {
        const { bank_id, event_name, city, address, event_date } = req.body;
        const [result] = await db.query(
            'INSERT INTO donation_events (bank_id, event_name, city, address, event_date) VALUES (?,?,?,?,?)',
            [bank_id, event_name, city, address, event_date]
        );
        res.json({ message: 'Event added successfully', event_id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE event
router.delete('/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM donation_events WHERE event_id = ?', [req.params.id]);
        res.json({ message: 'Event deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;