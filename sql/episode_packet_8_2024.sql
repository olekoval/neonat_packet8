WITH 
dict AS -- підстава госпіталізації
(SELECT code, description
   FROM core.dim_rpt_dictionary_values
  WHERE is_current = 'Y' AND dictionary_id = '8ed54d16-173a-48bd-b4f4-d47a7389db5c'),
  
tariff_base AS 
(SELECT base_rate,
        packet_number
   FROM analytics.ref_pmg_packets
  WHERE packet_number = '8'
    AND year = 2024
    AND is_current = 'Y'),
	
tariff_service AS
(SELECT * FROM analytics.ref_pmg_coefficients_services
  WHERE is_current = 'Y'
    AND year = 2024
    AND packet_number = '8')

SELECT 
       e.episode_id,
       e.patient_id,
	   EXTRACT(MONTH FROM e.ends) AS місяць_виписки,
	   dict.description AS підстава_госпіталізації,
	   ec.adrg,
	   ec.service_number,
	   ts.name,
	   tb.base_rate AS тариф,
	   ts.value AS коефіцієнт	   
  FROM analytics.rds_pmg_events_2024 e											
       JOIN analytics.rds_pmg_events_checks_2024 ec ON e.id = ec.id		
	   LEFT JOIN dict ON dict.code = e.admission_source
       JOIN tariff_base AS tb ON tb.packet_number = ec.packet_number
	   LEFT JOIN tariff_service AS ts ON ts.service_number = ec.service_number
 WHERE ec.packet_number = '8'
   AND ec.is_correct
   AND ec.is_payment
   
   