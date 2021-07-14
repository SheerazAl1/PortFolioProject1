Select * 
From PortfolioProject..CovidDeaths
order by 3,4


Select Location,date,total_cases,new_cases,total_deaths,Population
From PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Pakistan%'
order by 1,2

--total_cases vs population
Select Location,date,population,total_cases,(total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Pakistan%'
order by 1,2

--highest countries with infection rate
Select location,population,MAX(total_cases) as HighestInfectionRate,MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
group by location,population
order by PercentagePopulationInfected desc


--countries with highest death 
Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathsCount desc

--continents with most deaths 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc


--global numbers
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--total population vs vacinations
Select dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using CTE

with PopvsVac (continent,date,Location,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--temp table
DROP Table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
on dea.location = vac.location
and dea.date = vac.date


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPeopleVaccinated

-- creating view for visual
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated 