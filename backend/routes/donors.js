const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET all donors
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM donors ORDER BY created_at DESC');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET single donor
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM donors WHERE donor_id = ?', [req.params.id]);
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST add new donor
router.post('/', async (req, res) => {
    try {
        const { name, age, gender, blood_group, city, phone, email } = req.body;
        const [result] = await db.query(
            'INSERT INTO donors (name, age, gender, blood_group, city, phone, email) VALUES (?,?,?,?,?,?,?)',
            [name, age, gender, blood_group, city, phone, email]
        );
        res.json({ message: 'Donor added successfully', donor_id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT update donor availability
router.put('/:id/availability', async (req, res) => {
    try {
        const { is_available } = req.body;
        await db.query('UPDATE donors SET is_available = ? WHERE donor_id = ?', [is_available, req.params.id]);
        res.json({ message: 'Donor availability updated' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE donor
router.delete('/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM donors WHERE donor_id = ?', [req.params.id]);
        res.json({ message: 'Donor deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;