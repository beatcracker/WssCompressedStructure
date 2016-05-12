<#
.Synopsis
    Converts WssCompressedStructure object to byte array

.Parameter InputObject
    Valid WssCompressedStructure object

.Example
    $Object | ConvertTo-WssCompressedStructureBinary

.Example
    ConvertTo-WssCompressedStructureBinary -InputObject $Object
#>
function ConvertTo-WssCompressedStructureBinary
{
    [CmdletBinding()]
    [OutputType([byte[]])]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript({
            $_ | Test-ValidWssCompressedStructure
        })]
        $InputObject
    )

    Process
    {
        ,[byte[]]$(
            foreach($prop in (New-WssCompressedStructureHeader).PsObject.Properties.Name){
                $InputObject.$prop
            }
        )
    }
}