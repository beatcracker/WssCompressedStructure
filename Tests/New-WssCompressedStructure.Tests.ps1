$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    It 'Creates new WssCompressedStructure from string (string from: Named Argument)' {
        New-WssCompressedStructure -InputObject (
            [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml")
        ) | Should Not BeNullOrEmpty
    }

    It 'Creates new WssCompressedStructure from string (string from: ValueFromPipeline)' {
        [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
            New-WssCompressedStructure |
                Should Not BeNullOrEmpty
    }

    It 'Creates new WssCompressedStructure from single file (Path from: Named Argument)' {
        New-WssCompressedStructure -Path "$here\Mocks\WssCompressedStructure.xml" |
            Should Not BeNullOrEmpty
    }

    It 'Creates new WssCompressedStructures from multiple files (Path from: Named Argument)' {
        New-WssCompressedStructure -Path "$here\Mocks\*.xml" |
            Should Not BeNullOrEmpty
    }

    It 'Creates new WssCompressedStructures from multiple files (Path from: ValueFromPipelineByPropertyName)' {
        Get-ChildItem -Path "$here\Mocks\*.xml" | New-WssCompressedStructure |
            Should Not BeNullOrEmpty
    }
}