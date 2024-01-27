CREATE ROLE AirportEmployeeRole; 
CREATE ROLE PassengerRole; 

GRANT USAGE ON *.* TO AirportEmployeeRole;
GRANT USAGE ON *.* TO PassengerRole;


GRANT USAGE ON Airport.* TO AirportEmployeeRole;
GRANT USAGE ON Airport.* TO PassengerRole;


GRANT SELECT, INSERT, UPDATE, DELETE ON Airport.* TO AirportEmployeeRole;
GRANT CREATE, ALTER, DROP ON Airport.* TO AirportEmployeeRole;
GRANT SELECT, INSERT, UPDATE ON Airport.* TO PassengerRole;


CREATE USER employee_user IDENTIFIED BY 'employee_user';
CREATE USER passenger_user IDENTIFIED BY 'passenger_user';

GRANT AirportEmployeeRole TO employee_user;
GRANT PassengerRole TO passenger_user;
