# Define the source and destination folders
$sourceFolder = "C:\Users\suppo\Downloads"
$destinationFolder = "D:\GitHub\Powershell\kite"
$destinationFileName = "holdings.csv"
$profitFilePath = "D:\GitHub\Powershell\kite\profit.csv"

# Find the latest file with the pattern holdings*.csv in the source folder
$latestFile = Get-ChildItem -Path $sourceFolder -Filter "holdings*.csv" |
              Sort-Object LastWriteTime -Descending |
              Select-Object -First 1

# Check if a file was found
if (-not $latestFile) {
    Write-Output "No matching file found in $sourceFolder. Aborting process."
    exit
}

# Define the destination path
$destinationPath = Join-Path -Path $destinationFolder -ChildPath $destinationFileName

# Move the file and rename it, overwriting if it already exists
Move-Item -Path $latestFile.FullName -Destination $destinationPath -Force
Write-Output "Moved $($latestFile.Name) to $destinationPath"

# Import CSV and calculate total profit, total P&L, invested value, and current value
$totalPnL = 0
$investedValue = 0
$currentValue = 0
$processedCount = 0
$holderName = "UNKNOWN"  # Default holder name

# Read the CSV file
$csvData = Import-Csv -Path $destinationPath

# Determine the holder name based on instrument presence
if ($csvData.Instrument -contains "RAJMET-BE") {
    $holderName = "Navneeth"
} elseif ($csvData.Instrument -contains "VIKASECO") {
    $holderName = "Kaushik"
} elseif ($csvData.Instrument -contains "IDEA") {
    $holderName = "Ramesh"
}

# Read the list of instruments to exclude, trim whitespace, and convert to lowercase
$excludeFilePath = "D:\GitHub\Powershell\kite\exclude_$holderName.txt"
$excludeList = Get-Content -Path $excludeFilePath | ForEach-Object { $_.Trim().ToLower() }


# Filter out the records of excluded instruments
$filteredData = @()

foreach ($row in $csvData) {
    # Extract relevant fields and convert them to numbers
    $instrument = $row.Instrument.Trim().ToLower()  # Trim and convert to lowercase
    $qty = [double]$row.'Qty.'
    $avgCost = [double]$row.'Avg. cost'
    $ltp = [double]$row.LTP
    $curVal = [double]$row.'Cur. val'
    $dayChg = [double]$row.'Day chg.'
    $pnl = [double]$row.'P&L'

    # Check if the instrument is in the exclude list (case-insensitive)
    if ($excludeList -contains $instrument) {
        Write-Output "Skipping instrument $($row.Instrument) as it is in the exclude list."
        continue
    }
    

    # Add profit to the total profit

    # Add P&L to the total P&L
    $totalPnL += $pnl

    # Calculate and add to the invested value and current value
    $investedValue += $qty * $avgCost
    $currentValue += $qty * $ltp

    # Increment the processed count
    $processedCount++

    # Add the row to the filtered data
    $filteredData += $row
}

# Output the total profit, P&L, invested value, current value, and number of instruments processed
Write-Output "Total Profit for all instruments for holder $($holderName): $totalProfit"
Write-Output "Total P&L for all instruments: $totalPnL"
Write-Output "Invested Value: $investedValue"
Write-Output "Current Value: $currentValue"
Write-Output "Total number of instruments processed: $processedCount"

# Get the current date in the format 'dd-MMM-yyyy'
$currentDate = Get-Date -Format "dd-MMM-yyyy"

# Prepare the data to append
$record = [pscustomobject]@{
    Date            = $currentDate
    'Holder name'   = $holderName
    'Invested Value' = $investedValue
    'Current Value'  = $currentValue
    'Total P&L'     = $totalPnL
}

# Append the result to the profit.csv file
if (Test-Path -Path $profitFilePath) {
    $record | Export-Csv -Path $profitFilePath -Append -NoTypeInformation
} else {
    $record | Export-Csv -Path $profitFilePath -NoTypeInformation
}

# Remove excluded instruments from holdings.csv and rename the file
$filteredFileName = "holdings_$holderName.csv"
$filteredFilePath = Join-Path -Path $destinationFolder -ChildPath $filteredFileName

# Export the filtered data to the new file
$filteredData | Export-Csv -Path $filteredFilePath -NoTypeInformation
Write-Output "Saved filtered data to $filteredFilePath"

# Wait for Enter key press before closing
Read-Host "Press Enter to exit"
