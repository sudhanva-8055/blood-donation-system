-- ============================================================
-- ACTIVE BLOOD DONATION AND MANAGEMENT SYSTEM
-- MySQL Schema — VTU DBMS Project
-- ============================================================

DROP DATABASE IF EXISTS blood_donation_db;
CREATE DATABASE blood_donation_db;
USE blood_donation_db;

-- ============================================================
-- TABLE 1: HOSPITALS
-- ============================================================
CREATE TABLE hospitals (
    hospital_id     INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    address         VARCHAR(255) NOT NULL,
    phone           VARCHAR(15) NOT NULL,
    email           VARCHAR(100),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 2: BLOOD BANKS
-- ============================================================
CREATE TABLE blood_banks (
    bank_id         INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    address         VARCHAR(255) NOT NULL,
    phone           VARCHAR(15) NOT NULL,
    email           VARCHAR(100),
    latitude        DECIMAL(9,6),
    longitude       DECIMAL(9,6),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 3: DONORS
-- ============================================================
CREATE TABLE donors (
    donor_id            INT AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    age                 INT NOT NULL CHECK (age >= 18 AND age <= 65),
    gender              ENUM('Male','Female','Other') NOT NULL,
    blood_group         ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    city                VARCHAR(100) NOT NULL,
    phone               VARCHAR(15) NOT NULL UNIQUE,
    email               VARCHAR(100) UNIQUE,
    last_donated_date   DATE,
    is_available        BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 4: BLOOD INVENTORY
-- ============================================================
CREATE TABLE blood_inventory (
    inventory_id        INT AUTO_INCREMENT PRIMARY KEY,
    bank_id             INT NOT NULL,
    blood_group         ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    units_available     INT NOT NULL DEFAULT 0 CHECK (units_available >= 0),
    last_updated        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bank_id) REFERENCES blood_banks(bank_id) ON DELETE CASCADE,
    UNIQUE KEY unique_bank_blood (bank_id, blood_group)
);

-- ============================================================
-- TABLE 5: DONATION EVENTS
-- ============================================================
CREATE TABLE donation_events (
    event_id        INT AUTO_INCREMENT PRIMARY KEY,
    bank_id         INT NOT NULL,
    event_name      VARCHAR(150) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    address         VARCHAR(255) NOT NULL,
    event_date      DATE NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bank_id) REFERENCES blood_banks(bank_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE 6: DONATIONS
-- ============================================================
CREATE TABLE donations (
    donation_id     INT AUTO_INCREMENT PRIMARY KEY,
    donor_id        INT NOT NULL,
    event_id        INT NOT NULL,
    units_donated   INT NOT NULL DEFAULT 1 CHECK (units_donated > 0),
    donation_date   DATE NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donors(donor_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES donation_events(event_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE 7: RECIPIENTS
-- ============================================================
CREATE TABLE recipients (
    recipient_id        INT AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    age                 INT NOT NULL CHECK (age > 0),
    gender              ENUM('Male','Female','Other') NOT NULL,
    blood_group_needed  ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    city                VARCHAR(100) NOT NULL,
    phone               VARCHAR(15) NOT NULL,
    hospital_id         INT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE 8: BLOOD REQUESTS
-- ============================================================
CREATE TABLE blood_requests (
    request_id      INT AUTO_INCREMENT PRIMARY KEY,
    recipient_id    INT NOT NULL,
    blood_group     ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    request_type    ENUM('Immediate','Non-Immediate') NOT NULL,
    units_needed    INT NOT NULL DEFAULT 1 CHECK (units_needed > 0),
    city_entered    VARCHAR(100) NOT NULL,
    status          ENUM('Pending','Fulfilled','Cancelled') DEFAULT 'Pending',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (recipient_id) REFERENCES recipients(recipient_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE 9: BLOOD COMPATIBILITY
-- ============================================================
CREATE TABLE blood_compatibility (
    needed_group    ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    can_use_from    ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    PRIMARY KEY (needed_group, can_use_from)
);

-- Insert compatibility rules
INSERT INTO blood_compatibility (needed_group, can_use_from) VALUES
('A+',  'A+'), ('A+',  'A-'), ('A+',  'O+'), ('A+',  'O-'),
('A-',  'A-'), ('A-',  'O-'),
('B+',  'B+'), ('B+',  'B-'), ('B+',  'O+'), ('B+',  'O-'),
('B-',  'B-'), ('B-',  'O-'),
('AB+', 'A+'), ('AB+', 'A-'), ('AB+', 'B+'), ('AB+', 'B-'),
('AB+', 'AB+'),('AB+', 'AB-'),('AB+', 'O+'), ('AB+', 'O-'),
('AB-', 'A-'), ('AB-', 'B-'), ('AB-', 'AB-'),('AB-', 'O-'),
('O+',  'O+'), ('O+',  'O-'),
('O-',  'O-');

-- ============================================================
-- TRIGGER 1: After donation — increase blood inventory
-- ============================================================
DELIMITER $$
CREATE TRIGGER after_donation_insert
AFTER INSERT ON donations
FOR EACH ROW
BEGIN
    DECLARE v_blood_group ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-');
    DECLARE v_bank_id INT;

    SELECT d.blood_group INTO v_blood_group
    FROM donors d WHERE d.donor_id = NEW.donor_id;

    SELECT de.bank_id INTO v_bank_id
    FROM donation_events de WHERE de.event_id = NEW.event_id;

    INSERT INTO blood_inventory (bank_id, blood_group, units_available)
    VALUES (v_bank_id, v_blood_group, NEW.units_donated)
    ON DUPLICATE KEY UPDATE
        units_available = units_available + NEW.units_donated;

    UPDATE donors SET last_donated_date = NEW.donation_date
    WHERE donor_id = NEW.donor_id;
END$$
DELIMITER ;

-- ============================================================
-- TRIGGER 2: After blood request fulfilled — decrease inventory
-- ============================================================
DELIMITER $$
CREATE TRIGGER after_request_fulfilled
AFTER UPDATE ON blood_requests
FOR EACH ROW
BEGIN
    IF NEW.status = 'Fulfilled' AND OLD.status != 'Fulfilled' THEN
        UPDATE blood_inventory
        SET units_available = units_available - NEW.units_needed
        WHERE blood_group = NEW.blood_group
          AND bank_id = (
              SELECT bank_id FROM blood_inventory
              WHERE blood_group IN (
                  SELECT can_use_from FROM blood_compatibility
                  WHERE needed_group = NEW.blood_group
              )
              AND city = NEW.city_entered
              AND units_available >= NEW.units_needed
              ORDER BY units_available DESC
              LIMIT 1
          );
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- STORED PROCEDURE 1: Immediate Blood Request Search
-- ============================================================
DELIMITER $$
CREATE PROCEDURE SearchImmediate(
    IN p_blood_group ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-'),
    IN p_city VARCHAR(100)
)
BEGIN
    -- Blood banks in same city with compatible stock
    SELECT
        'Blood Bank' AS source_type,
        bb.name AS source_name,
        bb.city,
        bb.address,
        bb.phone,
        bi.blood_group AS available_group,
        bi.units_available AS units,
        0 AS distance_priority
    FROM blood_inventory bi
    JOIN blood_banks bb ON bi.bank_id = bb.bank_id
    WHERE bi.blood_group IN (
        SELECT can_use_from FROM blood_compatibility WHERE needed_group = p_blood_group
    )
    AND bi.units_available > 0
    AND LOWER(bb.city) = LOWER(p_city)

    UNION ALL

    -- Available donors in same city with compatible blood group
    SELECT
        'Donor' AS source_type,
        d.name AS source_name,
        d.city,
        'Contact donor directly' AS address,
        d.phone,
        d.blood_group AS available_group,
        1 AS units,
        0 AS distance_priority
    FROM donors d
    WHERE d.blood_group IN (
        SELECT can_use_from FROM blood_compatibility WHERE needed_group = p_blood_group
    )
    AND d.is_available = TRUE
    AND LOWER(d.city) = LOWER(p_city)

    ORDER BY distance_priority, units DESC;
END$$
DELIMITER ;

-- ============================================================
-- STORED PROCEDURE 2: Non-Immediate Blood Request Search
-- ============================================================
DELIMITER $$
CREATE PROCEDURE SearchNonImmediate(
    IN p_blood_group ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-')
)
BEGIN
    SELECT
        'Blood Bank' AS source_type,
        bb.name AS source_name,
        bb.city,
        bb.address,
        bb.phone,
        bi.blood_group AS available_group,
        bi.units_available AS units
    FROM blood_inventory bi
    JOIN blood_banks bb ON bi.bank_id = bb.bank_id
    WHERE bi.blood_group IN (
        SELECT can_use_from FROM blood_compatibility WHERE needed_group = p_blood_group
    )
    AND bi.units_available > 0

    UNION ALL

    SELECT
        'Donor' AS source_type,
        d.name AS source_name,
        d.city,
        'Contact donor directly' AS address,
        d.phone,
        d.blood_group AS available_group,
        1 AS units
    FROM donors d
    WHERE d.blood_group IN (
        SELECT can_use_from FROM blood_compatibility WHERE needed_group = p_blood_group
    )
    AND d.is_available = TRUE

    ORDER BY city, units DESC;
END$$
DELIMITER ;

-- ============================================================
-- USEFUL VIEWS
-- ============================================================

-- View: Full inventory summary per bank
CREATE VIEW inventory_summary AS
SELECT
    bb.name AS bank_name,
    bb.city,
    bi.blood_group,
    bi.units_available,
    bi.last_updated
FROM blood_inventory bi
JOIN blood_banks bb ON bi.bank_id = bb.bank_id
ORDER BY bb.city, bi.blood_group;

-- View: Pending blood requests with recipient info
CREATE VIEW pending_requests AS
SELECT
    br.request_id,
    r.name AS recipient_name,
    r.phone AS recipient_phone,
    br.blood_group,
    br.request_type,
    br.units_needed,
    br.city_entered,
    br.status,
    br.created_at
FROM blood_requests br
JOIN recipients r ON br.recipient_id = r.recipient_id
WHERE br.status = 'Pending'
ORDER BY br.request_type DESC, br.created_at ASC;

-- View: Donor donation history
CREATE VIEW donor_history AS
SELECT
    d.name AS donor_name,
    d.blood_group,
    d.city,
    COUNT(dn.donation_id) AS total_donations,
    SUM(dn.units_donated) AS total_units,
    MAX(dn.donation_date) AS last_donated
FROM donors d
LEFT JOIN donations dn ON d.donor_id = dn.donor_id
GROUP BY d.donor_id, d.name, d.blood_group, d.city;

-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Hospitals
INSERT INTO hospitals (name, city, address, phone, email) VALUES
('Manipal Hospital', 'Bangalore', 'Old Airport Road, Bangalore', '08023456789', 'info@manipal.com'),
('Fortis Hospital', 'Bangalore', 'Bannerghatta Road, Bangalore', '08024567890', 'info@fortis.com'),
('NIMHANS', 'Bangalore', 'Hosur Road, Bangalore', '08025678901', 'info@nimhans.com'),
('Apollo Hospital', 'Mysore', 'Mysore Road', '08212345678', 'info@apollo.com'),
('KMC Hospital', 'Mangalore', 'Ambedkar Circle', '08242345678', 'info@kmc.com');

-- Blood Banks
INSERT INTO blood_banks (name, city, address, phone, email, latitude, longitude) VALUES
('Red Cross Blood Bank', 'Bangalore', 'MG Road, Bangalore', '08022345678', 'redcross@bb.com', 12.9716, 77.5946),
('Rotary Blood Bank', 'Bangalore', 'Jayanagar, Bangalore', '08023456789', 'rotary@bb.com', 12.9250, 77.5938),
('Government Blood Bank', 'Mysore', 'Irwin Road, Mysore', '08212234567', 'govt@bb.com', 12.2958, 76.6394),
('Life Blood Bank', 'Mangalore', 'Hampankatta, Mangalore', '08242234567', 'life@bb.com', 12.8698, 74.8431),
('Unity Blood Bank', 'Hubli', 'Station Road, Hubli', '08362234567', 'unity@bb.com', 15.3647, 75.1240);

-- Blood Inventory
INSERT INTO blood_inventory (bank_id, blood_group, units_available) VALUES
(1,'A+',25),(1,'A-',10),(1,'B+',30),(1,'B-',8),(1,'AB+',15),(1,'AB-',5),(1,'O+',40),(1,'O-',12),
(2,'A+',18),(2,'A-',6),(2,'B+',22),(2,'B-',4),(2,'AB+',10),(2,'AB-',3),(2,'O+',35),(2,'O-',9),
(3,'A+',12),(3,'B+',15),(3,'O+',20),(3,'AB+',8),(3,'O-',6),
(4,'A+',10),(4,'B+',12),(4,'O+',18),(4,'AB+',5),(4,'B-',3),
(5,'A+',8),(5,'B+',10),(5,'O+',15),(5,'O-',4);

-- Donors
INSERT INTO donors (name, age, gender, blood_group, city, phone, email, is_available) VALUES
('Rahul Sharma', 28, 'Male', 'O+', 'Bangalore', '9876543210', 'rahul@email.com', TRUE),
('Priya Nair', 24, 'Female', 'A+', 'Bangalore', '9876543211', 'priya@email.com', TRUE),
('Amit Patel', 32, 'Male', 'B+', 'Bangalore', '9876543212', 'amit@email.com', FALSE),
('Sneha Reddy', 26, 'Female', 'AB+', 'Mysore', '9876543213', 'sneha@email.com', TRUE),
('Kiran Kumar', 30, 'Male', 'O-', 'Mangalore', '9876543214', 'kiran@email.com', TRUE),
('Divya Menon', 22, 'Female', 'A-', 'Bangalore', '9876543215', 'divya@email.com', TRUE),
('Suresh Gowda', 35, 'Male', 'B-', 'Hubli', '9876543216', 'suresh@email.com', TRUE),
('Anita Singh', 29, 'Female', 'O+', 'Bangalore', '9876543217', 'anita@email.com', TRUE);

-- Donation Events
INSERT INTO donation_events (bank_id, event_name, city, address, event_date) VALUES
(1, 'World Blood Donor Day Camp', 'Bangalore', 'Cubbon Park, Bangalore', '2025-06-14'),
(2, 'Rotary Blood Drive 2025', 'Bangalore', 'Jayanagar 4th Block', '2025-07-20'),
(3, 'Mysore Blood Camp', 'Mysore', 'Mysore Palace Grounds', '2025-08-10'),
(4, 'Coastal Blood Drive', 'Mangalore', 'Hampankatta Circle', '2025-09-05');

-- Donations
INSERT INTO donations (donor_id, event_id, units_donated, donation_date) VALUES
(1, 1, 1, '2025-06-14'),
(2, 1, 1, '2025-06-14'),
(3, 2, 1, '2025-07-20'),
(4, 3, 1, '2025-08-10'),
(5, 4, 1, '2025-09-05');

-- Recipients
INSERT INTO recipients (name, age, gender, blood_group_needed, city, phone, hospital_id) VALUES
('Vikram Rao', 45, 'Male', 'O+', 'Bangalore', '9123456780', 1),
('Lakshmi Devi', 38, 'Female', 'A+', 'Bangalore', '9123456781', 2),
('Mohan Das', 60, 'Male', 'B+', 'Mysore', '9123456782', 4),
('Kavya Shetty', 25, 'Female', 'AB+', 'Mangalore', '9123456783', 5);

-- Blood Requests
INSERT INTO blood_requests (recipient_id, blood_group, request_type, units_needed, city_entered, status) VALUES
(1, 'O+', 'Immediate', 2, 'Bangalore', 'Pending'),
(2, 'A+', 'Non-Immediate', 1, 'Bangalore', 'Pending'),
(3, 'B+', 'Immediate', 1, 'Mysore', 'Fulfilled'),
(4, 'AB+', 'Non-Immediate', 2, 'Mangalore', 'Pending');

-- ============================================================
-- USEFUL QUERIES (for viva reference)
-- ============================================================

-- Q1: List all donors with their blood group and availability
-- SELECT name, blood_group, city, is_available FROM donors ORDER BY blood_group;

-- Q2: Total units per blood group across all banks
-- SELECT blood_group, SUM(units_available) AS total_units FROM blood_inventory GROUP BY blood_group ORDER BY total_units DESC;

-- Q3: Find compatible blood sources for a patient needing O+
-- CALL SearchImmediate('O+', 'Bangalore');

-- Q4: All pending immediate requests
-- SELECT * FROM pending_requests WHERE request_type = 'Immediate';

-- Q5: Donor donation history
-- SELECT * FROM donor_history;

-- Q6: Banks with low stock (less than 5 units of any group)
-- SELECT bb.name, bb.city, bi.blood_group, bi.units_available FROM blood_inventory bi JOIN blood_banks bb ON bi.bank_id = bb.bank_id WHERE bi.units_available < 5;

SELECT 'Database setup complete!' AS Status;
