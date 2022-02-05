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

!define ARP "Software\Microsoft\Windows\CurrentVersion\Uninstall\dictpw"

!ifndef EXEFILE
	!define EXEFILE 'build\dictpw.exe'
!endif

!ifndef DOCFILE
	!define DOCFILE 'build\dictpw.pdf'
!endif

# I discovered that using MUI adds about 30KB of bloat to the installer, it
# also seems slower, there's a little pause before it starts the installation.
# We'll use the old installer widget by default.
!ifdef USE_MUI
        !define MUI_DIRECTORYPAGE_VARIABLE "$INSTDIR"
        !include "MUI2.nsh"
        !insertmacro MUI_PAGE_LICENSE "LICENSE.md"
        !insertmacro MUI_PAGE_DIRECTORY
        !insertmacro MUI_PAGE_INSTFILES
        !insertmacro MUI_UNPAGE_DIRECTORY
        !insertmacro MUI_UNPAGE_INSTFILES

	!ifndef OUTFILE
		!define OUTFILE 'build\setup-mui-dictpw.exe'
	!endif
!else
        LicenseData "LICENSE.md"
        Page license
        Page directory
        Page instfiles
        UninstPage uninstConfirm
        UninstPage instfiles
	!ifndef OUTFILE
		!define OUTFILE 'build\setup-dictpw.exe'
	!endif
!endif

Name "dictpw"
OutFile "${OUTFILE}"
InstallDir "$PROGRAMFILES\dictpw"
RequestExecutionLevel admin
ManifestSupportedOS all

Section
        SetOutPath $INSTDIR
	CreateDirectory "$INSTDIR\bin"
        File /oname=bin\dictpw.exe "${EXEFILE}"
# Read: If we've been given a path to the msys dll. For the msys build.
!ifdef MSYS
	File /oname=bin\msys-2.0.dll "${MSYS}"
!endif
        File /oname=LICENSE.txt "LICENSE.md"
        File /oname=README.txt "README.md"
        File "${DOCFILE}"
        WriteUninstaller "$INSTDIR\uninstall.exe"

        # Add/Remove programs registry
        WriteRegStr HKLM "${ARP}" \
                         "InstallLocation" "$\"$INSTDIR$\""
        WriteRegStr HKLM "${ARP}" \
                         "DisplayName" \
			 "dictpw -- dictionary-based password generator"
        WriteRegStr HKLM "${ARP}" \
                         "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
        WriteRegStr HKLM "${ARP}" \
                         "QuietUninstallString" \
			 "$\"$INSTDIR\uninstall.exe$\" /S"
        WriteRegStr HKLM "${ARP}" \
                         "URLUpdateInfo" "https://github.com/guijan/dictpw"
        WriteRegStr HKLM "${ARP}" \
                         "URLInfoAbout" "https://github.com/guijan/dictpw"
        WriteRegDWORD HKLM "${ARP}" \
                           "NoModify" 0x00000001
        WriteRegDWORD HKLM "${ARP}" \
                           "NoRepair" 0x00000001
        ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
        IntFmt $0 "0x%08X" $0
        WriteRegDWORD HKLM "${ARP}" "EstimatedSize" "$0"

	!define ap \
		"Software\Microsoft\Windows\CurrentVersion\App Paths\dictpw.exe"
        # Allows running the program with `start /b /wait dictpw`
        WriteRegStr HKLM "${ap}" \
                         "" "$INSTDIR\bin\dictpw.exe"
SectionEnd

Section "Uninstall"
        DeleteRegKey HKLM \
		"Software\Microsoft\Windows\CurrentVersion\App Paths\dictpw.exe"
        DeleteRegKey HKLM \
		"Software\Microsoft\Windows\CurrentVersion\Uninstall\dictpw"
        Delete "$INSTDIR\uninstall.exe"
        Delete "$INSTDIR\dictpw.pdf"
        Delete "$INSTDIR\README.txt"
        Delete "$INSTDIR\LICENSE.txt"
!ifdef MSYS
	Delete "$INSTDIR\bin\msys-2.0.dll"
!endif
        Delete "$INSTDIR\bin\dictpw.exe"
        RMDir "$INSTDIR\bin"
        RMDir "$INSTDIR"
SectionEnd
