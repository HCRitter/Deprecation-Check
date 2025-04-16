<#
.SYNOPSIS
    Retrieves a list of commands from a specified module along with their aliases.

.DESCRIPTION
    This function retrieves commands from a specified PowerShell module (MSOnline, AzureAD, or AzureADPreview) 
    and returns a list of command names, module names, command types, and any aliases associated with each command.

.PARAMETER Type
    Specifies the module to retrieve commands from. Valid values are 'MSOnline', 'AzureAD', and 'AzureADPreview'. 
    The default value is 'AzureAD'.

.EXAMPLE
    Get-DeprecatedCommands -Type AzureAD

    Returns a list of commands from the AzureAD module, including their names, module names, command types, and aliases.

.EXAMPLE
    Get-DeprecatedCommands -Type MSOnline | Where-Object {$_.Aliases -ne $null}

    Returns a list of commands from the MSOnline module that have aliases defined.

.NOTES
    This function uses Get-Command to retrieve the commands and Get-Alias to find any aliases.
    Error handling is included to gracefully handle cases where a command does not have an alias.

.INPUTS
    None. You cannot pipe objects to this function.

.OUTPUTS
    System.Collections.Generic.List[PSCustomObject]
    A list of PSCustomObject objects, each representing a command with the following properties:
    - CommandName: The name of the command.
    - ModuleName: The name of the module the command belongs to.
    - CommandType: The type of command (e.g., Function, Cmdlet).
    - Aliases: An array of aliases defined for the command, or $null if no aliases are found.
#>
function Get-DeprecatedCommands {
    [CmdletBinding()]
    
    param (
        [ValidateSet('MSOnline', 'AzureAD', 'AzureADPreview')]
        $Type = 'AzureAD'
    )
    
    begin {

        $Commands = Get-Command -Module $Type  | Select-Object Name, ModuleName, CommandType, Definition
        $CommandList = [System.Collections.Generic.List[object]]::new()
    }
    
    process {
        foreach($Command in $Commands){
            $CommandList.Add(
                [PSCustomObject]@{
                    CommandName = $Command.Name
                    ModuleName  = $Command.ModuleName
                    CommandType = $Command.CommandType
                    Aliases     = try{(Get-Alias -Definition $Command.Name -ErrorAction Stop).Name} catch { $null }
                }
            )
        }
    }
    
    end {
        return $CommandList
    }
}