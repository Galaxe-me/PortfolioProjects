-- Checking if the dataset is fine
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY location, date;

-- Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths)/(total_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC;

-- Looking at total cases vs total deaths in my country
SELECT location, date, total_cases, total_deaths, (total_deaths)/(total_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Brazil'
AND continent IS NOT NULL
ORDER BY 1,2 DESC;

-- Show percentage of population who got COVID
SELECT location, date, population, total_cases, (total_cases)/(population)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC;

-- Country with highest infection rate compared to population
SELECT location, population, ISNULL(MAX(total_cases), 0) AS total_infection, ISNULL(MAX((total_cases)/(population)*100), 0) AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_infection DESC;

-- Countries with highest death count per population
SELECT location, population, MAX(cast(total_deaths as INT)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count DESC;

-- Breaking down by continent
SELECT location, population, ISNULL(MAX(cast(total_deaths as INT)), 0) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY total_death_count DESC;

-- Global numbers
SELECT date, ISNULL(SUM(total_cases), 0) AS TotalCases, ISNULL(SUM(cast(total_deaths as INT)), 0) AS TotalDeaths, 
ISNULL(SUM(cast(total_deaths as INT))/SUM(total_cases)*100, 0) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Checking pandemic control in countries
SELECT vac.location, ISNULL(MAX(CAST(total_tests as float)), 0) AS total_tests, ISNULL(MAX(CONVERT(INT, total_deaths)), 0) AS total_deaths,
(MAX(CAST(total_tests as float)))/(MAX(CONVERT(INT, total_deaths))) AS tests_per_death
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths	dea
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.location
ORDER BY total_tests, total_deaths;

-- Looking if exists a relationship between population density or gdp per capita and deaths
SELECT vac.location, ISNULL(MAX(CONVERT(INT, total_deaths)), 0) AS total_deaths, MAX(population_density) AS population_density,
MAX(gdp_per_capita) AS GDP_per_capita
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths	dea
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.location
ORDER BY total_deaths DESC;

-- Looking if a certain condition made it worse
SELECT population, MAX(cardiovasc_death_rate) AS cardiovasc, MAX(diabetes_prevalence) AS diabetes, 
MAX(female_smokers) AS female_smokers, MAX(male_smokers) AS male_smokers, MAX(CAST(total_deaths as int)) AS total_deaths
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths	dea
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY population
ORDER BY total_deaths DESC;

-- Looking if certain conditions helped to have less deaths
SELECT vac.location, MAX(ISNULL(handwashing_facilities, 0)) AS handwashin_facilities, 
MAX(hospital_beds_per_thousand) AS hospital_beds, MAX(CAST(total_deaths as int)) AS total_deaths
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths	dea
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.location
ORDER BY total_deaths DESC;

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, ISNULL(vac.new_vaccinations, 0) AS new_vaccinations,
ISNULL(SUM(CONVERT(int, vac.new_vaccinations)) OVER  (Partition by dea.location ORDER BY dea.date), 0) AS total_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, ISNULL(vac.new_vaccinations, 0) AS new_vaccinations,
ISNULL(SUM(CONVERT(int, vac.new_vaccinations)) OVER  (Partition by dea.location ORDER BY dea.date), 0) AS total_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, ISNULL((total_vaccinations)/(population)*100, 0) AS vaccinated_population
FROM PopvsVac;

-- Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER  (Partition by dea.location ORDER BY dea.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (total_vaccinations)/(population)*100 AS vaccinated_population
FROM #PercentPopulationVaccinated;

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER  (Partition by dea.location ORDER BY dea.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Checking the view
SELECT *
FROM PercentPopulationVaccinated

