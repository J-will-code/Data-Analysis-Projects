--To view the database tables:
SELECT * 
FROM SELECT * 
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
Order by 3,4

SELECT * 
FROM COVID_19_database..COVID_Vaccinations
WHERE continent is not null
Order by 3,4

--***********************************
--Data that will be used:

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
ORDER BY 1,2

----Total cases vs Total deaths for Jamaica
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Infection_Rate
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
WHERE location like '%Jamaica%'
ORDER BY 1,2

----Total Cases vs Population for Jamaica
SELECT location, date, total_cases, population, (total_cases/population)*100 as Infection_rate 
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
WHERE location like 'Jamaica'
ORDER BY 1,2

--Countries with the highest infection rate compared to the population 
SELECT location, population, MAX(total_cases) as Highest_infection_cases, MAX(total_cases/population)*100 as Max_Infected_rate
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
--WHERE location like 'Jamaica'
GROUP BY location, population
ORDER BY Max_Infected_rate desc

--Countries with highest death count per population 
SELECT location, MAX(CAST(total_deaths as int)) as 'Max death count'
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
GROUP BY location
ORDER BY 'Max death count' desc


--Showing continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) as 'Max death count'
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY 'Max death count' desc

--Global scales

----Total cases vs Total deaths Globally
SELECT date, SUM(new_cases) as 'Daily global cases', SUM(Cast(new_deaths as int)) as 'Daily new deaths',
SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as 'Death percentage'--, total_deaths, (total_deaths/total_cases)*100 as Death_Infection_Rate
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

----Total cases vs Total deaths Globally to date
SELECT SUM(new_cases) as 'global cases', SUM(Cast(new_deaths as int)) as 'Global deaths',
SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as 'Death percentage'--, total_deaths, (total_deaths/total_cases)*100 as Death_Infection_Rate
FROM COVID_19_database..COVID_Deaths
WHERE continent is not null
ORDER BY 1,2




----COVID VACCINATIONS----

SELECT * 
FROM COVID_19_database..COVID_Vaccinations

---JOINS: looking at total population vs vaccination---
With POPvsVAC (continent, location, date, population, new_vaccinations, Rolling_count_vaccinations )
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_count_vaccinations
FROM COVID_19_database..COVID_Deaths dea
join COVID_19_database..COVID_Vaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Rolling_count_vaccinations/population)*100
FROM POPvsVAC



--TEMP TABLE--
DROP table if exists Percentage_Vaccinated
CREATE TABLE Percentage_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_count_vaccinations numeric
)

INSERT INTO Percentage_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) as Rolling_count_vaccinations
FROM COVID_19_database..COVID_Deaths dea
join COVID_19_database..COVID_Vaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date

SELECT *, (Rolling_count_vaccinations/population)*100 as Rolling_count_vaccinations_rate
FROM Percentage_Vaccinated


--Creating view for the Visualization--
 ALTER view PercentageVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) as Rolling_count_vaccinations
FROM COVID_19_database..COVID_Deaths dea
join COVID_19_database..COVID_Vaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent is not null 
