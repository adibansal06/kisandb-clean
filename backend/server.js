const express = require('express');
const cors    = require('cors');
const path    = require('path');
 
const app = express();
app.use(cors());
app.use(express.json());
 
// Serve the frontend HTML as a static file
app.use('/frontend', express.static(path.join(__dirname, '../frontend')));
 
// API routes
const farmerRoutes = require('./routes/farmerRoutes');
app.use('/api', farmerRoutes);
 
// Root health check
app.get('/', (req, res) => res.json({ status: 'KisanDB API running ✔', port: PORT }));
 
const PORT = 5000;
app.listen(PORT, () => {
  console.log(`\n✔  KisanDB backend running at http://localhost:${PORT}`);
  console.log(`   Farmers API : http://localhost:${PORT}/api/farmers`);
  console.log(`   Dashboard   : open frontend/farmer_dashboard.html in browser\n`);
});