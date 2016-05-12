$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
. "$here\Helpers\ArrayHelper.ps1"
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    It 'Expands WssCompressedStructure to string (WssCompressedStructure from: ValueFromPipelineByPropertyName)' {
            . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"

            [System.IO.File]::ReadAllText("$here\Mocks\WssCompressedStructure.xml") |
                Should BeExactly ('FOOBAR' | New-WssCompressedStructure | Expand-WssCompressedStructure)
    }

    It 'Expands WssCompressedStructure to file (WssCompressedStructure from: ValueFromPipelineByPropertyName)' {
            . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
            $testPath = 'TestDrive:\WssCompressedStructure.xml'
            'FOOBAR' | New-WssCompressedStructure | Expand-WssCompressedStructure -FilePath $testPath

            ArrayDifferences (
                [System.IO.File]::ReadAllBytes(
                    $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath($testPath, [ref]$null)
                )
            ) (
                [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.xml")
            ) | Should BeNullOrEmpty
    }

    It 'Expands multiple WssCompressedStructure to files (WssCompressedStructure, ListId from: ValueFromPipelineByPropertyName)' {
            . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
            $Guid = [guid]::NewGuid().Guid
            'FOOBAR' | New-WssCompressedStructure |
                # Exclude properties that are already in CSV to test them properly
                Select-Object -ExcludeProperty 'ListId' -Property '*', @{n = 'ListId' ; e = {$Guid}} |
                    Expand-WssCompressedStructure -DestinationPath $TestDrive

            ArrayDifferences (
                [System.IO.File]::ReadAllBytes((Join-Path -Path $TestDrive -ChildPath "$Guid.xml"))
            ) (
                [System.IO.File]::ReadAllBytes("$here\Mocks\WssCompressedStructure.xml")
            ) | Should BeNullOrEmpty
    }
}