<#
.Synopsis
    Test if WssCompressedStructure object conforms to MS specs.

.Parameter ID
    2 bytes:  MUST be 0xA8A9

.Parameter Version
    2 bytes:  For Microsoft SharePoint Foundation 2013, MUST be 0x3031 (ASCII "01")

.Parameter FileHeaderSize
    4 bytes:  A 4-byte, unsigned integer specifying the size of the header. In Microsoft SharePoint Foundation 2013, it is 0x0C000000.

.Parameter OrigSize
    4 bytes: A 4-byte, unsigned integer specifying the size of the original content. It MUST be the size of the uncompressed stream before compression.

.Parameter ZlibStream
    N bytes: The compressed string using zlib compression.

.Parameter Expand
    With Expand switch function will also try to expand ZlibStream and compare its decompressed size to OrigSize.
    By default, this function only checks these magic values in header: ID, Version, FileHeaderSize.

.Link
    # https://msdn.microsoft.com/en-us/library/hh661051.aspx

.Outputs
    This function will return true if object is valid WssCompressedStructure and false otherwise.
#>
function Test-ValidWssCompressedStructure
{
    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateCount(2, 2)]
        [byte[]]$ID,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateCount(2, 2)]
        [byte[]]$Version,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateCount(4, 4)]
        [byte[]]$FileHeaderSize,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Expand')]
        [ValidateCount(4, 4)]
        [byte[]]$OrigSize,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Expand')]
        [ValidateNotNullOrEmpty()]
        [byte[]]$ZlibStream,

        [Parameter(ParameterSetName = 'Expand')]
        [switch]$Expand
    )

    Process
    {
        $WCS_HDR = New-WssCompressedStructureHeader
        $ret = switch ($PSBoundParameters.Keys) {
            'ID' {
                [System.BitConverter]::ToUInt16($ID, 0) -eq  [System.BitConverter]::ToUInt16($WCS_HDR.ID, 0)
            }
            'Version' {
                [System.BitConverter]::ToUInt16($Version, 0) -eq [System.BitConverter]::ToUInt16($WCS_HDR.Version, 0)
            }
            'FileHeaderSize' {
                [System.BitConverter]::ToUInt32($FileHeaderSize, 0) -eq [System.BitConverter]::ToUInt32($WCS_HDR.FileHeaderSize, 0)
            }
            'Expand' {
                try {
                    [bool](Expand-WssCompressedStructure -OrigSize $OrigSize -ZlibStream $ZlibStream -ErrorAction Stop)
                } catch {
                    $false
                }
            }
        }

        $ret -notcontains $false
    }
}