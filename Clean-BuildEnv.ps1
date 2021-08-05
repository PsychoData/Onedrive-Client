$module = 'Onedrive-Client'
Push-Location $PSScriptroot

#Unload Module
Get-Module $module | Remove-Module -Force

#Manual Cleanup of directories
#Get-ChildItem -Path "$PSScriptRoot\output\$module\bin", "$PSScriptRoot\src\bin", "$PSScriptRoot\src\obj", "$PSScriptRoot\output\$module\$module.ps*" -ErrorAction SilentlyContinue | Remove-Item -Recurse
Get-ChildItem -Path "$PSScriptRoot\output\$module\", "$PSScriptRoot\src\bin", "$PSScriptRoot\src\obj" -Force -ErrorAction SilentlyContinue -Exclude '.gitkeep' | Remove-Item -Recurse -Force
