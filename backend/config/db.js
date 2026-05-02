// ─────────────────────────────────────────────
//  KisanDB — MySQL Connection Pool
//  File: backend/config/db.js
// ─────────────────────────────────────────────
require('dotenv').config();
const mysql = require('mysql2');
 
const pool = mysql.createPool({

 host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
 
// Test connection on startup
pool.getConnection((err, conn) => {
  if (err) {
    console.error('✘  MySQL connection failed:', err.message);
    console.error('   Check: is MySQL running? Is the password correct in db.js?');
  } else {
    console.log('✔  MySQL connected → kisandb database');
    conn.release();
  }
});
 
module.exports = pool.promise();