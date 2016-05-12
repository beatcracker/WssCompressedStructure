Mock New-WssCompressedStructure {
    Import-Csv -LiteralPath "$here\Mocks\WssCompressedStructure.csv" | ForEach-Object {
        $ret = $_
        $_.PsObject.Properties.Name | ForEach-Object {
            $ret.$_ = $ret.$_ | Invoke-Expression
        }
        $ret
    }
}