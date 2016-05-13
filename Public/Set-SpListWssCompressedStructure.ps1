<#
.Synopsis
    Sets SharePoint list data in content database from WssCompressedStructure.
    This can BREAK YOUR SHAREPOINT INSTALLATION and will put it in the UNSUPPORTED STATE, use with EXTREME CAUTION!

    Details:

    http://mossblogger.blogspot.com/2010/06/administration-supported-database.html
    http://www.collabshow.com/2010/08/12/were-serious-dont-modify-your-database-or-face-consequences/
    http://sharepoint.stackexchange.com/questions/96291/is-accessing-sharepoint-content-database-in-code-advisable

.Parameter ServerInstance
    ServerInstance to query. For default instance, only specify the computer name: "MyComputer". For named instance, use the format "ComputerName\InstanceName".

.Parameter Database
    A character string specifying the name of a database.

.Parameter UseSqlCredential
    If this switch is specified, you will be asked for SQL AUTHENTICATION credentials.
    By default, connection is made with WINDOWS AUTHENTICATION and current user's credentials.
    To connect as another user using WINDOWS AUTHENTICATION, use RunAs to launch PowerShell under a different account.

.Parameter ListId
    Guid. SharePoint list Id, e.g. 'cff8ae4b-a78d-444c-8efd-5fe290821cb9'.

.Parameter Fields
    Set XML Schema for list. Uses 'tp_Fields' column.

.Parameter ContentTypes
    Set Content Types for list. Uses 'tp_ContentTypes' column.

.Parameter Force
    Suppress confirmation. Use with -Confirm:$false to suppress all confirmations.

.Example
    'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin' | Import-WssCompressedStructureBinary | Set-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9'
    Import XML Schema from binary file 'cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin' and update it in content database for list with ID 'cff8ae4b-a78d-444c-8efd-5fe290821cb9'
    

.Example
    New-WssCompressedStructure -Path 'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.xml' | Set-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9'
    Create new XML Schema from XML file 'cff8ae4b-a78d-444c-8efd-5fe290821cb9.xml' and update it in content database for list with ID 'cff8ae4b-a78d-444c-8efd-5fe290821cb9'

#>
function Set-SpListWssCompressedStructure
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')] 
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Database,

        [switch]$UseSqlCredential,

        [Parameter(Mandatory = $true)]
        [guid]$ListId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fields')]
        [switch]$Fields,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'ContentTypes')]
        [switch]$ContentTypes,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript({
            $_ |  Test-ValidWssCompressedStructure
        })]
        [ValidateNotNullOrEmpty()]
        $WssCompressedStructure,

        [switch]$Force
    )

    Process
    {
        $Row = if($Fields){
            'tp_Fields'
        } elseif ($ContentTypes){
            'tp_ContentTypes'
        }
        $Query = "Update AllLists SET $Row = @WssCompressedStructure WHERE tp_ID = @ListId"

        $RejectAll = $false
        $ConfirmAll = $false

        if($PSCmdlet.ShouldProcess( 
            'This operation will modify your SharePoint database!',
            "
            Server: $ServerInstance
            Database: $Database
            List guid: $ListId
            Query: $Query
            ",
            'SharePoint database update')
        ) {
            if(
                $Force -or $PSCmdlet.ShouldContinue(
                    'Are you REALLY sure you want to modify you SharePoint database?',
                    'SharePoint database update',
                    [ref]$ConfirmAll,
                    [ref]$RejectAll)
            ) {

                $Splat = @{
                    ServerInstance = $ServerInstance
                    Database= $Database
                    Query = $Query
                    SqlParameters = @{
                        WssCompressedStructure = $WssCompressedStructure | ConvertTo-WssCompressedStructureBinary
                        ListId = $ListId
                    }
                }

                if($UseSqlCredential){
                    $PsCred = Get-Credential
                    $Splat.Add('Credential', $PsCred)
                }

                Invoke-Sqlcmd2 @Splat
            }
        }
    }
}