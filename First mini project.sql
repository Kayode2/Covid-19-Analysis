Select *
From PortfolioProject..CovidDeaths
Where Continent is not null
Order By 3,4

 --Select *
 --From PortfolioProject..CovidVaccinations
 --Order By 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where Continent is not null
Order by 1,2

-- Looking at Total cases vs total Deaths
-- Shows the the likelihood of contracting the virus

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location = 'Nigeria' and Continent is not null -- Where location like '%States%%'
Order by 1,2

-- Looking at Total cases vs Population
-- Shows the % of the population that got Covid

Select Location, date, Population, total_cases, (total_cases/Population) * 100 as PercentPopulationinfected
From PortfolioProject..CovidDeaths
-- Where location = 'Nigeria' -- Where location like '%States%%'
Order by 1,2

-- Looking at countries with Highest infection rate compared to production

Select Location, Population, MAX(Total_cases) as HighestInfestationCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by location, population
order by  PercentPopulationInfected desc 
 
 -- Showing countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by location
order by TotalDeathCount desc 
 

 -- Let's break things down by continent

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--Where Continent is null
--Group by location
--order by TotalDeathCount desc 

-- showing the continent with the highest deathcount

 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by continent
order by TotalDeathCount desc 

-- Global Numbers
-- This is recording number of deaths per day
Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/Sum(New_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by date
order by 1,2

-- Total number of deaths overall
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/Sum(New_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null
--Group by date
order by 1,2
  
Select *
From PortfolioProject..CovidVaccinations

-- Looking at Total Population Vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location -- or we can use >>, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location)
, dea.Date) as RollingPeoplevaccinated 
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- RollingPeoplevaccinated is a new created column and can not be used immediately for another calculation
-- We can either use CTE or Temp Table

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location
, dea.Date as RollingPeoplevaccinated) 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3
)
Select *, (RollingPeoplevaccinated/Population)*100
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location
, dea.Date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeoplevaccinated/Population)*100
From #PercentPopulationVaccinated


--Create View to store data for later visualization


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location
, dea.Date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated





