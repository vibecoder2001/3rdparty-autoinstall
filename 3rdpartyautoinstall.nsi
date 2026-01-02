!include WinVer.nsh
!include x64.nsh
!include LogicLib.nsh
!include Sections.nsh
!include StrFunc.nsh

!define DRIVERNAME "3rdpartyautoinstall"
!define VERSION "1.0.1"

!define INTEL_WLAN_LIST "PCI\VEN_8086&DEV_02F0&*;PCI\VEN_8086&DEV_06F0&*;PCI\VEN_8086&DEV_2526&*;PCI\VEN_8086&DEV_2723&*;PCI\VEN_8086&DEV_2725&*;PCI\VEN_8086&DEV_272B&*;PCI\VEN_8086&DEV_30DC&*;PCI\VEN_8086&DEV_31DC&*;PCI\VEN_8086&DEV_34F0&*;PCI\VEN_8086&DEV_3DF0&*;PCI\VEN_8086&DEV_43F0&*;PCI\VEN_8086&DEV_4DF0&*;PCI\VEN_8086&DEV_51F0&*;PCI\VEN_8086&DEV_51F1&*;PCI\VEN_8086&DEV_54F0&*;PCI\VEN_8086&DEV_7740&*;PCI\VEN_8086&DEV_7A70&*;PCI\VEN_8086&DEV_7AF0&*;PCI\VEN_8086&DEV_7E40&*;PCI\VEN_8086&DEV_7F70&*;PCI\VEN_8086&DEV_9DF0&*;PCI\VEN_8086&DEV_A0F0&*;PCI\VEN_8086&DEV_A370&*;PCI\VEN_8086&DEV_A840&*;PCI\VEN_8086&DEV_E340&*;PCI\VEN_8086&DEV_E440&*"
!define MTK_WLAN_LIST "PCI\VEN_14C3&DEV_0616&*;PCI\VEN_14C3&DEV_0618&*;PCI\VEN_14C3&DEV_0619&*;PCI\VEN_14C3&DEV_0628&*;PCI\VEN_14C3&DEV_0629&*;PCI\VEN_14C3&DEV_062A&*;PCI\VEN_14C3&DEV_062B&*;PCI\VEN_14C3&DEV_0632&*;PCI\VEN_14C3&DEV_0633&*;PCI\VEN_14C3&DEV_0635&*"
!define RTK_WLAN_LIST "PCI\VEN_10EC&DEV_8852&*;PCI\VEN_10EC&DEV_8852A&*;PCI\VEN_10EC&DEV_8852B&*;PCI\VEN_10EC&DEV_8852C&*;PCI\VEN_10EC&DEV_8851B&*;PCI\VEN_10EC&DEV_8851C&*;PCI\VEN_10EC&DEV_C822&*;PCI\VEN_10EC&DEV_C821&*;PCI\VEN_10EC&DEV_C820&*"
!define BHT_SD_LIST "PCI\VEN_1217&DEV_8420&*;PCI\VEN_1217&DEV_8421&*;PCI\VEN_1217&DEV_8520&*;PCI\VEN_1217&DEV_8620&*;PCI\VEN_1217&DEV_8621&*;PCI\VEN_1217&DEV_8720&*;PCI\VEN_1217&DEV_8721&*;PCI\VEN_1217&DEV_8722&*;PCI\VEN_1217&DEV_8723&*"
!define GL_SD_LIST "PCI\VEN_17A0&DEV_7428&*;PCI\VEN_17A0&DEV_9750&*;PCI\VEN_17A0&DEV_9753&*;PCI\VEN_17A0&DEV_9755&*"
!define RTK_SD_LIST "PCI\VEN_10EC&DEV_5227&*;PCI\VEN_10EC&DEV_5228&*;PCI\VEN_10EC&DEV_522A&*;PCI\VEN_10EC&DEV_5249&*;PCI\VEN_10EC&DEV_524A&*;PCI\VEN_10EC&DEV_5250&*;PCI\VEN_10EC&DEV_525A&*;PCI\VEN_10EC&DEV_5260&*;PCI\VEN_10EC&DEV_5261&*;PCI\VEN_10EC&DEV_5264&*;PCI\VEN_10EC&DEV_526A&*;PCI\VEN_10EC&DEV_5287&*"

Caption "${DRIVERNAME} installer"
Name "${DRIVERNAME} ${VERSION}"
Outfile "${DRIVERNAME}.${VERSION}-installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

InstallDir "$TEMP\${DRIVERNAME}"

PageEx components
  ComponentText "Select which components you have. Autodetected components should be selected. Click install to start the installation." "" ""
PageExEnd

Page instfiles

Section
  SetOutPath $INSTDIR
  File /r "drivers"
SectionEnd

!macro _GetExpandExe _OutVar
  ${If} ${RunningX64}
    StrCpy ${_OutVar} "$WINDIR\Sysnative\expand.exe"
  ${Else}
    StrCpy ${_OutVar} "$SYSDIR\expand.exe"
  ${EndIf}
!macroend

!macro _GetPnPUtilExe _OutVar
  ${If} ${RunningX64}
    StrCpy ${_OutVar} "$WINDIR\Sysnative\pnputil.exe"
  ${Else}
    StrCpy ${_OutVar} "$SYSDIR\pnputil.exe"
  ${EndIf}
!macroend

!macro ExtractCab _CabRelPath _DestDir
  Push $9
  !insertmacro _GetExpandExe $9
  ; -F:* extracts everything
  nsExec::Exec '"$9" -F:* "$INSTDIR\drivers\${_CabRelPath}" "${_DestDir}"'
  Pop $9
!macroend

!macro InstallInfsFromDir _Dir
  Push $9
  !insertmacro _GetPnPUtilExe $9
  nsExec::Exec '"$9" /add-driver "${_Dir}\*.inf" /subdirs /install'
  Pop $9
!macroend

!macro PrepWorkDir _Subdir
  InitPluginsDir
  StrCpy $0 "$PLUGINSDIR\${_Subdir}"
  RMDir /r "$0"
  CreateDirectory "$0"
!macroend

Section /o "Intel WiFi Drivers" IntelWLAN
  !insertmacro InstallInfsFromDir "$INSTDIR\drivers\wifi\intel"
SectionEnd

Section /o "Mediatek WiFi Drivers" MtkWLAN
  !insertmacro InstallInfsFromDir "$INSTDIR\drivers\wifi\mtk"
SectionEnd

Section /o "Realtek WiFi Drivers" RtkWLAN
  !insertmacro InstallInfsFromDir "$INSTDIR\drivers\wifi\rtk"
SectionEnd

Section /o "Intel CML Chipset Drivers" CmlChip
  !insertmacro PrepWorkDir "drv_cml"

  !insertmacro ExtractCab "chipset\cml\chipset.cab" "$0"
  !insertmacro ExtractCab "chipset\cml\lpss.cab"    "$0"
  !insertmacro ExtractCab "chipset\cml-jsl-tgl\dptf.cab"    "$0"
  !insertmacro ExtractCab "chipset\heci.cab"    "$0"

  !insertmacro InstallInfsFromDir "$0"
  RMDir /r "$0"
SectionEnd

Section /o "Intel JSL Chipset Drivers" JslChip
  !insertmacro PrepWorkDir "drv_jsl"

  !insertmacro ExtractCab "chipset\jsl\chipset.cab"         "$0"
  !insertmacro ExtractCab "chipset\jsl\lpss.cab"            "$0"
  !insertmacro ExtractCab "chipset\cml-jsl-tgl\dptf.cab"        "$0"
  !insertmacro ExtractCab "chipset\jsl-tgl-adl\gna.cab"     "$0"
  !insertmacro ExtractCab "chipset\heci.cab"    "$0"

  !insertmacro InstallInfsFromDir "$0"
  RMDir /r "$0"
SectionEnd

Section /o "Intel TGL Chipset Drivers" TglChip
  !insertmacro PrepWorkDir "drv_tgl"

  !insertmacro ExtractCab "chipset\tgl\chipset.cab"     "$0"
  !insertmacro ExtractCab "chipset\tgl\lpss.cab"        "$0"
  !insertmacro ExtractCab "chipset\cml-jsl-tgl\dptf.cab"    "$0"
  !insertmacro ExtractCab "chipset\jsl-tgl-adl\gna.cab"     "$0"
  !insertmacro ExtractCab "chipset\heci.cab"    "$0"

  !insertmacro InstallInfsFromDir "$0"
  RMDir /r "$0"
SectionEnd

Section /o "Intel ADL/RPL Chipset Drivers" AdlChip
  !insertmacro PrepWorkDir "drv_adl"

  !insertmacro ExtractCab "chipset\adl-rpl\chipset.cab" "$0"
  !insertmacro ExtractCab "chipset\adl-rpl\lpss.cab"    "$0"
  !insertmacro ExtractCab "chipset\adl-rpl-mtl\ipf.cab"     "$0"
  !insertmacro ExtractCab "chipset\jsl-tgl-adl\gna.cab"     "$0"
  !insertmacro ExtractCab "chipset\heci.cab"    "$0"

  !insertmacro InstallInfsFromDir "$0"
  RMDir /r "$0"
SectionEnd

Section /o "Intel ADL-N/TWL Chipset Drivers" AdlNChip
  !insertmacro PrepWorkDir "drv_adln"

  !insertmacro ExtractCab "chipset\adl-rpl\chipset-n.cab" "$0"
  !insertmacro ExtractCab "chipset\adl-rpl\lpss-n.cab"    "$0"
  !insertmacro ExtractCab "chipset\adl-rpl-mtl\ipf.cab"       "$0"
  !insertmacro ExtractCab "chipset\jsl-tgl-adl\gna.cab"       "$0"
  !insertmacro ExtractCab "chipset\heci.cab"    "$0"

  !insertmacro InstallInfsFromDir "$0"
  RMDir /r "$0"
SectionEnd

Section /o "Intel MTL Chipset Drivers" MtlChip
  !insertmacro PrepWorkDir "drv_mtl"

  !insertmacro ExtractCab "chipset\mtl\chipset.cab" "$0"
  !insertmacro ExtractCab "chipset\mtl\lpss.cab"    "$0"
  !insertmacro ExtractCab "chipset\adl-rpl-mtl\ipf.cab"     "$0"
  !insertmacro ExtractCab "chipset\mtl\npu.cab"     "$0"
  !insertmacro ExtractCab "chipset\heci.cab"    "$0"

  !insertmacro InstallInfsFromDir "$0"
  RMDir /r "$0"
SectionEnd

Section /o "Genesis Logic SD Card Drivers" GlPciSD
  !insertmacro PrepWorkDir "drv_glpcisd"

  !insertmacro ExtractCab "$INSTDIR\drivers\sd\glpcisd.cab" "$0"
  !insertmacro InstallInfsFromDir "$0"

  RMDir /r "$0"
SectionEnd

Section /o "Bayhub SD Card Drivers" BhtSd
  !insertmacro PrepWorkDir "drv_bayhubsd"

  !insertmacro ExtractCab "$INSTDIR\drivers\sd\bayhubsd.cab" "$0"
  !insertmacro InstallInfsFromDir "$0"

  RMDir /r "$0"
SectionEnd

Section /o "Realtek SD Card Drivers" RtkSD
  !insertmacro PrepWorkDir "drv_rtksd"

  !insertmacro ExtractCab "$INSTDIR\drivers\sd\rtksd.cab" "$0"
  !insertmacro InstallInfsFromDir "$0"

  RMDir /r "$0"
SectionEnd

!macro DisableSection _SectionId
  Push $0
  SectionGetFlags ${_SectionId} $0
  ; unselect + disable (read-only)
  IntOp $0 $0 & ~${SF_SELECTED}
  IntOp $0 $0 | ${SF_RO}
  SectionSetFlags ${_SectionId} $0
  Pop $0
!macroend

!macro EnableSelectSection _SectionId
  Push $0
  SectionGetFlags ${_SectionId} $0
  ; enable + select
  IntOp $0 $0 & ~${SF_RO}
  IntOp $0 $0 | ${SF_SELECTED}
  SectionSetFlags ${_SectionId} $0
  Pop $0
!macroend

${StrStr}
Var DetOut

!macro SetSectionFromDetection _SectionId _Key
  Push $0
  ${StrStr} $0 $DetOut "${_Key}=1"
  ${If} $0 != ""
    !insertmacro EnableSelectSection ${_SectionId}
  ${Else}
    !insertmacro DisableSection ${_SectionId}
  ${EndIf}
  Pop $0
!macroend

; ----------------------------
; Run ONE PowerShell process, ONE Get-PnpDevice -PresentOnly, compute all flags
; Requires these !defines to exist:
;   INTEL_WLAN_LIST, MTK_WLAN_LIST, RTK_WLAN_LIST
;   BHT_SD_LIST, GL_SD_LIST, RTK_SD_LIST
; ----------------------------
!macro DetectHardwareOnce
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5

  ; Force 64-bit PowerShell on x64 systems
  ${If} ${RunningX64}
    StrCpy $3 "$WINDIR\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
  ${Else}
    StrCpy $3 "$SYSDIR\WindowsPowerShell\v1.0\powershell.exe"
  ${EndIf}

  ; Generate a temp .ps1 (avoids all quoting issues)
  GetTempFileName $4
  StrCpy $5 "$4.ps1"
  Rename $4 $5

  FileOpen $0 $5 w

  ; ---- PowerShell begins ----
  FileWrite $0 "$$ErrorActionPreference = 'SilentlyContinue'$\r$\n"
  FileWrite $0 "$$ids = Get-PnpDevice -PresentOnly | ForEach-Object { $$_.InstanceId }$\r$\n"

  FileWrite $0 "function AnyMatch([string]$$raw){$\r$\n"
  FileWrite $0 "  if ([string]::IsNullOrWhiteSpace($$raw)) { return $$false }$\r$\n"
  FileWrite $0 "  $$pats = $$raw -split ';' | ForEach-Object { $$_.Trim() } | Where-Object { $$_.Length -gt 0 }$\r$\n"
  FileWrite $0 "  foreach ($$p in $$pats) {$\r$\n"
  FileWrite $0 "    foreach ($$id in $$ids) { if ($$id -like $$p) { return $$true } }$\r$\n"
  FileWrite $0 "  }$\r$\n"
  FileWrite $0 "  return $$false$\r$\n"
  FileWrite $0 "}$\r$\n"

  ; Pattern sets (embedded; caller controls wildcards)
  FileWrite $0 "$$pat_IntelWLAN = '${INTEL_WLAN_LIST}'$\r$\n"
  FileWrite $0 "$$pat_MtkWLAN   = '${MTK_WLAN_LIST}'$\r$\n"
  FileWrite $0 "$$pat_RtkWLAN   = '${RTK_WLAN_LIST}'$\r$\n"

  FileWrite $0 "$$pat_CmlChip   = 'ACPI\INT34BB\0'$\r$\n"
  FileWrite $0 "$$pat_JslChip   = 'ACPI\INT34C8\0'$\r$\n"
  FileWrite $0 "$$pat_TglChip   = 'ACPI\INT34C5\0'$\r$\n"
  FileWrite $0 "$$pat_AdlChip   = 'ACPI\INTC1055\0;ACPI\INTC1056\0;ACPI\INTC1085\0'$\r$\n"
  FileWrite $0 "$$pat_AdlNChip  = 'ACPI\INTC1057\0'$\r$\n"
  FileWrite $0 "$$pat_MtlChip   = 'ACPI\INTC1083\0'$\r$\n"

  FileWrite $0 "$$pat_GlPciSD   = '${GL_SD_LIST}'$\r$\n"
  FileWrite $0 "$$pat_BhtSd     = '${BHT_SD_LIST}'$\r$\n"
  FileWrite $0 "$$pat_RtkSD     = '${RTK_SD_LIST}'$\r$\n"

  ; Emit Key=1/0 for each group (MUST match your EnableIfDetected keys)
  FileWrite $0 "foreach ($$k in 'IntelWLAN','MtkWLAN','RtkWLAN','CmlChip','JslChip','TglChip','AdlChip','AdlNChip','MtlChip','GlPciSD','BhtSd','RtkSD') {$\r$\n"
  FileWrite $0 "  $$raw = Get-Variable -Name ('pat_' + $$k) -ValueOnly$\r$\n"
  FileWrite $0 "  $$v = if (AnyMatch $$raw) { '1' } else { '0' }$\r$\n"
  FileWrite $0 "  Write-Output ($$k + '=' + $$v)$\r$\n"
  FileWrite $0 "}$\r$\n"
  ; ---- PowerShell ends ----

  FileClose $0

  ; Execute once; capture stdout in $DetOut
  nsExec::ExecToStack '"$3" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$5"'
  Pop $1   ; exit code (not used)
  Pop $2   ; stdout

  Delete "$5"

  StrCpy $DetOut $2

  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
!macroend

function .onInit
    ${If} ${RunningX64}
      # do nothing
    ${Else}
        MessageBox MB_ICONSTOP "32-bit (x86) Windows is not supported. Please reinstall 64-bit Windows."
        Abort
    ${EndIf}

    !insertmacro DetectHardwareOnce

    !insertmacro SetSectionFromDetection ${IntelWLAN} "IntelWLAN"
    !insertmacro SetSectionFromDetection ${MtkWLAN}   "MtkWLAN"
    !insertmacro SetSectionFromDetection ${RtkWLAN}   "RtkWLAN"
    !insertmacro SetSectionFromDetection ${CmlChip}   "CmlChip"
    !insertmacro SetSectionFromDetection ${JslChip}   "JslChip"
    !insertmacro SetSectionFromDetection ${TglChip}   "TglChip"
    !insertmacro SetSectionFromDetection ${AdlChip}   "AdlChip"
    !insertmacro SetSectionFromDetection ${AdlNChip}  "AdlNChip"
    !insertmacro SetSectionFromDetection ${MtlChip}   "MtlChip"
    !insertmacro SetSectionFromDetection ${GlPciSD}   "GlPciSD"
    !insertmacro SetSectionFromDetection ${BhtSd}     "BhtSd"
    !insertmacro SetSectionFromDetection ${RtkSD}     "RtkSD"
functionEnd

Function .onInstSuccess
  ; $INSTDIR is $TEMP\${DRIVERNAME}
  ; Remove extracted payload after successful install
  RMDir /r "$INSTDIR"
FunctionEnd

Function .onInstFailed
  RMDir /r "$INSTDIR"
FunctionEnd