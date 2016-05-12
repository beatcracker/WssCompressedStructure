$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    It 'Converts single byte array to WssCompressedStructure (byte array from: Named Argument)' {
        ConvertFrom-WssCompressedStructureBinary -InputObject (
            [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
        ) | Should Not BeNullOrEmpty
    }

    It 'Converts multiple byte arrays to WssCompressedStructures (byte arrays from: Named Argument)' {
        $ByteArray = [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
        ConvertFrom-WssCompressedStructureBinary -InputObject ($ByteArray, $ByteArray) |
            ForEach-Object {
                $_ | Should Not BeNullOrEmpty
            }
    }

    It 'Converts byte array to WssCompressedStructure (byte array from: ValueFromPipeline)' {
        [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin") | 
            ConvertFrom-WssCompressedStructureBinary |
                Should Not BeNullOrEmpty
    }

    It 'Converts multiple byte arrays to WssCompressedStructures (byte array from: ValueFromPipeline)' {
        $ByteArray = [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
        $ByteArray, $ByteArray | ConvertFrom-WssCompressedStructureBinary | ForEach-Object {
            $_ | Should Not BeNullOrEmpty
        }
    }
}