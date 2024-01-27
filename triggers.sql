-- переврірка дати бронювання
DROP TRIGGER IF EXISTS check_date_schedule;
DELIMITER //
CREATE TRIGGER check_date_schedule
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE schedule_date DATE;
    SELECT schedule.schedule_date INTO schedule_date 
    FROM schedule
    JOIN route ON schedule.scheduleID = route.scheduleID
    WHERE route.routeID = NEW.routeID;
    IF NEW.booking_date > schedule_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата бронювання не може бути пізнішою за дату розкладу';
    END IF;
END;//
DELIMITER ;



-- переврірка дати бронювання
DROP TRIGGER IF EXISTS check_booking_date;
DELIMITER //
CREATE TRIGGER check_booking_date
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE baggage_date DATE;
    SELECT registration_date INTO baggage_date FROM baggage WHERE baggageID = NEW.baggageID;
    IF NEW.booking_date < baggage_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата бронювання не може бути ранішою за дату реєстрації багажу';
    END IF;
END;//
DELIMITER ;



-- Максимальна кількість білетів на рейс
DROP TRIGGER IF EXISTS check_seats;
DELIMITER //
CREATE TRIGGER check_seats
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE max_seats INT;
    DECLARE booked_seats INT;
    SELECT max_number_of_passengers INTO max_seats
    FROM plane
    JOIN route ON plane.routeID = route.routeID
    WHERE route.routeID = NEW.routeID
    LIMIT 1;
    SELECT COUNT(*) INTO booked_seats
    FROM booking
    WHERE routeID = NEW.routeID;
    IF booked_seats >= max_seats THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Неможливо забронювати більше білетів, ніж максимальна кількість місць на літаку';
    END IF;
END;//
DELIMITER ;


-- вага багажу не перевищує вантажопідйомності 
DROP TRIGGER IF EXISTS check_baggage_weight;
DELIMITER //
CREATE TRIGGER check_baggage_weight
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE plane_capacity INT;
    DECLARE baggage_weight INT;
    SELECT carrying_capacity INTO plane_capacity
    FROM plane
    WHERE planeID = NEW.routeID;
    SELECT weight INTO baggage_weight
    FROM baggage
    WHERE baggageID = NEW.baggageID;
    IF baggage_weight > plane_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Вага багажу перевищує вантажопідйомність літака';
    END IF;
END;//
DELIMITER ;




-- перевірка чи вага багажу не від'ємна
DROP TRIGGER IF EXISTS check_weight;
DELIMITER //
CREATE TRIGGER check_weight
BEFORE INSERT ON baggage
FOR EACH ROW
BEGIN
	IF NEW.weight < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Вага багажу не може бути меншою за 0';
	END IF;
END;//
DELIMITER ;




-- перевірка повноліття пасажирів
DROP TRIGGER IF EXISTS check_passenger_age;
DELIMITER //
CREATE TRIGGER check_passenger_age
BEFORE INSERT ON passenger
FOR EACH ROW
BEGIN
	IF (YEAR(CURDATE()) - YEAR(NEW.date_of_birth)) < 18 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Пасажир має бути старше 18';
	END IF;
END;//
DELIMITER ;


