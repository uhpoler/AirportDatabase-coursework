USE airport;

DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS passenger_check;
DROP TABLE IF EXISTS passenger;
DROP TABLE IF EXISTS plane;
DROP TABLE IF EXISTS route;
DROP TABLE IF EXISTS baggage;
DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS characteristic;
DROP TABLE IF EXISTS employee;


CREATE TABLE employee(
	employeeID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50) NOT NULL,
    emp_lastname VARCHAR(50) NOT NULL,
    emp_surname VARCHAR(50) NOT NULL,
    date_of_birth DATE
);


CREATE TABLE characteristic (
    characteristicID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    brand VARCHAR(30),
    date_last_tech_insp DATE NOT NULL,
    producing_country VARCHAR(30) 
);


CREATE TABLE schedule (
    scheduleID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    schedule_date DATE NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL
);

CREATE TABLE city (
    cityID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(50) NOT NULL,
    country VARCHAR(50)
);

CREATE TABLE baggage (
    baggageID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    weight INT NOT NULL,
    type VARCHAR(50),
    registration_date DATE
);

CREATE TABLE route (
    routeID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    scheduleID INT NOT NULL,
    starting_pointID INT NOT NULL,
    end_pointID INT NOT NULL,
    duration INT,
    FOREIGN KEY (scheduleID) REFERENCES schedule(scheduleID),
    FOREIGN KEY (starting_pointID) REFERENCES city(cityID),
    FOREIGN KEY (end_pointID) REFERENCES city(cityID),
    CHECK (duration > 0)
);

CREATE TABLE plane (
    planeID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    carrying_capacity INT NOT NULL,
    max_number_of_passengers INT NOT NULL,
    characteristicID INT NOT NULL,
    routeID INT NOT NULL,
    FOREIGN KEY (characteristicID) REFERENCES characteristic(characteristicID),
    FOREIGN KEY (routeID) REFERENCES route(routeID),
	CHECK (max_number_of_passengers > 1),
    CHECK (carrying_capacity > 0)
);

CREATE TABLE passenger (
    passengerID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    baggageID INT NOT NULL,
    pas_name VARCHAR(50) NOT NULL,
    pas_lastname VARCHAR(50) NOT NULL,
    pas_surname VARCHAR(50) NOT NULL,
    passport_number INT(9) NOT NULL,
    date_of_birth DATE,
    citizenship VARCHAR(50),
    FOREIGN KEY (baggageID) REFERENCES baggage(baggageID)
);


CREATE TABLE passenger_check (
    passenger_checkID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    passengerID INT NOT NULL,
    baggageID INT NOT NULL,
    employeeID INT NOT NULL,
    check_result BOOLEAN NOT NULL,
    FOREIGN KEY (passengerID) REFERENCES passenger(passengerID),
    FOREIGN KEY (baggageID) REFERENCES baggage(baggageID),
    FOREIGN KEY (employeeID) REFERENCES employee(employeeID)
);

CREATE TABLE booking (
    bookingID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    passengerID INT NOT NULL,
    baggageID INT NOT NULL,
    routeID INT NOT NULL,
    booking_date DATE,
    booking_time TIME,
    FOREIGN KEY (passengerID) REFERENCES passenger(passengerID),
    FOREIGN KEY (baggageID) REFERENCES baggage(baggageID),
    FOREIGN KEY (routeID) REFERENCES route(routeID)
);


ALTER TABLE booking
ADD UNIQUE (passengerID);

ALTER TABLE booking
ADD UNIQUE (baggageID);

ALTER TABLE passenger
ADD UNIQUE (baggageID);

ALTER TABLE passenger_check
ADD UNIQUE (baggageID);


ALTER TABLE passenger_check
ADD UNIQUE (passengerID);


ALTER TABLE plane
ADD UNIQUE (characteristicID);