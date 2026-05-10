-- ============================================================
-- DEMO DATA — Active Blood Donation and Management System
-- Run this AFTER blood_donation_db.sql
-- ============================================================

USE blood_donation_db;

-- Clear existing data first (safe reset)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE blood_requests;
TRUNCATE TABLE donations;
TRUNCATE TABLE donation_events;
TRUNCATE TABLE blood_inventory;
TRUNCATE TABLE recipients;
TRUNCATE TABLE donors;
TRUNCATE TABLE blood_banks;
TRUNCATE TABLE hospitals;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- HOSPITALS (10 records)
-- ============================================================
INSERT INTO hospitals (name, city, address, phone, email) VALUES
('Manipal Hospital', 'Bangalore', 'Old Airport Road, Bangalore - 560017', '08023456789', 'info@manipal.com'),
('Fortis Hospital', 'Bangalore', 'Bannerghatta Road, Bangalore - 560076', '08024567890', 'info@fortis.com'),
('NIMHANS', 'Bangalore', 'Hosur Road, Bangalore - 560029', '08025678901', 'info@nimhans.com'),
('Apollo Hospital', 'Mysore', 'Mysore Road, Mysore - 570001', '08212345678', 'info@apollo-mys.com'),
('KMC Hospital', 'Mangalore', 'Ambedkar Circle, Mangalore - 575001', '08242345678', 'info@kmc.com'),
('KIMS Hospital', 'Hubli', 'KIMS Campus, Hubli - 580022', '08362345678', 'info@kims.com'),
('SDM Hospital', 'Dharwad', 'Sattur, Dharwad - 580009', '08362456789', 'info@sdm.com'),
('Vydehi Hospital', 'Bangalore', 'Whitefield, Bangalore - 560066', '08028456789', 'info@vydehi.com'),
('St. Johns Hospital', 'Bangalore', 'Koramangala, Bangalore - 560034', '08025678902', 'info@stjohns.com'),
('Wenlock Hospital', 'Mangalore', 'Hampankatta, Mangalore - 575001', '08242456789', 'info@wenlock.com');

-- ============================================================
-- BLOOD BANKS (8 records)
-- ============================================================
INSERT INTO blood_banks (name, city, address, phone, email, latitude, longitude) VALUES
('Red Cross Blood Bank', 'Bangalore', 'MG Road, Bangalore - 560001', '08022345678', 'redcross@bb.com', 12.9716, 77.5946),
('Rotary Blood Bank', 'Bangalore', 'Jayanagar 4th Block, Bangalore - 560011', '08023456789', 'rotary@bb.com', 12.9250, 77.5938),
('Government Blood Bank', 'Mysore', 'Irwin Road, Mysore - 570001', '08212234567', 'govt@bb-mys.com', 12.2958, 76.6394),
('Life Blood Bank', 'Mangalore', 'Hampankatta, Mangalore - 575001', '08242234567', 'life@bb.com', 12.8698, 74.8431),
('Unity Blood Bank', 'Hubli', 'Station Road, Hubli - 580020', '08362234567', 'unity@bb.com', 15.3647, 75.1240),
('Sanjeevini Blood Bank', 'Bangalore', 'Rajajinagar, Bangalore - 560010', '08026234567', 'sanjeevini@bb.com', 12.9899, 77.5530),
('Dharwad Blood Bank', 'Dharwad', 'PB Road, Dharwad - 580001', '08362345670', 'dharwad@bb.com', 15.4589, 75.0078),
('Coastal Blood Bank', 'Mangalore', 'Kadri, Mangalore - 575002', '08242345670', 'coastal@bb.com', 12.8800, 74.8550);

-- ============================================================
-- BLOOD INVENTORY (all 8 blood groups for all 8 banks)
-- ============================================================
INSERT INTO blood_inventory (bank_id, blood_group, units_available) VALUES
-- Red Cross Blood Bank Bangalore
(1,'A+',28),(1,'A-',12),(1,'B+',35),(1,'B-',9),(1,'AB+',18),(1,'AB-',6),(1,'O+',45),(1,'O-',14),
-- Rotary Blood Bank Bangalore
(2,'A+',20),(2,'A-',7),(2,'B+',25),(2,'B-',5),(2,'AB+',12),(2,'AB-',4),(2,'O+',38),(2,'O-',10),
-- Government Blood Bank Mysore
(3,'A+',15),(3,'A-',4),(3,'B+',18),(3,'B-',3),(3,'AB+',9),(3,'AB-',2),(3,'O+',22),(3,'O-',7),
-- Life Blood Bank Mangalore
(4,'A+',12),(4,'A-',3),(4,'B+',14),(4,'B-',2),(4,'AB+',7),(4,'AB-',2),(4,'O+',19),(4,'O-',5),
-- Unity Blood Bank Hubli
(5,'A+',10),(5,'A-',3),(5,'B+',12),(5,'B-',2),(5,'AB+',5),(5,'AB-',1),(5,'O+',16),(5,'O-',4),
-- Sanjeevini Blood Bank Bangalore
(6,'A+',22),(6,'A-',8),(6,'B+',28),(6,'B-',6),(6,'AB+',14),(6,'AB-',4),(6,'O+',40),(6,'O-',11),
-- Dharwad Blood Bank
(7,'A+',8),(7,'A-',2),(7,'B+',10),(7,'B-',1),(7,'AB+',4),(7,'AB-',1),(7,'O+',13),(7,'O-',3),
-- Coastal Blood Bank Mangalore
(8,'A+',11),(8,'A-',3),(8,'B+',13),(8,'B-',2),(8,'AB+',6),(8,'AB-',2),(8,'O+',17),(8,'O-',5);

-- ============================================================
-- DONORS (20 records across cities)
-- ============================================================
INSERT INTO donors (name, age, gender, blood_group, city, phone, email, is_available, last_donated_date) VALUES
('Rahul Sharma',     28, 'Male',   'O+',  'Bangalore', '9876543210', 'rahul.s@email.com',   TRUE,  '2024-12-10'),
('Priya Nair',       24, 'Female', 'A+',  'Bangalore', '9876543211', 'priya.n@email.com',   TRUE,  NULL),
('Amit Patel',       32, 'Male',   'B+',  'Bangalore', '9876543212', 'amit.p@email.com',    FALSE, '2025-01-15'),
('Sneha Reddy',      26, 'Female', 'AB+', 'Mysore',    '9876543213', 'sneha.r@email.com',   TRUE,  NULL),
('Kiran Kumar',      30, 'Male',   'O-',  'Mangalore', '9876543214', 'kiran.k@email.com',   TRUE,  '2024-11-20'),
('Divya Menon',      22, 'Female', 'A-',  'Bangalore', '9876543215', 'divya.m@email.com',   TRUE,  NULL),
('Suresh Gowda',     35, 'Male',   'B-',  'Hubli',     '9876543216', 'suresh.g@email.com',  TRUE,  '2024-10-05'),
('Anita Singh',      29, 'Female', 'O+',  'Bangalore', '9876543217', 'anita.s@email.com',   TRUE,  NULL),
('Vijay Rao',        33, 'Male',   'A+',  'Mysore',    '9876543218', 'vijay.r@email.com',   TRUE,  '2025-02-01'),
('Kavitha Shetty',   27, 'Female', 'B+',  'Mangalore', '9876543219', 'kavitha.s@email.com', TRUE,  NULL),
('Deepak Joshi',     31, 'Male',   'AB-', 'Bangalore', '9876543220', 'deepak.j@email.com',  FALSE, '2024-09-15'),
('Meena Kulkarni',   25, 'Female', 'O+',  'Dharwad',   '9876543221', 'meena.k@email.com',   TRUE,  NULL),
('Rajan Pillai',     38, 'Male',   'A+',  'Bangalore', '9876543222', 'rajan.p@email.com',   TRUE,  '2025-01-20'),
('Sowmya Hegde',     23, 'Female', 'B+',  'Hubli',     '9876543223', 'sowmya.h@email.com',  TRUE,  NULL),
('Naveen Gowda',     36, 'Male',   'O-',  'Bangalore', '9876543224', 'naveen.g@email.com',  TRUE,  '2024-08-10'),
('Pooja Sharma',     28, 'Female', 'A-',  'Mysore',    '9876543225', 'pooja.s@email.com',   TRUE,  NULL),
('Arjun Nair',       34, 'Male',   'B-',  'Mangalore', '9876543226', 'arjun.n@email.com',   FALSE, '2024-12-25'),
('Lakshmi Devi',     26, 'Female', 'AB+', 'Bangalore', '9876543227', 'lakshmi.d@email.com', TRUE,  NULL),
('Mohan Das',        40, 'Male',   'O+',  'Dharwad',   '9876543228', 'mohan.d@email.com',   TRUE,  '2025-03-01'),
('Rekha Iyer',       29, 'Female', 'A+',  'Bangalore', '9876543229', 'rekha.i@email.com',   TRUE,  NULL);

-- ============================================================
-- DONATION EVENTS (6 records)
-- ============================================================
INSERT INTO donation_events (bank_id, event_name, city, address, event_date) VALUES
(1, 'World Blood Donor Day Camp 2025',    'Bangalore', 'Cubbon Park, MG Road, Bangalore',       '2025-06-14'),
(2, 'Rotary Blood Drive — Jayanagar',     'Bangalore', 'Jayanagar 4th Block Community Hall',    '2025-07-20'),
(3, 'Mysore Palace Blood Camp',           'Mysore',    'Mysore Palace Grounds, Mysore',          '2025-08-10'),
(4, 'Coastal Blood Drive 2025',           'Mangalore', 'Hampankatta Circle, Mangalore',          '2025-09-05'),
(6, 'Rajajinagar Donation Drive',         'Bangalore', 'Rajajinagar 1st Block, Bangalore',      '2025-10-02'),
(5, 'Hubli Independence Day Blood Camp',  'Hubli',     'Town Hall Grounds, Station Road, Hubli', '2025-08-15');

-- ============================================================
-- DONATIONS (8 records)
-- ============================================================
INSERT INTO donations (donor_id, event_id, units_donated, donation_date) VALUES
(1,  1, 1, '2025-06-14'),
(2,  1, 1, '2025-06-14'),
(3,  2, 1, '2025-07-20'),
(4,  3, 1, '2025-08-10'),
(5,  4, 1, '2025-09-05'),
(8,  1, 1, '2025-06-14'),
(13, 2, 1, '2025-07-20'),
(9,  3, 1, '2025-08-10');

-- ============================================================
-- RECIPIENTS (12 records)
-- ============================================================
INSERT INTO recipients (name, age, gender, blood_group_needed, city, phone, hospital_id) VALUES
('Vikram Rao',       45, 'Male',   'O+',  'Bangalore', '9123456780', 1),
('Sunita Verma',     38, 'Female', 'A+',  'Bangalore', '9123456781', 2),
('Mohan Krishnan',   60, 'Male',   'B+',  'Mysore',    '9123456782', 4),
('Kavya Shetty',     25, 'Female', 'AB+', 'Mangalore', '9123456783', 5),
('Ravi Shankar',     52, 'Male',   'O-',  'Bangalore', '9123456784', 9),
('Usha Rani',        43, 'Female', 'A-',  'Hubli',     '9123456785', 6),
('Prakash Nair',     35, 'Male',   'B-',  'Bangalore', '9123456786', 8),
('Geetha Menon',     29, 'Female', 'AB-', 'Mysore',    '9123456787', 4),
('Sanjay Gupta',     48, 'Male',   'A+',  'Mangalore', '9123456788', 5),
('Padma Devi',       55, 'Female', 'O+',  'Dharwad',   '9123456789', 7),
('Arjun Reddy',      32, 'Male',   'B+',  'Bangalore', '9123456790', 1),
('Nirmala Shetty',   41, 'Female', 'A+',  'Bangalore', '9123456791', 3);

-- ============================================================
-- BLOOD REQUESTS (10 records — mix of types and statuses)
-- ============================================================
INSERT INTO blood_requests (recipient_id, blood_group, request_type, units_needed, city_entered, status) VALUES
(1,  'O+',  'Immediate',     2, 'Bangalore', 'Pending'),
(2,  'A+',  'Non-Immediate', 1, 'Bangalore', 'Pending'),
(3,  'B+',  'Immediate',     1, 'Mysore',    'Fulfilled'),
(4,  'AB+', 'Non-Immediate', 2, 'Mangalore', 'Pending'),
(5,  'O-',  'Immediate',     3, 'Bangalore', 'Pending'),
(6,  'A-',  'Non-Immediate', 1, 'Hubli',     'Fulfilled'),
(7,  'B-',  'Immediate',     2, 'Bangalore', 'Cancelled'),
(8,  'AB-', 'Non-Immediate', 1, 'Mysore',    'Pending'),
(9,  'A+',  'Immediate',     2, 'Mangalore', 'Pending'),
(10, 'O+',  'Non-Immediate', 1, 'Dharwad',   'Fulfilled');

SELECT 'Demo data loaded successfully!' AS Status;
