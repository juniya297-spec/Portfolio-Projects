SELECT *
FROM CovidDeaths
WHERE continent is not null
order by 3,4

SELECT *
FROM CovidVaccinations
WHERE continent is not null
order by 3,4

Select Location, date,total_cases,new_cases,total_deaths, population
FROM CovidDeaths
WHERE continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date,total_cases,total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date,total_cases,Population,(Total_cases/population)*100 as PercentageofPopulationInfected
FROM CovidDeaths
WHERE continent is not null
--Where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population,date, MAX(total_cases) as HighInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--Where location like %'states'%
Group by Location, Population, date
Order by PercentPopulationInfected desc



--Showing the Countries with Highest Death count per Population


SELECT Location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--Where location like %'states'%
WHERE continent is null
and location not in ('World','European','International')
GROUP by location
Order by TotalDeathCount desc


--Let's Break Things down by Continent

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--Where Locations like %'states%'
WHERE continent is not null
Group by location
order by TotalDeathCount descO

--Global Numbers


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (New_cases)*100 as DeathPercentage
FROM CovidDeaths
--Where Locations like %'states%'
WHERE continent is not null
--GROUP by date
order by 1,2

--Looking at total Population vs Vaccination


With PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac. date 
WHERE dea.continent is not null
--order by 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--USE CTE


--TEMP Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac. date 
WHERE dea.continent is not null
order by 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




--Creating view to store data for later visualizations

 Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac. date 
WHERE dea.continent is not null
--order by 2,3

Select *
FROM PercentPopulationVaccinated
