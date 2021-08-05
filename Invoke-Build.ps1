$module = 'Onedrive-Client'
Push-Location $PSScriptroot

.\Clean-BuildEnv.ps1

Write-Host "Psscriptroot: $PSScriptroot"
if (-not (Test-Path "$PSScriptRoot\output\$module\" )) {
    New-Item -ItemType Directory -Path "$PSScriptRoot\output\$module\"
}
Copy-Item "$PSScriptRoot\$module\*" "$PSScriptRoot\output\$module\" -Recurse -Force 
Push-Location .\output\$module\
$manifest = @{
    Path               = "$PSScriptRoot\output\$module\$module.psd1"
    RequiredAssemblies = @(($dllsToInclude | Get-Item -ea SilentlyContinue | Resolve-Path -Relative) -replace "^\.\\output\\$module\\" )
}
if ([string]::IsNullOrWhiteSpace($manifest.RequiredAssemblies)) {
    $manifest.Remove('RequiredAssemblies')
}
Update-ModuleManifest @manifest

Import-Module "$PSScriptRoot\Output\$module\$module.psd1" -Verbose
#Invoke-Pester "$PSScriptRoot\Tests"
