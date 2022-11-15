select * 
from [Projeto Sql]..CovidDeaths
where continent is not null
order by 3, 4

--select * 
--from [Projeto Sql]..CovidVaccinations
--order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population 
from [Projeto Sql]..CovidDeaths
where continent is not null
order by 1, 2


--likelihood of dying if covid is contracted in Portugal
--total cases vs total deaths

select location, date, total_cases, total_deaths, 
	(total_deaths/total_cases)*100 as death_percentage
from [Projeto Sql]..CovidDeaths
where continent is not null
and location like '%portugal%'
order by 1, 2 


--percentage of population that got covid
--total cases vs population

select location, date, total_cases, population,
	(total_cases/population)*100 as population_percentage
from [Projeto Sql]..CovidDeaths
where continent is not null
order by 1, 2


--percentage of population that got covid in Portugal
--total cases vs population

select location, date, total_cases, population,
	(total_cases/population)*100 as population_percentage
from [Projeto Sql]..CovidDeaths
where continent is not null
and location like '%portugal%'
order by 1, 2


--highest infection rate per population

select location, max(total_cases) as highest_infection, population,
	max((total_cases/population))*100 as populationinfected_percentage
from [Projeto Sql]..CovidDeaths
where continent is not null
group by location, population
order by populationinfected_percentage desc

--highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathscount
from [Projeto Sql]..CovidDeaths
where continent is not null
group by location
order by totaldeathscount desc

--highest death count per population by continent 

select continent, max(cast(total_deaths as int)) as totaldeathscount
from [Projeto Sql]..CovidDeaths
where continent is not null
group by continent
order by totaldeathscount desc


-- global numbers 

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from [Projeto Sql]..CovidDeaths
where continent is not null
--and location like '%portugal%'
group by date
order by 1, 2 


--total population vs vaccination

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeople_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeople_vaccinated
	--(rollingpeople_vaccinated/population)*100 
from [Projeto Sql]..CovidDeaths dea
join [Projeto Sql]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3
)
select *, (rollingpeople_vaccinated/population)*100 as percentage
from popvsvac


-- view creation for visualization

create view percentpopulationvaccinated as 
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeople_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeople_vaccinated
	--(rollingpeople_vaccinated/population)*100 
from [Projeto Sql]..CovidDeaths dea
join [Projeto Sql]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3
)
select *, (rollingpeople_vaccinated/population)*100 as percentage
from popvsvac