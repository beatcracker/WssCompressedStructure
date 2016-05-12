<#
.Synopsis
    Converts byte array to WssCompressedStructure object

.Parameter InputObject
    Byte array

.Example
    $Object | ConvertFrom-WssCompressedStructureBinary

.Example
    $ObjectA, $ObjectB | ConvertFrom-WssCompressedStructureBinary

.Example
    ConvertFrom-WssCompressedStructureBinary -InputObject $Object

.Example
    ConvertFrom-WssCompressedStructureBinary -InputObject $ObjectA, $ObjectB
#>
function ConvertFrom-WssCompressedStructureBinary
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]$InputObject
    )

    Begin
    {
        $IsCollected = $false
        $Pipeline = New-Object -TypeName System.Collections.Generic.List[byte]
        $NewWssCompressedStructureHeader = {
            New-WssCompressedStructureHeader `
                -ID $Pipeline[0..1] `
                -Version $Pipeline[2..3] `
                -FileHeaderSize $Pipeline[4..7] `
                -OrigSize $Pipeline[8..11] `
                -ZlibStream $Pipeline[12..($Pipeline.Count - 1)] | Add-TypeName
        }
    }

    Process
    {
        # Do we have an array?
        if($InputObject.Length -gt 1) {
            # Is this a nested array?
            if($InputObject[0].Length -gt 1) {
                # For each item in nested array
                foreach($item in $InputObject) {
                    # This shouldn't be a nested array
                    if($item[0].Length -eq 1 ){
                        # Create new WssCompressedStructureHeader
                        $Pipeline.Clear()
                        $Pipeline.AddRange($item)
                        . $NewWssCompressedStructureHeader
                    } else {
                        Write-Error 'Looks like nested multidimensional array, can''t work with this!'
                    }
                }
            } else {
                # Create new WssCompressedStructureHeader
                $Pipeline.Clear()
                $Pipeline.AddRange([byte[]]$InputObject)
                . $NewWssCompressedStructureHeader
            }
        # Not an array?
        } else {
            # Collect all pipeline input, then
            $IsCollected = $true
            $Pipeline.Add($InputObject[0])
        }
    }

    End
    {
        # Had we collected pipeline input?
        if($IsCollected) {
            # Create new WssCompressedStructureHeader
            . $NewWssCompressedStructureHeader
        }
    }
}