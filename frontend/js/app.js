// ============================================================
// BLOOD DONATION SYSTEM — Main JS
// ============================================================

const API = 'http://localhost:5000/api';

// ── TOAST NOTIFICATIONS ──
function showToast(message, type = 'success') {
    let toast = document.getElementById('toast');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = 'toast';
        toast.className = 'toast';
        document.body.appendChild(toast);
    }
    toast.textContent = message;
    toast.className = `toast ${type} show`;
    setTimeout(() => toast.classList.remove('show'), 3000);
}

// ── MODAL HELPERS ──
function openModal(id) {
    document.getElementById(id).classList.add('open');
}

function closeModal(id) {
    document.getElementById(id).classList.remove('open');
}

// Close modal on overlay click
document.addEventListener('click', (e) => {
    if (e.target.classList.contains('modal-overlay')) {
        e.target.classList.remove('open');
    }
});

// ── BLOOD GROUP BADGE ──
function bgBadge(group) {
    return `<span class="bg-badge">${group}</span>`;
}

// ── STATUS BADGE ──
function statusBadge(status) {
    const map = {
        'Pending': 'badge-amber',
        'Fulfilled': 'badge-green',
        'Cancelled': 'badge-gray'
    };
    return `<span class="badge ${map[status] || 'badge-gray'}">${status}</span>`;
}

// ── AVAILABILITY BADGE ──
function availBadge(val) {
    return val
        ? `<span class="badge badge-green">Available</span>`
        : `<span class="badge badge-gray">Unavailable</span>`;
}

// ── FORMAT DATE ──
function fmtDate(d) {
    if (!d) return '—';
    return new Date(d).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
}

// ============================================================
// DASHBOARD
// ============================================================
async function loadDashboard() {
    if (!document.getElementById('stat-donors')) return;

    try {
        const [donors, banks, inventory, requests] = await Promise.all([
            fetch(`${API}/donors`).then(r => r.json()),
            fetch(`${API}/banks`).then(r => r.json()),
            fetch(`${API}/inventory/summary`).then(r => r.json()),
            fetch(`${API}/requests/all`).then(r => r.json()),
        ]);

        document.getElementById('stat-donors').textContent = donors.length;
        document.getElementById('stat-banks').textContent = banks.length;
        document.getElementById('stat-requests').textContent = requests.filter(r => r.status === 'Pending').length;

        const totalUnits = inventory.reduce((sum, i) => sum + parseInt(i.total_units || 0), 0);
        document.getElementById('stat-units').textContent = totalUnits;

        // Blood group summary
        const bgGrid = document.getElementById('bg-summary');
        if (bgGrid) {
            bgGrid.innerHTML = inventory.map(i => `
                <div class="inv-card ${i.total_units < 5 ? 'critical' : i.total_units < 10 ? 'low' : ''}">
                    <div class="blood-type">${i.blood_group}</div>
                    <div class="units">${i.total_units}</div>
                    <div class="units-sub">units</div>
                </div>
            `).join('');
        }

        // Recent requests
        const reqTable = document.getElementById('recent-requests');
        if (reqTable) {
            const recent = requests.slice(0, 5);
            reqTable.innerHTML = recent.length ? recent.map(r => `
                <tr>
                    <td>${r.recipient_name}</td>
                    <td>${bgBadge(r.blood_group)}</td>
                    <td><span class="badge ${r.request_type === 'Immediate' ? 'badge-red' : 'badge-blue'}">${r.request_type}</span></td>
                    <td>${r.city_entered}</td>
                    <td>${statusBadge(r.status)}</td>
                    <td>${fmtDate(r.created_at)}</td>
                </tr>
            `).join('') : `<tr><td colspan="6"><div class="empty-state"><div class="empty-icon">📋</div><p>No requests yet</p></div></td></tr>`;
        }

    } catch (err) {
        console.error('Dashboard error:', err);
    }
}

// ============================================================
// DONORS PAGE
// ============================================================
let allDonors = [];

async function loadDonors() {
    if (!document.getElementById('donors-table')) return;

    const tbody = document.getElementById('donors-table');
    tbody.innerHTML = `<tr><td colspan="8"><div class="loading">Loading donors...</div></td></tr>`;

    try {
        allDonors = await fetch(`${API}/donors`).then(r => r.json());
        renderDonors(allDonors);
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="8"><div class="empty-state"><p>Failed to load donors</p></div></td></tr>`;
    }
}

function renderDonors(donors) {
    const tbody = document.getElementById('donors-table');
    tbody.innerHTML = donors.length ? donors.map(d => `
        <tr>
            <td>#${d.donor_id}</td>
            <td><strong>${d.name}</strong></td>
            <td>${d.age} / ${d.gender[0]}</td>
            <td>${bgBadge(d.blood_group)}</td>
            <td>${d.city}</td>
            <td>${d.phone}</td>
            <td>${availBadge(d.is_available)}</td>
            <td>
                <button class="btn btn-outline btn-sm" onclick="toggleAvailability(${d.donor_id}, ${d.is_available})">
                    ${d.is_available ? 'Mark Busy' : 'Mark Available'}
                </button>
                <button class="btn btn-danger btn-sm" onclick="deleteDonor(${d.donor_id})">Delete</button>
            </td>
        </tr>
    `).join('') : `<tr><td colspan="8"><div class="empty-state"><div class="empty-icon">🩸</div><p>No donors registered yet</p></div></td></tr>`;
}

function searchDonors(query) {
    const q = query.toLowerCase();
    const filtered = allDonors.filter(d =>
        d.name.toLowerCase().includes(q) ||
        d.blood_group.toLowerCase().includes(q) ||
        d.city.toLowerCase().includes(q)
    );
    renderDonors(filtered);
}

async function addDonor(e) {
    e.preventDefault();
    const data = {
        name: document.getElementById('d-name').value,
        age: document.getElementById('d-age').value,
        gender: document.getElementById('d-gender').value,
        blood_group: document.getElementById('d-blood').value,
        city: document.getElementById('d-city').value,
        phone: document.getElementById('d-phone').value,
        email: document.getElementById('d-email').value,
    };

    try {
        const res = await fetch(`${API}/donors`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();
        if (result.donor_id) {
            showToast('Donor registered successfully!');
            closeModal('add-donor-modal');
            document.getElementById('add-donor-form').reset();
            loadDonors();
        } else {
            showToast(result.error || 'Failed to add donor', 'error');
        }
    } catch (err) {
        showToast('Server error', 'error');
    }
}

async function toggleAvailability(id, current) {
    try {
        await fetch(`${API}/donors/${id}/availability`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ is_available: !current })
        });
        showToast('Availability updated!');
        loadDonors();
    } catch (err) {
        showToast('Failed to update', 'error');
    }
}

async function deleteDonor(id) {
    if (!confirm('Delete this donor?')) return;
    try {
        await fetch(`${API}/donors/${id}`, { method: 'DELETE' });
        showToast('Donor deleted');
        loadDonors();
    } catch (err) {
        showToast('Failed to delete', 'error');
    }
}

// ============================================================
// INVENTORY PAGE
// ============================================================
async function loadInventory() {
    if (!document.getElementById('inventory-table')) return;

    try {
        const data = await fetch(`${API}/inventory`).then(r => r.json());
        const tbody = document.getElementById('inventory-table');
        tbody.innerHTML = data.length ? data.map(i => `
            <tr>
                <td>${i.bank_name}</td>
                <td>${i.city}</td>
                <td>${bgBadge(i.blood_group)}</td>
                <td>
                    <span style="color: ${i.units_available < 5 ? '#E74C3C' : i.units_available < 10 ? '#F39C12' : '#27AE60'}; font-weight: 700;">
                        ${i.units_available}
                    </span>
                    ${i.units_available < 5 ? '<span class="badge badge-red" style="margin-left:8px">Critical</span>' : ''}
                </td>
                <td>${fmtDate(i.last_updated)}</td>
            </tr>
        `).join('') : `<tr><td colspan="5"><div class="empty-state"><p>No inventory data</p></div></td></tr>`;

        // Summary grid
        const summary = await fetch(`${API}/inventory/summary`).then(r => r.json());
        const grid = document.getElementById('inv-summary-grid');
        if (grid) {
            grid.innerHTML = summary.map(i => `
                <div class="inv-card ${i.total_units < 5 ? 'critical' : i.total_units < 10 ? 'low' : ''}">
                    <div class="blood-type">${i.blood_group}</div>
                    <div class="units">${i.total_units}</div>
                    <div class="units-sub">total units</div>
                </div>
            `).join('');
        }
    } catch (err) {
        console.error('Inventory error:', err);
    }
}

// ============================================================
// BLOOD REQUESTS PAGE
// ============================================================
let currentTab = 'immediate';

async function loadRequests() {
    if (!document.getElementById('requests-table')) return;

    try {
        const data = await fetch(`${API}/requests/all`).then(r => r.json());
        const tbody = document.getElementById('requests-table');
        tbody.innerHTML = data.length ? data.map(r => `
            <tr>
                <td>#${r.request_id}</td>
                <td><strong>${r.recipient_name}</strong></td>
                <td>${r.recipient_phone}</td>
                <td>${bgBadge(r.blood_group)}</td>
                <td><span class="badge ${r.request_type === 'Immediate' ? 'badge-red' : 'badge-blue'}">${r.request_type}</span></td>
                <td>${r.units_needed}</td>
                <td>${r.city_entered}</td>
                <td>${statusBadge(r.status)}</td>
                <td>
                    ${r.status === 'Pending' ? `
                        <button class="btn btn-success btn-sm" onclick="updateStatus(${r.request_id}, 'Fulfilled')">Fulfill</button>
                        <button class="btn btn-danger btn-sm" onclick="updateStatus(${r.request_id}, 'Cancelled')">Cancel</button>
                    ` : '—'}
                </td>
            </tr>
        `).join('') : `<tr><td colspan="9"><div class="empty-state"><div class="empty-icon">📋</div><p>No requests found</p></div></td></tr>`;
    } catch (err) {
        console.error('Requests error:', err);
    }
}

async function searchBlood() {
    const bloodGroup = document.getElementById('search-blood-group').value;
    const city = document.getElementById('search-city') ? document.getElementById('search-city').value : '';
    const resultsDiv = document.getElementById('search-results');

    if (!bloodGroup) { showToast('Please select a blood group', 'error'); return; }
    if (currentTab === 'immediate' && !city) { showToast('Please enter your city', 'error'); return; }

    resultsDiv.innerHTML = `<div class="loading">Searching...</div>`;

    try {
        let res, data;
        if (currentTab === 'immediate') {
            res = await fetch(`${API}/requests/search/immediate`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ blood_group: bloodGroup, city })
            });
        } else {
            res = await fetch(`${API}/requests/search/nonimmediate`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ blood_group: bloodGroup })
            });
        }
        data = await res.json();

        if (!data || data.length === 0) {
            resultsDiv.innerHTML = `<div class="empty-state"><div class="empty-icon">😔</div><p>No blood available matching your criteria</p></div>`;
            return;
        }

        resultsDiv.innerHTML = data.map(item => `
            <div class="result-card ${item.source_type === 'Blood Bank' ? 'bank' : 'donor'}">
                <div class="result-info">
                    <h4>${item.source_name}</h4>
                    <p>📍 ${item.city} — ${item.address}</p>
                    <p>📞 ${item.phone} &nbsp;|&nbsp; ${bgBadge(item.available_group)}</p>
                    <p style="margin-top:4px">
                        <span class="badge ${item.source_type === 'Blood Bank' ? 'badge-blue' : 'badge-green'}">${item.source_type}</span>
                    </p>
                </div>
                <div class="result-units">
                    <div class="units-num">${item.units}</div>
                    <div class="units-label">units</div>
                </div>
            </div>
        `).join('');
    } catch (err) {
        resultsDiv.innerHTML = `<div class="empty-state"><p>Search failed. Try again.</p></div>`;
    }
}

function switchTab(tab) {
    currentTab = tab;
    document.querySelectorAll('.req-tab').forEach(t => t.classList.remove('active-tab'));
    document.querySelector(`.req-tab.${tab}`).classList.add('active-tab');

    const cityField = document.getElementById('city-field');
    if (cityField) {
        cityField.style.display = tab === 'immediate' ? 'block' : 'none';
    }
}

async function updateStatus(id, status) {
    try {
        await fetch(`${API}/requests/${id}/status`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status })
        });
        showToast(`Request marked as ${status}`);
        loadRequests();
    } catch (err) {
        showToast('Failed to update status', 'error');
    }
}

async function addRequest(e) {
    e.preventDefault();
    const data = {
        recipient_id: document.getElementById('req-recipient').value,
        blood_group: document.getElementById('req-blood').value,
        request_type: document.getElementById('req-type').value,
        units_needed: document.getElementById('req-units').value,
        city_entered: document.getElementById('req-city').value,
    };

    try {
        const res = await fetch(`${API}/requests`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();
        if (result.request_id) {
            showToast('Blood request submitted!');
            closeModal('add-request-modal');
            document.getElementById('add-request-form').reset();
            loadRequests();
        } else {
            showToast(result.error || 'Failed to submit request', 'error');
        }
    } catch (err) {
        showToast('Server error', 'error');
    }
}

// ============================================================
// EVENTS PAGE
// ============================================================
async function loadEvents() {
    if (!document.getElementById('events-table')) return;

    try {
        const data = await fetch(`${API}/events`).then(r => r.json());
        const tbody = document.getElementById('events-table');
        tbody.innerHTML = data.length ? data.map(e => `
            <tr>
                <td>#${e.event_id}</td>
                <td><strong>${e.event_name}</strong></td>
                <td>${e.bank_name}</td>
                <td>${e.city}</td>
                <td>${e.address}</td>
                <td>${fmtDate(e.event_date)}</td>
                <td>
                    <button class="btn btn-danger btn-sm" onclick="deleteEvent(${e.event_id})">Delete</button>
                </td>
            </tr>
        `).join('') : `<tr><td colspan="7"><div class="empty-state"><div class="empty-icon">📅</div><p>No events scheduled</p></div></td></tr>`;
    } catch (err) {
        console.error('Events error:', err);
    }
}

async function addEvent(e) {
    e.preventDefault();
    const data = {
        bank_id: document.getElementById('ev-bank').value,
        event_name: document.getElementById('ev-name').value,
        city: document.getElementById('ev-city').value,
        address: document.getElementById('ev-address').value,
        event_date: document.getElementById('ev-date').value,
    };

    try {
        const res = await fetch(`${API}/events`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();
        if (result.event_id) {
            showToast('Event added successfully!');
            closeModal('add-event-modal');
            document.getElementById('add-event-form').reset();
            loadEvents();
        } else {
            showToast(result.error || 'Failed to add event', 'error');
        }
    } catch (err) {
        showToast('Server error', 'error');
    }
}

async function deleteEvent(id) {
    if (!confirm('Delete this event?')) return;
    try {
        await fetch(`${API}/events/${id}`, { method: 'DELETE' });
        showToast('Event deleted');
        loadEvents();
    } catch (err) {
        showToast('Failed to delete', 'error');
    }
}

// ============================================================
// RECIPIENTS PAGE
// ============================================================
async function loadRecipients() {
    if (!document.getElementById('recipients-table')) return;

    try {
        const data = await fetch(`${API}/recipients`).then(r => r.json());
        const tbody = document.getElementById('recipients-table');
        tbody.innerHTML = data.length ? data.map(r => `
            <tr>
                <td>#${r.recipient_id}</td>
                <td><strong>${r.name}</strong></td>
                <td>${r.age} / ${r.gender[0]}</td>
                <td>${bgBadge(r.blood_group_needed)}</td>
                <td>${r.city}</td>
                <td>${r.phone}</td>
                <td>${r.hospital_name || '—'}</td>
                <td>
                    <button class="btn btn-danger btn-sm" onclick="deleteRecipient(${r.recipient_id})">Delete</button>
                </td>
            </tr>
        `).join('') : `<tr><td colspan="8"><div class="empty-state"><div class="empty-icon">🏥</div><p>No recipients registered</p></div></td></tr>`;
    } catch (err) {
        console.error('Recipients error:', err);
    }
}

async function addRecipient(e) {
    e.preventDefault();
    const data = {
        name: document.getElementById('r-name').value,
        age: document.getElementById('r-age').value,
        gender: document.getElementById('r-gender').value,
        blood_group_needed: document.getElementById('r-blood').value,
        city: document.getElementById('r-city').value,
        phone: document.getElementById('r-phone').value,
        hospital_id: document.getElementById('r-hospital').value || null,
    };

    try {
        const res = await fetch(`${API}/recipients`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();
        if (result.recipient_id) {
            showToast('Recipient added successfully!');
            closeModal('add-recipient-modal');
            document.getElementById('add-recipient-form').reset();
            loadRecipients();
        } else {
            showToast(result.error || 'Failed to add recipient', 'error');
        }
    } catch (err) {
        showToast('Server error', 'error');
    }
}

async function deleteRecipient(id) {
    if (!confirm('Delete this recipient?')) return;
    try {
        await fetch(`${API}/recipients/${id}`, { method: 'DELETE' });
        showToast('Recipient deleted');
        loadRecipients();
    } catch (err) {
        showToast('Failed to delete', 'error');
    }
}

// ============================================================
// POPULATE DROPDOWNS
// ============================================================
async function populateBankDropdown(selectId) {
    const sel = document.getElementById(selectId);
    if (!sel) return;
    const banks = await fetch(`${API}/banks`).then(r => r.json());
    sel.innerHTML = `<option value="">Select Blood Bank</option>` +
        banks.map(b => `<option value="${b.bank_id}">${b.name} — ${b.city}</option>`).join('');
}

async function populateRecipientDropdown(selectId) {
    const sel = document.getElementById(selectId);
    if (!sel) return;
    const recipients = await fetch(`${API}/recipients`).then(r => r.json());
    sel.innerHTML = `<option value="">Select Recipient</option>` +
        recipients.map(r => `<option value="${r.recipient_id}">${r.name} — ${r.city}</option>`).join('');
}

// ============================================================
// INIT — runs on every page load
// ============================================================
document.addEventListener('DOMContentLoaded', () => {
    loadDashboard();
    loadDonors();
    loadInventory();
    loadRequests();
    loadEvents();
    loadRecipients();
    populateBankDropdown('ev-bank');
    populateBankDropdown('req-bank');
    populateRecipientDropdown('req-recipient');
});