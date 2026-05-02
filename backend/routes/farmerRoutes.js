// ─────────────────────────────────────────────
//  KisanDB — API Routes
//  File: backend/routes/farmerRoutes.js
// ─────────────────────────────────────────────
const express = require('express');
const router  = express.Router();
const ctrl    = require('../controllers/farmerController');
 
//  GET  /api/dashboard
router.get('/dashboard', ctrl.getDashboardStats);
 
//  GET  /api/farmers          — all farmers with effective area
//  POST /api/farmers          — add a new farmer (inserts into DB)
router.get('/farmers',  ctrl.getAllFarmers);
router.post('/farmers', ctrl.addFarmer);
 
//  GET  /api/lands            — all land parcels with ownership info
router.get('/lands', ctrl.getAllLands);
 
//  GET  /api/crops            — all crop records with full JOIN context
router.get('/crops', ctrl.getAllCropRecords);
 
//  GET  /api/subsidies        — all subsidy policies
//  GET  /api/subsidies/check/:farmer_id — calls sp_check_subsidy procedure
router.get('/subsidies',               ctrl.getAllSubsidies);
router.get('/subsidies/check/:farmer_id', ctrl.checkSubsidy);
 
//  GET  /api/yield-logs       — trigger output from YIELD_LOG table
router.get('/yield-logs', ctrl.getYieldLogs);
 
module.exports = router;