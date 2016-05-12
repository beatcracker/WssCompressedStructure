<#
.Synopsis
    Imports binary file as WssCompressedStructure

.Description
    Imports binary file as WssCompressedStructure. Supports wildcards and piping from Get-ChildItem.

.Parameter Path
    Array of paths, supports wildcards and piping from Get-ChildItem.

.Example
    'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin' | Import-WssCompressedStructureBinary

.Example
    Import-WssCompressedStructureBinary -Path 'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin'

.Example
    'X:\Wss\*.bin' | Import-WssCompressedStructureBinary

.Example
    Get-ChildItem -Path 'X:\Wss\*.bin' | Import-WssCompressedStructureBinary
#>
function Import-WssCompressedStructureBinary
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [string[]]$Path
    )

    Process
    {
        $AllPaths = foreach($item in $Path){
            $PSCmdlet.GetResolvedProviderPathFromPSPath($item, [ref]$null)
        }

        foreach($item in $AllPaths){
            [System.IO.File]::ReadAllBytes($item) |
                ConvertFrom-WssCompressedStructureBinary |
                    Where-Object {$_ | Test-ValidWssCompressedStructure}
        }
    }
}