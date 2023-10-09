--What % of population infected due to covid
SELECT Location,date, population,total_cases, 
(total_cases/population) as InfectedPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--looking at countries with highest infection rate 
select location, date, MAX(total_cases)
From PortfolioProject..CovidDeaths
order by 1


--Countries with max affected population
SELECT Location, Population, MAX(total_cases) as highest,
MAX((total_cases/population)*100 )as MaxPopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location,Population 
order by MaxPopulationInfectedPercentage desc


--Showing countries with highest death count
SELECT  location, population, MAX(CAST(total_deaths as bigint)) as totDeaths,
MAX(CAST(total_deaths as bigint)*100/population) as maxDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY  totDeaths desc

--show highest death % in continents
select continent, MAX(CAST(total_deaths as bigint)) as highestDeaths
FROM PortfolioProject..CovidDeaths
where continent is not null 
GROUP BY continent
ORDER BY highestDeaths desc
--------------------------------------------------------------------------------------------

--total population vs vaccinated
SELECT deaths.continent,deaths.location,deaths.date,deaths.population,
vac.new_vaccinations
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null 
	ORDER BY 2,3

--count of vaccinations till given date
select deaths.continent, deaths.location, deaths.date, deaths.population,
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location order by deaths.date) as total_vaccinated_till_date
from PortfolioProject..CovidDeaths deaths
JOIN  PortfolioProject..CovidVaccinations vac
on deaths.location=vac.location 
and deaths.date = vac.date
order by 2,3



-- % of populated vaccinated till date USING CTE (Common table expressions)
With people_vaccinated (continent, location, date, population,new_vaccinations, total_vaccinated_till_date)
 as
(select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location order by deaths.date) as total_vaccinated_till_date
from PortfolioProject..CovidDeaths deaths
JOIN  PortfolioProject..CovidVaccinations vac
on deaths.location=vac.location 
and deaths.date = vac.date
)
select *, (CAST(total_vaccinated_till_date*100/population as decimal)) as PercentVaccinated
from people_vaccinated

 

 -----creating view for later visualization

create view percentPopulated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location order by deaths.date) as total_vaccinated_till_date
from PortfolioProject..CovidDeaths deaths
JOIN  PortfolioProject..CovidVaccinations vac
on deaths.location=vac.location 
and deaths.date = vac.date