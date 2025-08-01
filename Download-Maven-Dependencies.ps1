param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [string]$ArtifactId,
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [Parameter(Mandatory = $false)]
    [string]$OutputFolder = "./dependencies"
)

# Resolve output folder to absolute path
$absoluteOutputFolder = [System.IO.Path]::GetFullPath($OutputFolder)

# Ensure output folder exists
if (-not (Test-Path $absoluteOutputFolder)) {
    New-Item -ItemType Directory -Path $absoluteOutputFolder | Out-Null
}

if (-not (Test-Path $absoluteOutputFolder/source)) {
    New-Item -ItemType Directory -Path $absoluteOutputFolder/source | Out-Null
}

# Create a temporary folder for the Maven project
$tempDir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName())
Set-Location $tempDir.FullName

# Generate a minimal pom.xml
$pomContent = @"
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>temp</groupId>
    <artifactId>temp</artifactId>
    <version>1.0</version>
    <dependencies>
        <dependency>
            <groupId>$GroupId</groupId>
            <artifactId>$ArtifactId</artifactId>
            <version>$Version</version>
        </dependency>
    </dependencies>
</project>
"@
Set-Content -Path "$tempDir\pom.xml" -Value $pomContent

# Download binary and source jars
$mvnCmd1 = "mvn dependency:copy-dependencies -DoutputDirectory=`"$absoluteOutputFolder`" -f pom.xml"
$mvnCmd2 = "mvn dependency:copy-dependencies -DoutputDirectory=`"$absoluteOutputFolder/source`" -Dclassifier=sources -f pom.xml"

Invoke-Expression $mvnCmd1
Invoke-Expression $mvnCmd2

# Clean up temporary folder
Set-Location -Path $PSScriptRoot
Remove-Item -Recurse -Force $tempDir

Write-Host "Dependencies downloaded to: $absoluteOutputFolder."
