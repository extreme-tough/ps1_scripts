# Path to the input and output files
$inputFile = "C:\path\to\your\input\file.txt"
$outputFile = "C:\path\to\your\output\file.txt"

# Initialize an array to store the processed URLs
$processedURLs = @()

# Read the input file line by line
$lines = Get-Content $inputFile
for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]

    # Check if the line contains a URL
    if ($line -match "🔗 (http.*)\.\.\. (.)&type=m3u") {
        $urlPrefix = $matches[1]
        $lostPassword = $matches[2]

        # Get the username and password from subsequent lines
        $usernameLine = $lines[$i+2]
        $passwordLine = $lines[$i+3]

        if ($usernameLine -match "👤 USERNAME : (.+)") {
            $username = $matches[1]
        }
        if ($passwordLine -match "🔑 PASSWORD : (.+)") {
            $password = $matches[1]
        }

        # Construct the fixed URL
        $fixedURL = "${urlPrefix}/get.php?username=${username}&password=${password}&type=m3u"
        
        # Add the fixed URL to the array
        $processedURLs += $fixedURL
    }
}

# Write the processed URLs to the output file
$processedURLs | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "Processing complete. Processed URLs saved to $outputFile"
