CREATE DATABASE hotel_bookings_p;

USE hotel_bookings_p;

CREATE TABLE hotel_bookings_raw (
    hotel VARCHAR(50),
    is_canceled TINYINT,
    lead_time INT,
    arrival_date_year INT,
    arrival_date_month VARCHAR(15),
    arrival_date_week_number INT,
    arrival_date_day_of_month INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children INT,
    babies INT,
    meal VARCHAR(10),
    country VARCHAR(10),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(30),
    is_repeated_guest INT,
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    reserved_room_type VARCHAR(5),
    assigned_room_type VARCHAR(5),
    booking_changes INT,
    deposit_type VARCHAR(30),
    agent INT, 
    company INT, 
    days_in_waiting_list INT,
    customer_type VARCHAR(30),
    adr DECIMAL(10,2), -- Assuming ADR is a decimal with 2 decimal places
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    reservation_status VARCHAR(30),
    reservation_status_date DATE
);