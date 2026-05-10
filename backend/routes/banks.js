const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET all blood banks
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM blood_banks ORDER BY city');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET single blood bank
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM blood_banks WHERE bank_id = ?', [req.params.id]);
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST add new blood bank
router.post('/', async (req, res) => {
    try {
        const { name, city, address, phone, email, latitude, longitude } = req.body;
        const [result] = await db.query(
            'INSERT INTO blood_banks (name, city, address, phone, email, latitude, longitude) VALUES (?,?,?,?,?,?,?)',
            [name, city, address, phone, email, latitude, longitude]
        );
        res.json({ message: 'Blood bank added successfully', bank_id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE blood bank
router.delete('/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM blood_banks WHERE bank_id = ?', [req.params.id]);
        res.json({ message: 'Blood bank deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;