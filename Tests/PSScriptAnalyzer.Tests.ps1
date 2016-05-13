$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')

Describe "$FunctionName" {
    It 'Should not have any PSScriptAnalyzer warnings' {
        $ScriptWarnings = @(
            Get-ChildItem -LiteralPath $here | Where-Object {
                # Excluding temp folder, tests, and third-party function
                $_.FullName -notmatch '.+\\\.wip.*' -and 
                $_.FullName -notmatch '.+\\Tests\.*' -and
                $_.Name -ne 'Invoke-Sqlcmd2.ps1'
            } | Invoke-ScriptAnalyzer
        )
        $ScriptWarnings.Length | Should be 0
    }
}