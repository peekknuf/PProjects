
--Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.

SELECT
  p.patient_id,
  p.first_name,
  p.last_name
FROM patients p
  JOIN admissions a ON p.patient_id = a.patient_id
WHERE diagnosis = 'Dementia'


--Show first name and sort them by the length of the name and then alphabetically

SELECT first_name
FROM(
    SELECT
      first_name,
      LEN(first_name) as length
    FROM patients
    ORDER BY
      2,
      1
  )

--Show the total amount of male patients and the total amount of female patients in the patients table. Display the two results in the same row.

SELECT
  SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS total_male_patients,
  SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS total_female_patients
FROM patients;


--Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. 
--Show results ordered ascending by allergies then by first_name then by last_name.

SELECT first_name, last_name, allergies
FROM patients
WHERE allergies IN('Penicillin', 'Morphine')
ORDER BY 3,1,2

--Show patient_id, weight, height, isObese from the patients table.
--Display isObese as a boolean 0 or 1.
--Obese is defined as weight(kg)/(height(m)2) >= 30.

SELECT
  patient_id,
  weight,
  height,
  CASE WHEN weight / POWER(height / 100.0, 2) >= 30 THEN 1 ELSE 0 END AS isObese
FROM patients;

--Show patient_id, first_name, last_name, and attending doctor's specialty.
--Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'

SELECT
  p.patient_id,
  p.first_name,
  p.last_name,
  d.specialty
FROM patients p
  JOIN admissions a ON p.patient_id = a.patient_id
  JOIN doctors d ON a.attending_doctor_id = d.doctor_id
WHERE a.diagnosis = 'Epilepsy' AND d.first_name = 'Lisa'

--All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. 
--Show the patient_id and temp_password.
--The password must be the following, in order:
--1. patient_id
--2. the numerical length of patient's last_name
--3. year of patient's birth_date

SELECT
  patient_id,
  CONCAT(patient_id, LENGTH(last_name), YEAR(birth_date)) AS temp_password
FROM patients
WHERE patient_id IN (
  SELECT DISTINCT patient_id FROM admissions
);

--Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance.
--Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.

SELECT 
  CASE 
    WHEN patient_id % 2 = 0 THEN 'Yes' 
    ELSE 'No' 
  END AS has_insurance,
  SUM(CASE 
        WHEN patient_id % 2 = 0 THEN 10 
        ELSE 50 
      END) AS admission_total_cost
FROM 
  admissions
GROUP BY 
  has_insurance
;


--Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name


SELECT
  pn.province_name
FROM patients p
  JOIN province_names pn ON p.province_id = pn.province_id
GROUP BY province_name
HAVING
  SUM(
    CASE
      WHEN gender = 'M' THEN 1
      ELSE 0
    END
  ) > SUM(
    CASE
      WHEN gender = 'F' THEN 1
      ELSE 0
    END
  )
;


--We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
--- First_name contains an 'r' after the first two letters.
--- Identifies their gender as 'F'
--- Born in February, May, or December
--- Their weight would be between 60kg and 80kg
--- Their patient_id is an odd number
--- They are from the city 'Kingston'

SELECT *
FROM patients
WHERE first_name LIKE '__%r%'
  AND gender = 'F'
  AND MONTH(birth_date) IN (2, 5, 12)
  AND weight BETWEEN 60 AND 80
  AND patient_id % 2 = 1
  AND city = 'Kingston';










