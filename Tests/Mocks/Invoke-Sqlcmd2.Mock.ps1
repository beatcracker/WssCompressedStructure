Mock Invoke-Sqlcmd2 {
    Import-Csv -LiteralPath "$here\Mocks\SqlResult.csv" | ForEach-Object {
        $ret = $_
        $_.PsObject.Properties.Name | ForEach-Object {
            $ret.$_ = $ret.$_ | Invoke-Expression
        }
        $ret | Select-Object -ExcludeProperty 'Row' -Property (
            '*',
            @{
                n = if ($Fields) {'tp_Fields'} elseif ($ContentTypes) {'tp_ContentTypes'};
                e = {$_.Row}
            }
        )
    } 
}