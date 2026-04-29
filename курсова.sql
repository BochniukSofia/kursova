DROP DATABASE IF EXISTS SeteraExpress;
CREATE DATABASE SeteraExpress;
USE SeteraExpress;

-- 2. Таблиця Автобусів (Fleet)
--  Вся інформація про транспорт і того, хто його надає, тут.
CREATE TABLE Bus (
    BusID INT AUTO_INCREMENT PRIMARY KEY,
    Model VARCHAR(100) NOT NULL,
    LicensePlate VARCHAR(20) UNIQUE NOT NULL,
    TotalSeats INT NOT NULL, -- Загальна кількість місць в автобусі
    CarrierName VARCHAR(150) NOT NULL, -- Назва перевізника
    CarrierPhone VARCHAR(30)
);

-- 3. Таблиця Користувачів
CREATE TABLE User (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Phone VARCHAR(30),
    Role ENUM('Client', 'Admin') DEFAULT 'Client'
);

-- 4. Таблиця Маршрутів
CREATE TABLE Route (
    RouteID INT AUTO_INCREMENT PRIMARY KEY,
    DepartureCity VARCHAR(100) NOT NULL,
    ArrivalCity VARCHAR(100) NOT NULL,
    EstimatedDuration TIME
);

-- 5. Таблиця Рейсів (Trip)
-- Тут ми додали поле AvailableSeats, щоб миттєво показувати кількість вільних місць.
CREATE TABLE Trip (
    TripID INT AUTO_INCREMENT PRIMARY KEY,
    RouteID INT NOT NULL,
    BusID INT NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    BasePrice DECIMAL(10, 2) NOT NULL,
    -- Поточна кількість вільних місць (оновлюється при бронюванні)
    AvailableSeats INT NOT NULL, 
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE,
    FOREIGN KEY (BusID) REFERENCES Bus(BusID) ON DELETE CASCADE
);

-- 6. Таблиця Бронювань (Booking)
-- Оскільки ми видалили таблицю Seat, ми просто вказуємо номер місця (SeatNumber) тут.
CREATE TABLE Booking (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    TripID INT NOT NULL,
    UserID INT NOT NULL,
    SeatNumber INT NOT NULL, -- Людина просто обирає число від 1 до TotalSeats
    BookingTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (TripID) REFERENCES Trip(TripID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);