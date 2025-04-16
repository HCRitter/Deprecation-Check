

Get-ChildItem -Path  .\Public -Filter *.ps1 | ForEach-Object {
    $FunctionName = $_.BaseName
    $FunctionPath = $_.FullName
    . $FunctionPath
}

Export-ModuleMember -Function Invoke-DeprecationCheck, Get-DeprecatedCommands

