SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

 --Total Cases vs. Total Deaths
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  ROUND((total_deaths / total_cases) * 100.0, 2) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

 --Total Cases vs. Population
SELECT 
  location,
  date,
  total_cases,
  population,
  ROUND((total_cases / population) * 100.0, 2) AS percent_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

 --Countries with Highest Infection Rates
SELECT
  continent,
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  ROUND(MAX((total_cases / population) * 100.0), 2) AS percent_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY percent_infected DESC;

 --Countries with Highest Death Counts
SELECT
  continent,
  location,
  MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY total_death_count DESC;

 --Continents with Highest Death Counts
SELECT
  population,
  location,
  MAX(CAST(total_deaths AS int)) AS total_death_count,
  ROUND(MAX(CAST(total_deaths AS int)) / population * 100, 2) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY population, location
ORDER BY total_death_count DESC;

--Global Numbers
SELECT
  date,
  SUM(new_cases) AS daily_cases,
  SUM(CAST(new_deaths AS INT)) AS daily_deaths,
  ROUND((SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100.0, 2) AS daily_death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, daily_cases;

--Total Vaccinations vs. Population
WITH PercentVaccinated (
  continent,
  location,
  date,
  population,
  new_vaccinations,
  cumulative_vaccinations
) AS ( 
  SELECT
    cd.continent,
	  cd.location,
	  cd.date,
	  cd.population,
	  cv.new_vaccinations,
	  SUM(CAST(new_vaccinations AS INT)) OVER (
	    PARTITION BY cd.location
	    ORDER BY cd.date
	  ) AS cumulative_vaccinations
  FROM PortfolioProject..CovidDeaths cd
  JOIN PortfolioProject..CovidVaccinations cv
    ON cd.location = cv.location
    AND cd.date = cv.date
  WHERE cd.continent IS NOT NULL
)

SELECT *, ROUND((cumulative_vaccinations / population) * 100.0, 2) AS percent_vaccinated
FROM PercentVaccinated
ORDER BY location, date;

--Create view to store data for later visualizations
CREATE VIEW PercentVaccinated AS
SELECT
  cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(new_vaccinations AS INT)) OVER (
	  PARTITION BY cd.location
	  ORDER BY cd.date
	) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

--Death Percentage by Latitude
SELECT
  City_Name,
  Country_Na,
  Latitude,
  Reported_D,
  Population,
  Total_Deat,
  Total_Case,
  ROUND((Total_Deat / Total_Case) * 100, 2) AS Death_Perc
FROM PortfolioProject..CovidCityData
WHERE Population != 0 AND Total_Case != 0
ORDER BY Death_Perc DESC
