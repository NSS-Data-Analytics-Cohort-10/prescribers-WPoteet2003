-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?

SELECT COUNT(p.npi)
  FROM prescriber p
 WHERE NOT EXISTS(SELECT NULL
                    FROM prescription pr
                   WHERE p.npi = pr.npi)
	

-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT generic_name, SUM(total_claim_count)
FROM prescription
LEFT JOIN prescriber
USING(npi)
LEFT JOIN drug
USING(drug_name)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

SELECT generic_name, SUM(total_claim_count)
FROM prescription
LEFT JOIN prescriber
USING(npi)
LEFT JOIN drug
USING(drug_name)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

SELECT generic_name, SUM(total_claim_count)
FROM prescription p
LEFT JOIN prescriber pr
USING(npi)
LEFT JOIN drug d
USING(drug_name)
WHERE specialty_description = 'Cardiology' OR specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.



--     b. Now, report the same for Memphis.



--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.



-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.



-- 5.
--     a. Write a query that finds the total population of Tennessee.



--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.

 
