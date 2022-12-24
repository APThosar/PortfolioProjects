select *
from PortfolioProject..CovidDeaths1$
order by 3,4
--select *
--from PortfolioProject..CovidDeaths1$
--order by 3,4

--Select data that we are going to be using

Select location,date, total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths1$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows chances of dying if you get covid
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths1$
where location like 'India'
order by 1,2

--Looking total cases vs Population
--Shows Percentage of Population got Covid
Select location,date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths1$
where location like 'India'
order by 1,2

--Looking at countries with highest Infection Rate
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths1$
group by location, population
order by InfectedPercentage desc

--Showing countries with highest deathcount
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths1$
where continent is not null
group by location
order by TotalDeathCount desc

--Continents with highest deathcounts per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths1$
where continent is not null
group by continent
order by TotalDeathCount desc

--Globle Figures

Select date, Sum(new_cases) as Totalcases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths1$
where continent is not null
group by date
order by 1,2

--Total Population vs Total Vaccination

select dea.continent, dea.date, dea.population, dea.location, vac.new_vaccinations
from PortfolioProject..CovidDeaths1$ dea
join PortfolioProject..CovidVac1$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.date, dea.population, dea.location, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths1$ dea
join PortfolioProject..CovidVac1$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac


-- Temp Table
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.date, dea.population, dea.location, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths1$ dea
join PortfolioProject..CovidVac1$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 
from #PercentagePopulationVaccinated

-- Creating View to store data for visualization
 
CREATE VIEW PercentagePopulationVaccinated as
Select dea.continent, dea.date, dea.population, dea.location, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths1$ dea
join PortfolioProject..CovidVac1$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null

select *
from PercentagePopulationVaccinated



