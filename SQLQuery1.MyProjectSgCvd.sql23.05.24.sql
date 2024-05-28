
--
Select *
From PortfolioProject..CovidDeaths
WHERE location = 'Singapore'

Select *
From PortfolioProject..CovidVaccination
WHERE location = 'Singapore'



Select FORMAT(date, 'dd-MM-yyyy') FormatedDate, new_cases, total_cases, total_deaths, population, location
From PortfolioProject..CovidDeaths
WHERE location = 'Singapore'

Select FORMAT(date, 'dd-MM-yyyy') FormatedDate, people_vaccinated, people_fully_vaccinated,  total_vaccinations, location
From PortfolioProject..CovidVaccination
WHERE location = 'Singapore'



--Death Rate In Singapore

SELECT 
  FORMAT(date, 'dd-MM-yyyy') AS FormattedDate,
  location,
  total_cases,
  total_deaths,
  CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT) *100 AS CaseFatalityRate 
FROM PortfolioProject..CovidDeaths
WHERE location = 'Singapore'
ORDER BY Date 


--World Death Rate

SELECT 
  FORMAT(date, 'dd-MM-yyyy') AS FormattedDate,
  location,
  total_cases,
  total_deaths,
  CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT) *100 AS CaseFatalityRate
FROM PortfolioProject..CovidDeaths
ORDER BY Date 




--Singapore PercentPopulationInfected Rate

SELECT 
  location, population, MAX(total_cases) AS HighestInfected, MAX(total_cases/population) *100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE location = 'Singapore'
Group by  location, population
ORDER BY PercentPopulationInfected desc


--World PercentPopulationInfected Rate

SELECT 
  location, population, MAX(total_cases) AS HighestInfected, MAX(total_cases/population) *100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by  location, population
ORDER BY PercentPopulationInfected desc





--Singapore PercentPopulationDeath Rate

SELECT 
  location, population, MAX(total_deaths) AS HighestDeath, MAX(total_deaths/population) *100 AS PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE location = 'Singapore'
Group by  location, population
ORDER BY PercentPopulationDeath desc


--World PercentPopulationDeath Rate

SELECT 
  location, population, MAX(total_deaths) AS HighestDeath, MAX(total_deaths/population) *100 AS PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by  location, population
ORDER BY PercentPopulationDeath desc





--World PercentDeathPerPopulation Ranking (SG 153)

SELECT 
  location,
  population,
  MAX(total_deaths) AS HighestDeath,
  MAX(total_deaths / population) * 100 AS PercentDeathPerPopulation,
  DENSE_RANK() OVER (ORDER BY MAX(total_deaths / population) * 100 DESC) AS Ranking
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Ranking


--World PercentDeathPerCases Ranking (SG 210)

SELECT
  location,
  population,
  MAX(total_cases) AS HighestCases,
  MAX(total_deaths) AS HighestDeath,
  MAX(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS PercentDeathPerCases,
  DENSE_RANK() OVER (ORDER BY MAX(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 DESC) AS Ranking
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Ranking



--Continent Total Death Count

SELECT continent, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc



--Continent Total Death Count By Population

SELECT 
	continent,
  MAX(total_deaths) AS HighestDeath,
  MAX(total_deaths / population) * 100 AS PercentDeathPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercentDeathPerPopulation Desc




--Global Death Percentage

SELECT
	SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-- Total Population vs Vaccinations

SELECT
	dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 3,2



-- Singapore Daily Vaccinations with Rolling Totals

SELECT
  dea.date, dea.location, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.location = 'Singapore'
AND new_vaccinations IS NOT NULL  
ORDER BY 1, 2;




--PopvsVac: Singapore Daily Vaccinations CTE

WITH PopvsVac (location, FormatedDate, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT
   dea.location, FORMAT(dea.date, 'dd-MM-yyyy') FormatedDate, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.location = 'Singapore'
AND new_vaccinations IS NOT NULL 
)

SELECT *, (RollingPeopleVaccinated/Population) *100 AS VacPerPop
FROM PopvsVac 



