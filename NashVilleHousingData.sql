

/*Data Cleaning using SQL Queries...
This project is inspired by a blog https://deepnote.com/@ansonnn/Nashville-Housing-Data-Cleaning-xd4MYPwNTmeiK-PnC5KXHg 
where in the Data cleaning was done in Python and I tried doing it in SQL
*/


select * 
from [SQLDataCleaningProject].[dbo].[NashVilleHousing]


-------Standardizing the DateFormat-----
select SaleDate
from [SQLDataCleaningProject].[dbo].[NashVilleHousing]

select SaleDate, CONVERT(Date, SaleDate) as Formatted_saledate
from [SQLDataCleaningProject].[dbo].[NashVilleHousing]

ALTER TABLE [NashVilleHousing]
ALTER COLUMN SaleDate Date



----Populate Property Address data--------
/*There are few rows where in Property Address is NULL, 
Property address will be same if ParcelID is same.*/

---let's fill in Property Address data where ParcelID is same---
Select UniqueID, ParcelID, PropertyAddress
from [SQLDataCleaningProject].[dbo].[NashVilleHousing]


---Using self join ---------
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress) as updated_address
FROM [SQLDataCleaningProject].[dbo].[NashVilleHousing] a
join [SQLDataCleaningProject].[dbo].[NashVilleHousing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [SQLDataCleaningProject].[dbo].[NashVilleHousing] a
join [SQLDataCleaningProject].[dbo].[NashVilleHousing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


select * from [SQLDataCleaningProject].[dbo].[NashVilleHousing]



--Breaking down address into individual columns (Address, city, state)--------
----------Using SUBSTRING & CHARINDEX------------
select PropertyAddress
from [SQLDataCleaningProject].[dbo].[NashVilleHousing]

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, 
LEN(PropertyAddress)) AS Address
FROM [SQLDataCleaningProject].[dbo].[NashVilleHousing]

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, 
LEN(PropertyAddress))



--Breaking down OwnerAddress into individual columns (Address, city, state)--------
----Using PARSENAME---
select OwnerAddress from [SQLDataCleaningProject].[dbo].[NashVilleHousing]

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [SQLDataCleaningProject].[dbo].[NashVilleHousing]

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From [SQLDataCleaningProject].[dbo].[NashVilleHousing]



-----Change Y and N to Yes and No in "Sold as Vacant" field-------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [SQLDataCleaningProject].[dbo].[NashVilleHousing]
Group by SoldAsVacant
order by 2

/*Output:
Y - 52
N - 399
Yes - 4623
No - 51403*/

SELECT SoldAsVacant 
, CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END
From [SQLDataCleaningProject].[dbo].[NashVilleHousing]

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




----- Remove Duplicates-----------

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From [SQLDataCleaningProject].[dbo].[NashVilleHousing]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From [SQLDataCleaningProject].[dbo].[NashVilleHousing]




-- Delete Unused Columns----------
Select *
From [SQLDataCleaningProject].[dbo].[NashVilleHousing]


ALTER TABLE [SQLDataCleaningProject].[dbo].[NashVilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate