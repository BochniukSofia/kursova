const sql = require('mssql');

const dbConfig = {
  user: 'sa',
  password: 'Setera2025!',     // той самий пароль, що в SSMS
  server: 'localhost',
  port: 1433,
  database: 'SeteraExpress',
  options: {
    trustServerCertificate: true,
    encrypt: false
  }
};

async function test() {
  try {
    console.log('Connecting to DB...');
    const pool = await sql.connect(dbConfig);
    console.log('Connected!');

    const result = await pool.request().query('SELECT TOP 5 * FROM dbo.Trip;');
    console.log('Trips:', result.recordset);

    await sql.close();
  } catch (err) {
    console.error('DB TEST ERROR:', err);
  }
}

test();
