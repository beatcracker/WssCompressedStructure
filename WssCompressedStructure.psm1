if(!$PSScriptRoot){
    $PSScriptRoot = Split-Path $Script:MyInvocation.MyCommand.Path -Parent
}

'Public', 'Private' | ForEach-Object {
    foreach($path in $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath("$PSScriptRoot\$_\*.ps1", [ref]$null)){
        try {
            Write-Verbose "Dotsourcing file: $path"
            . $path
        } catch {
            throw "Can't import functions from file: $path"
        }
   }
}