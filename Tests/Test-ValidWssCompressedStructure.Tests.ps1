$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    It 'Tests if WssCompressedStructure valid (WssCompressedStructure from: ValueFromPipeline)' {
            . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
            'FOOBAR' | New-WssCompressedStructure |
                Test-ValidWssCompressedStructure -Expand |
                    Should Be $true
    }

    It 'Tests if WssCompressedStructure not valid (WssCompressedStructure from: ValueFromPipeline)' {
            'FOOBAR' | New-WssCompressedStructure | ForEach-Object {$_.ID = 0xFF, 0xFF ; $_} |
                Test-ValidWssCompressedStructure -Expand |
                    Should Be $false
        }
}