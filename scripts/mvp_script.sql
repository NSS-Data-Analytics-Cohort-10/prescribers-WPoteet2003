-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
   
SELECT prescriber.npi, SUM(total_claim_count)
FROM prescription
LEFT JOIN prescriber
ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi
ORDER BY SUM(total_claim_count) DESC
LIMIT 3;
	
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT prescriber.npi, nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, SUM(total_claim_count)
FROM prescription
LEFT JOIN prescriber
ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi, nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 3;

-- ANSWER: Bruce Pendley, Family Practice, 99,707

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count)
FROM prescription
LEFT JOIN prescriber
ON prescriber.npi = prescription.npi
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 3;

-- ANSWER: Family Practice with 9,752,347

--     b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description, SUM(total_claim_count), opioid_drug_flag
FROM prescription
LEFT JOIN prescriber
ON prescriber.npi = prescription.npi
LEFT JOIN drug 
ON prescription.drug_name = drug.drug_name
GROUP BY specialty_description, opioid_drug_flag
HAVING opioid_drug_flag = 'Y'
ORDER BY SUM(total_claim_count) DESC
LIMIT 3;

-- ANSWER: Nurse Practitioner with 900,845

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT specialty_description, SUM(total_claim_count)
FROM prescription
LEFT JOIN prescriber
ON prescriber.npi = prescription.npi
GROUP BY specialty_description
HAVING SUM(total_claim_count) = '0'
ORDER BY SUM(total_claim_count) ASC
LIMIT 3;

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?



-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, SUM(total_drug_cost)
FROM prescription
LEFT JOIN drug 
ON prescription.drug_name = drug.drug_name
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC
LIMIT 3;

--ANSWER: Insulin, a nerve pain medication with 104,264,066.

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) as cost_ratio
FROM prescription
LEFT JOIN drug 
ON prescription.drug_name = drug.drug_name
GROUP BY generic_name
ORDER BY cost_ratio DESC
LIMIT 3;

--Answer: C1 inhibitor, an HAE medicine, with 3495.22

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
CASE
WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END drug_type
FROM drug
LIMIT 10;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT CAST(SUM(total_drug_cost) as Money),
CASE
WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END drug_type
FROM prescription
LEFT JOIN drug 
ON prescription.drug_name = drug.drug_name
GROUP BY drug_type;

--Answer: Opioid with 105,080,626

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%, TN%';

--Answer: 56

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsaname, SUM(population)
FROM population
LEFT JOIN cbsa
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsaname
ORDER BY SUM(population) DESC;

--ANSWER: Nashville-Davidson-Murfeesboro-Frankin, TN  with 1,830,410

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT *
FROM population
LEFT JOIN cbsa
ON cbsa.fipscounty = population.fipscounty
LEFT JOIN fips_county
ON fips_county.fipscounty = population.fipscounty
WHERE cbsaname IS NULL
ORDER BY population DESC
LIMIT 3;

--ANSWER: Sevier, 95,523

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count > 3000;

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT prescription.drug_name, total_claim_count, opioid_drug_flag
FROM prescription
LEFT JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE total_claim_count > 3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT prescription.drug_name, total_claim_count, opioid_drug_flag, 
nppes_provider_first_name || ' ' || nppes_provider_last_org_name
FROM prescription
LEFT JOIN drug
ON prescription.drug_name = drug.drug_name
LEFT JOIN prescriber
ON prescription.npi = prescriber.npi
WHERE total_claim_count > 3000;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
   
SELECT npi, drug.drug_name, total_claim_count
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';

--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.


