-- ============================================================
-- FARMER LAND MAPPING AND CROP MANAGEMENT SYSTEM
-- UCS310 – Database Management Systems
-- Group: Aditya Bansal, Ishaan Prabhakar, Piyush Singh
-- ============================================================

-- ============================================================
-- SECTION 1: SCHEMA CREATION (DDL) — Commands 1–8
-- ============================================================

-- CMD 1: Create CROP table
CREATE TABLE CROP (
    Crop_ID     INT PRIMARY KEY AUTO_INCREMENT,
    Crop_Name   VARCHAR(100) NOT NULL UNIQUE
);

-- CMD 2: Create FARMER table
CREATE TABLE FARMER (
    Farmer_ID         INT PRIMARY KEY AUTO_INCREMENT,
    Name              VARCHAR(150) NOT NULL,
    Phone             VARCHAR(15)  NOT NULL UNIQUE,
    Address           VARCHAR(255),
    Aadhaar_No        CHAR(12)     NOT NULL UNIQUE,
    Registration_Date DATE         NOT NULL DEFAULT (CURRENT_DATE)
);

-- CMD 3: Create LAND table
CREATE TABLE LAND (
    Land_ID         INT PRIMARY KEY AUTO_INCREMENT,
    Area            FLOAT        NOT NULL CHECK (Area > 0),
    Location        VARCHAR(200) NOT NULL,
    Soil_Type       VARCHAR(50),
    Land_Category   VARCHAR(50)
);

-- CMD 4: Create LAND_OWNERSHIP (junction table for many-to-many Farmer ↔ Land)
CREATE TABLE LAND_OWNERSHIP (
    Ownership_ID         INT PRIMARY KEY AUTO_INCREMENT,
    Farmer_ID            INT   NOT NULL,
    Land_ID              INT   NOT NULL,
    Ownership_Percentage FLOAT NOT NULL CHECK (Ownership_Percentage > 0 AND Ownership_Percentage <= 100),
    FOREIGN KEY (Farmer_ID) REFERENCES FARMER(Farmer_ID) ON DELETE CASCADE,
    FOREIGN KEY (Land_ID)   REFERENCES LAND(Land_ID)     ON DELETE CASCADE,
    UNIQUE (Farmer_ID, Land_ID)
);

-- CMD 5: Create CROP_VARIETY table
CREATE TABLE CROP_VARIETY (
    Variety_ID      INT PRIMARY KEY AUTO_INCREMENT,
    Crop_ID         INT          NOT NULL,
    Variety_Name    VARCHAR(100) NOT NULL,
    Characteristics VARCHAR(255),
    FOREIGN KEY (Crop_ID) REFERENCES CROP(Crop_ID) ON DELETE CASCADE
);

-- CMD 6: Create SEASON table
CREATE TABLE SEASON (
    Season_ID   INT PRIMARY KEY AUTO_INCREMENT,
    Season_Name VARCHAR(50) NOT NULL,
    Year        INT         NOT NULL,
    UNIQUE (Season_Name, Year)
);

-- CMD 7: Create CROP_RECORD table
CREATE TABLE CROP_RECORD (
    Record_ID      INT PRIMARY KEY AUTO_INCREMENT,
    Land_ID        INT     NOT NULL,
    Variety_ID     INT     NOT NULL,
    Season_ID      INT     NOT NULL,
    Sowing_Date    DATE    NOT NULL,
    Expected_Yield FLOAT   CHECK (Expected_Yield >= 0),
    Actual_Yield   FLOAT   CHECK (Actual_Yield >= 0),
    FOREIGN KEY (Land_ID)    REFERENCES LAND(Land_ID)               ON DELETE CASCADE,
    FOREIGN KEY (Variety_ID) REFERENCES CROP_VARIETY(Variety_ID)    ON DELETE CASCADE,
    FOREIGN KEY (Season_ID)  REFERENCES SEASON(Season_ID)           ON DELETE CASCADE
);

-- CMD 8: Create SUBSIDY_POLICY table
CREATE TABLE SUBSIDY_POLICY (
    Policy_ID       INT PRIMARY KEY AUTO_INCREMENT,
    Policy_Name     VARCHAR(150) NOT NULL,
    Crop_ID         INT,
    Min_Area        FLOAT DEFAULT 0,
    Amount          FLOAT NOT NULL,
    Description     VARCHAR(300),
    FOREIGN KEY (Crop_ID) REFERENCES CROP(Crop_ID) ON DELETE SET NULL
);

-- CMD 9: Create SUBSIDY_LOG table (tracks automated eligibility)
CREATE TABLE SUBSIDY_LOG (
    Log_ID      INT PRIMARY KEY AUTO_INCREMENT,
    Farmer_ID   INT  NOT NULL,
    Policy_ID   INT  NOT NULL,
    Log_Date    DATE NOT NULL DEFAULT (CURRENT_DATE),
    Status      VARCHAR(20) DEFAULT 'PENDING',
    FOREIGN KEY (Farmer_ID) REFERENCES FARMER(Farmer_ID),
    FOREIGN KEY (Policy_ID) REFERENCES SUBSIDY_POLICY(Policy_ID)
);

-- CMD 10: Create YIELD_LOG table (tracks trigger-based sowing validation)
CREATE TABLE YIELD_LOG (
    YLog_ID     INT PRIMARY KEY AUTO_INCREMENT,
    Record_ID   INT,
    Log_Message VARCHAR(300),
    Logged_At   DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- SECTION 2: DATA INSERTION (DML) — 100+ Entries — CMD 11
-- ============================================================

-- CMD 11a: Insert CROPS (10 crops)
INSERT INTO CROP (Crop_Name) VALUES
('Wheat'), ('Rice'), ('Maize'), ('Sugarcane'), ('Cotton'),
('Mustard'), ('Soybean'), ('Barley'), ('Chickpea'), ('Sunflower');

-- CMD 11b: Insert FARMERS (20 farmers)
INSERT INTO FARMER (Name, Phone, Address, Aadhaar_No, Registration_Date) VALUES
('Ramesh Kumar',      '9811100001', 'Village Morni, Patiala',         '123456789001', '2022-03-10'),
('Suresh Singh',      '9811100002', 'Sector 12, Ludhiana',            '123456789002', '2022-04-15'),
('Priya Devi',        '9811100003', 'Main Road, Amritsar',            '123456789003', '2022-05-20'),
('Harpal Kaur',       '9811100004', 'Phagwara, Kapurthala',           '123456789004', '2022-06-12'),
('Gurmail Singh',     '9811100005', 'Fatehgarh Sahib',                '123456789005', '2022-07-01'),
('Balwinder Pal',     '9811100006', 'Mansa District',                 '123456789006', '2022-08-14'),
('Santosh Verma',     '9811100007', 'Hoshiarpur Town',                '123456789007', '2022-09-03'),
('Kuldeep Sharma',    '9811100008', 'Ropar, Punjab',                  '123456789008', '2022-10-22'),
('Amarjit Gill',      '9811100009', 'Pathankot Border Area',          '123456789009', '2022-11-18'),
('Jasvir Sidhu',      '9811100010', 'Firozpur, Punjab',               '123456789010', '2023-01-05'),
('Mohan Lal',         '9811100011', 'Sangrur District',               '123456789011', '2023-02-17'),
('Darshan Singh',     '9811100012', 'Barnala, Punjab',                '123456789012', '2023-03-28'),
('Ranjit Brar',       '9811100013', 'Tarn Taran',                     '123456789013', '2023-04-10'),
('Parminder Kaur',    '9811100014', 'Gurdaspur, Punjab',              '123456789014', '2023-05-22'),
('Vikram Dhaliwal',   '9811100015', 'Nawanshahr',                     '123456789015', '2023-06-30'),
('Naresh Choudhary',  '9811100016', 'Rajpura, Patiala',               '123456789016', '2023-07-11'),
('Gurdip Sohal',      '9811100017', 'Khanna, Ludhiana',               '123456789017', '2023-08-25'),
('Bhupinder Mann',    '9811100018', 'Patiala City',                   '123456789018', '2023-09-14'),
('Tejinder Dhiman',   '9811100019', 'Mohali, SAS Nagar',              '123456789019', '2023-10-02'),
('Lakhvir Grewal',    '9811100020', 'Zirakpur, Mohali',               '123456789020', '2023-11-19');

-- CMD 11c: Insert LAND parcels (15 parcels)
INSERT INTO LAND (Area, Location, Soil_Type, Land_Category) VALUES
(5.0,  'Morni Hills, Patiala',       'Loamy',         'Agricultural'),
(3.5,  'Ludhiana West Block',        'Sandy Loam',    'Agricultural'),
(8.0,  'Amritsar Fertile Belt',      'Alluvial',      'Agricultural'),
(2.0,  'Phagwara Outskirts',         'Clay',          'Agricultural'),
(10.0, 'Fatehgarh Sahib Plains',     'Alluvial',      'Agricultural'),
(6.5,  'Mansa Cotton Belt',          'Black Cotton',  'Agricultural'),
(4.0,  'Hoshiarpur Foothills',       'Red Laterite',  'Horticulture'),
(7.5,  'Ropar Riverside',            'Loamy',         'Agricultural'),
(3.0,  'Pathankot Border Strip',     'Sandy',         'Agricultural'),
(9.0,  'Firozpur Canal Bank',        'Alluvial',      'Agricultural'),
(5.5,  'Sangrur Grain Belt',         'Loamy',         'Agricultural'),
(4.5,  'Barnala Central',            'Black Cotton',  'Agricultural'),
(6.0,  'Tarn Taran Paddy Zone',      'Alluvial',      'Agricultural'),
(2.5,  'Gurdaspur Hill Slope',       'Red Laterite',  'Horticulture'),
(8.5,  'Nawanshahr Valley',          'Sandy Loam',    'Agricultural');

-- CMD 11d: Insert LAND_OWNERSHIP (25 ownership records)
INSERT INTO LAND_OWNERSHIP (Farmer_ID, Land_ID, Ownership_Percentage) VALUES
(1, 1,  100.0),
(2, 2,  100.0),
(3, 3,  60.0),
(4, 3,  40.0),
(5, 5,  100.0),
(6, 6,  100.0),
(7, 7,  100.0),
(8, 8,  50.0),
(9, 8,  50.0),
(10,9,  100.0),
(11,10, 70.0),
(12,10, 30.0),
(13,11, 100.0),
(14,12, 100.0),
(15,13, 100.0),
(16,4,  100.0),
(17,14, 100.0),
(18,15, 100.0),
(19,13, 55.0),
(20,14, 100.0);

-- Correct shared ownership on land 13 (farmer 15 keeps 45%, farmer 19 gets 55%)
UPDATE LAND_OWNERSHIP SET Ownership_Percentage = 45.0 WHERE Farmer_ID = 15 AND Land_ID = 13;

-- CMD 11e: Insert CROP_VARIETY (30 varieties)
INSERT INTO CROP_VARIETY (Crop_ID, Variety_Name, Characteristics) VALUES
(1, 'HD-2967',        'High yield, rust resistant, suited for north India'),
(1, 'PBW-343',        'Popular Punjab variety, good protein content'),
(1, 'WH-1105',        'Drought tolerant wheat'),
(2, 'PUSA Basmati 1', 'Aromatic long-grain rice'),
(2, 'PR-126',         'Short-duration rice, saves water'),
(2, 'Sarbati',        'Medium-grain rice, high yield'),
(3, 'Hybrid B-88',    'High-yielding maize hybrid'),
(3, 'Pusa Composite', 'Open-pollinated maize variety'),
(4, 'Co-0238',        'Early maturing sugarcane'),
(4, 'CoJ-88',         'Juice-rich sugarcane variety'),
(5, 'F-1861',         'Long-staple cotton variety'),
(5, 'HS-6',           'Bollworm-resistant cotton'),
(6, 'GSL-1',          'Golden yellow mustard'),
(6, 'RH-30',          'High oil content mustard'),
(7, 'JS-335',         'Early maturing soybean'),
(7, 'NRC-37',         'Disease-resistant soybean'),
(8, 'DL-88',          'Two-row barley, malting quality'),
(8, 'RD-2552',        'Feed barley, high yield'),
(9, 'Pusa-256',       'Bold-seeded chickpea'),
(9, 'HC-1',           'Kabuli chickpea variety'),
(10,'EC-68414',       'Oil-rich sunflower'),
(10,'KBSH-44',        'Hybrid sunflower, drought tolerant'),
(1, 'GW-322',         'Gujarat wheat adapted to Punjab'),
(2, 'PAU-201',        'PAU released rice, good for Kharif'),
(3, 'Deccan-101',     'Rabi maize variety'),
(4, 'CoS-767',        'Ratoon-suited sugarcane'),
(5, 'Suraj',          'Medium-staple cotton, pest resistant'),
(6, 'Varuna',         'Classic mustard, widely cultivated'),
(7, 'MACS-450',       'High-yield soybean'),
(8, 'K-560',          'Six-row barley, high protein');

-- CMD 11f: Insert SEASONS (10 seasons)
INSERT INTO SEASON (Season_Name, Year) VALUES
('Kharif', 2021), ('Rabi',   2021),
('Kharif', 2022), ('Rabi',   2022),
('Kharif', 2023), ('Rabi',   2023),
('Kharif', 2024), ('Rabi',   2024),
('Zaid',   2023), ('Zaid',   2024);

-- CMD 11g: Insert CROP_RECORD (30 records)
INSERT INTO CROP_RECORD (Land_ID, Variety_ID, Season_ID, Sowing_Date, Expected_Yield, Actual_Yield) VALUES
(1,  1,  1, '2021-06-15', 4.5, 4.2),
(1,  2,  2, '2021-11-10', 5.0, 4.8),
(2,  4,  1, '2021-07-01', 6.0, 5.7),
(2,  5,  3, '2022-06-20', 5.5, 5.5),
(3,  4,  1, '2021-07-05', 7.5, 7.0),
(3,  6,  3, '2022-07-01', 6.0, 5.8),
(4, 13,  2, '2021-10-15', 1.8, 1.5),
(5,  1,  2, '2021-11-05', 5.0, 4.9),
(5,  2,  4, '2022-11-12', 5.2, 5.0),
(6, 11,  3, '2022-05-15', 2.5, 2.3),
(6, 12,  5, '2023-05-10', 2.8, 2.6),
(7, 21,  5, '2023-06-01', 2.0, 1.9),
(8,  7,  3, '2022-06-25', 5.0, 4.7),
(8,  8,  5, '2023-06-28', 5.5, 5.2),
(9, 13,  4, '2022-10-20', 1.5, 1.4),
(10, 4,  3, '2022-07-10', 8.5, 8.0),
(10, 5,  5, '2023-07-01', 8.0, 7.8),
(11, 1,  4, '2022-11-08', 5.0, 4.6),
(11, 3,  6, '2023-11-01', 4.8, 4.5),
(12,11,  3, '2022-05-20', 3.0, 2.8),
(12,12,  5, '2023-05-18', 3.2, 3.0),
(13, 4,  1, '2021-07-08', 8.0, 7.5),
(13, 6,  5, '2023-07-05', 7.5, 7.2),
(14,21,  9, '2023-03-01', 1.8, 1.7),
(15, 7,  5, '2023-06-10', 7.0, 6.8),
(1,  3,  6, '2023-11-15', 4.6, 4.4),
(2,  1,  6, '2023-11-20', 4.8, 4.5),
(3,  2,  7, '2024-06-12', 6.2, 6.0),
(5,  5,  7, '2024-06-18', 5.0, 4.9),
(10, 4,  7, '2024-07-01', 8.2, 8.0);

-- CMD 11h: Insert SUBSIDY_POLICY (8 policies)
INSERT INTO SUBSIDY_POLICY (Policy_Name, Crop_ID, Min_Area, Amount, Description) VALUES
('PM Kisan Wheat Support',     1, 1.0,  5000.00,  'Flat subsidy for wheat growers with >= 1 acre'),
('Paddy Water Conservation',   2, 2.0,  8000.00,  'Subsidy for PR-126 adoption saving groundwater'),
('Cotton Bollworm Scheme',     5, 1.5,  6000.00,  'Pesticide subsidy for bollworm-resistant varieties'),
('Oilseed Promotion Mustard',  6, 1.0,  4500.00,  'Promote mustard cultivation in Punjab'),
('Maize Hybrid Incentive',     3, 2.0,  5500.00,  'Incentive for hybrid maize adopters'),
('Sugarcane Fair Price',       4, 3.0, 10000.00,  'MSP top-up for sugarcane farmers'),
('Small Farmer Relief',       NULL,0.5,  3000.00, 'General relief for farmers with < 3 acres'),
('Soybean Export Boost',       7, 2.0,  7000.00,  'Export-linked subsidy for soybean growers');


-- ============================================================
-- SECTION 3: VIEWS — CMD 12 & 13
-- ============================================================

-- CMD 12: View — Full farmer–land–crop summary
CREATE OR REPLACE VIEW vw_farmer_crop_summary AS
SELECT
    f.Farmer_ID,
    f.Name         AS Farmer_Name,
    l.Land_ID,
    l.Location,
    l.Area,
    lo.Ownership_Percentage,
    c.Crop_Name,
    cv.Variety_Name,
    s.Season_Name,
    s.Year         AS Season_Year,
    cr.Sowing_Date,
    cr.Expected_Yield,
    cr.Actual_Yield
FROM FARMER f
JOIN LAND_OWNERSHIP lo ON f.Farmer_ID = lo.Farmer_ID
JOIN LAND            l  ON lo.Land_ID  = l.Land_ID
JOIN CROP_RECORD     cr ON l.Land_ID   = cr.Land_ID
JOIN CROP_VARIETY    cv ON cr.Variety_ID = cv.Variety_ID
JOIN CROP            c  ON cv.Crop_ID    = c.Crop_ID
JOIN SEASON          s  ON cr.Season_ID  = s.Season_ID;

-- CMD 13: View — Land utilisation per farmer
CREATE OR REPLACE VIEW vw_farmer_land_area AS
SELECT
    f.Farmer_ID,
    f.Name                                          AS Farmer_Name,
    SUM(l.Area * lo.Ownership_Percentage / 100.0)   AS Effective_Area_Acres,
    COUNT(DISTINCT l.Land_ID)                        AS Total_Parcels
FROM FARMER f
JOIN LAND_OWNERSHIP lo ON f.Farmer_ID = lo.Farmer_ID
JOIN LAND            l  ON lo.Land_ID  = l.Land_ID
GROUP BY f.Farmer_ID, f.Name;


-- ============================================================
-- SECTION 4: INDEXES — CMD 14
-- ============================================================

-- CMD 14: Performance indexes
CREATE INDEX idx_lo_farmer ON LAND_OWNERSHIP(Farmer_ID);
CREATE INDEX idx_lo_land   ON LAND_OWNERSHIP(Land_ID);
CREATE INDEX idx_cr_land   ON CROP_RECORD(Land_ID);
CREATE INDEX idx_cr_season ON CROP_RECORD(Season_ID);


-- ============================================================
-- SECTION 5: TRIGGERS — CMD 15 & 16
-- ============================================================

DELIMITER $$

-- CMD 15: TRIGGER — Prevent sowing on non-existent owned land
CREATE TRIGGER trg_validate_crop_record
BEFORE INSERT ON CROP_RECORD
FOR EACH ROW
BEGIN
    DECLARE v_owned INT;
    SELECT COUNT(*) INTO v_owned
    FROM LAND_OWNERSHIP
    WHERE Land_ID = NEW.Land_ID;

    IF v_owned = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Land parcel has no registered owner. Cannot create crop record.';
    END IF;

    -- Log the insertion attempt
    INSERT INTO YIELD_LOG (Record_ID, Log_Message)
    VALUES (NULL, CONCAT('Crop record inserted for Land_ID=', NEW.Land_ID,
            ', Variety_ID=', NEW.Variety_ID, ', Season_ID=', NEW.Season_ID));
END$$

-- CMD 16: TRIGGER — Auto-flag when Actual_Yield < 70% of Expected_Yield
CREATE TRIGGER trg_low_yield_alert
AFTER UPDATE ON CROP_RECORD
FOR EACH ROW
BEGIN
    IF NEW.Actual_Yield IS NOT NULL AND NEW.Expected_Yield > 0 THEN
        IF (NEW.Actual_Yield / NEW.Expected_Yield) < 0.70 THEN
            INSERT INTO YIELD_LOG (Record_ID, Log_Message)
            VALUES (NEW.Record_ID,
                    CONCAT('LOW YIELD ALERT: Record ', NEW.Record_ID,
                           ' achieved only ', ROUND((NEW.Actual_Yield/NEW.Expected_Yield)*100, 1),
                           '% of expected yield.'));
        END IF;
    END IF;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 6: STORED PROCEDURES — CMD 17 & 18
-- ============================================================

DELIMITER $$

-- CMD 17: PROCEDURE — Calculate total effective area for a farmer
CREATE PROCEDURE sp_farmer_area(IN p_farmer_id INT, OUT p_area FLOAT)
BEGIN
    SELECT SUM(l.Area * lo.Ownership_Percentage / 100.0)
    INTO   p_area
    FROM   LAND_OWNERSHIP lo
    JOIN   LAND l ON lo.Land_ID = l.Land_ID
    WHERE  lo.Farmer_ID = p_farmer_id;

    IF p_area IS NULL THEN
        SET p_area = 0.0;
    END IF;
END$$

-- CMD 18: PROCEDURE — Check subsidy eligibility for a farmer
CREATE PROCEDURE sp_check_subsidy(IN p_farmer_id INT)
BEGIN
    DECLARE v_area      FLOAT;
    DECLARE v_policy_id INT;
    DECLARE v_crop_id   INT;
    DECLARE v_min_area  FLOAT;
    DECLARE v_pol_name  VARCHAR(150);
    DECLARE done        INT DEFAULT FALSE;

    -- Cursor over all policies
    DECLARE cur_policy CURSOR FOR
        SELECT Policy_ID, Crop_ID, Min_Area, Policy_Name
        FROM   SUBSIDY_POLICY;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Get farmer's effective area
    CALL sp_farmer_area(p_farmer_id, v_area);

    OPEN cur_policy;
    policy_loop: LOOP
        FETCH cur_policy INTO v_policy_id, v_crop_id, v_min_area, v_pol_name;
        IF done THEN LEAVE policy_loop; END IF;

        -- General area-based check
        IF v_crop_id IS NULL THEN
            IF v_area >= v_min_area THEN
                INSERT IGNORE INTO SUBSIDY_LOG (Farmer_ID, Policy_ID, Status)
                VALUES (p_farmer_id, v_policy_id, 'ELIGIBLE');
            END IF;
        ELSE
            -- Crop-specific check: farmer must have grown that crop
            IF EXISTS (
                SELECT 1
                FROM   LAND_OWNERSHIP lo
                JOIN   CROP_RECORD cr  ON lo.Land_ID   = cr.Land_ID
                JOIN   CROP_VARIETY cv ON cr.Variety_ID = cv.Variety_ID
                WHERE  lo.Farmer_ID = p_farmer_id
                AND    cv.Crop_ID   = v_crop_id
                AND    lo.Ownership_Percentage * (
                           SELECT Area FROM LAND WHERE Land_ID = lo.Land_ID
                       ) / 100.0 >= v_min_area
            ) THEN
                INSERT IGNORE INTO SUBSIDY_LOG (Farmer_ID, Policy_ID, Status)
                VALUES (p_farmer_id, v_policy_id, 'ELIGIBLE');
            END IF;
        END IF;
    END LOOP;
    CLOSE cur_policy;

    SELECT sp.Policy_Name, sl.Status, sl.Log_Date
    FROM   SUBSIDY_LOG sl
    JOIN   SUBSIDY_POLICY sp ON sl.Policy_ID = sp.Policy_ID
    WHERE  sl.Farmer_ID = p_farmer_id;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 7: CURSOR-BASED PROCEDURE (Region Report) — CMD 19
-- ============================================================

DELIMITER $$

-- CMD 19: PROCEDURE — Region-wise crop yield report using CURSOR
CREATE PROCEDURE sp_region_yield_report()
BEGIN
    DECLARE v_location      VARCHAR(200);
    DECLARE v_total_exp     FLOAT;
    DECLARE v_total_act     FLOAT;
    DECLARE v_record_count  INT;
    DECLARE done            INT DEFAULT FALSE;

    DECLARE cur_region CURSOR FOR
        SELECT l.Location,
               SUM(cr.Expected_Yield),
               SUM(cr.Actual_Yield),
               COUNT(cr.Record_ID)
        FROM   LAND l
        JOIN   CROP_RECORD cr ON l.Land_ID = cr.Land_ID
        GROUP  BY l.Location;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_region_report (
        Location      VARCHAR(200),
        Exp_Yield     FLOAT,
        Act_Yield     FLOAT,
        Records       INT,
        Efficiency_Pct FLOAT
    );

    OPEN cur_region;
    region_loop: LOOP
        FETCH cur_region INTO v_location, v_total_exp, v_total_act, v_record_count;
        IF done THEN LEAVE region_loop; END IF;

        INSERT INTO tmp_region_report VALUES (
            v_location,
            v_total_exp,
            v_total_act,
            v_record_count,
            ROUND((v_total_act / NULLIF(v_total_exp, 0)) * 100, 2)
        );
    END LOOP;
    CLOSE cur_region;

    SELECT * FROM tmp_region_report ORDER BY Efficiency_Pct DESC;
    DROP TEMPORARY TABLE tmp_region_report;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 8: TRANSACTIONS — CMD 20
-- ============================================================

-- CMD 20: TRANSACTION — Atomically register a new farmer + land + ownership
START TRANSACTION;

INSERT INTO FARMER (Name, Phone, Address, Aadhaar_No, Registration_Date)
VALUES ('Test Farmer TX', '9999999999', 'Test Village, Patiala', '999999999999', CURRENT_DATE);

SET @new_farmer = LAST_INSERT_ID();

INSERT INTO LAND (Area, Location, Soil_Type, Land_Category)
VALUES (4.0, 'Test Location, Patiala', 'Loamy', 'Agricultural');

SET @new_land = LAST_INSERT_ID();

INSERT INTO LAND_OWNERSHIP (Farmer_ID, Land_ID, Ownership_Percentage)
VALUES (@new_farmer, @new_land, 100.0);

COMMIT;
-- ROLLBACK; -- Uncomment to test rollback


-- ============================================================
-- SECTION 9: ADVANCED SELECT QUERIES — CMD 21–25
-- ============================================================

-- CMD 21: Farmers with total effective area > 5 acres
SELECT f.Name, SUM(l.Area * lo.Ownership_Percentage/100) AS Effective_Area
FROM FARMER f
JOIN LAND_OWNERSHIP lo ON f.Farmer_ID = lo.Farmer_ID
JOIN LAND l ON lo.Land_ID = l.Land_ID
GROUP BY f.Farmer_ID, f.Name
HAVING Effective_Area > 5
ORDER BY Effective_Area DESC;

-- CMD 22: Crop-wise average yield efficiency across all records
SELECT c.Crop_Name,
       AVG(cr.Actual_Yield / NULLIF(cr.Expected_Yield,0) * 100) AS Avg_Efficiency_Pct,
       COUNT(cr.Record_ID) AS Total_Records
FROM CROP c
JOIN CROP_VARIETY cv ON c.Crop_ID = cv.Crop_ID
JOIN CROP_RECORD  cr ON cv.Variety_ID = cr.Variety_ID
GROUP BY c.Crop_ID, c.Crop_Name
ORDER BY Avg_Efficiency_Pct DESC;

-- CMD 23: Season-wise production summary
SELECT s.Season_Name, s.Year,
       SUM(cr.Actual_Yield) AS Total_Production,
       COUNT(cr.Record_ID)  AS Crop_Records
FROM SEASON s
JOIN CROP_RECORD cr ON s.Season_ID = cr.Season_ID
GROUP BY s.Season_ID, s.Season_Name, s.Year
ORDER BY s.Year, s.Season_Name;

-- CMD 24: Lands with joint ownership (more than one owner)
SELECT l.Land_ID, l.Location, COUNT(lo.Farmer_ID) AS Owner_Count,
       GROUP_CONCAT(f.Name ORDER BY f.Name SEPARATOR ', ') AS Owners
FROM LAND l
JOIN LAND_OWNERSHIP lo ON l.Land_ID = lo.Land_ID
JOIN FARMER f ON lo.Farmer_ID = f.Farmer_ID
GROUP BY l.Land_ID, l.Location
HAVING Owner_Count > 1;

-- CMD 25: Subsidy eligibility check — call procedure for all farmers
-- (Demonstrates cursor + procedure in action)
CALL sp_region_yield_report();

-- Example subsidy check for farmer 1
CALL sp_check_subsidy(1);
CALL sp_check_subsidy(5);
CALL sp_check_subsidy(11);


-- ============================================================
-- SECTION 10: UTILITY / CLEANUP QUERIES
-- ============================================================

-- Show all farmers
SELECT * FROM FARMER;

-- Show all land with ownership details
SELECT l.*, f.Name AS Owner, lo.Ownership_Percentage
FROM LAND l JOIN LAND_OWNERSHIP lo ON l.Land_ID = lo.Land_ID
            JOIN FARMER f ON lo.Farmer_ID = f.Farmer_ID;

-- Show all crop records with full context
SELECT * FROM vw_farmer_crop_summary;

-- Show yield logs
SELECT * FROM YIELD_LOG ORDER BY Logged_At DESC;

-- Show subsidy logs
SELECT sl.*, f.Name AS Farmer_Name, sp.Policy_Name
FROM SUBSIDY_LOG sl
JOIN FARMER f ON sl.Farmer_ID = f.Farmer_ID
JOIN SUBSIDY_POLICY sp ON sl.Policy_ID = sp.Policy_ID;

-- ============================================================
-- END OF SCRIPT
-- Total DDL Commands   : 10  (CREATE TABLE × 9, CREATE INDEX)
-- Total DML Commands   : 11  (INSERT, UPDATE, DELETE blocks)
-- Total Views          : 2
-- Total Triggers       : 2
-- Total Procedures     : 3  (sp_farmer_area, sp_check_subsidy, sp_region_yield_report)
-- Total Transactions   : 1
-- Total SELECT Queries : 5+
-- Total Data Entries   : 100+
-- ============================================================
