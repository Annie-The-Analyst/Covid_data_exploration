--Global summary of total new cases, total deaths and death percentage if infected with Covid

Select SUM(new_cases) as Total_NewCase, 
	   SUM(cast(new_deaths as int)) as Total_NewDeath, 
	   SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Where  continent is not null
Order by 1,2


--The highest death count each continent

Select continent, MAX(cast(total_deaths as int) ) as TotalDeath
From PortfolioProject..['Covid Deaths$']
Where continent is not null
Group by continent
Order by TotalDeath desc


--Canada's percentage of death if infected with Covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Where location ='Canada' and continent is not null
Order by 2


--America's percentage of population infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..['Covid Deaths$']
Where location like '%states%' and continent is not null
order by date


--Highest infection percentage compared to population for each country

Select location, population, MAX(total_cases) as HighestInfection, (MAX(total_cases) / population )*100 as InfectionPercentage
From PortfolioProject..['Covid Deaths$']
Where continent is not null
Group by location, population
Order by 4 desc


--Top 10 countries with highest death count per population

Select * 
From (
	Select location,max(cast(total_deaths as int)) as Max_totaldeath, 
	DENSE_RANK() over (order by max(cast(total_deaths as int)) desc) rank
	From PortfolioProject..['Covid Deaths$']
	Where continent is not null
	Group by location) a
 Where rank <=10

 --Canada's running total vaccinations count for people received at least one vaccine

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as Rollingvaccinated
From PortfolioProject..['Covid Deaths$'] dea
join PortfolioProject..['Covid Vaccinations$'] vac
ON  dea.location = vac.location and dea.date=vac.date
Where dea.continent is not null and dea.location ='Canada'
Order by 2, 3


--Country's percentage of population that people received at least one vaccine

With Vacpercentage (continent, location, date, population, new_vaccinations, Rollingvaccinated)
as
	(Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinated
	From PortfolioProject..['Covid Deaths$'] dea
	join PortfolioProject..['Covid Vaccinations$'] vac
	ON  dea.location = vac.location 
	and dea.date=vac.date
	Where dea.continent is not null 
	)
Select * , (rollingvaccinated/population)*100  as vaccinationspercentage
From Vacpercentage

--Top 100 countries' percentage of population that people fully vaccinations

Drop table if exists Fullyvaccinated
Create Table Fullyvaccinated
( 
continent nvarchar(255), 
location nvarchar (255),
population numeric, 
fullyvaccinated numeric
)
Insert into Fullyvaccinated
 	Select dea.continent, dea.location, dea.population, max(convert(bigint, vac.people_fully_vaccinated)) as fullyvaccinated
	From PortfolioProject..['Covid Deaths$'] dea
	join PortfolioProject..['Covid Vaccinations$'] vac
	ON  dea.location = vac.location 
	and dea.date=vac.date
	Where dea.continent is not null 
	Group by dea.continent, dea.location, dea.population
	Order by dea.continent, dea.location

Select top 100 * , (fullyvaccinated/population) *100 as fullvaccinationspercentage
From Fullyvaccinated
Order by fullvaccinationspercentage desc
