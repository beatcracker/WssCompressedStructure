$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    It 'Imports single file as WssCompressedStructure (path to file from: Named Argument)' {
        Import-WssCompressedStructureBinary -Path "$here\Mocks\WssCompressedStructure.bin" |
            Should Not BeNullOrEmpty
    }

    It 'Imports single file as WssCompressedStructure (path to file from: ValueFromPipeline)' {
        "$here\Mocks\WssCompressedStructure.bin" | Import-WssCompressedStructureBinary |
            Should Not BeNullOrEmpty
    }

    It 'Imports mutiple files using wildcard as WssCompressedStructures (path to file from: Named Argument)' {
        Import-WssCompressedStructureBinary -Path "$here\Mocks\*.bin" |
            Should Not BeNullOrEmpty
    }

    It 'Imports mutiple files using wildcard as WssCompressedStructure (path to file from: ValueFromPipeline)' {
         "$here\Mocks\*.bin" | Import-WssCompressedStructureBinary |
            Should Not BeNullOrEmpty
    }

    It 'Imports mutiple files as WssCompressedStructure (path to file from: ValueFromPipelineByPropertyName)' {
         Get-ChildItem -LiteralPath "$here\Mocks" -Filter '*.bin' |
            Import-WssCompressedStructureBinary |
                Should Not BeNullOrEmpty
    }
             
}