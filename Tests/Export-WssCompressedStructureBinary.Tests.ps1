$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
. "$here\Helpers\ArrayHelper.ps1"
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    It 'Exports single WssCompressedStructure to binary file (WssCompressedStructure from: ValueFromPipeline)' {
            . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
            $testPath = 'TestDrive:\WssCompressedStructure.bin'
            'FOOBAR' | New-WssCompressedStructure |
                Export-WssCompressedStructureBinary -FilePath $testPath

            ArrayDifferences (
                [System.IO.File]::ReadAllBytes(
                    $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath($testPath, [ref]$null)
                )
            ) (
                [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
            ) | Should BeNullOrEmpty
    }

    InModuleScope WssCompressedStructure {
        $here = $PSScriptRoot
        . "$here\Helpers\ArrayHelper.ps1"

        It 'Exports multiple WssCompressedStructures to binary files (WssCompressedStructure from: ValueFromPipeline)' {
                . "$PSScriptRoot\Mocks\Invoke-Sqlcmd2.Mock.ps1"

                $WssCS = Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields
                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
                $WssCS | Export-WssCompressedStructureBinary -DestinationPath 'TestDrive:\'

                ArrayDifferences (
                    [System.IO.File]::ReadAllBytes(
                        $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath(('TestDrive:\{0}.bin' -f $WssCS.ListId), [ref]$null)
                    )
                ) (
                    [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
                ) | Should BeNullOrEmpty
        }
    }

    It 'Exports single WssCompressedStructure to binary file (WssCompressedStructure, ListId from: Named Argument)' {
            . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
            $ListId = [guid]::NewGuid().Guid

            Export-WssCompressedStructureBinary -InputObject (
                'FOOBAR' | New-WssCompressedStructure
            ) -ListId $ListId -DestinationPath 'TestDrive:\'
            
            ArrayDifferences (
                [System.IO.File]::ReadAllBytes(
                    $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath(("TestDrive:\$ListId.bin"), [ref]$null)
                )
            ) (
                [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
            ) | Should BeNullOrEmpty
    }

    It 'Exports single WssCompressedStructure to binary file (ListId from: Named Argument)' {
        . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
        $testPath = 'TestDrive:\WssCompressedStructure.bin'
        'FOOBAR' | New-WssCompressedStructure |
            Export-WssCompressedStructureBinary -FilePath $testPath

        ArrayDifferences (
            [System.IO.File]::ReadAllBytes(
                $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath($testPath, [ref]$null)
            )
        ) (
            [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.bin")
        ) | Should BeNullOrEmpty
    }
}