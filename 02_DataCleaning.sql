-- Data cleaning project

-- Standarize Date Format


SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.NsvlHousing

UPDATE NsvlHousing
SET SaleDate=CONVERT(DATE,SaleDate)

ALTER TABLE NsvlHousing
ADD SaleDateConverted Date;

UPDATE NsvlHousing
SET SaleDateConverted=CONVERT(DATE,SaleDate)

-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NsvlHousing
--Where PropertyAddress is null
Order by ParcelID


-- # join 2x ta sama tabela

SELECT TL.ParcelID, TL.PropertyAddress, TR.ParcelID, TR.PropertyAddress, ISNULL(TL.PropertyAddress,TR.PropertyAddress)
FROM PortfolioProject.dbo.NsvlHousing TL
JOIN PortfolioProject.dbo.NsvlHousing TR
	ON TL.ParcelID=TR.ParcelID
	AND TL.[UniqueID ]<>TR.[UniqueID ]
WHERE TR.PropertyAddress is null

UPDATE TL
SET PropertyAddress= ISNULL(TL.PropertyAddress,TR.PropertyAddress)
FROM PortfolioProject.dbo.NsvlHousing TL
JOIN PortfolioProject.dbo.NsvlHousing TR
	ON TL.ParcelID=TR.ParcelID
	AND TL.[UniqueID ]<>TR.[UniqueID ]
WHERE TL.PropertyAddress is null


-- Breaking out address into Individual Columns (address, city, State)

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Adress,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NsvlHousing


ALTER TABLE PortfolioProject.dbo.NsvlHousing
ADD PropertySplitAddress nvarchar(255);


UPDATE PortfolioProject.dbo.NsvlHousing
SET PropertySplitAddress=SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE PortfolioProject.dbo.NsvlHousing
ADD PropertySplitCity nvarchar(255);


UPDATE PortfolioProject.dbo.NsvlHousing
SET PropertySplitCity=SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject.dbo.NsvlHousing

--splitting the owner adress:

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NsvlHousing


ALTER TABLE PortfolioProject.dbo.NsvlHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NsvlHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NsvlHousing
ADD OwnerSplitState nvarchar(255);


UPDATE PortfolioProject.dbo.NsvlHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE PortfolioProject.dbo.NsvlHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE PortfolioProject.dbo.NsvlHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)



-- Change Y/N in Yes/No in SoldAsVacant field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NsvlHousing
GROUP BY SoldAsVacant
ORDER  BY SoldAsVacant

UPDATE PortfolioProject.dbo.NsvlHousing
SET SoldAsVacant='Yes'
WHERE SoldAsVacant='Y'

UPDATE PortfolioProject.dbo.NsvlHousing
SET SoldAsVacant=
CASE 
	WHEN SoldAsVacant='N' THEN 'No'
	WHEN SoldAsVacant='Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NsvlHousing


-- REMOVE DUPLICATES


WITH CTE_rowNum AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY
	ParcelID,
	PropertyAddress,
	SaleDate,
	LegalReference,
	OwnerName
	ORDER BY UniqueID
	) AS rowNum
FROM PortfolioProject.dbo.NsvlHousing
)

SELECT *
FROM CTE_rowNum
Where rowNum>1
--ORDER BY OwnerName


-- delete unused columns

ALTER TABLE PortfolioProject.dbo.NsvlHousing
DROP COLUMN SaleDate
	
SELECT *
FROM PortfolioProject.dbo.NsvlHousing



