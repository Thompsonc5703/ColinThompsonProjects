-- Reformat total_cases from varchar to float

ALTER TABLE PortfolioProjectCT..COVIDDeath2022 
ALTER COLUMN total_cases float

-- Standard SELECT statements for each table

SELECT *
FROM PortfolioProjectCT..COVIDDeath2022
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProjectCT..COVIDVac2022
ORDER BY 3,4


--Select data that will be used

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectCT..COVIDDeath2022
WHERE continent IS NOT NULL


-- Total Cases vs. Total Deaths (% of people dying from COVID in US)

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjectCT..COVIDDeath2022
WHERE Location = 'United States' AND continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs. Population (% of population with COVID in US)

SELECT Location, Date, total_cases, population, (total_cases/population)*100 AS PercentofPopulationInfected
FROM PortfolioProjectCT..COVIDDeath2022
WHERE Location = 'United States' AND continent IS NOT NULL
ORDER BY 1,2


-- Countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentofPopulationInfected
FROM PortfolioProjectCT..COVIDDeath2022
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 4 DESC


-- Showing countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProjectCT..COVIDDeath2022
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 2 DESC


-- Showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProjectCT..COVIDDeath2022
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- Global numbers running toal

SELECT DISTINCT(Date),
SUM(new_cases) OVER(ORDER BY Date) AS total_cases,
SUM(new_deaths) OVER(ORDER BY Date) AS total_deaths,
ISNULL((SUM(new_deaths) OVER(ORDER BY Date)/NULLIF(SUM(new_cases) OVER(ORDER BY Date),0)),0)*100 AS DeathPercentage
FROM PortfolioProjectCT..COVIDDeath2022
WHERE continent IS NOT NULL
GROUP BY Date, new_cases, new_deaths


-- Looking at total population vs vaccinations

Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS float)) OVER (PARTITION BY DEA.Location ORDER BY DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProjectCT..COVIDDeath2022 AS DEA
INNER JOIN PortfolioProjectCT..COVIDVac2022 AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL


-- USE CTE for 'RollingPeopleVaccinated'

With PoPvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS float)) OVER (PARTITION BY DEA.Location ORDER BY DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProjectCT..COVIDDeath2022 AS DEA
INNER JOIN PortfolioProjectCT..COVIDVac2022 AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PoPvsVac


-- Creating a TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS float)) OVER (PARTITION BY DEA.Location ORDER BY DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProjectCT..COVIDDeath2022 AS DEA
INNER JOIN PortfolioProjectCT..COVIDVac2022 AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


-- Creating a View to store data later for visualizations

Create View PercentPopulationVaccinated as
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS float)) OVER (PARTITION BY DEA.Location ORDER BY DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProjectCT..COVIDDeath2022 AS DEA
INNER JOIN PortfolioProjectCT..COVIDVac2022 AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL