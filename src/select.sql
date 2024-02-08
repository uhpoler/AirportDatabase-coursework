--  список пасажирів, які пройшли паспортний контроль
SELECT p.pas_name, p.pas_lastname, p.pas_surname, pc.check_result
FROM passenger p
JOIN passenger_check pc ON p.passengerID = pc.passengerID;



-- об'єднання імені та прізвища пасажира та назви міста разом з країною для початкової та кінцевої точок маршруту.
SELECT
    CONCAT(p.pas_name, ' ', p.pas_lastname) AS passenger_name,
    CONCAT(c1.city_name, ', ', c1.country) AS starting_point,
    CONCAT(c2.city_name, ', ', c2.country) AS end_point
FROM
    booking b
JOIN passenger p ON b.passengerID = p.passengerID
JOIN route r ON b.routeID = r.routeID
JOIN city c1 ON r.starting_pointID = c1.cityID
JOIN city c2 ON r.end_pointID = c2.cityID;



-- вибирає інформацію про бронювання пасажирів, включаючи їх імена та дати бронювання, та сортує їх за датою бронювання
SELECT p.pas_name, p.pas_lastname, b.booking_date, b.booking_time
FROM booking b
JOIN passenger p ON b.passengerID = p.passengerID
WHERE b.booking_date >= '2023-01-01'
ORDER BY b.booking_date DESC, b.booking_time DESC;



-- вибирається інформація про пасажирів, їх бронювання та маршрути, де місто відправлення Париж
SELECT p.passengerID, p.pas_name, p.pas_lastname, b.bookingID, b.booking_date, r.routeID
FROM passenger p
JOIN booking b ON p.passengerID = b.passengerID
JOIN route r ON b.routeID = r.routeID
WHERE 
    r.starting_pointID = (
		SELECT cityID 
        FROM city 
        WHERE city_name = 'Mirandamouth')
    AND b.booking_date < (SELECT CURDATE());


-- спільні бронювання з пасажирами протягом періоду
SELECT e.emp_name, e.emp_lastname, e.emp_surname
FROM employee e
WHERE EXISTS (
    SELECT 1
    FROM passenger p
    JOIN booking b ON p.passengerID = b.passengerID
    WHERE b.booking_date >= '2022-01-01'
        AND b.booking_date <= '2023-04-30'
        AND e.employeeID = b.routeID
);

-- пасажирів, які мають багаж вагою більше 20 кг:
SELECT pas_name
FROM passenger
WHERE baggageID IN (
	SELECT baggageID 
	FROM baggage 
    WHERE weight > 20);



-- всі міста, з яких відправляються рейси
SELECT city_name FROM city WHERE cityID IN (
	SELECT starting_pointID 
    FROM route);



-- список всіх міст, з яких починаються маршрути, а також всіх міст, в які ці маршрути прибувають, без повторень
SELECT city_name FROM city WHERE cityID IN (SELECT starting_pointID FROM route)
UNION
SELECT city_name FROM city WHERE cityID IN (SELECT end_pointID FROM route);


-- всі маршрути (routes), тривалість яких більше середньої тривалості всіх маршрутів
SELECT *
FROM route
WHERE duration > (SELECT AVG(duration) FROM route);

--  інформації про пасажирів та їхній багаж, який є типу 'Подорожний' і які мають бронювання на маршрутах, які починаються у місті Київ.
SELECT p.*, b.*
FROM passenger p
JOIN baggage b ON p.baggageID = b.baggageID
WHERE b.type = 'Ручний'
AND p.passengerID IN (
	SELECT passengerID 
	FROM booking 
	WHERE routeID IN (
		SELECT routeID 
        FROM route 
        WHERE starting_pointID = (
			SELECT cityID 
            FROM city 
            WHERE city_name = 'Paigeside')));


-- кількість пасажирів для кожного рейсу
SELECT routeID, COUNT(DISTINCT passengerID) AS passenger_count
FROM booking
GROUP BY routeID;


-- максимальну кількість пасажирів, яку може вмістити літак на певному рейсі
SELECT r.routeID, MAX(p.max_number_of_passengers) AS max_passengers
FROM route r
JOIN plane p ON r.routeID = p.routeID
GROUP BY r.routeID;


--  список міст, які є кінцевими точками хоча б одного рейсу
SELECT DISTINCT c.city_name
FROM city c
WHERE c.cityID IN (SELECT DISTINCT end_pointID FROM route);


-- всіх пасажирів, які здійснили бронювання на рейси, що мають тривалість більше 3 годин
SELECT p.*
FROM passenger p
JOIN booking b ON p.passengerID = b.passengerID
JOIN route r ON b.routeID = r.routeID
WHERE r.duration > 180;  -- Тривалість в хвилинах (3 години = 180 хвилин)


-- працівників, які взяли участь у перевірці багажу, та вивести кількість їх перевірених багажів
SELECT e.*, COUNT(pc.baggageID) AS checked_baggage_count
FROM employee e
LEFT JOIN passenger_check pc ON e.employeeID = pc.employeeID
GROUP BY e.employeeID;


-- літаки, які використовуються на рейсах із заданої країни
SELECT pl.*
FROM plane pl
JOIN route r ON pl.routeID = r.routeID
JOIN city c ON r.starting_pointID = c.cityID
WHERE c.country = 'Ghana';


--  список всіх міст, з яких вилітають рейси, та кількість рейсів, які вирушають з кожного міста
SELECT c.city_name, COUNT(r.routeID) AS flight_count
FROM city c
LEFT JOIN route r ON c.cityID = r.starting_pointID
GROUP BY c.cityID;


-- кількість міжнародних рейсів
SELECT COUNT(DISTINCT r.routeID) AS international_flights_count
FROM route r
WHERE EXISTS (
    SELECT 1
    FROM booking b
    JOIN passenger p ON b.passengerID = p.passengerID
    JOIN city c ON p.citizenship = c.country
    WHERE r.routeID = b.routeID AND r.starting_pointID != c.cityID
);


-- список працівників, які не брали участь у перевірці пасажирів
SELECT e.*
FROM employee e
LEFT JOIN passenger_check pc ON e.employeeID = pc.employeeID
WHERE pc.passenger_checkID IS NULL;



-- найважчий багаж серед усіх бронювань
SELECT MAX(b.weight) AS max_baggage_weight
FROM baggage b
JOIN booking bk ON b.baggageID = bk.baggageID;



-- рейси, на які було здійснено найбільше бронювань
SELECT r.routeID, COUNT(bk.bookingID) AS booking_count
FROM route r
LEFT JOIN booking bk ON r.routeID = bk.routeID
GROUP BY r.routeID
ORDER BY booking_count DESC
LIMIT 1;

-- рейси, для яких тривалість не перевищує середню тривалість усіх рейсів
SELECT r.routeID, r.duration
FROM route r
WHERE r.duration <= (SELECT AVG(duration) FROM route);


-- оптимізація

Select * FROM passenger
WHERE passport_number = '762608733';

CREATE INDEX idx_passenger_passport_number
ON passenger (passport_number);

DRop INDEX idx_baggage_baggageID on airport.baggage;
