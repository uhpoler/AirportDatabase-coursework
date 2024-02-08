DROP VIEW IF EXISTS view_a;
CREATE VIEW view_a AS
SELECT p.passengerID, p.pas_name, p.pas_lastname, p.pas_surname, b.routeID, b.booking_date, r.scheduleID, r.duration
FROM
    passenger p
    JOIN booking b ON p.passengerID = b.passengerID
    JOIN route r ON b.routeID = r.routeID;
SELECT * FROM view_a;


DROP VIEW IF EXISTS view_b;
CREATE VIEW view_b AS
SELECT a.passengerID, a.pas_name, a.pas_lastname, a.pas_surname, a.routeID, a.booking_date, a.scheduleID, a.duration, s.departure_time, s.arrival_time
FROM
    view_a a
    JOIN schedule s ON a.scheduleID = s.scheduleID;
SELECT * FROM view_b;




ALTER VIEW view_b AS
SELECT a.passengerID, a.pas_name, a.pas_lastname, a.pas_surname, a.routeID, a.booking_date, a.scheduleID, a.duration, s.departure_time, s.arrival_time,
    b.weight AS baggage_weight
FROM
    view_a a
    JOIN schedule s ON a.scheduleID = s.scheduleID
    JOIN passenger p ON a.passengerID = p.passengerID
    JOIN baggage b ON p.baggageID = b.baggageID;

SELECT * FROM view_b;