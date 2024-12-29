#!/usr/bin/makensis

# Copyright (c) 2022 Guilherme Janczak <guilherme.janczak@yandex.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# This script isn't meant to be used directly. dictpw_installer.sh is its
# interface.

!include "FileFunc.nsh"

!ifndef EXEFILE
	!define EXEFILE "..\build\dictpw.exe"
!endif

!ifndef DOCFILE
	!define DOCFILE "..\build\dictpw.txt"
!endif

!ifndef OUTFILE
	!define OUTFILE "..\build\setup-dictpw.exe"
!endif

!define LIBOBSD_LICENSE	"..\build\subprojects\libobsd\LICENSE_libobsd.txt"

!define MUI_DIRECTORYPAGE_VARIABLE "$INSTDIR"
!include "MUI2.nsh"
!insertmacro MUI_PAGE_LICENSE "..\LICENSE.md"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_DIRECTORY
!insertmacro MUI_UNPAGE_INSTFILES

Name "dictpw"
OutFile "${OUTFILE}"
InstallDir "$PROGRAMFILES\dictpw"
RequestExecutionLevel admin
showinstdetails show

Section
	# Uninstalling previous versions allows changing the installed files
	# without leaving any lingering files.
	Call UninstPrevious

        SetOutPath $INSTDIR
	CreateDirectory "$INSTDIR\bin"
        File /oname=bin\dictpw.exe "${EXEFILE}"
# Read: If we're building for the MSYS2 environment, distribute the msys DLL.
!ifdef MSYS
	File /oname=bin\msys-2.0.dll "${MSYS}"
!endif
        File "..\build\LICENSE.txt"
!if /FileExists "${LIBOBSD_LICENSE}"
	File "${LIBOBSD_LICENSE}"
!endif
        File "..\build\README.txt"
        File "${DOCFILE}"
        WriteUninstaller "$INSTDIR\uninstall.exe"

        # Add/Remove programs registry
	!define UN "Software\Microsoft\Windows\CurrentVersion\Uninstall\dictpw"
        WriteRegStr HKLM "${UN}" \
                         "InstallLocation" "$\"$INSTDIR$\""
        WriteRegStr HKLM "${UN}" \
                         "DisplayName" \
			 "dictpw -- generate password from dictionary"
        WriteRegStr HKLM "${UN}" \
                         "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
        WriteRegStr HKLM "${UN}" \
                         "QuietUninstallString" \
			 "$\"$INSTDIR\uninstall.exe$\" /S"
        WriteRegStr HKLM "${UN}" \
                         "URLUpdateInfo" "https://github.com/guijan/dictpw"
        WriteRegStr HKLM "${UN}" \
                         "URLInfoAbout" "https://github.com/guijan/dictpw"
        WriteRegDWORD HKLM "${UN}" \
                           "NoModify" 0x00000001
        WriteRegDWORD HKLM "${UN}" \
                           "NoRepair" 0x00000001

	# Windows needs to be told the install size manually.
        ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
        IntFmt $0 "0x%08X" $0
        WriteRegDWORD HKLM "${UN}" "EstimatedSize" "$0"

        # Allows running the program with `start /b /wait dictpw`
	!define AP \
		"Software\Microsoft\Windows\CurrentVersion\App Paths\dictpw.exe"
        WriteRegStr HKLM "${AP}" "" "$INSTDIR\bin\dictpw.exe"
SectionEnd

Section "Uninstall"
        DeleteRegKey HKLM "${AP}"
        DeleteRegKey HKLM "${UN}"
        Delete "$INSTDIR\dictpw.txt"
        Delete "$INSTDIR\README.txt"
!if /FileExists "${LIBOBSD_LICENSE}"
	Delete "$INSTDIR\LICENSE_libobsd.txt"
!endif
        Delete "$INSTDIR\LICENSE.txt"
!ifdef MSYS
	Delete "$INSTDIR\bin\msys-2.0.dll"
!endif
        Delete "$INSTDIR\bin\dictpw.exe"
	RMDir "$INSTDIR\bin"

	# Make sure to delete uninstall.exe only after everything else is
	# deleted.
	Delete "$INSTDIR\uninstall.exe"

        RMDir "$INSTDIR"
SectionEnd


Function UninstPrevious
	Push $R0
	Push $R1

	# References:
	# https://nsis.sourceforge.io/Talk:Auto-uninstall_old_before_installing_new
	# https://stackoverflow.com/questions/719631/how-do-i-require-user-to-uninstall-previous-version-with-nsis
	ReadRegStr $R1 HKLM "${UN}" "InstallLocation"
	StrCmp $R1 "" ret
	ReadRegStr $R0 HKLM "${UN}" "QuietUninstallString"

	# Remove the first and the last characters of InstallLocation, that is,
	# its enclosing quotes.
	# This is for:
	# https://nsis.sourceforge.io/When_I_use_ExecWait_uninstaller.exe_it_doesn%27t_wait_for_the_uninstaller
	StrCpy $R1 $R1 ""  1
	StrCpy $R1 $R1 -1
	ExecWait "$R0 _?=$R1"

ret:
	Pop $R1
	Pop $R0
FunctionEnd
