#include-once
Func CollectCCGold($bTest = False)
	If Not $g_bChkEnableCollectCCGold Then Return
	Local $bWindowOpened = False
	Local $CollectedCCGold = 0
	Local $aCollect, $iBuilderToUse = $g_iCmbForgeBuilder + 1
	SetLog("Start Collecting Clan Capital Gold", $COLOR_INFO)
	ClickAway("Right")
	_Sleep(500)
	ZoomOut() ;ZoomOut first
	_Sleep(500)
	
	If QuickMIS("BC1", $g_sImgCCGoldCollect, 250, 550, 400, 730) Then
		Click($g_iQuickMISX, $g_iQuickMISY + 20)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 180, 760, 225) Then
				$bWindowOpened = True
				ExitLoop
			EndIf
			_Sleep(500)
		Next
		
		If $bWindowOpened Then 
			$aCollect = QuickMIS("CNX", $g_sImgCCGoldCollect, 120, 360, 740, 430)
			If IsArray($aCollect) And UBound($aCollect) > 0 Then
				SetLog("Collecting " & UBound($aCollect) & " Clan Capital Gold", $COLOR_INFO)
				For $i = 0 To UBound($aCollect) - 1
					If Not $bTest Then 
						Click($aCollect[$i][1], $aCollect[$i][2]) ;Click Collect
						$CollectedCCGold +=1
					Else
						SetLog("Test Only, Should Click on [" & $aCollect[$i][1] & "," & $aCollect[$i][2] & "]")
					EndIf
					_Sleep(500)
				Next
			EndIf
			_Sleep(1000)
			
			If $iBuilderToUse > 3 Then 
				SetLog("Checking 4th Builder forge result", $COLOR_INFO)
				ClickDrag(720, 315, 600, 315, 500)
				_Sleep(1000)
				$aCollect = QuickMIS("CNX", $g_sImgCCGoldCollect, 500, 360, 740, 430)
				If IsArray($aCollect) And UBound($aCollect) > 0 Then
					SetLog("Collecting " & UBound($aCollect) & " Clan Capital Gold", $COLOR_INFO)
					For $i = 0 To UBound($aCollect) - 1
						If Not $bTest Then 
							Click($aCollect[$i][1], $aCollect[$i][2]) ;Click Collect
							$CollectedCCGold +=1
						Else
							SetLog("Test Only, Should Click on [" & $aCollect[$i][1] & "," & $aCollect[$i][2] & "]")
						EndIf
						_Sleep(500)
					Next
				EndIf
			EndIf
			
			SetLog("Clan Capital Gold collected successfully!", $COLOR_SUCCESS)
			_Sleep(800)
			
			If QuickMIS("BC1", $g_sImgGeneralCloseButton, 715, 190, 760, 235) Then
				Click($g_iQuickMISX, $g_iQuickMISY) ;Click close button
			EndIf
			
		EndIf	
		$g_iStatsClanCapCollected = $g_iStatsClanCapCollected + $CollectedCCGold
	Else
		SetLog("No available Clan Capital Gold to be collected!", $COLOR_INFO)
		Return
	EndIf
	ClickAway("Right")
	If _Sleep($DELAYCOLLECT3) Then Return
EndFunc

Func ClanCapitalReport($SetLog = True)
	$g_iLootCCGold = getOcrAndCapture("coc-ms", 670, 17, 160, 25)
	$g_iLootCCMedal = getOcrAndCapture("coc-ms", 670, 70, 160, 25)
	GUICtrlSetData($g_lblCapitalGold, $g_iLootCCGold)
	GUICtrlSetData($g_lblCapitalMedal, $g_iLootCCMedal)
	
	If $SetLog Then
		SetLog("Capital Report", $COLOR_INFO)
		SetLog("[Gold]:" & $g_iLootCCGold & " [Medal]:" & $g_iLootCCMedal, $COLOR_SUCCESS)
	EndIf
	
	If QuickMis("BC1", $g_sImgCCRaid, 360, 480, 500, 530) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(5000) Then Return
		SkipChat()
		SwitchToCapitalMain()
	EndIf
EndFunc

Func OpenForgeWindow()
	Local $bRet = False
	If QuickMIS("BC1", $g_sImgForgeHouse, 200, 570, 400, 730) Then 
		Click($g_iQuickMISX + 10, $g_iQuickMISY + 10)
		For $i = 1 To 5
			SetDebugLog("Waiting for Forge Window #" & $i, $COLOR_ACTION)
			If QuickMis("BC1", $g_sImgGeneralCloseButton, 715, 180, 760, 225) Then
				$bRet = True
				ExitLoop
			EndIf
			_Sleep(600)
		Next
	EndIf
	Return $bRet
EndFunc

Func WaitStartCraftWindow()
	Local $bRet = False
	For $i = 1 To 5
		SetDebugLog("Waiting for StartCraft Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 620, 200, 670, 250) Then
			$bRet = True
			ExitLoop
		EndIf
		_Sleep(600)
	Next
	If Not $bRet Then SetLog("StartCraft Window does not open", $COLOR_ERROR)
	Return $bRet
EndFunc

Func RemoveDupCNX(ByRef $arr, $sortBy = 1, $distance = 10)
	Local $atmparray[0][4]
	Local $tmpCoord = 0
	_ArraySort($arr, 0, 0, 0, $sortBy) ;sort by 1 = , 2 = y
	For $i = 0 To UBound($arr) - 1
		SetDebugLog("SortBy:" & $arr[$i][$sortBy])
		SetDebugLog("tmpCoord:" & $tmpCoord)
		If $arr[$i][$sortBy] >= $tmpCoord + $distance Then 
			_ArrayAdd($atmparray, $arr[$i][0] & "|" & $arr[$i][1] & "|" & $arr[$i][2] & "|" & $arr[$i][3])
			$tmpCoord = $arr[$i][$sortBy] + $distance
		Else
			SetDebugLog("Skip this dup: " & $arr[$i][$sortBy] & " is near " & $tmpCoord, $COLOR_INFO)
			ContinueLoop
		EndIf		
	Next
	$arr = $atmparray
	SetDebugLog(_ArrayToString($arr))
EndFunc

Func ForgeClanCapitalGold($bTest = False)
	ClickAway("Right")
	ZoomOut()
	Local $aForgeType[5] = [$g_bChkEnableForgeGold, $g_bChkEnableForgeElix, $g_bChkEnableForgeDE, $g_bChkEnableForgeBBGold, $g_bChkEnableForgeBBElix]
	Local $bForgeEnabled = False
	Local $iBuilderToUse = $g_iCmbForgeBuilder + 1
	For $i In $aForgeType ;check for every option enabled
		If $i = True Then 
			$bForgeEnabled = True
			ExitLoop
		EndIf
	Next
	If Not $bForgeEnabled Then Return
	If Not $g_bRunState Then Return
	SetLog("Checking for Forge ClanCapital Gold", $COLOR_INFO)
	
	getBuilderCount(True) ;check if we have available builder
	If $bTest Then $g_iFreeBuilderCount = 1
	Local $iWallReserve = $g_bUpgradeWallSaveBuilder ? 1 : 0
	If $g_iFreeBuilderCount - $iWallReserve - ReservedBuildersForHeroes() < 1 Then ;check builder reserve on wall and hero upgrade
		SetLog("FreeBuilder=" & $g_iFreeBuilderCount & ", Reserved (ForHero=" & $g_iHeroReservedBuilder & " ForWall=" & $iWallReserve & ")", $COLOR_INFO)
		SetLog("Not Have builder, exiting", $COLOR_INFO)
		Return
	EndIf
	
	Local $iCurrentGold = getResourcesMainScreen(695, 23) ;get current Gold
	Local $iCurrentElix = getResourcesMainScreen(695, 74) ;get current Elixir
	Local $iCurrentDE = getResourcesMainScreen(720, 120) ;get current Dark Elixir
	If Not $g_bRunState Then Return
	If Not OpenForgeWindow() Then 
		SetLog("Forge Window not Opened, exiting", $COLOR_ACTION)
		Return
	EndIf
	
	If $iBuilderToUse > 3 Then ClickDrag(720, 315, 600, 315)
	If _Sleep(1000) Then Return
	
	If Not $g_bRunState Then Return
	SetLog("Number of Enabled builder for Forge = " & $iBuilderToUse, $COLOR_ACTION)
	If ($g_iTownHallLevel = 13 Or $g_iTownHallLevel = 12) And $iBuilderToUse = 4 Then
		SetLog("TH Level Allows 3 Builders For Forge", $COLOR_DEBUG)
		$iBuilderToUse = 3
	ElseIf $g_iTownHallLevel = 11 And $iBuilderToUse > 2 Then
		SetLog("TH Level Allows 2 Builders For Forge", $COLOR_DEBUG)
		$iBuilderToUse = 2
	ElseIf $g_iTownHallLevel < 11 And $iBuilderToUse > 1 Then
		SetLog("TH Level Allows Only 1 Builder For Forge", $COLOR_DEBUG)
		$iBuilderToUse = 1
	EndIf
	
	Local $iBuilder = 0
	Local $iActiveForge = QuickMIS("CNX", $g_sImgActiveForge, 120, 230, 740, 450) ;check if we have forge in progress
	RemoveDupCNX($iActiveForge)
	If IsArray($iActiveForge) And UBound($iActiveForge) > 0 Then
		_ArraySort($iActiveForge, 0, 0, 0, 1)
		If UBound($iActiveForge) >= $iBuilderToUse Then
			SetLog("We have All Builder Active for Forge", $COLOR_INFO)
			ClickAway("Right")
			Return
		EndIf
		$iBuilder = UBound($iActiveForge)
	EndIf
	
	SetLog("Already active builder Forging = " & $iBuilder, $COLOR_ACTION)
	If Not $g_bRunState Then Return
	Local $iBuilderToAssign = Number($iBuilderToUse) - Number($iBuilder)
	Local $aResource[5][2] = [["Gold", 240], ["Elixir", 330], ["Dark Elixir", 425], ["Builder Base Gold", 520], ["Builder Base Elixir", 610]]
	Local $aCraft = QuickMIS("CNX", $g_sImgCCGoldCraft, 120, 230, 740, 450)
	_ArraySort($aCraft, 0, 0, 0, 1) ;sort by column 1 (x coord)
	SetDebugLog("Count of Craft Button: " & UBound($aCraft))
	SetLog("Available Builder for forge = " & $iBuilderToAssign, $COLOR_INFO)
	If IsArray($aCraft) And UBound($aCraft) > 0 And UBound($aCraft, $UBOUND_COLUMNS) > 1 Then
		For $j = 1 To $iBuilderToAssign
			SetDebugLog("Proceed with builder #" & $j)
			Click($aCraft[$j-1][1], $aCraft[$j-1][2])
			_Sleep(500)
			If Not WaitStartCraftWindow() Then 
				ClickAway("Right")
				Return
			EndIf
			For $i = 0 To UBound($aForgeType) -1
				If $aForgeType[$i] = True Then ;check if ForgeType Enabled
					SetLog("Try Forge using " & $aResource[$i][0], $COLOR_INFO)
					Click($aResource[$i][1], 300)
					_Sleep(1000)
					Local $cost = getOcrAndCapture("coc-forge", 240, 380, 160, 25, True)
					Local $gain = getOcrAndCapture("coc-forge", 528, 395, 100, 25, True)
					If $cost = "" Then 
						SetLog("Not enough resource to forge with" & $aResource[$i][0], $COLOR_INFO)
						ContinueLoop
					EndIf
					Local $bSafeToForge = False
					Switch $aResource[$i][0]
						Case "Gold"
							If Number($cost) + 200000 <= $iCurrentGold Then $bSafeToForge = True
						Case "Elixir"
							If Number($cost) + 200000 <= $iCurrentElix Then $bSafeToForge = True
						Case "Dark Elixir"
							If Number($cost) + 10000 <= $iCurrentDE Then $bSafeToForge = True
					EndSwitch
					SetLog("Forge Cost:" & $cost & ", gain Capital Gold:" & $gain, $COLOR_ACTION)
					If Not $bSafeToForge Then 
						SetLog("Not safe to forge with " & $aResource[$i][0] & ", not enough resource to save", $COLOR_INFO)
						ContinueLoop
					EndIf
					
					If Not $bTest Then 
						Click(430, 480)
						SetLog("Success Forge with " & $aResource[$i][0] & ", will gain " & $gain & " Capital Gold", $COLOR_SUCCESS)
						_Sleep(1000)
						ExitLoop
					Else
						SetLog("Only Test, should click on [430,480]", $COLOR_INFO)
						ClickAway("Right")
					EndIf
				EndIf
				_Sleep(1000)
				If Not $g_bRunState Then Return
			Next
		Next
	EndIf
	_Sleep(1000)
	ClickAway("Right")
EndFunc

Func IsCCBuilderMenuOpen()
	Local $bRet = False
	Local $aBorder[4] = [350, 73, 0xF7F8F5, 40]
	Local $sTriangle
	If _CheckPixel($aBorder, True) Then 
		SetDebugLog("Found Border Color: " & _GetPixelColor($aBorder[0], $aBorder[1], True), $COLOR_ACTION)
		$bRet = True ;got correct color for border 
	EndIf
	
	If Not $bRet Then ;lets re check if border color check not success
		$sTriangle = getOcrAndCapture("coc-buildermenu-cc", 350, 55, 200, 25)
		SetDebugLog("$sTriangle: " & $sTriangle)
		If $sTriangle = "^" Or $sTriangle = "~" Then $bRet = True
	EndIf
	SetDebugLog(String($bRet))
	Return $bRet
EndFunc

Func ClickCCBuilder()
	Local $bRet = False
	If IsCCBuilderMenuOpen() Then $bRet = True
	If Not $bRet Then
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then 
			Click($g_iQuickMISX, $g_iQuickMISY)
			_Sleep(1000)
			If IsCCBuilderMenuOpen() Then $bRet = True
		EndIf
	EndIf
	Return $bRet
EndFunc

Func FindCCExistingUpgrade()
	Local $aResult[0][3], $aBackup[0][3], $name[2] = ["", 0]
	Local $IsFoundArmy = False
	Local $aUpgrade = QuickMIS("CNX", $g_sImgResourceCC, 400, 100, 555, 360)
	If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
		_ArraySort($aUpgrade, 0, 0, 0, 2) ;sort by Y coord
		
		For $i = 0 To UBound($aUpgrade) - 1
			$name = getCCBuildingName($aUpgrade[$i][1] - 255, $aUpgrade[$i][2] - 9)
			If $g_bChkAutoUpgradeCCPriorArmy Then
				For $y In $g_bCCPriorArmy
					If StringInStr($name[0], $y) Then
						SetLog("Upgrade for Army Stuff Detected", $COLOR_SUCCESS1)
						$aResult = $aBackup
						_ArrayAdd($aResult, $name[0] & "|" & $aUpgrade[$i][1] & "|" &  $aUpgrade[$i][2])
						$IsFoundArmy = True
						ExitLoop 2
					EndIf
				Next
			EndIf
		Next
		If $IsFoundArmy = True Then Return $aResult
		
		For $i = 0 To UBound($aUpgrade) - 1
			$name = getCCBuildingName($aUpgrade[$i][1] - 255, $aUpgrade[$i][2] - 9)
			If $g_bChkAutoUpgradeCCIgnore Then 
				For $y In $aCCBuildingIgnore
					If StringInStr($name[0], $y) Then 
						SetLog("Upgrade for " & $name[0] & " Ignored, Skip!!", $COLOR_ACTION)
						ContinueLoop 2 ;skip this upgrade, looking next 
					EndIf
				Next
			EndIf
			If $g_bChkAutoUpgradeCCWallIgnore Then ; Filter for wall
				If StringInStr($name[0], "Wall") Then 
					SetLog("Upgrade for Walls Ignored, Skip!!", $COLOR_ACTION)
					ContinueLoop ;skip this upgrade, looking next 
				EndIf
			EndIf
			_ArrayAdd($aResult, $name[0] & "|" & $aUpgrade[$i][1] & "|" &  $aUpgrade[$i][2])
		Next
	EndIf
	Return $aResult
EndFunc

Func FindCCSuggestedUpgrade()
	Local $aResult[0][3], $aBackup[0][3], $name[2] = ["", 0]
	Local $IsFoundArmy = False
	Local $aUpgrade = QuickMIS("CNX", $g_sImgResourceCC, 400, 100, 560, 360)
	If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
		_ArraySort($aUpgrade, 0, 0, 0, 2) ;sort by Y coord
		
		For $i = 0 To UBound($aUpgrade) - 1
			SetDebugLog("Pixel on " & $aUpgrade[$i][1] - 15 & "," & $aUpgrade[$i][2] - 6 & ": " & _GetPixelColor($aUpgrade[$i][1] - 10, $aUpgrade[$i][2] - 5, True), $COLOR_INFO)
			If _ColorCheck(_GetPixelColor($aUpgrade[$i][1] - 15, $aUpgrade[$i][2] - 6, True), Hex(0xffffff, 6), 20) Then ContinueLoop;check if we have progressbar, upgrade to ignore
			$name = getCCBuildingNameSuggested($aUpgrade[$i][1] - 230, $aUpgrade[$i][2] - 12)
			If $name[0] = "l" Then $name = getCCBuildingNameBlue($aUpgrade[$i][1] - 230, $aUpgrade[$i][2] - 12)
			If $g_bChkAutoUpgradeCCPriorArmy Then
				For $y In $g_bCCPriorArmy
					If StringInStr($name[0], $y) Then
						SetLog("Upgrade for Army Stuff Detected", $COLOR_SUCCESS1)
						$aResult = $aBackup
						_ArrayAdd($aResult, $name[0] & "|" & $aUpgrade[$i][1] & "|" &  $aUpgrade[$i][2])
						$IsFoundArmy = True
						ExitLoop 2
					EndIf
				Next
			EndIf
		Next
		If $IsFoundArmy = True Then Return $aResult
		
		For $i = 0 To UBound($aUpgrade) - 1
			SetDebugLog("Pixel on " & $aUpgrade[$i][1] - 15 & "," & $aUpgrade[$i][2] - 6 & ": " & _GetPixelColor($aUpgrade[$i][1] - 10, $aUpgrade[$i][2] - 5, True), $COLOR_INFO)
			If _ColorCheck(_GetPixelColor($aUpgrade[$i][1] - 15, $aUpgrade[$i][2] - 6, True), Hex(0xffffff, 6), 20) Then ContinueLoop;check if we have progressbar, upgrade to ignore
			$name = getCCBuildingNameSuggested($aUpgrade[$i][1] - 230, $aUpgrade[$i][2] - 12)
			If $name[0] = "l" Then $name = getCCBuildingNameBlue($aUpgrade[$i][1] - 230, $aUpgrade[$i][2] - 12)
			If $g_bChkAutoUpgradeCCIgnore Then 
				For $y In $aCCBuildingIgnore
					If StringInStr($name[0], $y) Then 
						SetLog("Upgrade for " & $name[0] & " Ignored, Skip!!", $COLOR_ACTION)
						ContinueLoop 2 ;skip this upgrade, looking next 
					EndIf
				Next
			EndIf
			If $g_bChkAutoUpgradeCCWallIgnore Then ; Filter for wall
				If StringInStr($name[0], "Wall") Then 
					SetLog("Upgrade for Walls Ignored, Skip!!", $COLOR_ACTION)
					ContinueLoop ;skip this upgrade, looking next 
				EndIf
			EndIf
			_ArrayAdd($aResult, $name[0] & "|" & $aUpgrade[$i][1] & "|" &  $aUpgrade[$i][2])
		Next
	EndIf
	Return $aResult
EndFunc

Func WaitUpgradeButtonCC()
	Local $aRet[3] = [False, 0, 0]
	For $i = 1 To 10
		If Not $g_bRunState Then Return $aRet
		SetLog("Waiting for Upgrade Button #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgCCUpgradeButton, 300, 570, 600, 680) Then ;check for upgrade button (Hammer)
			$aRet[0] = True
			$aRet[1] = $g_iQuickMISX
			$aRet[2] = $g_iQuickMISY
			Return $aRet ;immediately return as we found upgrade button
		EndIf
		_Sleep(1000)
		If $i > 3 Then SkipChat()
	Next
	Return $aRet
EndFunc

Func WaitUpgradeWindowCC()
	Local $bRet = False
	For $i = 1 To 10
		SetLog("Waiting for Upgrade Window #" & $i, $COLOR_ACTION)
		_Sleep(1000)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 685, 125, 730, 170) Then ;check if upgrade window opened
			If Not QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 490, 200, 630) Then	;also check if there is no tutorial
				$bRet = True
				Return $bRet
			EndIf
		EndIf
		SkipChat()
	Next
	If Not $bRet Then SetLog("Upgrade Window doesn't open", $COLOR_ERROR)
	Return $bRet
EndFunc

Func SkipChat()
	For $y = 1 To 10 
		If Not $g_bRunState Then Return
		If QuickMIS("BC1", $g_sImgClanCapitalTutorial, 30, 490, 200, 630) Then			
			Click($g_iQuickMISX + 100, $g_iQuickMISY)
			SetLog("Skip chat #" & $y, $COLOR_INFO)
			_Sleep(5000)
		Else
			If $y > 5 Then 
				ExitLoop
			EndIf
		EndIf
		_Sleep(1000)
	Next
EndFunc

Func SwitchToMainVillage()
	Local $bRet = False
	SetDebugLog("Going To MainVillage", $COLOR_ACTION)
	SwitchToCapitalMain()
	For $i = 1 To 10
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 150, 760, 200) Then ; check if we have window covering map, close it!
			Click($g_iQuickMISX, $g_iQuickMISY)
			SetLog("Found a window covering map, close it!", $COLOR_INFO)
			_Sleep(2000)
			SwitchToCapitalMain()
		EndIf
		If QuickMIS("BC1", $g_sImgCCMap, 15, 610, 115, 700) Then 
			If $g_iQuickMISName = "ReturnHome" Then 
				Click(60, 670) ;Click ReturnHome
				_Sleep(2000)
				ExitLoop
			EndIf
		EndIf
	Next
	ZoomOut()
	_Sleep(500)
	If isOnMainVillage() Then 
		$bRet = True
	EndIf
	Return $bRet
EndFunc

Func SwitchToClanCapital()
	Local $bRet = False
	Local $bAirShipFound = False
	For $z = 0 to 10
		If QuickMIS("BC1", $g_sImgAirShip, 200, 570, 400, 730) Then
			$bAirShipFound = True
			Click($g_iQuickMISX, $g_iQuickMISY)
			ExitLoop
		EndIf
		_Sleep(350)	
	Next
	If $bAirShipFound = False Then Return $bRet
	_Sleep(3000)
	If QuickMis("BC1", $g_sImgGeneralCloseButton, 710, 150, 760, 200) Then
		SetLog("Found raid window covering map, close it!", $COLOR_INFO)
		Click($g_iQuickMISX, $g_iQuickMISY)
		_Sleep(3000)
	EndIf
	If QuickMis("BC1", $g_sImgCCRaid, 360, 480, 500, 530) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If _Sleep(5000) Then Return
		SkipChat()
	EndIf
	SwitchToCapitalMain()
	For $i = 1 To 10
		SetDebugLog("Waiting for Travel to Clan Capital Map #" & $i, $COLOR_ACTION)
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 65) Then
			$bRet = True
			SetLog("Success Travel to Clan Capital Map", $COLOR_INFO)
			ExitLoop
		EndIf
		_Sleep(800)
	Next
	If $bRet Then ClanCapitalReport()
	Return $bRet
EndFunc

Func SwitchToCapitalMain()
	Local $bRet = False
	SetDebugLog("Going to Clan Capital", $COLOR_ACTION)
	For $i = 1 To 5
		If QuickMIS("BC1", $g_sImgCCMap, 15, 610, 115, 700) Then 
			If $g_iQuickMISName = "MapButton" Then 
				Click(60, 670) ;Click Map
				_Sleep(3000)
			EndIf
		EndIf
		If QuickMIS("BC1", $g_sImgCCMap, 15, 610, 115, 700) Then 
			If $g_iQuickMISName = "ReturnHome" Then 
				SetDebugLog("We are on Clan Capital", $COLOR_ACTION)
				$bRet = True
				ExitLoop
			EndIf
		EndIf
	Next
	Return $bRet
EndFunc

Func AutoUpgradeCC()
	If Not $g_bChkEnableAutoUpgradeCC Then Return
	Local $Failed = False
	SetLog("Checking Clan Capital AutoUpgrade", $COLOR_INFO)
	ZoomOut() ;ZoomOut first
	If Not SwitchToClanCapital() Then Return
	_Sleep(1000)
	If Number($g_iLootCCGold) = 0 Then 
		SetLog("No Capital Gold to spend to Contribute", $COLOR_INFO)
		SwitchToMainVillage()
		Return
	EndIf
	
	While $g_iLootCCGold > 0
		If Not $g_bRunState Then Return
		If ClickCCBuilder() Then 
			_Sleep(1000)
			Local $Text = getOcrAndCapture("coc-buildermenu-capital", 345, 81, 100, 25)
			If StringInStr($Text, "No") Then 
				SetLog("No Upgrades in progress", $COLOR_INFO)
				_Sleep(500)
				ClickAway("Right") ;close builder menu
				ClanCapitalReport(False)
				ExitLoop
			EndIf
		Else
			SetLog("Fail to open Builder Menu", $COLOR_ERROR)
			$Failed = True
			ExitLoop
		EndIf
		_Sleep(500)
		Local $aUpgrade = FindCCExistingUpgrade() ;Find on Capital Map, should only find currently on progress building
		If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then 
			If Not CapitalMainUpgradeLoop($aUpgrade) Then
				$Failed = True
				ExitLoop
			EndIf
		EndIf
	WEnd
	
	_Sleep(500)
	ClickAway("Right")
	If $Failed Then 
		SwitchToMainVillage()
		Return
	EndIf
		
	;Upgrade through districts map
	Local $aMapCoord[7][3] = [["Golem Quarry", 185, 590], ["Dragon Cliffs", 630, 465], ["Builder's Workshop", 490, 525], ["Balloon Lagoon", 300, 490], _ 
							 ["Wizard Valley", 410, 400], ["Barbarian Camp", 530, 340], ["Capital Peak", 400, 225]]
	If Number($g_iLootCCGold) > 0 Then
		SetLog("Checking Upgrades From Districts", $COLOR_INFO)
		For $i = 0 To UBound($aMapCoord) - 1
			_Sleep(1000)
			SetLog("[" & $i & "] Checking " & $aMapCoord[$i][0], $COLOR_ACTION)
			If QuickMIS("BC1", $g_sImgLock, $aMapCoord[$i][1], $aMapCoord[$i][2] - 120, $aMapCoord[$i][1] + 100, $aMapCoord[$i][2]) Then 
				SetLog($aMapCoord[$i][0] & " is Locked", $COLOR_INFO)
				ContinueLoop
			Else
				SetLog($aMapCoord[$i][0] & " is UnLocked", $COLOR_INFO)
			EndIf
			SetLog("Go to " & $aMapCoord[$i][0] & " to Check Upgrades", $COLOR_ACTION)
			Click($aMapCoord[$i][1], $aMapCoord[$i][2])
			If Not $g_bRunState Then Return
			_Sleep(2000)
			If Not WaitForMap($aMapCoord[$i][0]) Then 
				SetLog("Going to " & $aMapCoord[$i][0] & " Failed", $COLOR_ERROR)
				SwitchToCapitalMain()
				_Sleep(1500)
				ContinueLoop
			EndIf
			If Not ClickCCBuilder() Then
				SetLog("Fail to open Builder Menu", $COLOR_ERROR)
				SwitchToCapitalMain()
				_Sleep(1500)
				ContinueLoop
			EndIf	
			_Sleep(1000)
			Local $aUpgrade = FindCCSuggestedUpgrade() ;Find on Distric Map, Will Read Blue Font (Ruins.. etc)
			If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
				DistrictUpgrade($aUpgrade)
				If Number($g_iLootCCGold) = 0 Then
					ExitLoop
				EndIf
			Else
				Local $Text = getOcrAndCapture("coc-buildermenu", 300, 81, 230, 25)
				Local $aDone[2] = ["All possible", "done"]
				Local $bAllDone = False
				For $z In $aDone
					If StringInStr($Text, $z) Then
						SetDebugLog("Match with: " & $z)
						SetLog("All Possible Upgrades Done In This District", $COLOR_INFO)
						$bAllDone = True
					EndIf
				Next
				If $bAllDone Then SwitchToCapitalMain()
			EndIf
			If Not $g_bRunState Then Return
		Next
	EndIf
	ClanCapitalReport(False)
	If Not $g_bRunState Then Return
	SwitchToMainVillage()
EndFunc

Func CapitalMainUpgradeLoop($aUpgrade)
	Local $aRet[3] = [False, 0, 0]
	Local $Failed = False
	_Sleep(1000)
	SetLog("Checking Upgrades From Capital Map", $COLOR_INFO)
	For $i = 0 To UBound($aUpgrade) - 1
		SetDebugLog("CCExistingUpgrade: " & $aUpgrade[$i][0])
		Click($aUpgrade[$i][1], $aUpgrade[$i][2])
		_Sleep(2000)
		$aRet = WaitUpgradeButtonCC()
		If Not $g_bRunState Then Return
		If Not $aRet[0] Then
			SetLog("Upgrade Button Not Found", $COLOR_ERROR)
			$Failed = True
			ExitLoop
		Else
			If IsUpgradeCCIgnore() Then
				SetLog("Upgrade Ignored, Back To Main Village", $COLOR_INFO) ; Should Never happen
				$Failed = True
				ExitLoop
			EndIf
			Local $BuildingName = getOcrAndCapture("coc-build", 200, 550, 460, 30)
			Click($aRet[1], $aRet[2])
			_Sleep(2000)
			If Not WaitUpgradeWindowCC() Then
				$Failed = True
				ExitLoop
			EndIf
			Local $cost = getOcrAndCapture("coc-ms", 590, 550, 160, 25)
			If Not $g_bRunState Then Return
			Click(645, 560) ;Click Contribute
			$g_iStatsClanCapUpgrade = $g_iStatsClanCapUpgrade + 1
			AutoUpgradeCCLog($BuildingName, $cost)
			_Sleep(1000)
			ClickAway("Right")
			_Sleep(800)
		EndIf
		ExitLoop
	Next
	SwitchToCapitalMain()
	_Sleep(1000)
	ClanCapitalReport(False)
	If Not $Failed Then Return True
	If Not $g_bRunState Then Return
EndFunc

Func DistrictUpgrade($aUpgrade)
	Local $aRet[3] = [False, 0, 0]
	_Sleep(1000)
	For $j = 0 To UBound($aUpgrade) - 1
		SetDebugLog("CCSuggestedUpgrade: " & $aUpgrade[$j][0])
		Click($aUpgrade[$j][1], $aUpgrade[$j][2])
		_Sleep(2000)
		$aRet = WaitUpgradeButtonCC()
		If Not $aRet[0] Then
			SetLog("Upgrade Button Not Found", $COLOR_ERROR)
			ExitLoop
		Else
			If IsUpgradeCCIgnore() Then
				SetLog("Upgrade Ignored, Looking Next Upgrade", $COLOR_INFO) ; Shouldn't happen
				ContinueLoop
			EndIf
			Local $BuildingName = getOcrAndCapture("coc-build", 200, 550, 450, 30)						
			Click($aRet[1], $aRet[2])
			_Sleep(2000)
			If Not WaitUpgradeWindowCC() Then
				ExitLoop
			EndIf
			Local $cost = getOcrAndCapture("coc-ms", 590, 550, 160, 25)						
			If Not $g_bRunState Then Return
			Click(645, 560) ;Click Contribute
			$g_iStatsClanCapUpgrade = $g_iStatsClanCapUpgrade + 1
			AutoUpgradeCCLog($BuildingName, $cost)
			_Sleep(1000)
			ClickAway("Right")
			_Sleep(800)
			ClickAway("Right")
		EndIf
		ExitLoop
	Next
	_Sleep(1000)
	SwitchToCapitalMain()
	_Sleep(2000)
	ClanCapitalReport(False)
EndFunc

Func WaitForMap($sMapName = "Capital Peak")
	Local $bRet
	For $i = 1 To 10
		SetDebugLog("Waiting for " & $sMapName & "#" & $i, $COLOR_ACTION)
		_Sleep(2000)
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then ExitLoop
	Next
	Local $aMapName = StringSplit($sMapName, " ", $STR_NOCOUNT)
	Local $Text = getOcrAndCapture("coc-mapname", $g_iQuickMISX, $g_iQuickMISY - 12, 230, 35)
	SetDebugLog("$Text: " & $Text)
	For $i In $aMapName
		If StringInStr($Text, $i) Then 
			SetDebugLog("Match with: " & $i)
			$bRet = True
			SetLog("We are on " & $sMapName, $COLOR_INFO)
			ExitLoop
		EndIf
	Next
	If Not $bRet Then
		SetDebugLog("checking with image")
		Local $ccMap = QuickMIS("CNX", $g_sImgCCMapName, $g_iQuickMISX, $g_iQuickMISY - 10, $g_iQuickMISX + 200, $g_iQuickMISY + 50)
		If IsArray($ccMap) And UBound($ccMap) > 0 Then
			Local $mapName = "dummyName"
			For $z = 0 To UBound($ccMap) - 1
				$mapName = String($ccMap[$z][0])
				For $i In $aMapName
					If StringInStr($mapName, $i) Then 
						SetDebugLog("Match with: " & $i)
						$bRet = True
						SetLog("We are on " & $sMapName, $COLOR_INFO)
						ExitLoop
					EndIf
				Next
			Next
		EndIf
	EndIf
	Return $bRet
EndFunc

Func IsUpgradeCCIgnore()
	Local $bRet = False
	Local $UpgradeName = getOcrAndCapture("coc-build", 200, 550, 460, 30)
	If $g_bChkAutoUpgradeCCWallIgnore Then ; Filter for wall
		If StringInStr($UpgradeName, "Wall") Then 
				SetDebugLog($UpgradeName & " Match with: Wall") 
				SetLog("Upgrade for wall Ignored, Skip!!", $COLOR_ACTION)
				$bRet = True
		EndIf
	EndIf
	If $g_bChkAutoUpgradeCCIgnore Then 
		For $y In $aCCBuildingIgnore
			If StringInStr($UpgradeName, $y) Then 
				SetDebugLog($UpgradeName & " Match with: " & $y) 
				SetLog("Upgrade for " & $y & " Ignored, Skip!!", $COLOR_ACTION)
				$bRet = True
				ExitLoop
			Else
				SetDebugLog("OCR: " & $UpgradeName & " compare with: " & $y)
			EndIf
		Next
	EndIf
	Return $bRet
EndFunc

Func AutoUpgradeCCLog($BuildingName = "", $cost = "")
	SetLog("Successfully upgrade " & $BuildingName & ", Contribute " & $cost & " CapitalGold", $COLOR_SUCCESS)
	GUICtrlSetData($g_hTxtAutoUpgradeCCLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Upgrade " & $BuildingName & ", contribute " & $cost & " CapitalGold", 1)
EndFunc