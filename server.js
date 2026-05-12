// server.js
const express = require('express');
const mysql = require('mysql2');
const path = require('path');

const app = express();
const PORT = 3000;

const pool = mysql.createPool({
  host: '192.168.211.128',
  port: 3306,
  user: 'dbuser',
  password: 'password123',
  database: 'SeteraExpress',
  waitForConnections: true,
}).promise();

app.use(express.json());
app.use(express.static(__dirname));

// GET всі рейси
app.get('/api/trips', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        t.TripID,
        b.Model,
        t.DepartureStationID,
        t.ArrivalStationID,
        t.DepartureTime,
        t.ArrivalTime
      FROM Trip t
      JOIN Bus b ON t.BusID = b.BusID
      ORDER BY t.DepartureTime
    `);
    res.json(rows);
  } catch (err) {
    console.error('TRIPS ERROR:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET місця для рейсу
app.get('/api/trips/:tripId/seats', async (req, res) => {
  const { tripId } = req.params;
  try {
    const [rows] = await pool.query(`
      SELECT
        s.SeatID,
        s.SeatNumber,
        CASE WHEN EXISTS (
          SELECT 1 FROM Booking bk
          WHERE bk.TripID = ?
          AND bk.SeatID = s.SeatID
          AND bk.Status = 'active'
        ) THEN 1 ELSE 0 END AS IsBooked
      FROM Trip t
      JOIN Bus b ON t.BusID = b.BusID
      JOIN Seat s ON s.BusID = b.BusID
      WHERE t.TripID = ?
      ORDER BY s.SeatNumber
    `, [tripId, tripId]);
    res.json(rows);
  } catch (err) {
    console.error('SEATS ERROR:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST бронювання
app.post('/api/bookings', async (req, res) => {
  const { tripId, seatId } = req.body;
  const userId = 1;
  try {
    const [check] = await pool.query(`
      SELECT * FROM Booking
      WHERE TripID = ? AND SeatID = ? AND Status = 'active'
    `, [tripId, seatId]);

    if (check.length > 0) {
      return res.status(400).json({ error: 'Місце вже заброньовано' });
    }

    await pool.query(`
      INSERT INTO Booking (UserID, TripID, SeatID, Status)
      VALUES (?, ?, ?, 'active')
    `, [userId, tripId, seatId]);

    res.json({ success: true });
  } catch (err) {
    console.error('BOOKING ERROR:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

app.listen(PORT, () => {
  console.log(`Сервер запущено: http://localhost:${PORT}`);
});