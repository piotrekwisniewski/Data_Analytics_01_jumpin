-- Total Cases vs Total Deaths and Population in Europe

Select Location, Date, total_cases, total_deaths,population, (total_deaths/total_cases)*100 AS DeathPercentage, (total_deaths/population)*100 AS DeathPercentPerMilion
FROM PortfolioProject..CovidDeaths
WHERE date='2024-01-14' AND total_deaths IS NOT NULL
ORDER BY DeathPercentPerMilion DESC

-- Countries with the highest death percentage.

Select Location, population, MAX(total_deaths) AS TotalDeathCount, MAX(total_deaths/population)*100 AS DeathPercentPerMilion
FROM PortfolioProject..CovidDeaths
WHERE total_deaths IS NOT NULL and continent is not null
GROUP BY location, population
ORDER BY DeathPercentPerMilion DESC

-- Continents with the highest death count per populaiton

Select continent, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount desc


--Select Location, continent,population, MAX(total_deaths) AS TotalDeathCount, MAX(total_deaths/population)*100 AS DeathPercentPerMilion
--FROM PortfolioProject..CovidDeaths
--WHERE continent is null
--GROUP BY location, continent, population
--ORDER BY DeathPercentPerMilion DESC


--Total deaths by continent

Select continent, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount desc


-- Global Numbers

Select /*date, */SUM(new_cases) as TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases is not null
--GROUP BY DATE
ORDER BY 1,2


-- New  vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- New vaccinations + total vaccinations till each day in separate countries

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) as TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null --and vac.new_vaccinations is not null
ORDER BY 2,3


 -- total vaccinations per day in separate countries and vaccination Rate using CTE


WITH CTE_VaccData AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) as TotalVaccinationsPerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null --and vac.new_vaccinations is not null
)

SELECT continent, location, date, population, TotalVaccinationsPerDay, ((TotalVaccinationsPerDay)/population*100) VaccinationRate
FROM CTE_VaccData
Where continent='Europe'
ORDER BY 6 DESC


-- total vaccinations per day in separate countries and vaccination Rate using #temp table
-- the same as one above but done in other way

DROP TABLE IF EXISTS #temp_VaccData
CREATE TABLE #temp_vaccData (
continent varchar(255),
location nvarchar(255),
date date,
population int,
new_vaccinations int,
TotalVaccinationsPerDay float
);


INSERT INTO #temp_VaccData
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) as TotalVaccinationsPerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null --and vac.new_vaccinations is not null


SELECT continent, location, date, population, TotalVaccinationsPerDay, ((TotalVaccinationsPerDay)/population*100) VaccinationRate
FROM #temp_vaccData
Where continent='Europe'
ORDER BY 6 DESC



--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) as TotalVaccinationsPerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null --and vac.new_vaccinations is not null


SELECT *
FROM PercentPopulationVaccinated