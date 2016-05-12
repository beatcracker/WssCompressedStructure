<#
.Synopsis
    Gets SharePoint list data from content database as WssCompressedStructure.

.Parameter ServerInstance
    ServerInstance to query. For default instance, only specify the computer name: "MyComputer". For named instance, use the format "ComputerName\InstanceName".

.Parameter Database
    A character string specifying the name of a database.

.Parameter Credential
    If this switch is specified, you will be asked for SQL AUTHENTICATION credentials.
    By default, connection is made with WINDOWS AUTHENTICATION and current user's credentials.
    To connect as another user using WINDOWS AUTHENTICATION, use RunAs to launch PowerShell under a different account.

.Parameter ListId
    Guid. One or more SharePoint list Id, e.g. 'cff8ae4b-a78d-444c-8efd-5fe290821cb9'.
    By default, function queries all lists from SharePoint database. You can use this parameter to limit search only to specific lists.

.Parameter Fields
    Get XML field schema for list. Uses 'tp_Fields' column.

.Parameter ContentTypes
    Get Content Types for list. Uses 'tp_ContentTypes' column.

.Example
    Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields

    Get Fields for all SharePoint lists from content database.

.Example
    Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9', '67152e33-e937-4bb8-b11c-809eff92b207'

    Gets Fields for particular SharePoint lists from content database.

.Example
    'cff8ae4b-a78d-444c-8efd-5fe290821cb9', '67152e33-e937-4bb8-b11c-809eff92b207' | Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields

    Gets Fields for particular SharePoint lists from content database.

.Example
    Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes

    Get Content Types for all SharePoint lists from content database

.Example
    Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9', '67152e33-e937-4bb8-b11c-809eff92b207'

    Gets Content Types for particular SharePoint lists from content database.

.Example
    'cff8ae4b-a78d-444c-8efd-5fe290821cb9', '67152e33-e937-4bb8-b11c-809eff92b207' | Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes

    Gets Content Types for particular SharePoint lists from content database.  
#>
function Get-SpListWssCompressedStructure
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Database,

        [switch]$Credential,

        [Parameter(ValueFromPipeline = $true)]
        [guid[]]$ListId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fields')]
        [switch]$Fields,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'ContentTypes')]
        [switch]$ContentTypes
    )

    End
    {
        $Pipeline = @($input)
        if($Pipeline){
            $ListId = $Pipeline
        }

        $Row = if($Fields){
            'tp_Fields'
        } elseif($ContentTypes){
            'tp_ContentTypes'
        }

        if($ListId){
            $WhereList = "AND tp_ID IN ('{0}')" -f ($ListId -join "', '")
        }

        $Query = "SELECT $Row, tp_ID, tp_Title, tp_Description FROM AllLists WHERE $Row IS NOT NULL $WhereList"

        $Splat = @{
            ServerInstance = $ServerInstance
            Database= $Database
            Query = $Query
        }

        if($Credential){
            $PsCred = Get-Credential
            $Splat.Add('Credential', $PsCred)
        }

        Invoke-Sqlcmd2 @Splat | ForEach-Object {
            $Id = $_.tp_ID.Guid
            $Title = $_.tp_Title
            $Description = $_.tp_Description
            ConvertFrom-WssCompressedStructureBinary -InputObject $_.$Row |
                Where-Object {$_ | Test-ValidWssCompressedStructure} |
                    Select-Object -Property (
                        @{n = 'ListId' ; e = {$Id}},
                        @{n = 'ListTitle' ; e = {$Title}},
                        @{n = 'ListDescription' ; e = {$Description}},
                        '*'
                    ) | Add-TypeName
        }
    }
}