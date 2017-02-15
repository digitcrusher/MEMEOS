BITS 16
jmp getmeout
nop
OEMLabel          db "MEMEOS  "    ;Disk label
BytesPerSector    dw 512           ;Bytes per sector
SectorsPerCluster db 1             ;Sectors per cluster
ReservedForBoot   dw 1             ;Reserved sectors for boot record
NumberOfFats      db 2             ;Number of copies of the FAT
RootDirEntries    dw 224           ;Number of entries in root dir (224 * 32 = 7168 = 14 sectors to read)
LogicalSectors    dw 2880          ;Number of logical sectors
MediumByte        db 0x0f0         ;Medium descriptor byte
SectorsPerFat     dw 9             ;Sectors per FAT
SectorsPerTrack   dw 18            ;Sectors per track (36/cylinder)
Sides             dw 2             ;Number of sides/heads
HiddenSectors     dd 0             ;Number of hidden sectors
LargeSectors      dd 0             ;Number of LBA sectors
DriveNo           dw 0             ;Drive No: 0
Signature         db 41            ;Drive signature: 41 for floppy
VolumeID          dd 0xdeadbeef    ;Volume ID: any number
VolumeLabel       db "MEMEOS     " ;Volume Label: any 11 chars
FileSystem        db "FAT12   "    ;File system type: don't change!
nop

getmeout:
jmp start

;#################
;#vga_disablecur #
;#################
vga_disablecur:
pusha
mov dx, 0x3D4
mov al, 0x0A
out dx, al
mov dx, 0x3D5
mov al, 00101100b
out dx, al
popa
ret

;#################
;#vga_enablecur  #
;#################
vga_enablecur:
pusha
mov dx, 0x3D4
mov al, 0x0A
out dx, al
mov dx, 0x3D5
mov al, 00001100b
out dx, al
popa
ret

;#################
;#vga_movecur    #
;#BH - column    #
;#BL - row       #
;#################
vga_movecur:
pusha
xor cx, cx
movzx ax, bh
mov cx, 0x80
mul cx
movzx cx, bl
add ax, cx
mov cx, ax
mov al, 0x0F
mov dx, 0x03D4
out dx, al
mov ax, cx
mov dx, 0x03D5
out dx, al
mov al, 0x0E
mov dx, 0x03D4
out dx, al
mov ax, cx
mov dx, 0x03D5
shr ax, 8
out dx, al
popa
ret

;#################
;#clear          #
;#################
clear:
pusha
xor cx, cx
.loop:
mov al, ''
mov ah, 0x0F
call putchar
inc cx
cmp cx, 2000
jl .loop
xor bh, bh
xor bl, bl
call gotoxy
popa
ret

;#################
;#updatecur      #
;#################
updatecur:
pusha
mov bh, [screen_xpos]
mov bl, [screen_ypos]
call vga_movecur
popa
ret

;#################
;#gotoxy         #
;#BH - column    #
;#BL - row       #
;#################
gotoxy:
pusha
mov [screen_xpos], bh
mov [screen_ypos], bl
popa
ret

;#################
;#puts           #
;#SI - string    #
;#AH - color code#
;#[back:fore]    #
;#################
puts:
pusha
puts_loop:
lodsb
cmp al, 0
je puts_end
call putchar
jmp puts_loop
puts_end:
popa
ret

;#################
;#putchar        #
;#AL - char      #
;#AH - color code#
;#[back:fore]    #
;#################
putchar:
pusha
mov bx, 0xaa
cmp al, [lf]
je putchar_lf
cmp al, [cr]
je putchar_cr
push ax
movzx ax, [screen_ypos]
mov bx, [screen_width]
mul bx
movzx bx, [screen_xpos]
add ax, bx
mov bx, 2
mul bx
mov bx, [screen_vgas]
mov es, bx
mov di, ax
pop ax
stosw
add byte [screen_xpos], 1
mov ax, [screen_xpos]
cmp ax, [screen_width]
call putchar_lf
call putchar_cr
putchar_done:
popa
ret
putchar_lf:
add byte [screen_ypos], 1
cmp bx, 0xaa
je putchar_done
ret
putchar_cr:
mov byte [screen_xpos], 0
cmp bx, 0xaa
je putchar_done
ret

start:
mov ax, 0x07c0
mov ds, ax
mov cs, ax
mov es, ax
xor ax, ax
mov ss, ax
mov sp, 0x7c00

call clear
mov ah, 0x07
mov si, welcome
call puts

hang:
hlt
jmp hang
nop
lf db 0x0a
cr db 0x0d
welcome db "Welcome to MEMEOS!",0x0d,0x0a,0
cmdbuffer times 64 db 0x0
screen_xpos db 0
screen_ypos db 0
screen_width db 80
screen_height db 25
screen_vgas dw 0xb800
nop
times 510-($-$$) db 0
db 0x55
db 0xAA
