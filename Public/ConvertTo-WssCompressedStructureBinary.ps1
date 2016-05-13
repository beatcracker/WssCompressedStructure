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
    # Suppressing warning, see comment in Process block
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly')]
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
        # Comma is used to stop PS from wrapping output to System.Object,
        # so we can write [byte[]] to the pipeline
        ,[byte[]]$(
            foreach($prop in (New-WssCompressedStructureHeader).PsObject.Properties.Name){
                $InputObject.$prop
            }
        )
    }
}