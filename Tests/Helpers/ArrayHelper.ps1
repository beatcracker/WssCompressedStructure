# https://www.simple-talk.com/sysadmin/powershell/practical-powershell-unit-testing-checking-program-flow/

<#
    Simple boolean indicating whether arrays match (order independent)
#>
function AreArraysEqual([object[]]$a1, [object[]]$a2)
{
    return @(Compare-Object $a1 $a2).Length -eq 0 
}


<#
    Report of array differences (order independent).
    Returns an empty string if the arrays match, otherwise enumerates
    differences between the expected and actual results.
    This is handy for unit tests to give meaningful output upon failure, as in
        ArrayDifferences $result $expected | Should BeNullOrEmpty
#>
function ArrayDifferences([object[]]$actual, [object[]]$expected)
{
    $result = ""
    $diffs = @(Compare-Object $actual $expected)
    if ($diffs) {
        $surplus = $diffs | ? SideIndicator -eq "<="
        $missing = $diffs | ? SideIndicator -eq "=>"
        if ($surplus) {
            $result += "Surplus: " + ($surplus.InputObject -join ",")
        }
        if ($missing) {
            if ($result) { $result += " && " }
            $result += "Missing: " + ($missing.InputObject -join ",")
        }
    }
    $result
}
