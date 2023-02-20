select * from [Data Analytics].dbo.['covid-death$'] where continent is not null;

select * from [Data Analytics].dbo.['covid-vactination-data$'] order by 3,4;

--select data that we are going to using 

select [location],[date],total_cases,new_cases,total_deaths,[population] from [Data Analytics].dbo.['covid-death$'] order by 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
select [location],[date],total_cases,total_deaths,(total_cases/total_deaths)*100 as DeathPercentage from [Data Analytics].dbo.['covid-death$'] 
where location like 'India%'
order by 1,2;

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
select [location],[date],[population],total_cases,(total_cases/[population])*100 as PercentPopulationInfected from [Data Analytics].dbo.['covid-death$'] 
where location like 'India%' 
order by 1,2;

--Looking at Countries with Highest Infection Rate compared to Population
select [location],[population],MAX(total_cases) as HighestInfectionCount,MAX(total_cases/[population])*100 as PercentPopulationInfected from [Data Analytics].dbo.['covid-death$'] 
--where location like 'India%' 
Group by [location],[population]
order by PercentPopulationInfected desc;

--Break things down by continent

--Showing continent with the highest death count per population
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount from [Data Analytics].dbo.['covid-death$'] where continent is not null
Group by continent
order by TotalDeathCount desc;

--Globel numbers 
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage from 
[Data Analytics].dbo.['covid-death$'] where continent is not null order by 1,2


--Looking at Total Populatino vs Vaccinations
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by death.location ORDER BY death.location,death.date) as RollingPeopleVaccination
from [Data Analytics].dbo.['covid-death$'] death join [Data Analytics].dbo.['covid-vactination-data$'] vac on
death.location=vac.location 
and death.date=vac.date 
where death.continent is not null
order by 1,2,3


--Use CTE
WITH PopvsVac(continent,Location,Date,population,new_vaccinations,RollingPeopleVaccination)
as
(
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by death.location ORDER BY death.location,death.date) as RollingPeopleVaccination
from [Data Analytics].dbo.['covid-death$'] death join [Data Analytics].dbo.['covid-vactination-data$'] vac on
death.location=vac.location 
and death.date=vac.date 
where death.continent is not null
--order by 1,2
)
select *,(RollingPeopleVaccination/population)*100 from PopvsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
Create table  #PercentPopulationVaccinated
(
Continent varchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)

insert into #PercentPopulationVaccinated
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by death.location ORDER BY death.location,death.date) as RollingPeopleVaccination
from [Data Analytics].dbo.['covid-death$'] death join [Data Analytics].dbo.['covid-vactination-data$'] vac on
death.location=vac.location 
and death.date=vac.date 
select *,(RollingPeopleVaccination/population)*100 from #PercentPopulationVaccinated


--Create View to store data for later visualizations
Create View PercentPopulationVaccinated as 
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by death.location ORDER BY death.location,death.date) as RollingPeopleVaccination
from [Data Analytics].dbo.['covid-death$'] death join [Data Analytics].dbo.['covid-vactination-data$'] vac on
death.location=vac.location 
and death.date=vac.date 
where death.continent is not null
--order by 1,2


SELECT * FROM PercentPopulationVaccinated;