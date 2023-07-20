select * 
from PortfolioProject.dbo.CovidDeaths

select *
from PortfolioProject.dbo.CovidDeaths



select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Total cases vs Total deaths
select Location, date, total_cases, new_cases, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--Total cases vs Total deaths in Canada
select Location, date, total_cases, new_cases, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject.dbo.CovidDeaths
where Location ='Canada'
order by 1,2

--Total cases vs Population in India
select Location, date, total_cases, Population, (total_cases/Population)*100 as cases_Percentage
from PortfolioProject.dbo.CovidDeaths
where Location like '%ndia%'
order by 1,2

--Countries with highest positive rate compared to Population
 select Location, Population, MAX(total_cases) as Highest_rate,MAX( (total_cases/Population))*100 as Positive_Percentage
from PortfolioProject.dbo.CovidDeaths
group by Location, Population
order by Positive_Percentage desc

--Counties with highest death count per population
select Location, Population, MAX(cast(total_deaths as INT)), MAX((total_deaths/Population)*100) as highest_death
from PortfolioProject..CovidDeaths
group by Location, population
order by highest_death desc

--Counties with higest death count
select Location, Max(cast(total_deaths as int)) as highest_deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by highest_deaths desc

--Highest death count by Continent
select location, MAX(cast(total_deaths as INT)) as deathcount 
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by deathcount desc

--Showing continents with highest deaths per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount

--Global Numbers
Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Population vs Vaccinations
With POPvsVac (Continent, Location, Date, Population,new_vaccinations, Rolling_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.Date) as Rolling_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
-- Using CTE (Common table Expression)
select *, (Rolling_Vaccinated/Population)*100
from POPvsVac

--Temp Table
DROP table if exists #PercentagePeopleVaccinated

Create table #PercentagePeopleVaccinated

(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinated numeric
)
Insert into #PercentagePeopleVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, (sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.Date)) as Rolling_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (Rolling_Vaccinated/Population)*100
From #PercentagePeopleVaccinated


-- Creating view for visualization
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, (sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.Date)) as Rolling_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated
