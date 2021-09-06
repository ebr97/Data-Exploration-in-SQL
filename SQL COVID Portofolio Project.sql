SELECT * FROM DataAnalystPortofolio..CovidDeaths$
ORDER BY 3,4;

SELECT * FROM DataAnalystPortofolio..CovidVaccination$
ORDER BY 3,4;

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM DataAnalystPortofolio..CovidDeaths$
ORDER BY 1,2;

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Romania

SELECT location, date, total_cases, total_deaths, CONCAT(CAST((total_deaths/total_cases)*100 AS VARCHAR(40)),' %') death_percentage
FROM DataAnalystPortofolio..CovidDeaths$
WHERE location LIKE 'Romania'
ORDER BY 2 DESC;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population,total_cases,CONCAT(CAST((total_cases/population)*100 AS VARCHAR(40)),' %') got_covid
FROM DataAnalystPortofolio..CovidDeaths$
WHERE location LIKE 'Romania'
ORDER BY 2;

-- Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) highest_infection_count, CONCAT(CAST((MAX(total_cases/population))*100 AS VARCHAR(40)),' %') percent_population_infected
FROM DataAnalystPortofolio..CovidDeaths$
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Showing Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM DataAnalystPortofolio..CovidDeaths$
WHERE _ IS NOT NULL
GROUP BY location 
ORDER BY total_death_count DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT "_" continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM DataAnalystPortofolio..CovidDeaths$
WHERE _ IS NOT NULL
GROUP BY _
ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS

SELECT  SUM(new_cases) total_cases, SUM(CAST(new_deaths AS INT)) total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 death_percentage
FROM DataAnalystPortofolio..CovidDeaths$
WHERE _ IS NOT NUL
ORDER BY 1,2;

-- Looking at total population VS vaccination

WITH pop_vs_vacc (_, location, date, population,new_vaccinations, rolling_people_vaccinated) -- USE CTE
AS
(
SELECT dea._, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM DataAnalystPortofolio..CovidDeaths$ dea
JOIN DataAnalystPortofolio..CovidVaccination$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea._ IS NOT NULL
--ORDER BY 1,2,3;
)
SELECT *, (rolling_people_vaccinated/population)*100 FROM pop_vs_vacc;

-- OR USING A TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	_ nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea._, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM DataAnalystPortofolio..CovidDeaths$ dea
JOIN DataAnalystPortofolio..CovidVaccination$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea._ IS NOT NULL
--ORDER BY 1,2,3;
SELECT * FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea._, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM DataAnalystPortofolio..CovidDeaths$ dea
JOIN DataAnalystPortofolio..CovidVaccination$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea._ IS NOT NULL
--ORDER BY 1,2,3;

SELECT * FROM PercentPopulationVaccinated;