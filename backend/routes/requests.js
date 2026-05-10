const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET all requests
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM pending_requests');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all requests including fulfilled
router.get('/all', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT br.*, r.name AS recipient_name, r.phone AS recipient_phone 
             FROM blood_requests br 
             JOIN recipients r ON br.recipient_id = r.recipient_id 
             ORDER BY br.created_at DESC`
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST — Immediate search
router.post('/search/immediate', async (req, res) => {
    try {
        const { blood_group, city } = req.body;
        const [rows] = await db.query(
            'CALL SearchImmediate(?, ?)',
            [blood_group, city]
        );
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST — Non-Immediate search
router.post('/search/nonimmediate', async (req, res) => {
    try {
        const { blood_group } = req.body;
        const [rows] = await db.query(
            'CALL SearchNonImmediate(?)',
            [blood_group]
        );
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST — Create new blood request
router.post('/', async (req, res) => {
    try {
        const { recipient_id, blood_group, request_type, units_needed, city_entered } = req.body;
        const [result] = await db.query(
            'INSERT INTO blood_requests (recipient_id, blood_group, request_type, units_needed, city_entered) VALUES (?,?,?,?,?)',
            [recipient_id, blood_group, request_type, units_needed, city_entered]
        );
        res.json({ message: 'Blood request created', request_id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT — Update request status
router.put('/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        await db.query(
            'UPDATE blood_requests SET status = ? WHERE request_id = ?',
            [status, req.params.id]
        );
        res.json({ message: 'Request status updated' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;