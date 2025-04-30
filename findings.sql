-- Q1: Monthly Cancellation Rates by Hotel Type

WITH cte_bookings AS (
SELECT dh.hotel,
       YEAR(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY)) AS booking_year, 
       MONTHNAME(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY)) AS booking_month,
	   COUNT(fhb.booking_id) AS total_bookings
FROM fact_hotel_booking fhb
JOIN dim_hotel dh USING(hotel_id)
JOIN dim_arrival_date dad USING (arrival_date_id)
WHERE (YEAR(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY))=2017) OR
	  (YEAR(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY))=2016 AND  
      MONTHNAME(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY)) in ('September', 'October', 'November', 'December'))
GROUP BY dh.hotel,
		 booking_year, 
         booking_month,
          MONTH(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY))
ORDER BY dh.hotel, booking_year,  MONTH(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY))
),
cte_cancellation AS
(
SELECT dh.hotel,
		YEAR(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY)) AS booking_year, 
        MONTHNAME(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY)) AS booking_month,
	   count(fhb.is_canceled)  AS total_cancellations
FROM fact_hotel_booking fhb
JOIN dim_hotel dh USING(hotel_id)
JOIN dim_arrival_date dad USING (arrival_date_id)
WHERE fhb.is_canceled=1 AND 
	  ((YEAR(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY))=2017) OR
	  (YEAR(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY))=2016 AND  
      MONTHNAME(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY)) in ('September', 'October', 'November', 'December')))
GROUP BY dh.hotel,
		 booking_year, 
         booking_month,
          MONTH(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY))
ORDER BY dh.hotel, booking_year,  MONTH(DATE_SUB(dad.arrival_date, INTERVAL fhb.lead_time DAY))
)
SELECT b.*, c.total_cancellations, ROUND((total_cancellations / total_bookings )* 100, 1) as cancellation_rate
FROM cte_bookings b
JOIN cte_cancellation c USING(hotel, booking_year, booking_month) ;


-- Q2 : Impact of Lead Time and Deposit Type on Cancellations
with non_cancelled_B AS (
SELECT ddt.deposit_type, ROUND(AVG(lead_time), 1) as avg_lead_time_non_c_b
FROM fact_hotel_booking fhb
JOIN dim_deposit_type ddt USING(deposit_type_id)
WHERE is_canceled = 0
GROUP BY ddt.deposit_type
),
cancelled_B AS (
SELECT ddt.deposit_type, ROUND(AVG(lead_time), 1) as avg_lead_time_c_b
FROM fact_hotel_booking fhb
JOIN dim_deposit_type ddt USING(deposit_type_id)
WHERE is_canceled = 1
GROUP BY ddt.deposit_type
)
SELECT * FROM non_cancelled_B JOIN cancelled_B USING (deposit_type)
