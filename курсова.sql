DROP DATABASE IF EXISTS SeteraExpress;
CREATE DATABASE SeteraExpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE SeteraExpress;

-- 1. Таблиця Користувачів (Users)
CREATE TABLE User (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) UNIQUE,
    Role ENUM('Client', 'Admin') DEFAULT 'Client',
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблиця Перевізників (Carrier)
CREATE TABLE Carrier (
    CarrierID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    ContactPhone VARCHAR(30) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    LegalAddress TEXT,
    Rating DECIMAL(3, 2) DEFAULT 0.00,
    JoinedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Таблиця Станцій/Міст (Station)
CREATE TABLE Station (
    StationID INT AUTO_INCREMENT PRIMARY KEY,
    City VARCHAR(100) NOT NULL,
    StationName VARCHAR(150) NOT NULL,
    Address VARCHAR(255),
    Latitude DECIMAL(10, 8),
    Longitude DECIMAL(11, 8)
);

-- 4. Таблиця Автобусів (Bus)
CREATE TABLE Bus (
    BusID INT AUTO_INCREMENT PRIMARY KEY,
    CarrierID INT NOT NULL,
    Model VARCHAR(100) NOT NULL,
    LicensePlate VARCHAR(20) UNIQUE NOT NULL,
    ManufactureYear YEAR,
    TotalSeats INT NOT NULL,
    Amenities TEXT, 
    Status ENUM('Active', 'In Maintenance', 'Retired') DEFAULT 'Active',
    FOREIGN KEY (CarrierID) REFERENCES Carrier(CarrierID) ON DELETE RESTRICT
);

-- 5. Таблиця Місць в автобусі (Seat)
CREATE TABLE Seat (
    SeatID INT AUTO_INCREMENT PRIMARY KEY,
    BusID INT NOT NULL,
    SeatNumber VARCHAR(10) NOT NULL, 
    -- Додав 'Standard' у перелік ENUM, щоб DEFAULT 'Standard' спрацював
    Position ENUM('Window', 'Aisle', 'Middle', 'BackRow', 'Standard') DEFAULT 'Standard',
    FloorLevel TINYINT DEFAULT 1, 
    IsAvailable BOOLEAN DEFAULT TRUE, 
    FOREIGN KEY (BusID) REFERENCES Bus(BusID) ON DELETE CASCADE,
    UNIQUE (BusID, SeatNumber) 
);
-- 6. Таблиця Маршрутів (Route)
CREATE TABLE Route (
    RouteID INT AUTO_INCREMENT PRIMARY KEY,
    DepartureStationID INT NOT NULL,
    ArrivalStationID INT NOT NULL,
    DistanceKm DECIMAL(6, 2),
    EstimatedDuration TIME,
    FOREIGN KEY (DepartureStationID) REFERENCES Station(StationID),
    FOREIGN KEY (ArrivalStationID) REFERENCES Station(StationID)
);

-- 7. Таблиця Конкретних Рейсів (Trip)
CREATE TABLE Trip (
    TripID INT AUTO_INCREMENT PRIMARY KEY,
    RouteID INT NOT NULL,
    BusID INT NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    BasePrice DECIMAL(10, 2) NOT NULL,
    Status ENUM('Scheduled', 'Boarding', 'In Transit', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE RESTRICT,
    FOREIGN KEY (BusID) REFERENCES Bus(BusID) ON DELETE RESTRICT
);

-- 8. Таблиця Бронювань (Booking) 
-- Це загальний кошик/чек користувача, який може вміщувати багато місць
CREATE TABLE Booking (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    TotalPrice DECIMAL(10, 2) NOT NULL,
    BookingTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Pending', 'Confirmed', 'Cancelled', 'Refunded') DEFAULT 'Pending',
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

-- 9. Таблиця Квитків / Заброньованих місць (Ticket)
-- Кожен квиток прив'язаний до загального BookingID (дозволяє купити місця для себе та дівчини в одному замовленні)
CREATE TABLE Ticket (
    TicketID INT AUTO_INCREMENT PRIMARY KEY,
    BookingID INT NOT NULL,
    TripID INT NOT NULL,
    SeatID INT NOT NULL,
    PassengerFirstName VARCHAR(50) NOT NULL,
    PassengerLastName VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL, 
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (TripID) REFERENCES Trip(TripID) ON DELETE CASCADE,
    FOREIGN KEY (SeatID) REFERENCES Seat(SeatID) ON DELETE RESTRICT,
    
    -- Захист від подвійного бронювання: одне місце на один рейс можна забронювати лише один раз
    UNIQUE (TripID, SeatID) 
);
