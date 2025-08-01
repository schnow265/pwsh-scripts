param (
    [string]$HomeDir = $env:USERPROFILE
)

# Recursively search for directories named '.git'
$gitDirs = Get-ChildItem -Path $HomeDir -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -eq '.git'
}

# Output the parent directory of each found .git folder (the repo root)
$gitRepoPaths = $gitDirs | ForEach-Object { $_.Parent.FullName }
return $gitRepoPaths