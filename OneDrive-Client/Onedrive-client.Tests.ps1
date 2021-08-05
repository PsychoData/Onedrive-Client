$ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

$ManifestPath = "$ModulePath\$ModuleName.psd1"
Describe "DescribeName" {
    Context "ContextName" {
        It "ItName" {
            #Assertion
        }
    }
}