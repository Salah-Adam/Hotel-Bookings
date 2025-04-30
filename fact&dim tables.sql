-- #################### dim_hotel
CREATE TABLE dim_hotel (
    hotel_id INT PRIMARY KEY AUTO_INCREMENT,
    hotel VARCHAR(20)
);

-- insert values into dim_hotel table
INSERT INTO dim_hotel(hotel)
SELECT DISTINCT hotel
FROM hotel_bookings_raw;

SELECT * FROM dim_hotel;

-- #################### dim_arrival_date
CREATE TABLE dim_arrival_date (
    arrival_date_id INT PRIMARY KEY AUTO_INCREMENT,
    arrival_date DATE,
    arrival_date_year INT,
    arrival_date_month VARCHAR(10),
    arrival_date_week_number INT,
    arrival_date_day_of_month INT
);

INSERT INTO dim_arrival_date (arrival_date, 
							   arrival_date_year, 
                               arrival_date_month, 
                               arrival_date_week_number, 
                               arrival_date_day_of_month)
SELECT DISTINCT
       STR_TO_DATE(CONCAT
	   (CAST(arrival_date_year AS CHAR), arrival_date_month, CAST(arrival_date_day_of_month AS CHAR)), '%Y %M %D') AS arrival_date,
	   arrival_date_year,
	   arrival_date_month,
	   arrival_date_week_number,
	   arrival_date_day_of_month
FROM hotel_bookings_raw;

SELECT * FROM dim_arrival_date;

-- #################### dim_guest
CREATE TABLE dim_guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    country VARCHAR(3),
    customer_type VARCHAR(20),
    agent DECIMAL(10,0),
    company DECIMAL(10,0),
    meal VARCHAR(3)
);

-- before insertion, i updated the 'meal' so that we can ovoid errors when insertin values into the dim_guest table
UPDATE hotel_bookings_raw
SET meal = NULL
WHERE LOWER(meal) = 'undefined';

INSERT INTO dim_guest ( country, customer_type, agent, company, meal)
SELECT distinct
		country,
       customer_type,
       agent,
       company,
	   meal
FROM hotel_bookings_raw;

SELECT * FROM dim_guest;

--  #################### dim_market_segment
CREATE TABLE dim_market_segment (
    market_segment_id INT PRIMARY KEY AUTO_INCREMENT,
    market_segment VARCHAR(50)
);

INSERT INTO dim_market_segment(market_segment)
SELECT DISTINCT market_segment 
FROM hotel_bookings_raw;

SELECT * FROM dim_market_segment;

-- #################### dim_distribution_channel
CREATE TABLE dim_distribution_channel (
    distribution_channel_id INT PRIMARY KEY AUTO_INCREMENT,
    distribution_channel VARCHAR(20)
);

INSERT INTO dim_distribution_channel(distribution_channel)
SELECT DISTINCT distribution_channel 
FROM hotel_bookings_raw;

SELECT * FROM dim_distribution_channel;

-- #################### dim_room
CREATE TABLE dim_room (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    reserved_room_type VARCHAR(5),
    assigned_room_type VARCHAR(5)
);

INSERT INTO dim_room(reserved_room_type, assigned_room_type)
SELECT DISTINCT reserved_room_type, assigned_room_type
FROM hotel_bookings_raw;

SELECT * FROM dim_room;

-- #################### dim_deposit_type
CREATE TABLE dim_deposit_type (
    deposit_type_id INT PRIMARY KEY AUTO_INCREMENT,
    deposit_type VARCHAR(20)
);

INSERT INTO dim_deposit_type (deposit_type)
SELECT DISTINCT deposit_type
FROM hotel_bookings_raw;

SELECT * FROM dim_deposit_type;

-- #################### dim_reservation_status
CREATE TABLE dim_reservation_status (
    reservation_status_id INT PRIMARY KEY AUTO_INCREMENT,
    reservation_status VARCHAR(20),
    reservation_status_date DATE
);

INSERT INTO dim_reservation_status (reservation_status, reservation_status_date)
SELECT DISTINCT reservation_status, reservation_status_date
FROM hotel_bookings_raw;

SELECT * FROM dim_reservation_status;


-- #################### fact_hotel_bookings ####################################
CREATE TABLE fact_hotel_booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    hotel_id INT,
    arrival_date_id INT,
    guest_id INT,
    market_segment_id INT,
    distribution_channel_id INT,
    room_id INT,
    deposit_type_id INT,
    reservation_status_id INT,
    lead_time INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children DECIMAL(3,1),
    babies INT,
    booking_changes INT,
    days_in_waiting_list INT,
    adr DECIMAL(10,2),
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    is_canceled INT,
    is_repeated_guest INT,
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    FOREIGN KEY (hotel_id) REFERENCES dim_hotel(hotel_id),
    FOREIGN KEY (arrival_date_id) REFERENCES dim_arrival_date(arrival_date_id),
    FOREIGN KEY (guest_id) REFERENCES dim_guests(guest_id),
    FOREIGN KEY (market_segment_id) REFERENCES dim_market_segment(market_segment_id),
    FOREIGN KEY (distribution_channel_id) REFERENCES dim_distribution_channel(distribution_channel_id),
    FOREIGN KEY (room_id) REFERENCES dim_room(room_id),
    FOREIGN KEY (deposit_type_id) REFERENCES dim_deposit_type(deposit_type_id),
    FOREIGN KEY (reservation_status_id) REFERENCES dim_reservation_status(reservation_status_id)
);



INSERT INTO fact_hotel_booking (
    hotel_id,
    arrival_date_id,
    guest_id,
    market_segment_id,
    distribution_channel_id,
    room_id,
    deposit_type_id,
    reservation_status_id,
    lead_time,
    stays_in_weekend_nights,
    stays_in_week_nights,
    adults,
    children,
    babies,
    booking_changes,
    days_in_waiting_list,
    adr,
    required_car_parking_spaces,
    total_of_special_requests,
    is_canceled,
    is_repeated_guest,
    previous_cancellations,
    previous_bookings_not_canceled
)
SELECT
    dh.hotel_id,
    dad.arrival_date_id,
    dg.guest_id,
    dms.market_segment_id,
    ddc.distribution_channel_id,
    dr.room_id,
    ddt.deposit_type_id,
    drs.reservation_status_id,
    hbr.lead_time,
    hbr.stays_in_weekend_nights,
    hbr.stays_in_week_nights,
    hbr.adults,
    hbr.children,
    hbr.babies,
    hbr.booking_changes,
    hbr.days_in_waiting_list,
    hbr.adr,
    hbr.required_car_parking_spaces,
    hbr.total_of_special_requests,
    hbr.is_canceled,
    hbr.is_repeated_guest,
    hbr.previous_cancellations,
    hbr.previous_bookings_not_canceled
FROM
    hotel_bookings_raw hbr
JOIN
    dim_hotel dh ON hbr.hotel = dh.hotel
JOIN
    dim_arrival_date dad ON STR_TO_DATE(CONCAT(CAST(hbr.arrival_date_year AS CHAR), hbr.arrival_date_month, 
											   CAST(hbr.arrival_date_day_of_month AS CHAR)), '%Y %M %D') = dad.arrival_date
                           AND hbr.arrival_date_year = dad.arrival_date_year
                           AND hbr.arrival_date_month = dad.arrival_date_month
                           AND hbr.arrival_date_week_number = dad.arrival_date_week_number
                           AND hbr.arrival_date_day_of_month = dad.arrival_date_day_of_month
                           
JOIN 
	dim_guests dg ON COALESCE(hbr.country, 'Unknown') = dg.country
                   AND hbr.customer_type = dg.customer_type
                   AND COALESCE(hbr.agent, -1) = dg.agent
                   AND COALESCE(hbr.company, -1) = dg.company
                   AND COALESCE(hbr.meal, 'Undefined') = dg.meal
JOIN
    dim_market_segment dms ON hbr.market_segment = dms.market_segment
JOIN
    dim_distribution_channel ddc ON hbr.distribution_channel = ddc.distribution_channel
JOIN
    dim_room dr ON hbr.reserved_room_type = dr.reserved_room_type
                 AND hbr.assigned_room_type = dr.assigned_room_type
JOIN
    dim_deposit_type ddt ON hbr.deposit_type = ddt.deposit_type
JOIN
    dim_reservation_status drs ON hbr.reservation_status = drs.reservation_status
                                 AND hbr.reservation_status_date = drs.reservation_status_date;
