-- Cleaning data in queries 


Select *
From Portfolio_Project.dbo.NashvilleHousing


--Standardize the sale date

Select SaleDateConverted, CONVERT(Date,SaleDate)
From Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate property address

Select *
From Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out Address into columns (Address, City, State)
Select *
From Portfolio_Project.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Portfolio_Project.dbo.NashvilleHousing





Select OwnerAddress
From Portfolio_Project.dbo.NashvilleHousing

Select
PARSENAME (Replace(OwnerAddress, ',' , '.'), 3),
PARSENAME (Replace(OwnerAddress, ',' , '.'), 2),
PARSENAME (Replace(OwnerAddress, ',' , '.'), 1)
From Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add  OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress, ',' , '.'), 3)

ALTER TABLE NashvilleHousing
Add  OwnerSplitCity  Nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitCity  = PARSENAME (Replace(OwnerAddress, ',' , '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitState = PARSENAME (Replace(OwnerAddress, ',' , '.'), 1)


--Select *
--From Portfolio_Project.dbo.NashvilleHousing


-- Change Y and N to Yes and NO

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
From Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET  SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END


-- REMOVE DUPLICATES
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

From Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress





--Delete Unused Columns
Select *
From Portfolio_Project.dbo.NashvilleHousing

Alter Table Portfolio_Project.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio_Project.dbo.NashvilleHousing
Drop Column SaleDate