# Define the path to the folder containing the text files
$folderPath = "C:\Users\suppo\Downloads\xtream"

# Get all text files in the specified folder
$textFiles = Get-ChildItem -Path $folderPath -Filter *.txt

# Function to get the content size of a URL by downloading the content
function Get-ContentSize {
    param (
        [string]$url
    )
    try {
        # Use Invoke-WebRequest to get the content
        $response = Invoke-WebRequest -Uri $url -ErrorAction Stop
        # Return the size of the content in bytes
        return $response.Content.Length
    } catch {
        Write-Host "Failed to access $url"
        return 0
    }
}

# Loop through each file in the folder
foreach ($file in $textFiles) {
    Write-Host "Processing file: $($file.FullName)"
    
    # Initialize an array to hold URL details for the current file
    $urlDetails = @()

    # Read the file and extract full URLs containing 'get.php'
    $urls = Select-String -Path $file.FullName -Pattern "http[s]?://[^ ]*get\.php[^ ]*" | ForEach-Object { $_.Matches.Value }

    # Loop through each URL, get its content size and store details
    foreach ($url in $urls) {
        Write-Host -NoNewline "  Processing URL: $url......."
        $sizeBytes = Get-ContentSize -url $url
        $sizeMB = [math]::Round($sizeBytes / 1MB, 2)
        Write-Host "Size is : $sizeBytes bytes ($sizeMB MB)"
        
        # Store the URL and its size details
        $urlDetails += [PSCustomObject]@{
            URL        = $url
            SizeBytes  = $sizeBytes
            SizeMB     = $sizeMB
        }
    }

    # Sort the URLs by size in descending order
    $sortedUrlDetails = $urlDetails | Sort-Object -Property SizeBytes -Descending

    # Define the output CSV file path based on the current input file name
    $outputCsvPath = "$($file.DirectoryName)\$($file.BaseName)_URL_Sizes.csv"

    # Export the sorted URLs to a CSV file
    $sortedUrlDetails | Export-Csv -Path $outputCsvPath -NoTypeInformation

    Write-Host "Processed URLs saved to $outputCsvPath"
}
