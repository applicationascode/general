<#
    .Synopsis
    Collects all the files and create the Citrix MicroApp using the .mapp extention

    .Description
    Collectes all folders in and files and creates the Citrix MicroApp first in zip format and renames it to the .mapp extention so it can be imported.

    .Parameter Path
    The path to the main MicroApps location

    .Example
    Compile-MicroApp -Path ".\Source"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $Path
)

$microAppDirs = Get-ChildItem -Path  $Path | Where-Object {$_.PSIsContainer -eq $true}

if  ($microAppDirs.Count -eq 0) {
    Write-Host "No Citrix MicroApps found..."
} else {

    foreach ($microAppDir in $microAppDirs) {
        $microAppFiles = Get-ChildItem -Path $($microAppDir.FullName) -Recurse

        $metaData = $microAppFiles | Where-Object {$_.Name -eq "metadata.json"}

        if ($metaData) {
            try {
                $metaDataContent = Get-Content -Path $($metaData.FullName) -Raw | ConvertFrom-Json
            } catch {
                Write-Error "Something went wrong while reading the Citrix MicroApp content: $($_.Exception.Message)"
            }
        
            if ($metaDataContent.vendor.ToLower() -eq "citrix") {
                Write-Host "Compiling Citrix MicroApp: $($metaDataContent.title)."
                
                try {
                    Compress-Archive -Path $microAppDir -DestinationPath "$($Path)\$($microAppDir.Name).zip"
                } catch {
                    Write-Error "Something went wrong while compressing the directory $($microAppDir.Name): $($_.Exception.Message)"
                }
                
                try {
                    Rename-Item -Path "$($Path)\$($microAppDir.Name).zip" -NewName "$($Path)\$($microAppDir.Name).mapp"
                    Write-Host "Citrix MicroApp $($microAppDir.Name) created successfully."
                } catch {
                    Write-Error "Something went wrong while renaming the Citrix MicroApp $($microAppDir.Name): $($_.Exception.Message)"
                }
            } else {
                Write-Error "Unknown Citrix MicroApp format..."
            }
        }
    }
}