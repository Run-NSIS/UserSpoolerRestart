<#
	Services ACL Split
	GSolone (2022)
	Credits:
		https://www.sqlshack.com/powershell-split-a-string-into-an-array/
		https://www.oreilly.com/library/view/mastering-windows-powershell/9781787126305/1e4f0048-80d2-465e-a0e2-c2fc2b61535f.xhtml
		https://www.winhelponline.com/blog/view-edit-service-permissions-windows/
#>

Param(
  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)][string] $ACL
)

$Split = $($ACL) -Split '(?=\))'

for($i = 0; $i -lt ($Split.Count -1); $i++) {
	if ($Split[$i].EndsWith('AU')) {
		$SplitACL = $Split[$i] -Split '(?=\;)'
		if ($SplitACL[2].EndsWith('RPWPDT')) {
			$AU_ACLMod = $SplitACL[2]
		} else {
			$AU_ACLMod = $SplitACL[2] + "RPWPDT"
		}
		$AUMod = $SplitACL[0] + $SplitACL[1] + $AU_ACLMod + $SplitACL[3] + $SplitACL[4] + $SplitACL[5]
		#Write-Host $AUMod -NoNewLine
		$Output = $Output + $AUMod
	} else {
		#Write-Host $Split[$i] -NoNewLine
		$Output = $Output + $Split[$i]
	}
}
#Write-Host ")"
$Output = $Output + ")"
echo $Output