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
    
    # Initialize variables to keep track of the largest URL and its size for the current file
    $largestUrl = $null
    $largestSize = 0

    # Read the file and extract full URLs containing 'get.php'
    $urls = Select-String -Path $file.FullName -Pattern "http[s]?://[^ ]*get\.php[^ ]*" | ForEach-Object { $_.Matches.Value }

    # Loop through each URL, get its content size and compare it
    foreach ($url in $urls) {
        Write-Host "  -NoNewline Processing URL: $url......."
        $size = Get-ContentSize -url $url
        Write-Host "Size is : $size bytes"
        if ($size -gt $largestSize) {
            $largestSize = $size
            $largestUrl = $url
        }
    }

    # Output the largest URL and its size for the current file
    if ($largestUrl) {
        Write-Host "The URL with the largest content in file $($file.Name) is:"
        Write-Host "$largestUrl"
        Write-Host "Content Size: $($largestSize) bytes"
		Set-Clipboard -Value $largestUrl
    } else {
        Write-Host "No valid URLs found in file $($file.Name)."
		Set-Clipboard -Value ""
    }
    
    Write-Host 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}
