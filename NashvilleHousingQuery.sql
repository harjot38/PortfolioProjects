/* 
	Data Cleaning of Nashville Housing Database
*/

Select * from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------


--- Standardize / Change Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing


Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------------------------------

--- Populate Property Address Data

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
	Join PortfolioProject..NashvilleHousing as b
		On a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
	Join PortfolioProject..NashvilleHousing as b
		On a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]


---------------------------------------------------------------------------

--- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select * from PortfolioProject..NashvilleHousing

Select OwnerAddress from PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



Select * from PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------

--- Change Y and N to Yes and No in 'SoldAsVacant'

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order by 2


Select SoldAsVacant, 
CASE when SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END

Select SoldAsVacant 
From NashvilleHousing


---------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE As (
Select *, 
		ROW_NUMBER() 
		OVER (
			PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID
			) as row_num
from PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Delete 
From RowNumCTE
where row_num > 1
--order by PropertyAddress

Select * from PortfolioProject..NashvilleHousing



---------------------------------------------------------------------------

-- Delete Unused Columns

Select * from PortfolioProject..NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate