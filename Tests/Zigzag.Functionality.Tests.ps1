$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
. "$here\Helpers\ArrayHelper.ps1"
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    It 'Converts existing xml file to WssCompressedStructure binary file' {
        $testPath = 'TestDrive:\WssCompressedStructure.bin' 
        [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
            New-WssCompressedStructure |
                Export-WssCompressedStructureBinary -FilePath $testPath

        ArrayDifferences (
            [System.IO.File]::ReadAllBytes(
                $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath($testPath, [ref]$null)
            )
        ) (
            [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
        ) | Should BeNullOrEmpty
    }

    It 'Converts existing xml file to WssCompressedStructure byte array' {
        ArrayDifferences (
            [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
        ) (
            [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
                New-WssCompressedStructure |
                    ConvertTo-WssCompressedStructureBinary
        ) | Should BeNullOrEmpty
    }

    It 'Reads existing WssCompressedStructure binary file and expands it' {
        [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
            Should BeExactly (
                ,[System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin") |
                    ConvertFrom-WssCompressedStructureBinary |
                        Expand-WssCompressedStructure
            )
    }

    It 'Imports existing WssCompressedStructure binary file and expands it' {
        [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
            Should BeExactly (
                Import-WssCompressedStructureBinary -Path "$here\Mocks\WssCompressedStructure.bin" |
                    Expand-WssCompressedStructure
            )
    }

    It 'Imports existing WssCompressedStructure binary file using wildcard and expands it' {
        [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
            Should BeExactly (
                Import-WssCompressedStructureBinary -Path "$here\Mocks\*.bin" |
                    Expand-WssCompressedStructure
            )
    }

    It 'Imports existing WssCompressedStructure binary file using FileInfo objects and expands them' {
        [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
            Should BeExactly (
                Get-ChildItem -Path "$here\Mocks\*.bin" |
                    Import-WssCompressedStructureBinary |
                        Expand-WssCompressedStructure
            )
    }

    InModuleScope WssCompressedStructure {
        $here = $PSScriptRoot

        It 'Gets Fields for SharePoint lists from content database and expands them' {
            . "$here\Mocks\Invoke-Sqlcmd2.Mock.ps1"

            [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
                Should BeExactly (
                    Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId ([guid]::NewGuid().Guid) |
                        Expand-WssCompressedStructure
                )

            Assert-MockCalled Invoke-Sqlcmd2 -Times 1
        }
    }

    InModuleScope WssCompressedStructure {
        $here = $PSScriptRoot

        It 'Converts existing xml file to WssCompressedStructure and Sets SharePoint list Field value in database to it' {
            Mock Invoke-Sqlcmd2 {}

            [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
                New-WssCompressedStructure |
                    Set-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId ([guid]::NewGuid().Guid) -Force -Confirm:$false

            Assert-MockCalled Invoke-Sqlcmd2 -Times 1
        }
    }
}