<#
.Synopsis
    Exports WssCompressedStructure object to binary file

.Parameter InputObject
    Valid WssCompressedStructure object

.Parameter ListId
    Guid of SharePoint list. Objects that come from Get-SpListWssCompressedStructure function will have this property.

.Parameter DestinationPath
    Path to the directory, where binary files will be saved. Used with ListId parameter or objects that come from Get-SpListWssCompressedStructure function.
    This parameter is used when exporting multiple objects that are acquired via Get-SpListWssCompressedStructure function.
    Files will be named <GUID>.bin, e.g.: cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin

.Parameter FilePath
    Path to the binary file to export. Used for single objects, that don't have ListId propery (created by New-WssCompressedStructure function).

.Example
    $Object | Export-WssCompressedStructureBinary -FilePath 'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin'

.Example
    Export-WssCompressedStructureBinary -InputObject $Object -FilePath 'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin'

.Example
    $Object | Export-WssCompressedStructureBinary -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9' -DestinationPath 'X:\Wss\'

.Example
    Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields | Export-WssCompressedStructureBinary -DestinationPath 'X:\Wss\'
#>
function Export-WssCompressedStructureBinary
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript({
            $_ | Test-ValidWssCompressedStructure
        })]
        [PsCustomObject]$InputObject,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Dir')]
        [ValidateNotNullOrEmpty()]
        [string]$ListId,

        [Parameter(ParameterSetName = 'Dir')]
        [ValidateScript({
            if(!(Test-Path -Path $_ -PathType Container)){
                throw "Target directory doesn't exist: $_"
            }
            $true
        })]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath,

        [Parameter(ParameterSetName = 'File')]
        [ValidateScript({
            $ParentDir = Split-Path -Path $_
            if(!(Test-Path -Path $ParentDir -PathType Container)){
                throw "Target directory doesn't exist: $ParentDir"
            }
            $true
        })]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath
    )

    Process
    {
        if($Decompressed = $InputObject | ConvertTo-WssCompressedStructureBinary){
            if($DestinationPath){
                [System.IO.File]::WriteAllBytes(
                    (Join-Path -Path $PSCmdlet.GetUnresolvedProviderPathFromPSPath($DestinationPath) -ChildPath "$ListId.bin"),
                    $Decompressed
                )
            } elseif ($FilePath){
                [System.IO.File]::WriteAllBytes(
                    $PSCmdlet.GetUnresolvedProviderPathFromPSPath($FilePath),
                    $Decompressed
                )
            } else {
                $Decompressed
            }
        }
    }
}