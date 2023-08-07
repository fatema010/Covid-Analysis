SELECT * FROM project.. CovidDeaths
Where continent is not null 
order by 3,4

SELECT * FROM project.. CovidVaccinations
Where continent is not null 
order by 3,4

Select Location,date,total_cases, new_cases,total_deaths,population 
FROM project.. CovidDeaths
Where continent is not null 
order by 1,2

---- Total Cases vs Total Deaths
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_PCT
FROM project.. CovidDeaths
Where Location like '%germany%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
Select Location,date,population,total_cases,(total_cases/population)*100 as infectedpopulation_PCT
FROM project.. CovidDeaths
Where Location like '%germany%'
order by 1,2


-- Highest Infection Rate countries compared to Population

Select Location,Population, MAX(total_cases) as HighestInfectionrate,  Max((total_cases/population))*100 as infectedpopulation_PCT
From project..CovidDeaths
--Where location like '%germany%'
Group by Location, Population
order by infectedpopulation_PCT desc


-- Highest countries Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From project..CovidDeaths
--Where location like '%germany%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Highest death count per population with contintents
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From project..CovidDeaths
--Where location like '%germany%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global information
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_PCT
From project..CovidDeaths
--Where location like '%germany%'
where continent is not null 
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_PCT
From project..CovidDeaths
--Where location like '%germany%'
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations

Select C.continent, C.location, C.date, C.population, V.new_vaccinations
From project..CovidDeaths C
Join project..CovidVaccinations V
	On C.location = V.location
	and C.date = V.date
where C.continent is not null 
order by 2,3

Select C.continent, C.location, C.date, C.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by C.Location Order by C.location, C.Date) as TotalPeopleVaccinated
From project..CovidDeaths C
Join project..CovidVaccinations V
	On C.location = V.location
	and C.date = V.date
where C.continent is not null 
order by 2,3

-- Used CTE (Common Table Expression)

With PopulationvsVaccination (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select C.continent, C.location, C.date, C.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by C.Location Order by C.location, C.Date) as TotalPeopleVaccinated
From project..CovidDeaths C
Join project..CovidVaccinations V
	On C.location = V.location
	and C.date = V.date
where C.continent is not null 
--order by 2,3
)
Select *, (TotalPeopleVaccinated/Population)*100 As PCT
From PopulationvsVaccination

-- Using Temp Table

DROP Table if exists #PopulationVaccinatedPCT
Create Table #PopulationVaccinatedPCT
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PopulationVaccinatedPCT
Select C.continent, C.location, C.date, C.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by C.Location Order by C.location, C.Date) as TotalPeopleVaccinated
From project..CovidDeaths C
Join project..CovidVaccinations V
	On C.location = V.location
	and C.date = V.date

Select *, (TotalPeopleVaccinated/Population)*100
From #PopulationVaccinatedPCT


-- View 

Create View PopulationVaccinatedPCT as
Select C.continent, C.location, C.date, C.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by C.Location Order by C.location, C.Date) as TotalPeopleVaccinated
From project..CovidDeaths C
Join project..CovidVaccinations V
	On C.location = V.location
	and C.date = V.date
where C.continent is not null 




