<#
.Synopsis
    Creates new WssCompressedStructure header from array of bytes

.Description
    Creates new WssCompressedStructure header from array of bytes.
    Default values are used for omitted parameters

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

.Link
        # https://msdn.microsoft.com/en-us/library/hh661051.aspx
#>
function New-WssCompressedStructureHeader
{
    # Suppressing warning: we don't actually change system state
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    Param
    (
        [ValidateCount(2, 2)]
        [byte[]]$ID = [byte[]](0xA8, 0xA9),

        [ValidateCount(2, 2)]
        [byte[]]$Version = [byte[]](0x30, 0x31),

        [ValidateCount(4, 4)]
        [byte[]]$FileHeaderSize = [byte[]](0x0C, 0x00, 0x00 ,0x00),                    

        [ValidateCount(4, 4)]
        [byte[]]$OrigSize = $null,

        [byte[]]$ZlibStream = $null
    )

    End
    {
        New-Object -TypeName PsCustomObject -Property @{
            ID = $ID
            Version =  $Version
            FileHeaderSize = $FileHeaderSize
            OrigSize = $OrigSize
            ZlibStream = $ZlibStream                                                 
        } | Select-Object -Property ID, Version, FileHeaderSize, OrigSize, ZlibStream
    }
}