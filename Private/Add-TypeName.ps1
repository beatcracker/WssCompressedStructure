<#
.Synopsis
    Adds TypeName 'WssCompressedStructure.Header' to piped object
#>
filter Add-TypeName {
    $_.PSObject.TypeNames.Insert(0, 'WssCompressedStructure.Header')
    $_
}