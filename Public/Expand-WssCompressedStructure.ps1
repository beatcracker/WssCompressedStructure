<#
.Synopsis
    Expands WssCompressedStructure object to xml file

.Parameter InputObject
    Valid WssCompressedStructure object

.Parameter ListId
    Guid of SharePoint list. Objects that come from Get-SpListWssCompressedStructure function will have this property.

.Parameter DestinationPath
    Path to the directory, where xml files will be saved. Used with ListId parameter or objects that come from Get-SpListWssCompressedStructure function.
    This parameter is used when expanding multiple objects that are acquired via Get-SpListWssCompressedStructure function.
    Files will be named <GUID>.xml, e.g.: cff8ae4b-a78d-444c-8efd-5fe290821cb9.xml

.Parameter FilePath
    Path to the xml file to export. Used for single objects, that don't have ListId propery (created by New-WssCompressedStructure function).

.Example
    $Object | Expand-WssCompressedStructure -FilePath 'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin'

.Example
    Expand-WssCompressedStructure -InputObject $Object -FilePath 'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin'

.Example
    $Object | Expand-WssCompressedStructure -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9' -DestinationPath 'X:\Wss\'

.Example
    Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields | Expand-WssCompressedStructure -DestinationPath 'X:\Wss\'
#>
function Expand-WssCompressedStructure
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateCount(4, 4)]
        [byte[]]$OrigSize,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [byte[]]$ZlibStream,

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
        if($Decompressed = [Ionic.Zlib.ZlibStream]::UncompressBuffer($ZlibStream)){
            $CompSize = [System.BitConverter]::ToUInt32($OrigSize, 0)
            $DecompSize = $Decompressed.Length

            if($CompSize -ne $DecompSize){
                Write-Error "Decompressed size mismatch! Expected: $CompSize, got: $DecompSize"
            }

            if($DestinationPath){
                [System.IO.File]::WriteAllBytes(
                    (Join-Path -Path $PSCmdlet.GetUnresolvedProviderPathFromPSPath($DestinationPath) -ChildPath "$ListId.xml"),
                    $Decompressed
                )
            } elseif ($FilePath){
                [System.IO.File]::WriteAllBytes(
                    $PSCmdlet.GetUnresolvedProviderPathFromPSPath($FilePath),
                    $Decompressed
                )
            } else {
                [System.Text.Encoding]::UTF8.GetString($Decompressed)
            }
        }
    }
}