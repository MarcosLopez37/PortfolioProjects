-- CONVERTING DATA TYPES IN COLUMNS
	--Alter table dbo.CovidDeaths alter column total_deaths float

	--Alter table dbo.CovidDeaths alter column total_cases float

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3, 4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are goint to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location not like '%virgin%' and location like '%states%' and continent is not null
ORDER by 1, 2


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentageInfected
FROM PortfolioProject..CovidDeaths
WHERE location not like '%virgin%' and location like '%states%' and continent is not null
ORDER by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location not like '%virgin%' and location like '%states%'
GROUP BY location, population
ORDER by PercentageInfected desc

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location not like '%virgin%' and location like '%states%'
GROUP BY location
ORDER by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing Continents with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null and location not like '%income%'
--WHERE location not like '%virgin%' and location like '%states%'
GROUP BY location
ORDER by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases), 0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location not like '%virgin%' and location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER by 1, 2

SELECT  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases), 0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location not like '%virgin%' and location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER by 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated	
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
FROM #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3