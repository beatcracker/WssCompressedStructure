$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    InModuleScope WssCompressedStructure {
        $here = $PSScriptRoot

        It 'Gets Fields for all SharePoint lists from content database' {
                . "$PSScriptRoot\Mocks\Invoke-Sqlcmd2.Mock.ps1"
                $WssCS = Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields

                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
                $WssCS.PsObject.Properties.Name | ForEach-Object {
                    $_ | Should Not BeNullOrEmpty
                }
        }

        It 'Gets Fields for particular SharePoint lists from content database (ListId from: Named Argument)' {
                . "$PSScriptRoot\Mocks\Invoke-Sqlcmd2.Mock.ps1"
                $WssCS = Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId ([guid]::NewGuid(), [guid]::NewGuid())

                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
                $WssCS.PsObject.Properties.Name | ForEach-Object {
                    $_ | Should Not BeNullOrEmpty
                }
        }

        It 'Gets Fields for particular SharePoint lists from content database (ListId from: ValueFromPipeline)' {
                . "$PSScriptRoot\Mocks\Invoke-Sqlcmd2.Mock.ps1"
                $WssCS = [guid]::NewGuid(), [guid]::NewGuid() | Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields

                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
                $WssCS.PsObject.Properties.Name | ForEach-Object {
                    $_ | Should Not BeNullOrEmpty
                }
        }

        It 'Gets Content types for all SharePoint lists from content database' {
                . "$PSScriptRoot\Mocks\Invoke-Sqlcmd2.Mock.ps1"
                $WssCS = Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes

                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
                $WssCS.PsObject.Properties.Name | ForEach-Object {
                    $_ | Should Not BeNullOrEmpty
                }
        }

        It 'Gets Content types for particular SharePoint lists from content database (ListId from: ValueFromPipeline)' {
                . "$PSScriptRoot\Mocks\Invoke-Sqlcmd2.Mock.ps1"
                $WssCS = [guid]::NewGuid(), [guid]::NewGuid() | Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes

                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
                $WssCS.PsObject.Properties.Name | ForEach-Object {
                    $_ | Should Not BeNullOrEmpty
                }
        }

        It 'Gets Content types for particular SharePoint lists from content database (ListId from: Named Argument)' {
                . "$PSScriptRoot\Mocks\Invoke-Sqlcmd2.Mock.ps1"
                $WssCS = Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes -ListId ([guid]::NewGuid(), [guid]::NewGuid())

                Assert-MockCalled Invoke-Sqlcmd2 -Times 1
                $WssCS.PsObject.Properties.Name | ForEach-Object {
                    $_ | Should Not BeNullOrEmpty
                }
        }
    }
}