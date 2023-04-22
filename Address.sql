/* Cleaning Data */
Select *
From DataCleaning.dbo.Address$

-- standardize Date Format in Sales


Select saleDateConverted, CONVERT(Date, SaleDate)
From DataCleaning.dbo.Address$

Update Address$
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table Address$
Add SaleDateConverted Date;

Update Address$
Set SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Blank Property Address data
Select *
From DataCleaning.dbo.Address$
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning.dbo.Address$ a
Join DataCleaning.dbo.Address$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning.dbo.Address$ a
Join DataCleaning.dbo.Address$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From DataCleaning.dbo.Address$

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address 
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From DataCleaning.dbo.Address$


Alter Table Address$
Add PropertySplitAddress Nvarchar(255);
Update Address$
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)


Alter Table Address$
Add PropertySplitCity Nvarchar(255);
Update Address$
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select OwnerAddress
From DataCleaning.dbo.Address$

Select
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
,PARSENAME(Replace(OwnerAddress, ',','.'), 2)
,PARSENAME(Replace(OwnerAddress, ',','.'), 1)
From DataCleaning.dbo.Address$


Alter Table Address$
Add OwnerSplitAddress Nvarchar(255);
Update Address$
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)


Alter Table Address$
Add OwnerSplitCity Nvarchar(255);
Update Address$
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

Alter Table Address$
Add OwnerSplitState Nvarchar(255);
Update Address$
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

Select *
From DataCleaning.dbo.Address$


--Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaning.dbo.Address$
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From DataCleaning.dbo.Address$


Update Address$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--remove duplicates
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

From DataCleaning.dbo.Address$
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From DataCleaning.dbo.Address$


--delete unused columns
Select *
From DataCleaning.dbo.Address$


ALTER TABLE DataCleaning.dbo.Address$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
