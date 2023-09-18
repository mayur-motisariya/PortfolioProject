/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths2
Where continent is not null 
order by 1,2


-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you are infected with Covid in your Country


SELECT Location , Date , Total_cases , total_deaths , (total_deaths / total_cases)*100 as DeathPercentage
From CovidDeaths
WHERE location like '%states%' and continent is not null 
Order By 1,2

--Looking at Total cases Vs Population


SELECT Location , Date , total_cases , population , (total_cases / population)*100 as Percentage_of_Pop_Infected
From CovidDeaths
WHERE location like '%states%' and continent is not null 
Order By 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population , Max(total_cases) as HighestInfectionCount , Max((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count Per Population


SELECT location, population , Max(CAST(total_deaths AS int)) as TotalDeathCount , Max((total_deaths/population))*100 AS PercentPopulationInfected
FROM coviddeaths
--WHERE location LIKE '%states%'
Where continent is not null 
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Let's break it by Continent


SELECT location , Max(CAST(total_deaths AS int)) as TotalDeathCount , Max((total_deaths/population))*100 AS PercentPopulationInfected
FROM coviddeaths
--WHERE location LIKE '%states%'
Where continent is null 
GROUP BY location
ORDER BY TotalDeathCount DESC




-- Showing the continents with Highest Death Count per Population

SELECT continent , Max(CAST(total_deaths AS int)) as TotalDeathCount , Max((total_deaths/population))*100 AS PercentPopulationInfected
FROM coviddeaths
--WHERE location LIKE '%states%'
Where continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Creating View

Create View DeathCountPerContinent AS

SELECT continent , Max(CAST(total_deaths AS int)) as TotalDeathCount , Max((total_deaths/population))*100 AS PercentPopulationInfected
FROM coviddeaths
--WHERE location LIKE '%states%'
Where continent is not null 
GROUP BY continent



-- GLOBAL NUMBERS


SELECT Date , SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths , SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--WHERE location like '%states%' and
WHERE continent is not null 
GROUP BY Date
Order By 1


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths , SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--WHERE location like '%states%' and
Order By 1



-- Looking at Total Population Vs Vaccination
SELECT dea.continent , dea.location, dea.date , dea.population , vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location , dea.Date ) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
FROM Coviddeaths dea
JOIN Covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.Continent is not null
ORDER BY 2,3




-- USE CTE

WITH PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent , dea.location, dea.date , dea.population , vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location , dea.Date ) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
FROM Coviddeaths dea
JOIN Covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.Continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopVsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar(100),
Location nvarchar(100),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopVaccinated

SELECT dea.continent , dea.location, dea.date , dea.population , vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location , dea.Date ) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
FROM Coviddeaths dea
JOIN Covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.Continent is not null
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopVaccinated;



-- Creating View to store data for later Visualization




CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent , dea.location, dea.date , dea.population , vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location , dea.Date ) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
FROM Coviddeaths dea
JOIN Covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.Continent is not null
--ORDER BY 2,3
