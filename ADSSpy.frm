VERSION 5.00
Begin VB.Form frmMain 
   Caption         =   "ADS Spy - written by Merijn"
   ClientHeight    =   6495
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8340
   Icon            =   "ADSSpy.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   6495
   ScaleWidth      =   8340
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox picStatus 
      AutoRedraw      =   -1  'True
      Height          =   255
      Left            =   120
      ScaleHeight     =   195
      ScaleWidth      =   6675
      TabIndex        =   17
      Top             =   6120
      Width           =   6735
   End
   Begin VB.Frame fraMain 
      Height          =   2175
      Left            =   120
      TabIndex        =   7
      Top             =   1440
      Width           =   6855
      Begin VB.CommandButton cmdScanFolder 
         Caption         =   ".."
         Height          =   255
         Left            =   6360
         TabIndex        =   16
         Top             =   720
         Width           =   255
      End
      Begin VB.TextBox txtScanFolder 
         Height          =   285
         Left            =   2520
         TabIndex        =   15
         Top             =   720
         Width           =   3735
      End
      Begin VB.OptionButton optScanLocation 
         Caption         =   "Scan only this folder:"
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   14
         Top             =   720
         Width           =   1815
      End
      Begin VB.OptionButton optScanLocation 
         Caption         =   "Full scan (all NTFS drives)"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   13
         Top             =   480
         Width           =   2295
      End
      Begin VB.OptionButton optScanLocation 
         Caption         =   "Quick scan (Windows base folder only)"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   12
         Top             =   240
         Value           =   -1  'True
         Width           =   3135
      End
      Begin VB.CommandButton cmdScan 
         Caption         =   "Scan the system for alternate data streams"
         Height          =   375
         Left            =   120
         TabIndex        =   11
         Top             =   1680
         Width           =   3375
      End
      Begin VB.CommandButton cmdRemove 
         Caption         =   "Remove selected streams"
         Height          =   375
         Left            =   3600
         TabIndex        =   10
         Top             =   1680
         Width           =   2175
      End
      Begin VB.CheckBox chkIgnoreEncryptable 
         Caption         =   "Ignore safe system info data streams ('encryptable', 'SummaryInformation', etc)"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   1020
         Value           =   1  'Checked
         Width           =   5895
      End
      Begin VB.CheckBox chkCalcMD5 
         Caption         =   "Calculate MD5 checksums of streams' contents"
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   1320
         Width           =   3855
      End
   End
   Begin VB.ListBox lstADSFound 
      Height          =   2325
      IntegralHeight  =   0   'False
      Left            =   120
      Sorted          =   -1  'True
      Style           =   1  'Checkbox
      TabIndex        =   0
      Top             =   3720
      Width           =   6255
   End
   Begin VB.TextBox txtUselessBlabber 
      BackColor       =   &H8000000F&
      BorderStyle     =   0  'None
      Height          =   1215
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   6
      Text            =   "ADSSpy.frx":27A2
      Top             =   120
      Width           =   6855
   End
   Begin VB.CommandButton cmdViewSave 
      Caption         =   "Save to disk..."
      Height          =   375
      Left            =   1440
      TabIndex        =   3
      Top             =   5640
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.CommandButton cmdViewBack 
      Cancel          =   -1  'True
      Caption         =   "Back"
      Height          =   375
      Left            =   5160
      TabIndex        =   5
      Top             =   5640
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.CommandButton cmdViewEdit 
      Caption         =   "Edit in Wordpad"
      Height          =   375
      Left            =   3240
      TabIndex        =   4
      Top             =   5640
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.CommandButton cmdViewCopy 
      Caption         =   "Copy"
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   5640
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.TextBox txtADSContent 
      BackColor       =   &H8000000F&
      Height          =   1815
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   1
      Top             =   3720
      Visible         =   0   'False
      Width           =   6255
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "PopupMenu"
      Visible         =   0   'False
      Begin VB.Menu mnuPopupSelAll 
         Caption         =   "Select all"
      End
      Begin VB.Menu mnuPopupSelNone 
         Caption         =   "Select none"
      End
      Begin VB.Menu mnuPopupSelInvert 
         Caption         =   "Invert selection"
      End
      Begin VB.Menu mnuPopupStr2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuPopupView 
         Caption         =   "View stream contents"
      End
      Begin VB.Menu mnuPopupStr1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuPopupSave 
         Caption         =   "Save scan results to disk..."
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
'TODO:
'V lblStatus -> picStatus
'* IE7 maakt ADS met ':favicon', ignore?

Private Declare Function FindFirstFile Lib "kernel32" Alias "FindFirstFileA" (ByVal lpFileName As String, lpFindFileData As WIN32_FIND_DATA) As Long
Private Declare Function FindNextFile Lib "kernel32" Alias "FindNextFileA" (ByVal hFindFile As Long, lpFindFileData As WIN32_FIND_DATA) As Long
Private Declare Function FindClose Lib "kernel32" (ByVal hFindFile As Long) As Long
Private Declare Function GetWindowsDirectory Lib "kernel32" Alias "GetWindowsDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
Private Declare Function GetTickCount Lib "kernel32" () As Long
Private Declare Function GetVolumeInformation Lib "kernel32.dll" Alias "GetVolumeInformationA" (ByVal lpRootPathName As String, ByVal lpVolumeNameBuffer As String, ByVal nVolumeNameSize As Long, lpVolumeSerialNumber As Long, lpMaximumComponentLength As Long, lpFileSystemFlags As Long, ByVal lpFileSystemNameBuffer As String, ByVal nFileSystemNameSize As Long) As Long
Private Declare Function CloseHandle Lib "kernel32.dll" (ByVal hObject As Long) As Long

Private Declare Function GetLogicalDrives Lib "kernel32" () As Long
Private Declare Function GetDriveType Lib "kernel32" Alias "GetDriveTypeA" (ByVal nDrive As String) As Long

Private Declare Function CreateFileA Lib "kernel32" (ByVal lpFileName As String, ByVal dwDesiredAccess As Long, ByVal dwShareMode As Long, lpSecurityAttributes As Any, ByVal dwCreationDisposition As Long, ByVal dwFlagsAndAttributes As Long, ByVal hTemplateFile As Long) As Long
Private Declare Function CreateFileW Lib "kernel32" (ByVal lpFileName As Long, ByVal dwDesiredAccess As Long, ByVal dwShareMode As Long, ByVal lpSecurityAttributes As Long, ByVal dwCreationDisposition As Long, ByVal dwFlagsAndAttributes As Long, ByVal hTemplateFile As Long) As Long
Private Declare Function NtQueryInformationFile Lib "NTDLL.DLL" (ByVal FileHandle As Long, IoStatusBlock_Out As IO_STATUS_BLOCK, lpFileInformation_Out As Long, ByVal Length As Long, ByVal FileInformationClass As FILE_INFORMATION_CLASS) As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
Private Declare Function DeleteFile Lib "kernel32.dll" Alias "DeleteFileA" (ByVal lpFileName As String) As Long
Private Declare Function SHFileExists Lib "shell32" Alias "#45" (ByVal szPath As String) As Long
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hWnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As Long) As Long
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long

Private Declare Function GetSaveFileName Lib "comdlg32.dll" Alias "GetSaveFileNameA" (pOpenfilename As OPENFILENAME) As Long

Private Declare Function CryptAcquireContext Lib "advapi32.dll" Alias "CryptAcquireContextA" (ByRef phProv As Long, ByVal pszContainer As String, ByVal pszProvider As String, ByVal dwProvType As Long, ByVal dwFlags As Long) As Long
Private Declare Function CryptCreateHash Lib "advapi32.dll" (ByVal hProv As Long, ByVal Algid As Long, ByVal hKey As Long, ByVal dwFlags As Long, ByRef phHash As Long) As Long
Private Declare Function CryptDestroyHash Lib "advapi32.dll" (ByVal hHash As Long) As Long
Private Declare Function CryptGetHashParam Lib "advapi32.dll" (ByVal pCryptHash As Long, ByVal dwParam As Long, ByRef pbData As Any, ByRef pcbData As Long, ByVal dwFlags As Long) As Long
Private Declare Function CryptHashData Lib "advapi32.dll" (ByVal hHash As Long, ByVal pbData As String, ByVal dwDataLen As Long, ByVal dwFlags As Long) As Long
Private Declare Function CryptReleaseContext Lib "advapi32.dll" (ByVal hProv As Long, ByVal dwFlags As Long) As Long

Private Declare Sub CoTaskMemFree Lib "ole32.dll" (ByVal hMem As Long)
Private Declare Function lstrcat Lib "kernel32" Alias "lstrcatA" (ByVal lpString1 As String, ByVal lpString2 As String) As Long
Private Declare Function SHBrowseForFolder Lib "shell32" (lpbi As BrowseInfo) As Long
Private Declare Function SHGetPathFromIDList Lib "shell32" (ByVal pidList As Long, ByVal lpBuffer As String) As Long

Private Type OPENFILENAME
    lStructSize As Long
    hWndOwner As Long
    hInstance As Long
    lpstrFilter As String
    lpstrCustomFilter As String
    nMaxCustFilter As Long
    nFilterIndex As Long
    lpstrFile As String
    nMaxFile As Long
    lpstrFileTitle As String
    nMaxFileTitle As Long
    lpstrInitialDir As String
    lpstrTitle As String
    flags As Long
    nFileOffset As Integer
    nFileExtension As Integer
    lpstrDefExt As String
    lCustData As Long
    lpfnHook As Long
    lpTemplateName As String
End Type

Private Enum FILE_INFORMATION_CLASS
    FileDirectoryInformation = 1
    FileFullDirectoryInformation   ' // 2
    FileBothDirectoryInformation   ' // 3
    FileBasicInformation           ' // 4  wdm
    FileStandardInformation        ' // 5  wdm
    FileInternalInformation        ' // 6
    FileEaInformation              ' // 74
    FileAccessInformation          ' // 8
    FileNameInformation            ' // 9
    FileRenameInformation          ' // 10
    FileLinkInformation            ' // 11
    FileNamesInformation           ' // 12
    FileDispositionInformation     ' // 13
    FilePositionInformation        ' // 14 wdm
    FileFullEaInformation          ' // 15
    FileModeInformation            ' // 16
    FileAlignmentInformation       ' // 17
    FileAllInformation             ' // 18
    FileAllocationInformation      ' // 19
    FileEndOfFileInformation       ' // 20 wdm
    FileAlternateNameInformation   ' // 21
    FileStreamInformation          ' // 22
    FilePipeInformation            ' // 23
    FilePipeLocalInformation       ' // 24
    FilePipeRemoteInformation      ' // 25
    FileMailslotQueryInformation   ' // 26
    FileMailslotSetInformation     ' // 27
    FileCompressionInformation     ' // 28
    FileObjectIdInformation        ' // 29
    FileCompletionInformation      ' // 30
    FileMoveClusterInformation     ' // 31
    FileQuotaInformation           ' // 32
    FileReparsePointInformation    ' // 33
    FileNetworkOpenInformation     ' // 34
    FileAttributeTagInformation    ' // 35
    FileTrackingInformation        ' // 36
    FileMaximumInformation
End Enum

Private Type FILE_STREAM_INFORMATION
    NextEntryOffset As Long
    StreamNameLength As Long
    StreamSize As Long
    StreamSizeHi As Long
    StreamAllocationSize As Long
    StreamAllocationSizeHi As Long
    StreamName(259) As Byte
End Type

Private Type IO_STATUS_BLOCK
    IoStatus As Long
    Information As Long
End Type

Private Type FILETIME
    dwLowDateTime As Long
    dwHighDateTime As Long
End Type

Private Type WIN32_FIND_DATA
    dwFileAttributes As Long
    ftCreationTime As FILETIME
    ftLastAccessTime As FILETIME
    ftLastWriteTime As FILETIME
    nFileSizeHigh As Long
    nFileSizeLow As Long
    dwReserved0 As Long
    dwReserved1 As Long
    cFileName As String * 260
    cAlternate As String * 14
End Type

Private Type BrowseInfo
    hWndOwner As Long
    pIDLRoot As Long
    pszDisplayName As Long
    lpszTitle As Long
    ulFlags As Long
    lpfnCallback As Long
    lParam As Long
    iImage As Long
End Type

Private Const BIF_RETURNONLYFSDIRS = 1

Private Const DRIVE_UNKNOWN = 1
Private Const DRIVE_REMOVABLE = 2
Private Const DRIVE_FIXED = 3
Private Const DRIVE_REMOTE = 4
Private Const DRIVE_CDROM = 5
Private Const DRIVE_RAMDISK = 6

Private Const ALG_TYPE_ANY As Long = 0
Private Const ALG_SID_MD5 As Long = 3
Private Const ALG_CLASS_HASH As Long = 32768

Private Const HP_HASHVAL As Long = 2
Private Const HP_HASHSIZE As Long = 4

Private Const CRYPT_VERIFYCONTEXT = &HF0000000

Private Const PROV_RSA_FULL As Long = 1
Private Const MS_ENHANCED_PROV As String = "Microsoft Enhanced Cryptographic Provider v1.0"

Private Const OFN_HIDEREADONLY = &H4
Private Const OFN_NONETWORKBUTTON = &H20000
Private Const OFN_OVERWRITEPROMPT = &H2
Private Const OFN_PATHMUSTEXIST = &H800

Private Const HKEY_LOCAL_MACHINE = &H80000002
Private Const KEY_QUERY_VALUE = &H1

Private Const FILE_NAMED_STREAMS As Long = &H40000
Private Const FILE_ATTRIBUTE_DIRECTORY = &H10
Private Const FILE_FLAG_BACKUP_SEMANTICS = &H2000000

Private Const OpenExisting As Long = 3

Private sWinDir$
Private bQuickScan As Boolean, bScanFolder As Boolean, bAbortScanNow As Boolean
Private bIgnoreEncryptable As Boolean, bCalcMD5 As Boolean
Private sSafeStreams$()

Private Sub cmdScanFolder_Click()
    Dim sPath$, sNTFSDrives$(), i&
    sPath = BrowseForFolder("Select a folder to scan:")
    If sPath <> vbNullString Then
        sNTFSDrives = Split(GetNTFSDrives(), "|")
        For i = 0 To UBound(sNTFSDrives)
            If InStr(1, sPath, sNTFSDrives(i), vbTextCompare) = 1 Then
                'check if drive of given path is NTFS
                txtScanFolder.Text = sPath
                optScanLocation(2).Value = True
                Exit Sub
            End If
        Next i
        MsgBox "The folder you have selected is not on a NTFS drive.", vbCritical
    End If
End Sub

Private Sub Form_Load()
    Me.Caption = "ADS Spy v" & App.Major & "." & Format(App.Minor, "00") & " - Written by Merijn"
    txtUselessBlabber.Text = "Alternate Data Streams (ADS) are pieces of " & _
      "info hidden as metadata on files on NTFS drives. They are not visible in Explorer " & _
      "and the size they take up is not reported by Windows. Recent " & _
      "browser hijackers started using ADS to hide their files, and very " & _
      "few anti-malware scanners detect this. Use ADS Spy to find and " & _
      "remove these streams." & vbCrLf & _
      "Note: this app can also display legitimate ADS streams. Don't " & _
      "delete streams if you are not completely sure they are malicious!"
    
    sWinDir = String(260, 0)
    sWinDir = Left(sWinDir, GetWindowsDirectory(sWinDir, Len(sWinDir)))
    If InStr(Command$, "/debug") > 0 Then
    'If 1 Then
        Dim i%, s$()
        Me.Show
        Status "Listing drives..."
        s = Split(GetDrives, "|")
        lstADSFound.Clear
        lstADSFound.AddItem " Enumerating system drives:"
        For i = 0 To UBound(s)
            lstADSFound.AddItem s(i)
        Next i
    Else
        CheckIfSystemIsNTFS
        If InStr(1, GetNTFSDrives, Left(sWinDir, 2), vbTextCompare) = 0 Then
            'chkQuickScan.Value = 0
            optScanLocation(0).Enabled = False
        End If
    End If
    
    ReDim sSafeStreams(6)
    sSafeStreams(0) = ":encryptable:$DATA"
    sSafeStreams(1) = ":SummaryInformation:$DATA"
    sSafeStreams(2) = ":DocumentSummaryInformation:$DATA"
    sSafeStreams(3) = ":{4c8cc155-6c1e-11d1-8e41-00c04fb9386d}:$DATA"
    sSafeStreams(4) = ":Zone.Identifier:$DATA"
    sSafeStreams(5) = ":Q30lsldxJoudresxAaaqpcawXc:$DATA"
    Status "Ready."
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    bAbortScanNow = True
    DoEvents
    Unload Me
    End
End Sub

Private Sub Form_Resize()
    If Me.WindowState = vbMinimized Then Exit Sub
    On Error Resume Next
    txtUselessBlabber.Width = Me.ScaleWidth - 255
    fraMain.Width = Me.ScaleWidth - 255
    lstADSFound.Width = Me.ScaleWidth - 255
    txtADSContent.Width = Me.ScaleWidth - 255
    picStatus.Width = Me.ScaleWidth - 255
    
    lstADSFound.Height = Me.ScaleHeight - 3690 - 480
    txtADSContent.Height = Me.ScaleHeight - 4170 - 480
    cmdViewCopy.Top = Me.ScaleHeight - 855
    cmdViewSave.Top = Me.ScaleHeight - 855
    cmdViewEdit.Top = Me.ScaleHeight - 855
    cmdViewBack.Top = Me.ScaleHeight - 855
    picStatus.Top = Me.ScaleHeight - 375
End Sub

Private Sub cmdViewBack_Click()
    txtADSContent.Visible = False
    cmdViewCopy.Visible = False
    cmdViewSave.Visible = False
    cmdViewEdit.Visible = False
    cmdViewBack.Visible = False
    lstADSFound.Visible = True
    cmdRemove.Enabled = True
    Status "Ready."
End Sub

Private Sub cmdViewCopy_Click()
    Clipboard.Clear
    Clipboard.SetText txtADSContent.Text
    Status "The contents of the currently displayed ADS have been copied to the clipboard."
End Sub

Private Sub cmdViewEdit_Click()
    'get path to Wordpad.exe
    Dim hKey&, sWordpadPath$, sStream$
    If RegOpenKeyEx(HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows\CurrentVersion\App Paths\WORDPAD.EXE", 0, KEY_QUERY_VALUE, hKey) <> 0 Then
        MsgBox "Unable to open the ADS for editing: Wordpad not found.", vbExclamation
        Exit Sub
    End If
    
    sWordpadPath = String(260, 0)
    If RegQueryValueEx(hKey, "", 0, ByVal 0, ByVal sWordpadPath, Len(sWordpadPath)) <> 0 Then
        RegCloseKey hKey
        MsgBox "Unable to open the ADS for editing: Wordpad not found.", vbExclamation
        Exit Sub
    End If
    
    sWordpadPath = TrimNull(Replace(sWordpadPath, "%ProgramFiles%", Environ("ProgramFiles")))
    sStream = lstADSFound.List(lstADSFound.ListIndex)
    sStream = Replace(sStream, " : ", ":")
    sStream = Left(sStream, InStr(sStream, "  (") - 1)
    ShellExecute Me.hWnd, "open", sWordpadPath, """" & sStream & """", vbNullString, 1
    Status "Ready."
End Sub

Private Sub cmdViewSave_Click()
    Dim uOFN As OPENFILENAME, sFileName$, sStream$ ', sStreamName$
    sStream = lstADSFound.List(lstADSFound.ListIndex)
    sStream = Replace(sStream, " : ", ":")
    sStream = Left(sStream, InStr(sStream, "  (") - 1)
    'sStreamName = Mid(sStream, InStrRev(sStream, ":") + 1)
    'If Asc(Left(sStreamName, 1)) = 5 Then sStreamName = Mid(sStreamName, 2)
    With uOFN
        .lStructSize = Len(uOFN)
        .hWndOwner = Me.hWnd
        .lpstrInitialDir = App.Path
        .lpstrTitle = "Save stream contents to file..."
        '.lpstrFile = sStreamName & String(260 - Len(sStreamName), 0)
        .lpstrFile = String(260, 0)
        .lpstrFileTitle = String(260, 0)
        .nMaxFile = Len(.lpstrFile)
        .nMaxFileTitle = Len(.lpstrFileTitle)
        .lpstrDefExt = "bin"
        .lpstrFilter = "Binary files (*.bin)" & Chr(0) & "*.bin" & Chr(0) & _
                       "Text files (*.txt)" & Chr(0) & "*.txt" & Chr(0) & _
                       "All files (*.*)" & Chr(0) & "*.*" & Chr(0) & Chr(0)
        .flags = OFN_HIDEREADONLY Or OFN_NONETWORKBUTTON Or OFN_OVERWRITEPROMPT Or OFN_PATHMUSTEXIST
        GetSaveFileName uOFN
        sFileName = TrimNull(.lpstrFile)
        If sFileName = vbNullString Then Exit Sub
        FileCopy sStream, sFileName
        If FileExists(sFileName) Then
            Status "Stream contents saved to " & TrimNull(.lpstrFileTitle) & " (" & FileLen(sFileName) & " bytes)."
        Else
            Status "An error occurred saving the stream to disk."
        End If
    End With
End Sub

Private Sub cmdScan_Click()
    Dim lTicks&, sDrives$(), i&, sScanFolder$
    If cmdScan.Caption = "Abort scan" Then
        bAbortScanNow = True
        Exit Sub
    End If
    
    cmdViewBack_Click
    lstADSFound.Clear
    lTicks = GetTickCount()
    bQuickScan = IIf(optScanLocation(0).Value, True, False)
    bScanFolder = IIf(optScanLocation(2), True, False)
    sScanFolder = txtScanFolder.Text
    bIgnoreEncryptable = IIf(chkIgnoreEncryptable.Value = 1, True, False)
    bCalcMD5 = IIf(chkCalcMD5.Value = 1, True, False)
    
    cmdScan.Caption = "Abort scan"
    If bQuickScan Then
        If InStr(1, GetNTFSDrives, Left(sWinDir, 2), vbTextCompare) = 0 Then
            MsgBox "Unable to scan the Windows folder, because the volume " & _
                   "containing this folder does not use NTFS format." & vbCrLf & _
                   "Uncheck the 'quick scan' option to scan all drives " & _
                   "with NTFS format.", vbExclamation
        Else
            EnumADSInAllFiles sWinDir
        End If
    Else
        If Not bScanFolder Then
            sDrives = Split(GetNTFSDrives, "|")
            For i = 0 To UBound(sDrives)
                EnumADSInFile sDrives(i), True
                EnumADSInAllFiles sDrives(i)
            Next i
        Else
            If sScanFolder <> vbNullString And FileExists(sScanFolder) Then
                EnumADSInFile sScanFolder, True
                EnumADSInAllFiles sScanFolder
            End If
        End If
    End If
    cmdScan.Caption = "Scan the system for alternate data streams"
    lTicks = GetTickCount() - lTicks
    If IsRunningInIDE() Then
        Status "Scan complete, found " & lstADSFound.ListCount & " alternate data streams (ADS's) in " & Format(lTicks / 1000, "##0.00#") & " s."
        If bAbortScanNow Then Status "Scan ABORTED, found " & lstADSFound.ListCount & " alternate data streams (ADS's) in " & Format(lTicks / 1000, "##0.00#") & " s."
    Else
        Status "Scan complete, found " & lstADSFound.ListCount & " alternate data streams (ADS's)."
        If bAbortScanNow Then Status "Scan ABORTED, found " & lstADSFound.ListCount & " alternate data streams (ADS's)."
    End If
    bAbortScanNow = False
End Sub

Private Sub cmdRemove_Click()
    If lstADSFound.ListCount = 0 Then Exit Sub
    If lstADSFound.SelCount = 0 Then lstADSFound.Clear: Exit Sub
    
    Dim i&, j&, k&, sStream$, sLockedStreams$
    k = lstADSFound.SelCount
    If MsgBox("Are you sure you want to remove the selected " & k & " ADS's from your system? They will be deleted permanently!", vbQuestion + vbYesNo) = vbNo Then Exit Sub
    'go from bottom of list to prevent .RemoveItem messing up the For loop
    Status "Removing selected streams..."
    For i = lstADSFound.ListCount - 1 To 0 Step -1
        If lstADSFound.Selected(i) Then
            sStream = lstADSFound.List(i)
            sStream = Replace(sStream, " : ", ":")
            sStream = Left(sStream, InStr(sStream, "  (") - 1)
            DeleteFile sStream
            Sleep 100
            If Not FileExists(sStream) Then
                lstADSFound.RemoveItem i
            Else
                sLockedStreams = sLockedStreams & lstADSFound.List(i) & vbCrLf
            End If
            j = j + 1
        End If
        Status "Removing selected streams... " & Int(CLng(j) / k * 100) & " %"
    Next i
    
    lstADSFound.Clear
    If sLockedStreams <> vbNullString Then
        MsgBox "The following ADS streams could not be deleted. They may be locked by another program:" & _
               vbCrLf & vbCrLf & Left(sLockedStreams, Len(sLockedStreams) - 2), vbExclamation
    End If
    Status "Ready."
End Sub

Private Function GetDrives$()
    Dim lDrives&, i&, sDrive$, sDrives$, lDriveType&
    Dim lFlags&, sVolName$, lVolSN&, lMaxCompLen&, sVolFileSys$, bNamedStreams As Boolean
    lDrives = GetLogicalDrives()
    For i = 0 To 26
        If (lDrives And 2 ^ i) Then
            sDrive = Chr(Asc("A") + i) & ":\"
            lDriveType = GetDriveType(sDrive)
            sVolName = String(260, 0)
            sVolFileSys = String(260, 0)
            lFlags = 0
            GetVolumeInformation sDrive, sVolName, Len(sVolName), lVolSN, lMaxCompLen, lFlags, sVolFileSys, Len(sVolFileSys)
            
            Select Case lDriveType
                Case DRIVE_UNKNOWN:   sDrive = sDrive & " - unknown type"
                Case DRIVE_REMOVABLE: sDrive = sDrive & " - removable"
                Case DRIVE_FIXED:     sDrive = sDrive & " - fixed"
                Case DRIVE_REMOTE:    sDrive = sDrive & " - network"
                Case DRIVE_CDROM:     sDrive = sDrive & " - CD-ROM"
                Case DRIVE_RAMDISK:   sDrive = sDrive & " - RAMdisk"
            End Select
            sVolFileSys = TrimNull(sVolFileSys)
            If sVolFileSys = vbNullString Then sVolFileSys = "?"
            sDrive = sDrive & " - " & sVolFileSys
            If (lFlags And FILE_NAMED_STREAMS) Then sDrive = sDrive & " - supports ADS"
            
            sDrives = sDrives & "|" & sDrive
        End If
    Next i
    If sDrives <> vbNullString Then GetDrives = Mid(sDrives, 2)
End Function

Private Function GetNTFSDrives$()
    Dim lFlags&, sVolName$, lVolSN&, lMaxCompLen&, sVolFileSys$
    Dim lDrives&, i&, sDrive$, sNTFSDrives$, lDriveType&
    lDrives = GetLogicalDrives()
    For i = 0 To 26
        If (lDrives And 2 ^ i) Then
            sDrive = Chr(Asc("A") + i) & ":\"
            lDriveType = GetDriveType(sDrive)
            If lDriveType = DRIVE_FIXED Or lDriveType = DRIVE_RAMDISK Then
                sVolName = String(260, 0)
                sVolFileSys = String(260, 0)
                lFlags = 0
                GetVolumeInformation sDrive, sVolName, Len(sVolName), lVolSN, lMaxCompLen, lFlags, sVolFileSys, Len(sVolFileSys)
                'If (lFlags And FILE_NAMED_STREAMS) = FILE_NAMED_STREAMS Then
                '    sNTFSDrives = sNTFSDrives & "|" & sDrive
                'End If
                If UCase(TrimNull(sVolFileSys)) = "NTFS" Then
                    sNTFSDrives = sNTFSDrives & "|" & sDrive
                End If
            End If
        End If
    Next i
    If sNTFSDrives <> vbNullString Then GetNTFSDrives = Mid(sNTFSDrives, 2)
End Function

Private Sub CheckIfSystemIsNTFS()
    If GetNTFSDrives() = vbNullString Then
        MsgBox "Alternate Data Streams (ADS) are only possible on NTFS systems." & vbCrLf & _
               "Since there are no NTFS volumes on this system, ADS Spy will now exit.", vbInformation
        End
    End If
End Sub

Private Sub EnumADSInAllFiles(sFolder$)
    Dim hFind, uWFD As WIN32_FIND_DATA, sFileName$
    hFind = FindFirstFile(BuildPath(sFolder, "*.*"), uWFD)
    If hFind = -1 Then
        Status "FindFirstFile() failed"
        Exit Sub
    End If
    
    Do
        sFileName = TrimNull(uWFD.cFileName)
        If Not ((uWFD.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY) = 16) Then
            Status BuildPath(sFolder, sFileName)
            EnumADSInFile BuildPath(sFolder, sFileName)
        Else
            If sFileName <> "." And sFileName <> ".." And Not bQuickScan Then
                EnumADSInFile BuildPath(sFolder, sFileName), True
                EnumADSInAllFiles BuildPath(sFolder, sFileName)
            End If
        End If
        If bAbortScanNow Then Exit Do
    Loop Until FindNextFile(hFind, uWFD) = 0
    FindClose hFind
End Sub

Private Sub EnumADSInFile(sFilePath$, Optional bIsFolder As Boolean = False)
    Dim hFile&, uIOSB As IO_STATUS_BLOCK, uFSI As FILE_STREAM_INFORMATION
    Dim uBuffer() As Byte, lStreamInfo&, lBufferLen&, sStreamName$
    If bAbortScanNow Then Exit Sub
'    If InStr(sFilePath, "test.txt") > 0 Then
'        MsgBox "blah"
'    End If
    If bIsFolder = False Then
        hFile = CreateFileW(StrPtr(sFilePath), 0, 0, 0, OpenExisting, 0, 0)
        'hFile = CreateFileW(StrPtr("\\?\" & sFilePath), 0, 0, 0, OpenExisting, 0, 0)
    Else
        hFile = CreateFileW(StrPtr(sFilePath), 0, 0, 0, OpenExisting, FILE_FLAG_BACKUP_SEMANTICS, 0)
    End If
    If hFile = -1 Then Exit Sub
    
    lBufferLen = 96 * CLng(4096)
    ReDim uBuffer(1 To lBufferLen)
    NtQueryInformationFile hFile, uIOSB, ByVal VarPtr(uBuffer(1)), lBufferLen, FileStreamInformation
    
    lStreamInfo = VarPtr(uBuffer(1))
    Do
        CopyMemory ByVal VarPtr(uFSI.NextEntryOffset), ByVal lStreamInfo, 24
        CopyMemory ByVal VarPtr(uFSI.StreamName(0)), ByVal lStreamInfo + 24, uFSI.StreamNameLength
        sStreamName = Left(uFSI.StreamName, uFSI.StreamNameLength / 2)
        If sStreamName <> vbNullString And _
           sStreamName <> "::$DATA" Then
           If InStr(Join(sSafeStreams, "|"), sStreamName) = 0 _
               Or Not bIgnoreEncryptable Then
                sStreamName = Mid(sStreamName, 2)
                sStreamName = Left(sStreamName, InStr(sStreamName, ":") - 1)
                If bCalcMD5 Then
                    lstADSFound.AddItem sFilePath & " : " & sStreamName & "  (" & uFSI.StreamSize & " bytes, MD5: " & GetFileMD5(sFilePath & ":" & sStreamName, uFSI.StreamSize) & ")"
                Else
                    lstADSFound.AddItem sFilePath & " : " & sStreamName & "  (" & uFSI.StreamSize & " bytes)"
                End If
            End If
        End If
        If uFSI.NextEntryOffset > 0 Then
            lStreamInfo = lStreamInfo + uFSI.NextEntryOffset
        Else
            Exit Do
        End If
        If bAbortScanNow Then Exit Do
    Loop
    CloseHandle hFile
End Sub

Private Function FileExists(sFile$) As Boolean
    FileExists = CBool(SHFileExists(StrConv(sFile, vbUnicode)))
End Function

Private Sub Status(s$)
    picStatus.Cls
    picStatus.Print s
    DoEvents
End Sub

Private Function TrimNull$(s$)
    If InStr(s, Chr(0)) > 0 Then
        TrimNull = Left(s, InStr(s, Chr(0)) - 1)
    Else
        TrimNull = s
    End If
End Function

Private Sub lstADSFound_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 2 And lstADSFound.ListCount > 0 Then PopupMenu mnuPopup
End Sub

Private Sub mnuPopupSave_Click()
    Dim sLog$, i%, uOFN As OPENFILENAME, sFileName$
    If lstADSFound.ListCount = 0 Then Exit Sub
    With uOFN
        .lStructSize = Len(uOFN)
        .hWndOwner = Me.hWnd
        .lpstrInitialDir = App.Path
        .lpstrTitle = "Save stream contents to file..."
        .lpstrFile = String(260, 0)
        .lpstrFileTitle = String(260, 0)
        .nMaxFile = Len(.lpstrFile)
        .nMaxFileTitle = Len(.lpstrFileTitle)
        .lpstrDefExt = "txt"
        .lpstrFilter = "Text files (*.txt)" & Chr(0) & "*.txt" & Chr(0) & _
                       "All files (*.*)" & Chr(0) & "*.*" & Chr(0) & Chr(0)
        .flags = OFN_HIDEREADONLY Or OFN_NONETWORKBUTTON Or OFN_OVERWRITEPROMPT Or OFN_PATHMUSTEXIST
        GetSaveFileName uOFN
        sFileName = TrimNull(.lpstrFile)
        If sFileName = vbNullString Then Exit Sub
        For i = 0 To lstADSFound.ListCount - 1
            sLog = sLog & lstADSFound.List(i) & vbCrLf
        Next i
        Open sFileName For Output As #1
            Print #1, sLog
        Close #1
        Status "Scan results saved to " & TrimNull(.lpstrFileTitle) & "."
    End With
    
End Sub

Private Sub mnuPopupSelAll_Click()
    Dim i%
    If lstADSFound.SelCount = lstADSFound.ListCount Then Exit Sub
    For i = 0 To lstADSFound.ListCount - 1
        lstADSFound.Selected(i) = True
    Next i
    lstADSFound.ListIndex = 0
End Sub

Private Sub mnuPopupSelInvert_Click()
    Dim i%
    For i = 0 To lstADSFound.ListCount - 1
        lstADSFound.Selected(i) = Not lstADSFound.Selected(i)
    Next i
    lstADSFound.ListIndex = 0
End Sub

Private Sub mnuPopupSelNone_Click()
    Dim i%
    If lstADSFound.SelCount = 0 Then Exit Sub
    For i = 0 To lstADSFound.ListCount - 1
        lstADSFound.Selected(i) = False
    Next i
    lstADSFound.ListIndex = 0
End Sub

Private Sub mnuPopupView_Click()
    cmdRemove.Enabled = False
    lstADSFound.Visible = False
    txtADSContent.Visible = True
    cmdViewCopy.Visible = True
    cmdViewSave.Visible = True
    cmdViewEdit.Visible = True
    cmdViewBack.Visible = True
    
    Dim sStream$, lSize&, sStreamContents$
    Status "Reading stream..."
    txtADSContent.Text = vbNullString
    sStream = lstADSFound.List(lstADSFound.ListIndex)
    sStream = Replace(sStream, " : ", ":")
    lSize = Val(Mid(sStream, InStr(sStream, "  (") + 3))
    sStream = Left(sStream, InStr(sStream, "  (") - 1)
    If FileExists(sStream) Then
        On Error Resume Next
        Open sStream For Input As #1
            sStreamContents = Input(lSize, #1)
            'binary stuff triggers error here
            If Err Then
                Err.Clear
                Close #1
                Open sStream For Binary Access Read As #1
                sStreamContents = Input(lSize, #1)
                sStreamContents = Replace(sStreamContents, Chr(0), " ")
                MsgBox "The stream '" & sStream & "' contains binary data " & _
                       "and will most likely not display properly or completely.", vbExclamation
            End If
        Close #1
        txtADSContent.Text = sStreamContents
    End If
    Status "Viewing contents of " & sStream & "."
End Sub

Private Function GetFileMD5$(sFileName$, lFileSize&)
    If Not FileExists(sFileName) Then Exit Function
    If lFileSize = 0 Then
        'speed tweak :) 0-byte file always has the same MD5
        GetFileMD5 = "D41D8CD98F00B204E9800998ECF8427E"
        Exit Function
    End If
    
    Dim sFileContents$
    On Error Resume Next
    Open sFileName For Binary Access Read As #1
        If Err Then Exit Function
        sFileContents = Input(lFileSize, #1)
    Close #1
    
    Dim hCrypt&, hHash&, uMD5(255) As Byte, lMD5Len&, i%, sMD5$
    If CryptAcquireContext(hCrypt, vbNullString, MS_ENHANCED_PROV, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) <> 0 Then
        If CryptCreateHash(hCrypt, ALG_TYPE_ANY Or ALG_CLASS_HASH Or ALG_SID_MD5, 0, 0, hHash) <> 0 Then
            If CryptHashData(hHash, sFileContents, Len(sFileContents), 0) <> 0 Then
                If CryptGetHashParam(hHash, HP_HASHSIZE, uMD5(0), UBound(uMD5) + 1, 0) <> 0 Then
                    lMD5Len = uMD5(0)
                    If CryptGetHashParam(hHash, HP_HASHVAL, uMD5(0), UBound(uMD5) + 1, 0) <> 0 Then
                        For i = 0 To lMD5Len - 1
                            sMD5 = sMD5 & Right("0" & Hex(uMD5(i)), 2)
                        Next i
                    End If
                End If
            End If
            CryptDestroyHash hHash
        End If
        CryptReleaseContext hCrypt, 0
    End If
    
    If sMD5 <> vbNullString Then
        GetFileMD5 = sMD5
    End If
End Function

Private Function IsRunningInIDE() As Boolean
    On Error Resume Next
    Debug.Print 1 / 0
    If Err Then IsRunningInIDE = True
End Function

Private Function BrowseForFolder$(sPrompt$)
    Dim uBI As BrowseInfo, lIDList&, sPath$
    With uBI
        .hWndOwner = Me.hWnd
        .lpszTitle = lstrcat(sPrompt, "")
        .ulFlags = BIF_RETURNONLYFSDIRS
    End With
    lIDList = SHBrowseForFolder(uBI)
    If lIDList > 0 Then
        sPath = String(260, 0)
        SHGetPathFromIDList lIDList, sPath
        CoTaskMemFree lIDList
        BrowseForFolder = TrimNull(sPath)
    End If
End Function

Private Function BuildPath$(sFolder$, sFile$)
    If Right(sFolder, 1) = "\" Then
        BuildPath = sFolder & sFile
    Else
        BuildPath = sFolder & "\" & sFile
    End If
End Function
