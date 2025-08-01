param (
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,

    [Parameter(Mandatory=$true)]
    [string]$InputFolder,

    [Parameter(Mandatory=$true)]
    [string]$OutputFolder
)

if (!(Test-Path $CsvPath)) {
    Write-Error "CSV file not found: $CsvPath"
    return
}

if (!(Test-Path $InputFolder)) {
    Write-Error "Input folder not found: $InputFolder"
    return
}

if (!(Test-Path $OutputFolder)) {
    Write-Output "Output folder does not exist. Creating: $OutputFolder"
    New-Item -Path $OutputFolder -ItemType Directory | Out-Null
}

$csv = Import-Csv $CsvPath

foreach ($row in $csv) {
    $name = $row.name
    $start = $row.start_time
    $end = $row.end_time

    $inputFile = Join-Path $InputFolder $name
    if (!(Test-Path $inputFile)) {
        Write-Warning "Input file not found: $inputFile"
        continue
    }

    $outputFile = Join-Path $OutputFolder $name

    # Calculate duration from start and end time
    $startSeconds = [timespan]::Parse($start).TotalSeconds
    $endSeconds = [timespan]::Parse($end).TotalSeconds
    $duration = $endSeconds - $startSeconds

    if ($duration -le 0) {
        Write-Warning "Invalid duration for $name. Skipping."
        continue
    }

    $ffmpegCmd = "ffmpeg -hide_banner -loglevel error -y -i `"$inputFile`" -ss $start -t $duration -c copy `"$outputFile`""
    Write-Host "Running: $ffmpegCmd"
    Invoke-Expression $ffmpegCmd
}