; Copyright (c) 2025 Guilherme Janczak <guilherme.janczak@yandex.com>
;
; Permission to use, copy, modify, and distribute this software for any
; purpose with or without fee is hereby granted, provided that the above
; copyright notice and this permission notice appear in all copies.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

#ifndef MESON
    #error "This installer can only be generated with Meson"
#endif

[Setup]
AppId=dictpw_{{sample.judiciary.virus.wildly.grafted.askew.overture.paprika}
AppName={#NAME}
AppVersion={#VERSION}
VersionInfoDescription="generate password from dictionary"
VersionInfoVersion={#VERSION}
; Don't put the version in the Add/Remove Programs entry, that's weird.
UninstallDisplayName={#NAME}
AppCopyright="(c) Guilherme Janczak"
AppPublisherURL={#URL}
AppSupportURL={#URL}
AppUpdatesURL={#URL}
DefaultDirName={autopf}\{#NAME}
ArchitecturesAllowed={#ARCH}
ArchitecturesInstallIn64BitMode=x64compatible
DefaultGroupName={#NAME}
DisableProgramGroupPage=yes
LicenseFile={#LICENSE}
PrivilegesRequiredOverridesAllowed=dialog
SourceDir={#BUILDDIR}
OutputDir=.
Compression=lzma
SolidCompression=yes
WizardStyle=modern
MinVersion={#WIN_MIN}
; Work around the time misdesign typical on Windows.
TimeStampsInUTC=yes
Uninstallable=WizardIsTaskSelected('stationary')
ChangesEnvironment=WizardIsTaskSelected('stationary\env_path')

[Tasks]
Name: stationary; \
    Description: "Stationary Installation (creates registry entries and uninstaller)"; \
    Flags: exclusive checkablealone
Name: stationary\env_path; Description: "Add to $env:PATH"
; "portable" is just a marker and never used
Name: portable; \
    Description: "Portable Installation (no registry entries and no uninstaller)"; \
    Flags: unchecked exclusive

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
#define EXEDESTDIR '{app}\bin'
#ifdef MSYS_DLL
Source: "{#MSYS_DLL}"; DestDir: "{#EXEDESTDIR}"; Flags: ignoreversion
#endif
Source: "{#EXEFILE}"; DestDir: "{#EXEDESTDIR}"; Flags: ignoreversion
Source: "{#MANFILE}"; DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly uninsremovereadonly; \
    Attribs: readonly
Source: "{#LICENSE}"; DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly uninsremovereadonly; \
    Attribs: readonly
Source: "{#README}"; DestDir: "{app}"; \
    Flags: isreadme ignoreversion overwritereadonly uninsremovereadonly; \
    Attribs: readonly
; LIBOBSD_LICENSE is optional, it may not be needed on msys2 someday.
#ifdef LIBOBSD_LICENSE
Source: "{#LIBOBSD_LICENSE}"; DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly uninsremovereadonly; \
    Attribs: readonly
#endif

[Registry]
Root: HKA; \
    Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\dictpw.exe"; \
    Flags: uninsdeletekey; \
    ValueType: string; \
    ValueData: "{#EXEDESTDIR}\dictpw.exe"; \
    Tasks: stationary
#define ENVIRONMENT \
            'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
Root: HKLM; \
    Subkey: "{#ENVIRONMENT}"; \
    ValueType: expandsz; \
    ValueName: "Path"; \
    ValueData: "{olddata};{#EXEDESTDIR}"; \
    Check: ShouldIAddToPATH('{#EXEDESTDIR}'); \
    Tasks: stationary\env_path

[code]
Function ShouldIAddToPATH(Path: string): boolean;
var
    PathList: string;
begin
    Result := true;
    if RegQueryStringValue(HKLM, '{#ENVIRONMENT}', 'Path', PathList) then
        Result := Pos(';' + PathList + ';', ';' + Path + ';') = 0;
end;

Procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
    Path, PathList: String;
    Position: Integer;
    PathLen: Longint;
begin
    Path := ExpandConstant('{#EXEDESTDIR}')
    If (CurUninstallStep = usPostUninstall) and
        { can't `WizardIsTaskSelected('stationary\env_path') and` in uninstall }
        RegQueryStringValue(HKLM, '{#ENVIRONMENT}', 'Path', PathList) then
    begin
        PathLen := Length(Path)
        Position := Pos(Path, PathList)
        If Position <> 0 then
        begin
            Delete(PathList, Position, PathLen);
            If Length(PathList) <> 0 then
            begin
                If PathList[Position-1] = ';' then
                    Position := Position - 1;
                Delete(PathList, Position, 1);
                RegWriteExpandStringValue(HKLM, '{#ENVIRONMENT}', 'Path',
                                          PathList);
            end;
        end;
    end;
end;

Function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo,
         MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo,
         MemoTasksInfo: String): String;
begin
    Result := 'If {#NAME} has been installed before, the installer will ';
    If not WizardIsTaskSelected('stationary') then
        Result := Result + 'NOT'
    else
        Result := Result + 'first';
    Result := Result + ' prompt to uninstall the previous version.' +
              Newline + Newline;

    if MemoUserInfoInfo <> '' then begin
        Result := MemoUserInfoInfo + Newline + NewLine;
    end;
    if MemoDirInfo <> '' then begin
        Result := Result + MemoDirInfo + Newline + NewLine;
    end;
    if MemoTypeInfo <> '' then begin
        Result := Result + MemoTypeInfo + Newline + NewLine;
    end;
    if MemoComponentsInfo <> '' then begin
        Result := Result + MemoComponentsInfo + Newline + NewLine;
    end;
    if MemoGroupInfo <> '' then begin
        Result := Result + MemoGroupInfo + Newline + NewLine;
    end;
    if MemoTasksInfo <> '' then begin
        Result := Result + MemoTasksInfo + Newline + NewLine;
    end;
end;

Function UninstallPrevious(const RootKey: Integer; const AppId,
                           Args: String): String;
var
    UninstallString, msg: String;
    ResultCode: Integer;
begin
    If RegQueryStringValue(RootKey,
        'Software\Microsoft\Windows\CurrentVersion\Uninstall\' + AppId,
        'UninstallString', UninstallString) then
    begin
        UninstallString := RemoveQuotes(UninstallString);
        Result := SetupMessage(msgCannotContinue);
        msg := SetupMessage(msgConfirmuninstall);
        StringChange(msg, '%1', '{#NAME}');
        if (SuppressibleMsgBox(msg, mbConfirmation, MB_YESNO, IDYES)
            = IDYES) and
            Exec(UninstallString, Args, GetTempDir(), SW_HIDE,
                    ewWaitUntilTerminated, ResultCode) and
            (ResultCode = 0)
        then
            SetLength(Result, 0);
    end;
end;

{ Uninstall previous version before installing a new one. }
Function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
    if WizardIsTaskSelected('stationary') then
    begin
        { New Inno installer. }
        Result := UninstallPrevious(HKA, '{#SetupSetting("AppId")}',
                  '/VERYSILENT');
        { Old NSIS installer. }
        if Length(Result) = 0 then
            Result := UninstallPrevious(HKLM, '{#NAME}', '/S');
    end;
end;
