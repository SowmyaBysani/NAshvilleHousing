/* Cleaning data in SQL */
Select *
From [Data Cleaning].dbo.NashvilleHousing
------------------------------------------------------------------------
/* Standardize data Format */
Select SaleDate, CONVERT(Date,SaleDate)
From [Data Cleaning].dbo.NashvilleHousing

ALTER table NashvilleHousing
ADD SaledateCon date;

Update NashvilleHousing
SET SaledateCon = CONVERT(date, SaleDate)
-
-----------------Populate property address----------------
/* Writing a select query to understand how to populate the address*/
Select *
From [Data Cleaning].dbo.NashvilleHousing
order by parcelID  /* Observe the data and you will find identical parcel id's where one of them didn't have the propert address*/


/* Creating a temporary column which helps in populating the Propertyaddress */
Select a.ParcelID, a.PropertyAddress,  b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning].dbo.NashvilleHousing a
join [Data Cleaning].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is NULL

/* Updating the table by replacing the existing a.PropertyAddress column with the temp column created */
UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning].dbo.NashvilleHousing a
join [Data Cleaning].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is NULL

/* Check the updated table */
Select *
From [Data Cleaning].dbo.NashvilleHousing
where PropertyAddress is null

---------------------Breaking out address into Individual Columns(Address, City, State)---------------------
/* Checking at what position the , is present int he column */
Select 
CHARINDEX(',', PropertyAddress)
From [Data Cleaning].dbo.NashvilleHousing

 /*-1 is wriiten in the Charindex because we can eliminate the ',' in the output */

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
 SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
From [Data Cleaning].dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 
From [Data Cleaning].dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update Nashvillehousing
 Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) 
From [Data Cleaning].dbo.NashvilleHousing

-------------Owner Address-------------------------
Select OwnerAddress
From [Data Cleaning].dbo.NashvilleHousing

/* logic for splitting the owners adress into adress,city, state */
Select PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From [Data Cleaning].dbo.NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 
From [Data Cleaning].dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) 
From [Data Cleaning].dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From [Data Cleaning].dbo.NashvilleHousing

------------------Change Y and N to Yes and No in Sold as Vacant field----------------

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From [Data Cleaning].dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' Then 'Yes'
 when SoldAsVacant = 'N' then'No'
else SoldAsVacant
END
From [Data Cleaning].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
 when SoldAsVacant = 'N' then'No'
else SoldAsVacant
END
From [Data Cleaning].dbo.NashvilleHousing 

-----------Remove Duplicates--------------------

WITH RowCTE AS(
Select *,
ROW_NUMBER() OVER (
Partition by  ParcelID,PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER  BY UniqueID) row_num
From [Data Cleaning].dbo.NashvilleHousing 
)


Delete
From RowCTE
where row_num>1

--------------------------DELETE UNUSED COLUMN-------------------
Alter table [Data Cleaning].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
Alter table [Data Cleaning].dbo.NashvilleHousing
DROP COLUMN SaleDate