$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    InModuleScope WssCompressedStructure {
        $here = $PSScriptRoot

        It 'Sets Field for SharePoint list in content database (WssCompressedStructure from: Named Argument)' {
                . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
                Mock Invoke-Sqlcmd2 {}
                Set-SpListWssCompressedStructure -WssCompressedStructure (
                    'FOOBAR' | New-WssCompressedStructure
                ) -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId ([guid]::NewGuid().Guid) -Force -Confirm:$false
                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
        }

        It 'Sets Field for SharePoint list in content database (WssCompressedStructure from: ValueFromPipeline)' {
                . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
                Mock Invoke-Sqlcmd2 {}
                'FOOBAR' | New-WssCompressedStructure |
                    Set-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId ([guid]::NewGuid().Guid) -Force -Confirm:$false
                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
        }

        It 'Sets Content type for SharePoint list in content database (WssCompressedStructure from: Named Argument)' {
                . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
                Mock Invoke-Sqlcmd2 {}
                Set-SpListWssCompressedStructure -WssCompressedStructure (
                    'FOOBAR' | New-WssCompressedStructure
                ) -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes -ListId ([guid]::NewGuid().Guid) -Force -Confirm:$false
                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
        }

        It 'Sets Content type for SharePoint list in content database (WssCompressedStructure from: ValueFromPipeline)' {
                . "$here\Mocks\New-WssCompressedStructure.Mock.ps1"
                Mock Invoke-Sqlcmd2 {}
                'FOOBAR' | New-WssCompressedStructure |
                    Set-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes -ListId ([guid]::NewGuid().Guid) -Force -Confirm:$false
                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
        }
    }
}