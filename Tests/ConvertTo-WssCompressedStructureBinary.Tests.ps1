$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
. "$here\Helpers\ArrayHelper.ps1"
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    It 'Converts WssCompressedStructure to byte array (WssCompressedStructure from: ValueFromPipeline)' {
            . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
            ArrayDifferences (
                'FOOBAR' | New-WssCompressedStructure | ConvertTo-WssCompressedStructureBinary
            ) (
                [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
            ) | Should BeNullOrEmpty
    }

    It 'Converts WssCompressedStructure to byte array (WssCompressedStructure from: Named Argument)' {
            . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
            ArrayDifferences (
                ConvertTo-WssCompressedStructureBinary -InputObject ('FOOBAR' | New-WssCompressedStructure)
            ) (
                [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
            ) | Should BeNullOrEmpty
    }
}
