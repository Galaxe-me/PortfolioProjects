-- Looking the dataset
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-- Standardize date format
SELECT SaleDate, CAST(SaleDate as date) AS SaleDateFormat
FROM PortfolioProject.dbo.NashvilleHousing;

-- Changing the data type in the table
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Checking null data in PropertyAddress column
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null;

-- Looking into patterns to replace the nulls
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID;

-- Replacing the PropertyAddress null data
SELECT HousingA.ParcelID, HousingA.PropertyAddress, HousingB.ParcelID, HousingB.PropertyAddress,
ISNULL(HousingA.PropertyAddress, HousingB.PropertyAddress) AS NewHousingAddress
FROM PortfolioProject.dbo.NashvilleHousing	HousingA
JOIN PortfolioProject.dbo.NashvilleHousing	HousingB
	ON HousingA.ParcelID = HousingB.ParcelID
	AND HousingA.[UniqueID] <> HousingB.[UniqueID]
WHERE HousingA.PropertyAddress is null

UPDATE HousingA
SET PropertyAddress = ISNULL(HousingA.PropertyAddress, HousingB.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing	HousingA
JOIN PortfolioProject.dbo.NashvilleHousing	HousingB
	ON HousingA.ParcelID = HousingB.ParcelID
	AND HousingA.[UniqueID] <> HousingB.[UniqueID]

-- Checking if the code worked
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null;

-- Breaking out Address into individual columns (address, city)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

-- Getting the address,city and state from the owner
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS city
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

-- Change Y an N to Yes and No in "Sold as Vacant"
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

-- Remove duplicates
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
					ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

-- Delete unused columns
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate, TaxDistrict, PropertyAddress;


-- CALCULATIONS!!
--Average Sale in Nashville
SELECT AVG(SalePrice) AS AveragePriceNashville
FROM PortfolioProject.dbo.NashvilleHousing;

-- Average "building cost"
SELECT AVG(TotalValue) AS AverageValueNashville
FROM PortfolioProject.dbo.NashvilleHousing;

-- Average gross profit and profit margin in Nashville
SELECT AVG(SalePrice) - AVG(TotalValue) AS AverageGrossProfit,
(AVG(SalePrice) - AVG(TotalValue))/(AVG(SalePrice))*100 AS AverageProfitMargin
FROM PortfolioProject.dbo.NashvilleHousing;

-- Average Sale Price per city
SELECT AVG(SalePrice) AS AveragePrice, PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY PropertySplitCity
ORDER BY 1;

-- Deleting the unknown row
DELETE
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertySplitCity LIKE 'UNKNOWN'

-- Total Sales per year
ALTER TABLE NashvilleHousing
ADD SaleYear INT;

UPDATE NashvilleHousing
SET SaleYear = YEAR(SaleDateConverted);

SELECT COUNT(*) AS total_sales, SaleYear
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SaleYear
ORDER BY 1 DESC;

-- Checking sasonal sales per month
ALTER TABLE NashvilleHousing
ADD SaleMonth INT;

UPDATE NashvilleHousing
SET SaleMonth = MONTH(SaleDateConverted);

SELECT COUNT(*) AS total_sales, SaleMonth
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SaleMonth
ORDER BY 1 DESC;

--Calculating the average sales gross profit per city
SELECT AVG(SalePrice) - AVG(TotalValue)  AS GrossProfit,
PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY PropertySplitCity
ORDER BY 1;

-- Calculating the average profit margin per city
SELECT (AVG(SalePrice) - AVG(TotalValue))/(AVG(SalePrice))*100  AS ProfitMargin,
PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY PropertySplitCity
ORDER BY 1;

-- Checking the buildings rotativity
SELECT COUNT(*) AS Counting, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY PropertySplitAddress, PropertySplitCity
ORDER BY 1 DESC;

-- Checking the most used land type
SELECT COUNT(*) AS Counting, LandUse
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY LandUse
ORDER BY 1 DESC;