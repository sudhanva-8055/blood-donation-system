const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Routes
const donorsRoute = require('./routes/donors');
const banksRoute = require('./routes/banks');
const inventoryRoute = require('./routes/inventory');
const requestsRoute = require('./routes/requests');
const eventsRoute = require('./routes/events');
const recipientsRoute = require('./routes/recipients');

app.use('/api/donors', donorsRoute);
app.use('/api/banks', banksRoute);
app.use('/api/inventory', inventoryRoute);
app.use('/api/requests', requestsRoute);
app.use('/api/events', eventsRoute);
app.use('/api/recipients', recipientsRoute);

// Test route
app.get('/', (req, res) => {
    res.json({ message: 'Blood Donation System API is running!' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});