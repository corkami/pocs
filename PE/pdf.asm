; a tiny PE with a PDF, copying itself and launching itself under acrobat

;Ange Albertini, BSD Licence, 2010-2013

%include 'consts.inc'

IMAGEBASE equ 400000h

org IMAGEBASE

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,         dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.Characteristics, dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd 4      ; also sets e_lfanew
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd 4
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFIMAGE - 1 ; 2ch <= SIZEOFHEADERS < SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             db IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE
iend

bits 32
EntryPoint:
    push 1
    push newfile
    push thisfile
    call [__imp__CopyFile]
    push 0
    push 0
    push 0
    push newfile
    push 0
    push 0
    call [__imp__ShellExecute]
    retn
thisfile db 'pdf.exe', 0
newfile  db 'pdf.pdf', 0

Import_Descriptor:
_import_descriptor shell32.dll
_import_descriptor kernel32.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend

hnShellExecute:
    dw 0
    db 'ShellExecuteA', 0
hnCopyFile:
    dw 0
    db 'CopyFileA', 0
_d

ImportsAddressTable:
shell32.dll_iat:
__imp__ShellExecute:
    dd hnShellExecute - IMAGEBASE
    dd 0
kernel32.dll_iat:
__imp__CopyFile:
    dd hnCopyFile - IMAGEBASE
    dd 0
_d

shell32.dll_hintnames:
    dd hnShellExecute - IMAGEBASE
    dd 0
kernel32.dll_hintnames:
    dd hnCopyFile - IMAGEBASE
    dd 0
_d

IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable

shell32.dll  db 'shell32.dll',0
kernel32.dll db 'kernel32.dll',0
_d

SIZEOFIMAGE equ $ - IMAGEBASE

incbin 'helloworld-X.pdf'