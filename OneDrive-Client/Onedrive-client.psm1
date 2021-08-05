function Get-ODClients {
    [CmdletBinding()]
    
    $returnObj = [PSCustomObject]@{}

    $globalConfigs = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Onedrive\Settings\*\global.ini" | Get-Content -Encoding unicode
    $clientIDmatches = $globalConfigs | Select-String -Pattern "^cid = (?<ClientID>.+)$" -AllMatches

    $clientIDMatches.Matches.Captures | Select-Object -ExpandProperty Groups | Where-Object { $_.Name -notmatch "\d+" } | ForEach-Object {
        Add-Member -InputObject $returnObj -MemberType NoteProperty -Name $_.Name -Value $_.Value
    }

    Return $returnObj
}
function Get-ODConfig {
    [CmdletBinding()]

    param (
        $ClientID
    )
    $clientIDConfigs = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Onedrive\Settings\*\$($ClientID).ini" | Get-Content -Encoding unicode
    return $clientIDConfigs
}
function Get-ODSyncedLibraryConfig {
    [CmdletBinding()]

    param (
        [parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]    
        $ClientID
    )
    $clientIDConfig = Get-ODConfig -ClientID $ClientID
    $LibraryScopeRegex = "^libraryScope = (?<LibraryScopeID>\d+) (?<SubscriptionID>(?:\w{32}|\w{8}-\w{4}-\w{4}-\w{4}-\w{12})\+\d+) \d+ \`"(?<SiteName>[\w- ]+)\`" \`"(?<FolderName>\w+)\`" \d+ \`"(?<SiteURL>.*?)\`" \`"(?<TenantID>\w{32}|\w{8}-\w{4}-\w{4}-\w{4}-\w{12})\`" (?<SiteID>\w{32}|\w{8}-\w{4}-\w{4}-\w{4}-\w{12}) (?<WebID>\w{32}|\w{8}-\w{4}-\w{4}-\w{4}-\w{12}) (?<ListID>\w{32}|\w{8}-\w{4}-\w{4}-\w{4}-\w{12}) \d+ \`"(?<FilePath>.*?)\`" \d+ (\w{32}|\w{8}-\w{4}-\w{4}-\w{4}-\w{12}).*?$"
    $libScopeMatches = $clientIDConfig | Select-String -Pattern $LibraryScopeRegex -AllMatches
    $libScopeMatches | ForEach-Object {
        $returnObj = [PSCustomObject]@{
            ClientID = $ClientID
        }
        $_.Matches.Captures | Select-Object -ExpandProperty Groups |  ForEach-Object {
            If ($_.Name -notmatch "\d+" ) {
                Add-Member -InputObject $returnObj -NotePropertyName $_.Name -NotePropertyValue $_.Value
            }
        }
        Add-Member -InputObject $returnObj  -NotePropertyName "SourceLine" -NotePropertyValue ($_.Matches.groups.Item('0').value)
        
        Add-Member -InputObject $returnObj  -NotePropertyName "SourceScopeLine" -NotePropertyValue ($_.Matches.groups.Item('0').value)
        Add-Member -InputObject $returnObj -NotePropertyName 'SourceFile' -NotePropertyValue (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Onedrive\Settings\*\$($ClientID).ini")

        
        if ([string]::IsNullOrWhiteSpace($returnObj.FilePath)) {
            $folders = $returnObj | Get-ODSyncedFolderConfig
            Add-Member -InputObject $returnObj -NotePropertyName 'SyncedFolders' -NotePropertyValue $folders
        }
        $returnObj
    }
}

function Get-ODClientEXE {
    [CmdletBinding()]

    $OnedriveEXEs = Get-Item "C:\Program Files*\Microsoft OneDrive\OneDrive.exe" , "$env:LOCALAPPDATA\Microsoft\Onedrive\onedrive.exe" -ea SilentlyContinue
    
    if ($null -eq $OnedriveEXEs) {
        Write-Error "No OneDrive EXE Found. Please ensure you are running as the user you want to act on, not System"
    }
    elseif (@($OnedriveEXEs).Count -gt 1) {
        Write-Warning "Hi you managed to apparently have both a per-user and per-machine install"
        Write-Warning "Congratulations! I couldn't manage to replicate or rule this out with my testing, so no promises if this works at all"
        
        Return ($OnedriveEXEs | Select-Object -first 1)
    }
    else {
        Return $OnedriveEXEs
    }

}

function Get-ODSyncedFolderConfig {
    [CmdletBinding()]

    param (
        [parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]    
        $ClientID,
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]    
        $LibraryScopeID        
    )
    #$SyncedLibrary = Get-ODSyncedLibraryConfig -ClientID $ClientID

    $LibraryFolderRegex = "^libraryFolder = (?<LibraryFolderID>\d+) (?<LibraryScopeID>\d+) (?:(?:\w{32}|\w{8}-\w{4}-\w{4}-\w{4}-\w{12})\+\d+) \d+ \`"(?<FilePath>.*?)\`" \d+ \`"(?<FolderName>\w+)\`" .*?$"

    $clientIDConfig = Get-ODConfig -ClientID $ClientID
    $matchFolders = $clientIDConfig | Select-String -Pattern $LibraryFolderRegex -AllMatches
    $returnFolders = $matchFolders | ForEach-Object {
        $libraryFolder = [PSCustomObject]@{
            ClientID = $ClientID
        }
        $_.Matches.Captures | Select-Object -ExpandProperty Groups |  ForEach-Object {
            If ($_.Name -notmatch "\d+" ) {
                Add-Member -InputObject $libraryFolder -NotePropertyName $_.Name -NotePropertyValue $_.Value -Force
            }
        }

        Add-Member -InputObject $libraryFolder -NotePropertyName "SourceFolderLine" -NotePropertyValue ($_.Matches.groups.Item('0').value)
        Add-Member -InputObject $libraryFolder -NotePropertyName 'SourceFile' -NotePropertyValue (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Onedrive\Settings\*\$($ClientID).ini")

        $libraryFolder
    } 
    If (-not [string]::IsNullOrWhiteSpace($LibraryScopeID)) {
        $returnFolders | Where-Object { $_.LibraryScopeID -eq $LibraryScopeID }
    }
    else {
        $returnFolders
    }
}

function Stop-ODClients {
    [CmdletBinding()]

    $OneDriveEXE = Get-ODClientEXE
    $process = Start-Process -FilePath $OneDriveEXE -ArgumentList "/shutdown" -PassThru
    
    try {
        $process | Wait-Process -TimeoutSec 60 
    }
    catch {
        $_.ErrorDetails
    }
}

function Start-ODClients {
    [CmdletBinding()]
    param (
        [switch]
        $PassThru
    )
    $OneDriveEXE = Get-ODClientEXE | Select-Object -ExpandProperty FullName
    $process = Start-Process -FilePath $OneDriveEXE -ArgumentList "/background" -PassThru

    # $process
    # Start-Sleep -Seconds 10
    # $process

    if ($PassThru) {
        Return $process
    }
}

function Remove-ODSyncedItemConfig {
    <#
    .SYNOPSIS
        Remove Synced Library/Folder from OneDrive 
    .DESCRIPTION
        Removes a Synced Library and/or Folder from OneDrive's Synced list and optionally also removes the local files from the disk. 
    .EXAMPLE
        PS C:\> Get-ODClients | Get-ODSyncedLibraryConfig  | where {$_.SiteName -like "OldTeam*"} | Remove-ODSyncedItemConfig
        Select a Team by SiteName and Remove it. 
        If multiple folders are Synced under a library it will remove all folders synced to this library
    .EXAMPLE
        PS C:\> Get-ODClients | Get-ODSyncedLibraryConfig  | where {$_.SiteID -eq "f496b4697f1d4b968542d065c7dd261b"} | Remove-ODSyncedItemConfig
        Select a Team by SiteID and Remove it. 
        If multiple folders are Synced under a library it will remove all folders synced to this library
    .EXAMPLE
        PS C:\> Get-ODClients | Get-ODSyncedLibraryConfig  | Out-GridView -PassThrough | Remove-ODSyncedItemConfig
        Open a GUID GridView and allow interactive Selection of Library items to remove. 
        If multiple folders are Synced under a library it will remove all folders synced to this library    
    .EXAMPLE
        PS C:\> Get-ODClients | Get-ODSyncedLibraryConfig  | select -expandProperty SyncedFolders | Out-GridView -PassThrough | Remove-ODSyncedItemConfig
        Open a GUID GridView and allow interactive Selection of Synced Folder items to remove. 
        If you select all folders under a library, but did not select the library itself, the folders will be removed, but the library config entry will not be removed directly, but may be cleaned up by OneDrive later on
    .EXAMPLE
        PS C:\> Get-ODClients | Get-ODSyncedLibraryConfig  | select -expandProperty SyncedFolders | where {$_.FolderName -eq 'OldDeadChannel'} | Remove-ODSyncedItemConfig
        Select a folder to remove by the name of the SharePoint folder it is mapped to, not the name of the Local Folder it is mapped to. 
        However, this would unmap all synced folders if there were entries for multiple Sites/Teams. Example it would match "Company - OldDeadChannel" and "TestTeam - OldDeadChannel"
    .EXAMPLE
        PS C:\> Get-ODClients | Get-ODSyncedLibraryConfig  | where {$_.SiteName -like "OldTeam"} | select -expandProperty SyncedFolders | where {$_.FolderName -eq 'OldDeadChannel'} | Remove-ODSyncedItemConfig
        Select a specific synced Folder within a specific synced library and unmap it.  Here I show selecting Site:`OldTeam` Channel:`OldDeadChannel` and remove just that folder, but not the entire "OldTeam" Library. 
        NOTE: This will only work if that folder is directly Synced down separately, it will not let you remove sub-folders of folders that are synced 
    .INPUTS
        Provide a SharePoint Library from Get-ODSyncedLibraryConfig or a Synced Folder from Get-ODSyncedFolderConfig / (Get-ODSyncedLibraryConfig).SyncedFolders
    .OUTPUTS
        Output (if any)
    .NOTES
        Needs to be reconstructed later into separate Parameter sets. LibraryScope, LibraryFolder, and Generic (sourceLine)
        NOTE: Has not been tested with Folders/Libraries related to Sites/Site Folders/items added as "shortcuts" to a User's OneDrive 
    #>
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]    
        $SourceFile,
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]    
        $SyncedFolders,
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]    
        $SourceScopeLine,
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]    
        $SourceFolderLine,
        [parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]    
        $FilePath,
        [parameter(
            Mandatory = $false)]    
        [bool]
        $RemoveLocalFiles = $true,
        [parameter(
            Mandatory = $false)]    
        [bool]
        $UnpinBeforeRemoval = $true
    )

    #Empty Case
    if ($null -eq $SourceFile -and ($null -eq $SourceScopeLine -or $null -eq $SourceFolderLine ) ) {
        Return
    }

    #Library with Non-root Synced Folders
    #means $filePath should already be empty
    if ($null -ne $SyncedFolders) {
        $SyncedFolders | ForEach-Object {
            $_ | Remove-ODSyncedItemConfig -RemoveLocalFiles $RemoveLocalFiles -UnpinBeforeRemoval $UnpinBeforeRemoval
        }
    }
    else {
    }

    if (-not [String]::IsNullOrWhiteSpace($SourceFolderLine)) {
        $SourceLine = $SourceFolderLine
    }
    elseif (-not [String]::IsNullOrWhiteSpace($SourceScopeLine)) {
        $SourceLine = $SourceScopeLine
    }
    else {
        Write-Error "What line would you like to remove?"
    }

    if (-not [string]::IsNullOrWhiteSpace($FilePath) -and $UnpinBeforeRemoval) {
        Write-Verbose "Force Unpinning directory (""Free Up Space"")"
        attrib.exe -P +U ($FilePath.FullName) /S /D | Write-Verbose 
    }

    Stop-ODClients
    (Get-Content $SourceFile -Encoding unicode ) -replace [regex]::Escape($SourceLine) | Out-File -FilePath $SourceFile -Encoding unicode -Force 
    Start-ODClients
    if (-not [string]::IsNullOrWhiteSpace($FilePath) -and $RemoveLocalFiles) {
        $FilePath | Get-ChildItem -Force | Remove-Item -Recurse -Force
        $FilePath | Get-Item -Force -EA SilentlyContinue | Remove-Item -Force    
    }
}

