$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    InModuleScope WssCompressedStructure {
        It 'Adds "WssCompressedStructure.Header" typename to the object' {
            (New-Object -TypeName PsCustomObject | Add-TypeName).PSObject.TypeNames[0] |
                Should BeExactly 'WssCompressedStructure.Header'
        }
    }
}