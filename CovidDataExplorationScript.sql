SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract COVID in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at Total cases vs Total population
--Shows what percentage pop got covid
SELECT location, date, total_cases, population, (total_cases/population*100) as PercentPopInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2


--What country has the highest infection rate compared to population?
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population*100) as PercentPopInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by PercentPopInfected desc


--What countries had the highest death count per pop?
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
--WHERE location like '%states%'
GROUP BY location
order by TotalDeathCount desc


--Breaking things down by continent (more accurate values; correct way)
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null
--WHERE location like '%states%'
GROUP BY location
order by TotalDeathCount desc

--for exercise purposes (breaking down by contient)
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
--WHERE location like '%states%'
GROUP BY continent
order by TotalDeathCount desc


--Global numbers
SELECT date, sum(new_cases) as TotalCases, 
	sum(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP by date
order by 1,2

	-- global total
	SELECT sum(new_cases) as TotalCases, 
		sum(cast(new_deaths as int)) as TotalDeaths, 
		SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	FROM PortfolioProject..CovidDeaths
	--WHERE location like '%states%'
	WHERE continent is not null
	order by 1,2


-- Total population vs. Total Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) 
	over (Partition by dea.location ORDER by dea.location, dea.date)
		as RollingPeopleVacc
--,RollingPeopleVacc/population*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--USE CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVacc)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) 
	over (Partition by dea.location ORDER by dea.location, dea.date)
		as RollingPeopleVacc
--,RollingPeopleVacc/population*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT *,(RollingPeopleVacc/population)*100
FROM PopvsVac


--USE TEMP TABLE
DROP TABLE if exists #PercentPopVacc
Create Table #PercentPopVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) 
	over (Partition by dea.location ORDER by dea.location, dea.date)
		as RollingPeopleVacc
--,RollingPeopleVacc/population*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopVacc




--Create View to store data for later visualizations
CREATE VIEW PercentPopVacc as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) 
	over (Partition by dea.location ORDER by dea.location, dea.date)
		as RollingPeopleVacc
--,RollingPeopleVacc/population*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopVacc