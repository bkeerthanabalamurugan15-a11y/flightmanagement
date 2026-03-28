CREATE DATABASE airline_db;

USE airline_db;

CREATE TABLE passengers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    class VARCHAR(20) NOT NULL, -- 'First', 'Business', 'Economy'
    ticket_rate DECIMAL(10,2) NOT NULL,
    flight_name VARCHAR(100) NOT NULL,
    aadhaar_no VARCHAR(12) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'BOOKED', -- 'BOOKED' or 'CANCELLED'
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255)
);
INSERT INTO admins (username, password)
VALUES ('', '');
USE airline_db;

ALTER TABLE passengers
ADD COLUMN pnr VARCHAR(10) UNIQUE AFTER id,
ADD COLUMN seat_no VARCHAR(5) AFTER pnr;