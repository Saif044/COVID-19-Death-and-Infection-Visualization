select * from
PortfolioProject.dbo.CovidDeaths

--select * from
--PortfolioProject.dbo.CovidVaccinations
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

-- total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%bangladesh%'
order by 1,2


-- total cases vs total deaths
select location,date,total_cases,population,(total_deaths/population)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%bangladesh%'
order by 1,2

-- countries with highest infection rate compared to population

select location,population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
group by location,population
order by PercentPopulationInfected desc

-- countries with highest DeathCount compared to population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--continent with highest DeathCount compared to population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- countries with highest DeathCount compared to population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Global Numbers
select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100
as death_percentages
from PortfolioProject.dbo.CovidDeaths
--where location like '%bangladesh%'
where continent is not null
group by date
order by 1,2

---- Population vs Vaccinations with CTE
with PopVsVAc (continent, Location, Date , Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over( partition by dea.location order by  dea.location, dea.date) 
As RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/Population)*100
from PopVsVAc

--- Creating View

create view PercentPopulationVaccinatd as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over( partition by dea.location order by  dea.location, dea.date) 
As RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinatd
