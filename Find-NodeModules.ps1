param (
    [string]$StartDir = $env:USERPROFILE,
    [switch]$Purge,
    [switch]$Export
)

# Recursively find all 'node_modules' directories
$allNodeModulesDirs = Get-ChildItem -Path $StartDir -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -eq 'node_modules'
}

# Filter out any 'node_modules' where any parent directory is named 'node_modules'
$filteredNodeModulesDirs = $allNodeModulesDirs | Where-Object {
    $current = $_.Parent
    $isNested = $false
    while ($current -ne $null -and $current.FullName -ne $StartDir) {
        if ($current.Name -eq 'node_modules') {
            $isNested = $true
            break
        }
        $current = $current.Parent
    }
    -not $isNested
}

if ($Purge) {
    $filteredNodeModulesDirs | ForEach-Object {
        Write-Host "Removing $($_.FullName)"
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($Export) {
    $exportPath = "node_modules_paths.txt"
    $filteredNodeModulesDirs | ForEach-Object { $_.FullName } | Set-Content -Path $exportPath
    Write-Host "Exported paths to $exportPath"
}

if (-not $Purge) {
    $filteredNodeModulesDirs | ForEach-Object { $_.FullName }
}

return $filteredNodeModulesDirs