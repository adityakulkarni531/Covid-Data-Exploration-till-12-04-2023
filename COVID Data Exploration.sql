SELECT *
FROM SQLProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--select *
--from SQLProject..CovidVaccination$
--order by 3,4

SELECT location,date, total_cases,new_cases,total_deaths,population
FROM SQLProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- LOOKING AT TATOAL CASES VS TOTAL DEATHS
-- In India
SELECT location, date, total_cases, total_deaths, ((convert(decimal(10,2), total_deaths) / convert(decimal(15,2), total_cases))*100) AS DeathPercentage
FROM SQLProject..CovidDeaths$
where location like '%india%'
WHERE continent is not null
ORDER BY 1,2

-- loking at total cases vs population
-- shows what percentage of population got covid

SELECT location, date, population, total_cases, ((convert(decimal(15,2), total_cases) / convert(decimal(15,2), population))*100) AS PercentPopulationInfected
FROM SQLProject..CovidDeaths$
where location like '%india%'
and continent is not null
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population

Select Location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From SQLProject..CovidDeaths$
--Where location like '%india%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLProject..CovidDeaths$
--Where location like '%india%'
WHERE continent is not null
Group by Location
order by TotalDeathCount desc


-- Let's Break things down by continent


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLProject..CovidDeaths$
WHERE continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers 

SELECT date, SUM(cast(new_cases as int)) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
NULLIF(SUM(CAST(new_deaths as int)),0)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM SQLProject..CovidDeaths$
--where location like '%india%'
where continent is not null
Group by date
ORDER BY 1,2


--Throught the world
SELECT SUM(cast(new_cases as int)) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
NULLIF(SUM(CAST(new_deaths as int)),0)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM SQLProject..CovidDeaths$
--where location like '%india%'
where continent is not null
--Group by date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
FROM SQLProject..CovidDeaths$ dea
JOIN SQLProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3


--Use CTE

With PopvsVac(Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
FROM SQLProject..CovidDeaths$ dea
JOIN SQLProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
FROM SQLProject..CovidDeaths$ dea
JOIN SQLProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Create View

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
FROM SQLProject..CovidDeaths$ dea
JOIN SQLProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated
