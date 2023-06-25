/* 

Cleaning Data in SQL Queries

*/

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashsvilleHousing

UPDATE NashsvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE PortfolioProject.dbo.NashsvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashsvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashsvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashsvilleHousing as a
JOIN PortfolioProject.dbo.NashsvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashsvilleHousing as a
JOIN PortfolioProject.dbo.NashsvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashsvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashsvilleHousing

ALTER TABLE PortfolioProject.dbo.NashsvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashsvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.NashsvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashsvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject.dbo.NashsvilleHousing


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashsvilleHousing

SELECT
parsename(Replace(OwnerAddress, ',', '.'), 3)
, parsename(Replace(OwnerAddress, ',', '.'), 2)
, parsename(Replace(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashsvilleHousing


ALTER TABLE PortfolioProject.dbo.NashsvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashsvilleHousing
SET OwnerSplitAddress = parsename(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashsvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashsvilleHousing
SET OwnerSplitCity = parsename(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashsvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashsvilleHousing
SET OwnerSplitState = parsename(Replace(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashsvilleHousing
GROUP BY SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashsvilleHousing

UPDATe PortfolioProject.dbo.NashsvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashsvilleHousing
--ORDER BY ParcelID
)
Delete
FROM RowNumCTE
Where row_num >1


-- Delete Unused Columns (don't do this to raw data)

SELECT *
FROM PortfolioProject.dbo.NashsvilleHousing

ALTER TABLE PortfolioProject.dbo.NashsvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashsvilleHousing
DROP COLUMN SaleDate