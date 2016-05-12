$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')
Import-Module -Name "$here\..\..\WssCompressedStructure" -ErrorAction Stop

Describe "$FunctionName" {
    InModuleScope WssCompressedStructure {
        It 'Creates new WssCompressedStructure header with default values in correct order' {
            Compare-Object -ReferenceObject (
                'ID', 'Version', 'FileHeaderSize', 'OrigSize', 'ZlibStream'
            ) -DifferenceObject (
                (New-WssCompressedStructureHeader).PsObject.Properties.Name
            ) -SyncWindow 0 |
                Should BeNullOrEmpty
        }

        It 'Creates new WssCompressedStructure header with specified parameters' {
            $Params = @{
                ID = 1,2
                Version = 3,4
                FileHeaderSize = 5, 6, 7 ,8
                OrigSize = 9, 10, 11, 12
                ZlibStream = 13, 14, 15, 16
            }

            $Params.GetEnumerator() | ForEach-Object {
                $Splat = @{$_.Key = $_.Value}
                New-WssCompressedStructureHeader @Splat |
                    Select-Object -ExpandProperty $_.Key |
                        Should BeExactly $_.Value
            }
        }

        It 'Creates new valid WssCompressedStructure from WssCompressedStructureHeader' {
            $WssCSH = New-WssCompressedStructureHeader
            [System.BitConverter]::ToUInt16($WssCSH.ID, 0) | Should BeExactly 43432
            [System.BitConverter]::ToUInt16($WssCSH.Version, 0) | Should BeExactly 12592
            [System.BitConverter]::ToUInt32($WssCSH.FileHeaderSize, 0)  | Should BeExactly 12

            $TestString = 'FOOBAR'
            $TestStringBytes = [System.Text.Encoding]::UTF8.GetBytes($TestString)
            $TestStringZlibStream = [Ionic.Zlib.ZlibStream]::CompressBuffer($TestStringBytes)
            $TestStringSize =  [System.BitConverter]::GetBytes([Uint32]($TestStringBytes.Length))

            New-WssCompressedStructureHeader -OrigSize $TestStringSize -ZlibStream $TestStringZlibStream |
                Test-ValidWssCompressedStructure -Expand |
                    Should Be $true
        }
    }
}