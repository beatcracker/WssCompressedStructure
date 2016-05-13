<#
.Synopsis
    Creates new WssCompressedStructure from string or file

.Parameter InputObject
    Array of source strings

.Parameter Path
    Array of paths, supports wildcards and piping from Get-ChildItem.

.Example
    '15.0.0.4535.0.0<FieldRef Name="ContentTypeId"/><FieldRef Name="Title" ColName="nvarchar1"/><FieldRef Name="_ModerationComments" ColName="ntext1"/><FieldRef Name="File_x0020_Type" ColName="nvarchar2"/>' | New-WssCompressedStructure

.Example
    New-WssCompressedStructure -InputObject '15.0.0.4535.0.0<FieldRef Name="ContentTypeId"/><FieldRef Name="Title" ColName="nvarchar1"/><FieldRef Name="_ModerationComments" ColName="ntext1"/><FieldRef Name="File_x0020_Type" ColName="nvarchar2"/>' 

.Example
    New-WssCompressedStructure -Path 'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.xml'

.Example
    'X:\Wss\*.xml' | New-WssCompressedStructure

.Example
    Get-ChildItem -Path 'X:\Wss\*.xml' | New-WssCompressedStructure
#>
function New-WssCompressedStructure
{
    # Suppressing warning: we don't actually change system state
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(DefaultParameterSetName = 'String')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'String')]
        [ValidateNotNullOrEmpty()]
        [string[]]$InputObject,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'File')]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [string[]]$Path
    )

    Begin
    {
        $NewWssCompressedStructure = {
            $WssStruct = New-WssCompressedStructureHeader

            $itemBytes = [System.Text.Encoding]::UTF8.GetBytes($item)

            $WssStruct.OrigSize = [System.BitConverter]::GetBytes([Uint32]($itemBytes.Length))
            $WssStruct.ZlibStream = [Ionic.Zlib.ZlibStream]::CompressBuffer($itemBytes)

            $WssStruct | Add-TypeName
        }
    }

    Process
    {
        if($PSCmdlet.ParameterSetName -eq 'String'){
            foreach($item in $InputObject){
                . $NewWssCompressedStructure
            }
        } else {
            $AllPaths = foreach($item in $Path){
                $PSCmdlet.GetResolvedProviderPathFromPSPath($item, [ref]$null)
            }

            foreach($filePath in $AllPaths){
                if($item = [System.IO.File]::ReadAllText($filePath)){
                    . $NewWssCompressedStructure
                }
            }
        }
    }
}