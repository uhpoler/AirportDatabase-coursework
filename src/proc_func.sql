
-- деталі маршруту
DROP PROCEDURE IF EXISTS GetRouteDetailsWithCityInfo;
DELIMITER //
CREATE PROCEDURE GetRouteDetailsWithCityInfo()
BEGIN
    SELECT r.routeID, r.duration, cs.city_name AS starting_city, ce.city_name AS ending_city
    FROM route r
    INNER JOIN city cs ON r.starting_pointID = cs.cityID
    INNER JOIN city ce ON r.end_pointID = ce.cityID;
END //
DELIMITER ;
CALL GetRouteDetailsWithCityInfo();




-- інформація про багаж та рейс на якому він зареєстрований
DROP PROCEDURE IF EXISTS GetBaggageDetailsWithRoute;
DELIMITER //
CREATE PROCEDURE GetBaggageDetailsWithRoute()
BEGIN
    SELECT b.baggageID, b.weight, b.type, b.registration_date, r.routeID, r.duration
    FROM baggage b
    INNER JOIN booking bo ON b.baggageID = bo.baggageID
    INNER JOIN route r ON bo.routeID = r.routeID;
END //
DELIMITER ;
CALL GetBaggageDetailsWithRoute();


-- отримання  працівника, що має найбільше перевірених пасажирів
DROP FUNCTION IF EXISTS GetEmployeeWithMostPassengers;
DELIMITER //
CREATE FUNCTION GetEmployeeWithMostPassengers()
RETURNS VARCHAR(255)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result VARCHAR(255);
    DECLARE employee_name VARCHAR(255);
    DECLARE passenger_count INT;
    SELECT CONCAT(emp_name, ' ', emp_lastname) INTO employee_name
    FROM employee
    WHERE employeeID = (
        SELECT employeeID
        FROM passenger_check
        GROUP BY employeeID
        ORDER BY COUNT(DISTINCT passengerID) DESC
        LIMIT 1
    );
    SELECT COUNT(DISTINCT passengerID) INTO passenger_count
    FROM passenger_check
    WHERE employeeID = (SELECT employeeID FROM employee WHERE CONCAT(emp_name, ' ', emp_lastname) = employee_name);
    SET result = CONCAT(employee_name, ' (', passenger_count, ' passengers)');
    RETURN result;
END //
DELIMITER ;
SELECT  GetEmployeeWithMostPassengers();





-- отримання кількості пасажирів, які здійснили бронювання на певний рейс
DROP FUNCTION IF EXISTS GetPassengerCountForRoute;
DELIMITER //
CREATE FUNCTION `GetPassengerCountForRoute`(route_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE passenger_count INT;
    SELECT COUNT(DISTINCT passengerID) INTO passenger_count
    FROM booking
    WHERE routeID = route_id;
    RETURN passenger_count;
END //
DELIMITER ;
SELECT GetPassengerCountForRoute(26) AS passenger_count;



-- отримання загальної ваги багажу для певного рейсу
DROP FUNCTION IF EXISTS GetTotalBaggageWeightForRoute;
DELIMITER //
CREATE FUNCTION `GetTotalBaggageWeightForRoute`(route_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_weight INT;
    SELECT SUM(b.weight) INTO total_weight
    FROM baggage b
    JOIN booking bk ON b.baggageID = bk.baggageID
    WHERE bk.routeID = route_id;
    RETURN total_weight;
END //
DELIMITER ;
SELECT GetTotalBaggageWeightForRoute(2) AS total_weight;



-- отримання кількості рейсів, які відправляються з певного міста
DROP FUNCTION IF EXISTS GetFlightCountFromCity;
DELIMITER //
CREATE FUNCTION `GetFlightCountFromCity`(city_name VARCHAR(50))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE flight_count INT;
    SELECT COUNT(*) INTO flight_count
    FROM route r
    JOIN city c ON r.starting_pointID = c.cityID
    WHERE c.city_name = city_name;
    RETURN flight_count;
END //
DELIMITER ;
SELECT GetFlightCountFromCity('Mirandamouth') AS flight_count;



-- отримання кількості багажу, який було зареєстровано після певної дати
DROP FUNCTION IF EXISTS GetBaggageCountAfterDate;
DELIMITER //
CREATE FUNCTION `GetBaggageCountAfterDate`(date DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE baggage_count INT;
    SELECT COUNT(*) INTO baggage_count
    FROM baggage
    WHERE registration_date > date;
    RETURN baggage_count;
END //
DELIMITER ;
SELECT GetBaggageCountAfterDate('2023-01-18') AS baggage_count;




-- отримання кількості пасажирів, які мають багаж певного типу
DROP FUNCTION IF EXISTS GetPassengerCountWithBaggageType;
DELIMITER //
CREATE FUNCTION `GetPassengerCountWithBaggageType`(baggage_type VARCHAR(50))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE passenger_count INT;
    SELECT COUNT(DISTINCT p.passengerID) INTO passenger_count
    FROM passenger p
    JOIN baggage b ON p.baggageID = b.baggageID
    WHERE b.type = baggage_type;
    RETURN passenger_count;
END //
DELIMITER ;
SELECT GetPassengerCountWithBaggageType('Бізнес') AS passenger_count;



-- отримання кількості рейсів, які відправляються в певний час
DROP FUNCTION IF EXISTS GetFlightCountAtTime;
DELIMITER //
CREATE FUNCTION `GetFlightCountAtTime`(time TIME)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE flight_count INT;
    SELECT COUNT(*) INTO flight_count
    FROM schedule
    WHERE departure_time = time;
    RETURN flight_count;
END //
DELIMITER ;
SELECT GetFlightCountAtTime('11:00:00') AS flight_count;




-- оновлення багажу певного пасажира
DROP PROCEDURE IF EXISTS UpdatePassengerBaggage;
DELIMITER //
CREATE PROCEDURE `UpdatePassengerBaggage`(IN passenger_id INT, IN new_weight INT, IN new_type VARCHAR(50), IN new_registration_date DATE)
BEGIN
    UPDATE baggage b
    JOIN passenger p ON b.baggageID = p.baggageID
    SET b.weight = new_weight,
        b.type = new_type,
        b.registration_date = new_registration_date
    WHERE p.passengerID = passenger_id;
END //
DELIMITER ;
CALL UpdatePassengerBaggage(1, 50, 'Бізнес', '2023-01-01');
Select * from baggage;



