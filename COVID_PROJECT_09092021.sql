--Select *
--From Portfolio_Project..CovidVaccinations
--order by 3,4

--Select Data that we are using

Select location, date, total_cases, new_cases,total_deaths, population
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelyhood of dying if you contract covid 
Select location, population, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Portfolio_Project..CovidDeaths
Where location like '%states%'
order by 1,2


--Countries with highest infection rate compared to population.
Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected 
From Portfolio_Project..CovidDeaths
Group  By location, population
order by Percent_Population_Infected desc

--Show countries with the highest death count per population
Select location, Max(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Project..CovidDeaths
where continent is not null
Group  By location
order by Total_Death_Count desc


--Which Continent has the most deaths
Select location, Max(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Project..CovidDeaths
where continent is null
Group  By location
order by Total_Death_Count desc

Select continent, Max(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Project..CovidDeaths
where continent is not null
Group  By continent
order by Total_Death_Count desc


--Global Numbers
Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From Portfolio_Project..CovidDeaths
where continent is not null
Group  By date
order by 1,2


Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

--Joining the two datasets
-- total population vs vacccination
--With CTE
With PopulationvsVaccination (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
Select dea.location, dea.date, dea.continent,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location order by dea.location, dea.date) as rolling_vaccinations
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2,3
)

Select*, (rolling_vaccinations/population)*100 as PercentVaccinated 
From PopulationvsVaccination


--creating view for data vizualization
Create View PercentVaccinated as
Select dea.location, dea.date, dea.continent,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location order by dea.location, dea.date) as rolling_vaccinations
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2,3
