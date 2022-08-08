/* 
Cleaning Data in SQL 
*/
select *
from [Nashville Housing]..Sales

-----------------------------------------------------------------------------------------------------------------------------------
--Standardize the Date format

select saledate, CONVERT(date, saledate) AS SaleDateConverted
from [Nashville Housing]..Sales

--Alter the table to add a new column SaleDateConverted using the design option of SSMS
--Populate the new column

UPDATE [Nashville Housing]..Sales
SET SaleDateConverted = CONVERT(date, saledate)

select SaleDateConverted
From [Nashville Housing]..Sales


-------------------------------------------------------------------------------------------------------------------------------------------
--Populate the Property Address
select *
From [Nashville Housing]..Sales
--where PropertyAddress is null

select a.[UniqueID ], a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from [Nashville Housing]..Sales AS a
JOIN [Nashville Housing]..Sales AS b
	ON a.parcelID = b.parcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
from [Nashville Housing]..Sales AS a
JOIN [Nashville Housing]..Sales AS b
	ON a.parcelID = b.parcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--
select PropertyAddress
From [Nashville Housing]..Sales
--where PropertyAddress is null

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM [Nashville Housing]..Sales

ALTER TABLE [Nashville Housing]..Sales
ADD Address NVARCHAR(255)

UPDATE [Nashville Housing]..Sales
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Nashville Housing]..Sales
ADD City NVARCHAR(255)

UPDATE [Nashville Housing]..Sales
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select *
from [Nashville Housing]..Sales

--Split Owner Address 
select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Nashville Housing]..Sales

ALTER TABLE [Nashville Housing]..Sales
ADD OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255);

UPDATE [Nashville Housing]..Sales
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM [Nashville Housing]..Sales


--------------------------------------------------------------------------------------------------------------------------------------
--Convert Y and N to Yes/No in SoldAsVacant


SELECT Distinct(soldasvacant), count(soldasvacant)
from [Nashville Housing]..Sales
group by SoldAsVacant
order by count(soldasvacant)

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE soldasvacant
END
FROM [Nashville Housing]..Sales

UPDATE [Nashville Housing]..Sales
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE soldasvacant
END


-----------------------------------------------------------------------------------------------------------
--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition BY parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) AS row_num
from [Nashville Housing]..Sales
)
SELECT *
FROM RowNumCTE
where row_num > 1
order by PropertyAddress

-------------------------------------------------------------------------------------------------------------------
--Remove unused columns
SELECT *
FROM [Nashville Housing]..Sales

ALTER TABLE [Nashville Housing]..Sales
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict, PropertyCity