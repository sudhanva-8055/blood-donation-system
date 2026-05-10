const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET all inventory
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM inventory_summary');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET inventory by bank
router.get('/bank/:bank_id', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT * FROM blood_inventory WHERE bank_id = ?',
            [req.params.bank_id]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET total units per blood group across all banks
router.get('/summary', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT blood_group, SUM(units_available) AS total_units FROM blood_inventory GROUP BY blood_group ORDER BY blood_group'
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET low stock (less than 5 units)
router.get('/lowstock', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT bb.name, bb.city, bi.blood_group, bi.units_available 
             FROM blood_inventory bi 
             JOIN blood_banks bb ON bi.bank_id = bb.bank_id 
             WHERE bi.units_available < 5 
             ORDER BY bi.units_available ASC`
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT update inventory manually
router.put('/:id', async (req, res) => {
    try {
        const { units_available } = req.body;
        await db.query(
            'UPDATE blood_inventory SET units_available = ? WHERE inventory_id = ?',
            [units_available, req.params.id]
        );
        res.json({ message: 'Inventory updated' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;