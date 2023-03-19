/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


USE PortfolioProject
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4


-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY location, date

Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'South Africa'
ORDER BY location, date


--Looking at Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage  
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'South Africa'
ORDER BY location, date


--Countries with Highest Infection RAte compared to Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected 
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'South Africa'
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases/population) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Break down by Continent 

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--BREAK DOWN BY CONTINENT

--Showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST
(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total Populatoin vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) 
 OVER (PARTITION BY dea.Location ORDER BY dea.Date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN  PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  2,3

-- Using CTE to perform Calculationon Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations))  OVER (PARTITION BY dea.Location ORDER BY dea.Date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN  PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp Table

DROP TABLE IF EXISTS  #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations))  OVER (PARTITION BY dea.Location ORDER BY  dea.Date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN  PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM  #PercentagePopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY  dea.Date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN  PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

