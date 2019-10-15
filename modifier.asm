
; mzp0514 22:00 2019.10.15
;注意：
; 1、直接调用 Cheat (id)   id说明如下
; #define MAX_MONEY 0
; #define MAX_CONSTRUCT_SPEED 1
; #define MAX_TANK_SPEED 2
; #define MAX_SOLDIER_SPEED 3
; #define MAX_PLANE_SPEED 4
; #define MAX_SHIP_SPEED 5
; #define MAX_ELECTRICITY 6
; #define OBJECT_UPGRADE 7
; #define CONSTRCUCT_ANYWHERE 8
; #define OPEN_RAID 9                //这项只能调用一次 不然会崩
;/2、将kernel32.inc 中 Process32FirstW 和 Process32NextW 中的W删掉


.386
.model flat, stdcall
option casemap : none

include      \masm32\include\kernel32.inc
includelib   \masm32\lib\kernel32.lib
include      \masm32\include\windows.inc

include      \masm32\include\msvcrt.inc
includelib   \masm32\lib\msvcrt.lib


THREAD_PARAM STRUCT
pFunc FARPROC 2 DUP(?)
THREAD_PARAM ENDS

Cheat PROTO id : DWORD
ReadInt PROTO address : DWORD
InjectCode PROTO
GetProcessIdByName PROTO

.data

KERNEL32_STR BYTE 'kernel32.dll', 0
LOADLIBRARYA_STR BYTE 'LoadLibraryA', 0
GETPROCADDRESS_STR BYTE 'GetProcAddress', 0

INFO_OFFSET DWORD 683D4Ch
INFO_OFFSETS DWORD 30Ch, 5384h, 5380h, 537Ch, 5378h, 5388h
MONEY_DISPLAY_OFFSET DWORD 484D08h

LOAD_OFFSET DWORD 108D18h

SELECTED_OFFSET DWORD 68ECBCh
SELECTED_CNT_OFFSET DWORD 68ECC8h
OBJECT_GRADE_OFFSET DWORD 150h

ARCHITECTURE DWORD 8273596

ENABLE_CONSTRUCT_OFFSET DWORD 0A8EB0h

RAID_OFFSET DWORD 108F45h
RAID_ELECTRICITY_OFFSET DWORD 108E3Ch

MONEY_DEST_VAL DWORD 3F3F3F3Fh
SPEED_DEST_VAL DWORD 10
UPGRADE_DEST_VAL DWORD 40000000h

NOP_VAL BYTE 90h
CONSTRUCT_ANY_WHERE_VAL QWORD 0010C200000001B8h
OPEN_RAID_VAL WORD 01B2h

BASE_ADDRESS DWORD 400000h

INJECT_CODE BYTE 60h, 06Ah, 01h, 0BBh, 0F0h, 6Dh, 65h, 00h, 0B9h, 0E8h, 0F7h, 87h, 00h,
                   0FFh, 0D3h, 0B9h, 4Ch, 3Dh, 0A8h, 00h, 8Bh, 91h, 1Ch, 02h, 00h, 00h,
	               52h, 0BBh, 90h, 7Dh, 57h, 00h, 0B9h, 0E8h, 0F7h, 87h, 00h, 0FFh, 0D3h,
                   61h, 0C3h

pName BYTE 'gamemd.exe', 0
pID DWORD ?
pHandle HANDLE ?

IntBuffer DWORD ?
BytesRead DWORD ?
pe32 PROCESSENTRY32 <>

ThreadParam THREAD_PARAM <>

.code

main PROC

invoke GetProcessIdByName
mov pID, eax
invoke OpenProcess, PROCESS_ALL_ACCESS, 0, eax
mov pHandle, eax

invoke Cheat, 9

invoke ExitProcess, 0
main ENDP



GetProcessIdByName PROC
invoke SetLastError, 0
invoke GetLastError
mov pe32.dwSize, SIZEOF PROCESSENTRY32
invoke CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0
mov	esi, eax

invoke Process32First, esi, addr pe32
test eax, eax
je mark2

mark1:
invoke crt_strcmp, addr pe32.szExeFile, addr pName
test eax, eax
je mark2
invoke Process32Next, esi, addr pe32
test eax, eax
jne mark1

mark2:
invoke CloseHandle, esi
invoke GetLastError
.IF eax != 0
mov eax, 0
.ELSE
mov eax, pe32.th32ProcessID
.ENDIF
ret
GetProcessIdByName ENDP




ReadInt PROC USES ecx edx address : DWORD 
invoke ReadProcessMemory, pHandle, address, ADDR IntBuffer, SIZEOF IntBuffer, ADDR BytesRead
mov eax, IntBuffer
ret
ReadInt ENDP




InjectCode PROC
invoke GetModuleHandleA, ADDR KERNEL32_STR
; hmod esi
mov esi, eax
invoke GetProcAddress, esi, ADDR LOADLIBRARYA_STR
mov ThreadParam.pFunc, eax

invoke GetProcAddress, esi, ADDR GETPROCADDRESS_STR
mov [ThreadParam.pFunc + 4], eax

; esi
invoke VirtualAllocEx, pHandle, NULL, SIZEOF ThreadParam, MEM_COMMIT, PAGE_READWRITE
mov esi, eax
invoke WriteProcessMemory, pHandle, esi, ADDR ThreadParam, SIZEOF ThreadParam, NULL

invoke VirtualAllocEx, pHandle, NULL, SIZEOF INJECT_CODE, MEM_COMMIT, PAGE_EXECUTE_READWRITE
mov edi, eax
invoke WriteProcessMemory, pHandle, edi, ADDR INJECT_CODE, SIZEOF INJECT_CODE, NULL

invoke CreateRemoteThread, pHandle, NULL, 0, edi, esi, 0, NULL
mov esi, eax

invoke WaitForSingleObject, esi, INFINITE

invoke CloseHandle, esi

mov eax, 1
ret
InjectCode ENDP




Cheat PROC  id : DWORD
mov esi, id

.IF esi == 0
    mov ebx, BASE_ADDRESS
    add ebx, INFO_OFFSET
    invoke ReadInt, ebx
    add eax, INFO_OFFSETS
    mov edi, eax
    mov ecx, BASE_ADDRESS
    add ecx, MONEY_DISPLAY_OFFSET
    invoke WriteProcessMemory, pHandle, ecx, ADDR MONEY_DEST_VAL, SIZEOF DWORD, NULL
    invoke WriteProcessMemory, pHandle, edi, ADDR MONEY_DEST_VAL, SIZEOF DWORD, NULL

.ELSEIF esi <= 5

mov ebx, BASE_ADDRESS
add ebx, INFO_OFFSET
invoke ReadInt, ebx
add eax, [INFO_OFFSETS + 4 * esi]
invoke WriteProcessMemory, pHandle, eax, ADDR SPEED_DEST_VAL, SIZEOF DWORD, NULL

.ELSEIF esi == 6

    mov ebx, BASE_ADDRESS
    add ebx, LOAD_OFFSET
    mov edi, 0
    .WHILE edi < 6
	invoke WriteProcessMemory, pHandle, ebx, ADDR NOP_VAL, SIZEOF NOP_VAL, NULL
	inc edi
	inc ebx
.ENDW

.ELSEIF esi == 7

	mov ebx, BASE_ADDRESS
	add ebx, SELECTED_CNT_OFFSET

	invoke ReadInt, ebx
	mov esi, eax

	.IF esi == 0
	mov eax, 0
	ret
	.ENDIF

	mov ebx, BASE_ADDRESS
	add ebx, SELECTED_OFFSET
	invoke ReadInt, ebx
	mov ebx, eax
	mov edi, 0

	.WHILE edi < esi
	invoke ReadInt, ebx
	mov ecx, eax
	invoke ReadInt, ecx
	.IF eax == ARCHITECTURE
	.CONTINUE
	.ENDIF
	add ecx, 150h
	invoke WriteProcessMemory, pHandle, ecx, ADDR UPGRADE_DEST_VAL, SIZEOF UPGRADE_DEST_VAL, NULL
	inc edi
	add ebx, 4
	.ENDW

.ELSEIF esi == 8

	mov ebx, BASE_ADDRESS
	add ebx, ENABLE_CONSTRUCT_OFFSET
	invoke WriteProcessMemory, pHandle, ebx, ADDR CONSTRUCT_ANY_WHERE_VAL, SIZEOF CONSTRUCT_ANY_WHERE_VAL, NULL

.ELSEIF esi == 9

	invoke InjectCode
	mov ebx, BASE_ADDRESS
	add ebx, RAID_ELECTRICITY_OFFSET
	invoke WriteProcessMemory, pHandle, ebx, ADDR OPEN_RAID_VAL, SIZEOF OPEN_RAID_VAL, NULL

	add ebx, 2
	mov edi, 0
	.WHILE edi < 4
	invoke WriteProcessMemory, pHandle, ebx, ADDR NOP_VAL, SIZEOF NOP_VAL, NULL
	inc edi
	inc ebx
	.ENDW

.ENDIF

	mov eax, 1
	ret
	
Cheat ENDP



END main

