# script to generate PE with any number of physically identical section, all executed

# Ange Albertini, BSD Licence 2011

import struct
import sys
import os

def roundup(value, rounding):
    return value if (value % rounding == 0) else ((value / rounding) + 1) * rounding

NbSec = int(sys.argv[1])
SECTIONALIGN = 0x1000
SizeFactor = 7 # number of SECTIONALIGN per section
if NbSec > 65535 or NbSec * SizeFactor * SECTIONALIGN > 0x80000000:
    sys.exit()
    
fn = "%isects.exe" % NbSec

FILEALIGN = 0x200
SizeOfHeaders = 0x138 + 0x28 * NbSec
FstSecOff = roundup(SizeOfHeaders, FILEALIGN)
FstSecRVA = roundup(FstSecOff, SECTIONALIGN)
#print "%i sections, header %X" % (NbSec, SizeOfHeaders)
#print "header size %08X" % SizeOfHeaders
#print "first section's offset %08X" % FstSecOff
#print "first section's RVA %08X" % FstSecRVA

AddressOfEntryPoint = FstSecRVA + 0x120
ImportsVA = FstSecRVA + 0x20
SizeOfImage = FstSecRVA + SECTIONALIGN * NbSec * SizeFactor

header = """
%%include '..\consts.inc'

IMAGEBASE equ 010000h
SECTIONALIGN equ 01000h
FILEALIGN equ 0200h

org IMAGEBASE
bits 32

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw 0%04xh
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd 0%xh
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd 1000h
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd 200h
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 0%xh
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd 0%xh
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd 0%04xh
iend
SIZEOFOPTIONALHEADER equ $ - OptionalHeader
""" % ( NbSec, AddressOfEntryPoint, SizeOfImage, SizeOfHeaders, ImportsVA)

with open("_hdr.as_", "wt") as f:
    f.write(header)
os.system("yasm -o %s _hdr.as_" % fn)
os.remove("_hdr.as_")

sec = ""
vs = SECTIONALIGN * SizeFactor
ps = FILEALIGN
pa = FstSecOff
va = FstSecRVA
sec += chr(0) * 4 * 2 + struct.pack("<4L", vs, va, ps, pa) + chr(0) * 4 * 3 + struct.pack("<L", 0xe00000c0)

ps = 0
for i in range(NbSec - 1):
	va = FstSecRVA + (i + 1) * SizeFactor * SECTIONALIGN
	sec += chr(0) * 4 * 2 + struct.pack("<4L", vs, va, ps, pa) + chr(0) * 4 * 3 + struct.pack("<L", 0xe00000c0)

sec += (FstSecOff - SizeOfHeaders) * chr(0)
with open("%s" % fn, "ab") as f:
	f.write(sec)

firstsec = """
bits 32
IMAGEBASE equ 010000h
%%include '..\consts.inc'

section progbits vstart= 0%xh + IMAGEBASE

start:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

_d
Import_Descriptor:
;kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

Msg db " * %i physically identical, virtually executed sections", 0ah, 0
_d

EntryPoint:
    ; build a return jump at the bottom of the virtual space
    mov edi, 0%xh
    mov al, 68h
    stosb
    mov eax, start
    stosd
    mov ax, 0c3h
    stosb
    ; give eax a good value to go thru 00 00's
    mov eax, ebx
align 0200h, db 0
""" % (
    FstSecRVA,
    # 6 = size of the patch, 1 = avoiding an extra 00
    NbSec, SECTIONALIGN * (1 + SizeFactor * NbSec) + FstSecRVA - 6 - 1
    )

with open("_1st.as_", "wt") as f:
    f.write(firstsec)
os.system("yasm -o _1st.bi_ _1st.as_")
os.remove("_1st.as_")

with open("_1st.bi_", "rb") as f:
    r = f.read()
os.remove("_1st.bi_")

with open("%s" % fn, "ab") as f:
    f.write(r)
