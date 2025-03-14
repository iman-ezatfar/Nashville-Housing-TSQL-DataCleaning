/*
Cleaning Data
*/


----------------------------------


SELECT *
FROM PortfolioProjects..NashvilleHousing

-------------------------------------


-- Standardize Date Format

SELECT SaleDate, CONVERT(date,saledate)
FROM PortfolioProjects..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

Update NashvilleHousing
SET SaleDateconverted = CONVERT(Date,SaleDate)


SELECT SaleDateConverted, CONVERT(date,saledate)
FROM PortfolioProjects..NashvilleHousing

------------------------------------------


-- Populate the Property Address Data


SELECT *
FROM PortfolioProjects..NashvilleHousing
WHERE PropertyAddress is null

--------------------------------------------


-- With some analysis we understand that when the ParcelId is same in two rows, the Property address must be the same
-- So we can Self join the table !!! Prevent repetation !!!

SELECT t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing t1
JOIN PortfolioProjects..NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress is null


UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing t1
JOIN PortfolioProjects..NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress is null

---------------------------------------------


-- Now we run the query again to see whether it shows any NULL value in property address or not (Should show nothing)

SELECT t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing t1
JOIN PortfolioProjects..NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress is null


-- Worked Perfectly!


-------------------------------------

-- Now it is time to break the address into seeparate columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProjects..NashvilleHousing

-- OR
/*
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, 
              LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) AS City
FROM PortfolioProjects..NashvilleHousing;
*/

------------------------------------------


-- Now we add these columns into our table

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255)

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProjects..NashvilleHousing

-------------------------------------------


-- Cleaning Owner Address column

SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) AS OwnerSplitAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) AS OwnerCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) AS OwnerState
FROM
	NashvilleHousing


--OR
/*
SELECT
    SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1) AS OwnerSplitAddress,
    SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, 
               CHARINDEX(',', OwnerAddress,CHARINDEX(',', OwnerAddress)+1) - CHARINDEX(',', OwnerAddress)-1) AS OwnerCity,
	SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress)+1)+1,
				LEN(OwnerAddress)-CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress)+1))AS OwnerState
FROM PortfolioProjects..NashvilleHousing;
*/


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(255)

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(255)

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

SELECT *
FROM NashvilleHousing


-------------------------------------------------------


-- Changing Y/N in  "Sold as vacant" Column to Yes/No

SELECT 
    CASE 
        WHEN SoldAsVacant = 'N' THEN 'No' 
        WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	ELSE SoldAsVacant
    END AS SoldAsVacantStatus
FROM NashvilleHousing;

SELECT DISTINCT(SoldAsVacant), COUNT(soldasvacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


UPDATE NashvilleHousing
SET SoldAsVacant = 
	    CASE 
        WHEN SoldAsVacant = 'N' THEN 'No' 
        WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	ELSE SoldAsVacant
    END
FROM NashvilleHousing;


------------------------------------


--Remove Duplicates


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	ORDER BY		
					UniqueID
	) row_num
FROM NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE ROW_Num > 1


-----------------------------------------


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
	ORDER BY		
					UniqueID
	) row_num
FROM NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE ROW_Num > 1


-------------------------------------


--Delete Unused Columns

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN	OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN	SaleDate


SELECT *
FROM NashvilleHousing
