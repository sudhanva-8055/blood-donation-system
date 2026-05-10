const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET all recipients
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT r.*, h.name AS hospital_name 
             FROM recipients r 
             LEFT JOIN hospitals h ON r.hospital_id = h.hospital_id 
             ORDER BY r.created_at DESC`
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET single recipient
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT r.*, h.name AS hospital_name 
             FROM recipients r 
             LEFT JOIN hospitals h ON r.hospital_id = h.hospital_id 
             WHERE r.recipient_id = ?`,
            [req.params.id]
        );
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST add new recipient
router.post('/', async (req, res) => {
    try {
        const { name, age, gender, blood_group_needed, city, phone, hospital_id } = req.body;
        const [result] = await db.query(
            'INSERT INTO recipients (name, age, gender, blood_group_needed, city, phone, hospital_id) VALUES (?,?,?,?,?,?,?)',
            [name, age, gender, blood_group_needed, city, phone, hospital_id]
        );
        res.json({ message: 'Recipient added successfully', recipient_id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE recipient
router.delete('/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM recipients WHERE recipient_id = ?', [req.params.id]);
        res.json({ message: 'Recipient deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;