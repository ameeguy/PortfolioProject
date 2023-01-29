/*
Covid 19 Data Exploration 
*/


SELECT * FROM Portfolio..coviddeaths
order by 3,4

-- Select Data going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..coviddeaths
ORDER BY 1, 2 desc


-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in a specific country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Portfolio..coviddeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2


-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM Portfolio..coviddeaths
--WHERE location LIKE '%Nigeria%'
ORDER BY 5 desc


-- Showing countries with highest infection rate compared to population

SELECT location, population, max(total_cases) AS highestInfectionCount, max((total_cases/population)*100) AS PercentagePopulationInfected
FROM Portfolio..coviddeaths
GROUP BY location, population
ORDER BY 4 desc


-- Showing countries with highest death count per population

SELECT location, population, max(cast (total_deaths as int)) AS HighestDeathCount
FROM Portfolio..coviddeaths
GROUP BY location, population
ORDER BY 3 desc


-- Let's Break Things Down By Continent
Select continent, max(cast (total_deaths as int)) As TotalDeathCount  
From Portfolio..coviddeaths
Where continent is not null
Group By continent
Order By 2 desc


-- Global Numbers
Select  date, SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..coviddeaths
Where continent is not null
group by date
Order By 1,2


Select  SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..coviddeaths
Where continent is not null
Order By 1,2


select * 
from Portfolio..coviddeaths as dea
join Portfolio..covidvaccines as vac
 on dea.location = vac.location
 and dea.date = vac.date



 -- Using CTE to perform Calculation on Partition By in previous query
 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..covidDeaths dea
Join Portfolio..covidvaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..coviddeaths dea
Join Portfolio..covidvaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..coviddeaths dea
Join Portfolio..covidvaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
