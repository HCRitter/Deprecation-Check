<#
.SYNOPSIS
    Checks for deprecated commands in PowerShell scripts.
.DESCRIPTION
    This function checks PowerShell scripts for deprecated commands from specified modules (MSOnline, AzureAD, AzureADPreview).
    It parses the scripts, identifies command usage, and reports any deprecated commands found.
.PARAMETER MSOnline
    Switch parameter to include the MSOnline module in the deprecation check.
.PARAMETER AzureAD
    Switch parameter to include the AzureAD module in the deprecation check.
.PARAMETER AzureADPreview
    Switch parameter to include the AzureADPreview module in the deprecation check.
.PARAMETER FilePaths
    An array of file paths to PowerShell scripts that will be checked for deprecated commands.
.EXAMPLE
    Invoke-DeprecationCheck -MSOnline -FilePaths "C:\Scripts\MyScript.ps1", "C:\Scripts\AnotherScript.ps1"
    Checks the scripts MyScript.ps1 and AnotherScript.ps1 for deprecated commands from the MSOnline module.
.EXAMPLE
    Invoke-DeprecationCheck -AzureAD -AzureADPreview -FilePaths "C:\Scripts\Script.ps1"
    Checks the script Script.ps1 for deprecated commands from both AzureAD and AzureADPreview modules.
.NOTES
    Ensure that the specified modules are installed before running this function.
#>
function Invoke-DeprecationCheck {
    [CmdletBinding()]
    param (
        [switch]$MSOnline,
        [switch]$AzureAD,
        [switch]$AzureADPreview,
        [string[]]$FilePaths
    )
    
    begin {

        $CommandList = [System.Collections.Generic.List[object]]::new()
        foreach ($key in $PSBoundParameters.Keys) {
            if ($PSBoundParameters[$key] -is [System.Management.Automation.SwitchParameter]) {
                try {
                    import-module $key -ErrorAction Stop
                    $CommandList.AddRange($(Get-DeprecatedCommands -Type $key))
                }
                catch {
                    Write-Warning $('Failed to import module: ' + $key + 'it may not be installed or loaded.')
                    Write-Warning 'Please ensure the module is installed and loaded before running this script.'
                    Write-Warning $_.Exception.Message
                }
            }
        }
        if ($CommandList.Count -eq 0) {
            Write-Error "No commands found in the specified modules. Please ensure the modules are installed and loaded."
            return
        }
    }
    
    process {
        $Report = foreach($FilePath in @($FilePaths)){
            $Scriptblock = Get-Content $FilePath -Raw
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Scriptblock,[ref]$null, [ref]$null)
            $UsedCommands = $ast.FindAll({ 
                $args[0] -is [System.Management.Automation.Language.CommandAst] 
            }, $true)

            foreach($UsedCommand in $UsedCommands){
                if($CommandList.CommandName -contains $UsedCommand.CommandElements[0].Value){
                    $Command = $CommandList | Where-Object { $_.CommandName -eq $UsedCommand.CommandElements[0].Value }
                    [PSCustomObject]@{
                        CommandName = $UsedCommand.CommandElements[0].Value
                        ModuleName  = $Command.ModuleName
                        CommandType = $Command.CommandType
                        ScriptPath = (Get-ChildItem -Path $FilePath).FullName
                        LineNumber = $UsedCommand.Extent.StartLineNumber
                        Alias = $command.Alias
                        isAlias = $false
                    }
                }
            }
        }
    }
    
    end {
        return $Report
    }
}