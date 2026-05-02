// ─────────────────────────────────────────────
//  KisanDB — Farmer Controller
//  File: backend/controllers/farmerController.js
// ─────────────────────────────────────────────
const db = require('../config/db');
 
// ── GET /api/farmers ─────────────────────────
exports.getAllFarmers = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT f.*,
        ROUND(COALESCE(SUM(l.Area * lo.Ownership_Percentage / 100), 0), 2) AS Effective_Area
      FROM FARMER f
      LEFT JOIN LAND_OWNERSHIP lo ON f.Farmer_ID = lo.Farmer_ID
      LEFT JOIN LAND l            ON lo.Land_ID   = l.Land_ID
      GROUP BY f.Farmer_ID
      ORDER BY f.Farmer_ID
    `);
    res.json(rows);
  } catch (err) {
    console.error('getAllFarmers:', err.message);
    res.status(500).json({ error: err.message });
  }
};
 
// ── POST /api/farmers ────────────────────────
exports.addFarmer = async (req, res) => {
  try {
    const { Name, Phone, Address, Aadhaar_No, Registration_Date } = req.body;
    if (!Name || !Phone || !Aadhaar_No)
      return res.status(400).json({ error: 'Name, Phone, and Aadhaar_No are required.' });
 
    const [result] = await db.query(
      `INSERT INTO FARMER (Name, Phone, Address, Aadhaar_No, Registration_Date)
       VALUES (?, ?, ?, ?, ?)`,
      [Name, Phone, Address || null, Aadhaar_No, Registration_Date || new Date()]
    );
    res.json({
      success   : true,
      Farmer_ID : result.insertId,
      message   : `Farmer "${Name}" added successfully with ID ${result.insertId}`
    });
  } catch (err) {
    console.error('addFarmer:', err.message);
    // Friendly duplicate error
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Phone or Aadhaar already registered.' });
    }
    res.status(500).json({ error: err.message });
  }
};
 
// ── GET /api/lands ───────────────────────────
exports.getAllLands = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT l.*,
        COUNT(lo.Farmer_ID)                                                  AS Owner_Count,
        GROUP_CONCAT(f.Name ORDER BY f.Name SEPARATOR ', ')                  AS Owners,
        IF(COUNT(lo.Farmer_ID) > 1, 'Yes', 'No')                            AS Is_Joint
      FROM LAND l
      LEFT JOIN LAND_OWNERSHIP lo ON l.Land_ID   = lo.Land_ID
      LEFT JOIN FARMER f          ON lo.Farmer_ID = f.Farmer_ID
      GROUP BY l.Land_ID
      ORDER BY l.Land_ID
    `);
    res.json(rows);
  } catch (err) {
    console.error('getAllLands:', err.message);
    res.status(500).json({ error: err.message });
  }
};
 
// ── GET /api/crops ───────────────────────────
exports.getAllCropRecords = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        cr.Record_ID,
        l.Location,
        c.Crop_Name,
        cv.Variety_Name,
        CONCAT(s.Season_Name, ' ', s.Year)                            AS Season,
        cr.Sowing_Date,
        cr.Expected_Yield,
        cr.Actual_Yield,
        ROUND(cr.Actual_Yield / NULLIF(cr.Expected_Yield, 0) * 100, 1) AS Efficiency_Pct
      FROM CROP_RECORD  cr
      JOIN LAND         l  ON cr.Land_ID    = l.Land_ID
      JOIN CROP_VARIETY cv ON cr.Variety_ID = cv.Variety_ID
      JOIN CROP         c  ON cv.Crop_ID    = c.Crop_ID
      JOIN SEASON       s  ON cr.Season_ID  = s.Season_ID
      ORDER BY cr.Record_ID
    `);
    res.json(rows);
  } catch (err) {
    console.error('getAllCropRecords:', err.message);
    res.status(500).json({ error: err.message });
  }
};
 
// ── GET /api/subsidies ───────────────────────
exports.getAllSubsidies = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT sp.*, c.Crop_Name
      FROM SUBSIDY_POLICY sp
      LEFT JOIN CROP c ON sp.Crop_ID = c.Crop_ID
      ORDER BY sp.Policy_ID
    `);
    res.json(rows);
  } catch (err) {
    console.error('getAllSubsidies:', err.message);
    res.status(500).json({ error: err.message });
  }
};
 
// ── GET /api/dashboard ───────────────────────
exports.getDashboardStats = async (req, res) => {
  try {
    const [[fc]]  = await db.query('SELECT COUNT(*) AS cnt FROM FARMER');
    const [[lc]]  = await db.query('SELECT COUNT(*) AS cnt FROM LAND');
    const [[cc]]  = await db.query('SELECT COUNT(*) AS cnt FROM CROP_RECORD');
    const [[sc]]  = await db.query('SELECT COUNT(*) AS cnt FROM SUBSIDY_POLICY');
 
    const [yieldByC] = await db.query(`
      SELECT c.Crop_Name,
        ROUND(AVG(cr.Actual_Yield / NULLIF(cr.Expected_Yield,0) * 100), 1) AS Avg_Efficiency
      FROM CROP_RECORD  cr
      JOIN CROP_VARIETY cv ON cr.Variety_ID = cv.Variety_ID
      JOIN CROP         c  ON cv.Crop_ID    = c.Crop_ID
      GROUP BY c.Crop_ID, c.Crop_Name
      ORDER BY c.Crop_ID
    `);
 
    const [seasonProd] = await db.query(`
      SELECT CONCAT(s.Season_Name, ' ', s.Year) AS Season_Label,
        ROUND(SUM(cr.Actual_Yield), 1)           AS Total_Production
      FROM SEASON s
      JOIN CROP_RECORD cr ON s.Season_ID = cr.Season_ID
      GROUP BY s.Season_ID, s.Season_Name, s.Year
      ORDER BY s.Year, s.Season_Name
    `);
 
    const [soilDist] = await db.query(`
      SELECT Soil_Type, COUNT(*) AS Count
      FROM LAND
      GROUP BY Soil_Type
      ORDER BY Count DESC
    `);
 
    const [regionYield] = await db.query(`
      SELECT l.Location,
        ROUND(SUM(cr.Actual_Yield) / NULLIF(SUM(cr.Expected_Yield),0) * 100, 1) AS Efficiency
      FROM LAND l
      JOIN CROP_RECORD cr ON l.Land_ID = cr.Land_ID
      GROUP BY l.Land_ID, l.Location
      ORDER BY Efficiency DESC
      LIMIT 5
    `);
 
    res.json({
      counts: { farmers: fc.cnt, lands: lc.cnt, cropRecords: cc.cnt, subsidies: sc.cnt },
      yieldByC,
      seasonProd,
      soilDist,
      regionYield,
    });
  } catch (err) {
    console.error('getDashboardStats:', err.message);
    res.status(500).json({ error: err.message });
  }
};
 
// ── GET /api/subsidies/check/:farmer_id ──────
// Calls the stored procedure sp_check_subsidy
exports.checkSubsidy = async (req, res) => {
  try {
    const fid = parseInt(req.params.farmer_id);
    if (isNaN(fid)) return res.status(400).json({ error: 'Invalid farmer_id' });
 
    await db.query('CALL sp_check_subsidy(?)', [fid]);
 
    const [logs] = await db.query(`
      SELECT sl.*, sp.Policy_Name, sp.Amount
      FROM SUBSIDY_LOG sl
      JOIN SUBSIDY_POLICY sp ON sl.Policy_ID = sp.Policy_ID
      WHERE sl.Farmer_ID = ?
      ORDER BY sl.Log_Date DESC
    `, [fid]);
 
    res.json(logs);
  } catch (err) {
    console.error('checkSubsidy:', err.message);
    res.status(500).json({ error: err.message });
  }
};
 
// ── GET /api/yield-logs ──────────────────────
// Returns YIELD_LOG rows written by triggers
exports.getYieldLogs = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM YIELD_LOG ORDER BY Logged_At DESC LIMIT 20'
    );
    res.json(rows);
  } catch (err) {
    console.error('getYieldLogs:', err.message);
    res.status(500).json({ error: err.message });
  }
};