select * from PortfolioProject..CovidDeaths
where continent is not Null
order by 3, 4

--select * from PortfolioProject..CovidVaccinations
--order by 3, 4

-- Select Data that we are going to be using

Select location, date, population, new_cases, total_cases, total_deaths
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at the Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 as "Death Percentage"
from PortfolioProject..CovidDeaths
where location like '%india%' and continent is not Null
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population) * 100 as "Percentage of People Got Covid"
from PortfolioProject..CovidDeaths
where location like '%india%' and continent is not Null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by population, location
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

Select  Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not Null
group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not Null
group by continent
order by TotalDeathCount desc

-- Showing continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not Null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases) * 100 as "Death Percentage"
from PortfolioProject..CovidDeaths
where continent is not Null
--group by date
order by 1,2

-- Select all from vaccinations

Select * from PortfolioProject..CovidVaccinations

-- Looking for Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


-- USE CTE
-- IF THE NUMBER OF COLUMNS ARE DIFFERENT IN CTE AND THE TABLE COLUMN ITS GONNA GIVE YOU THE ERROR

With PopVsVac (Continent, Location, date, population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
-- You have to run this query with CTE
select *, (RollingPeopleVaccinated/population) * 100
from PopVsVac


-- Temp Table

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated




--  Creating View to store data for later visualization
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3


Select * from PercentPopulationVaccinated

