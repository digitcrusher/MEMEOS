BITS 16
jmp start

;vga driver
screen_xpos db 0
screen_ypos db 0
screen_vga dw 0xb800

;SI - string
puts:
lodsb
cmp al, 0
je puts_end
call putchar
jmp puts
puts_end:
ret

clear:
xor cx, cx
clear_loop:
mov al, ''
mov ah, 0x0F
call putchar
inc cx
cmp cx, 2000
jl clear_loop
call putchar_cr
ret

;AX - column
;BX - row
gotoxy:
mov [screen_xpos], ax
mov [screen_ypos], bx
ret

disablevgacur:
mov dx, 0x03D4
mov al, 0x0A
out dx, al
mov dx, 0x03D5
mov al, 00101100b
out dx, al
ret

enablevgacur:
mov dx, 0x03D4
mov al, 0x0A
out dx, al
mov dx, 0x03D5
mov al, 00001100b
out dx, al
ret

;BH - column
;BL - row
movevgacur:
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
ret

;AL - char
;AH - color code [background:foreground]
putchar:
cmp al, 0x0a
je putchar_lf
cmp al, 0x0d
je putchar_cr
push ax
movzx ax, byte [screen_ypos]
mov bx, 80
mul bx
movzx bx, byte [screen_xpos]
add ax, bx
mov bx, 2
mul bx
mov bx, [screen_vga]
mov es, bx
mov di, 0
add di, ax
pop ax
stosw
add byte [screen_xpos], 1
cmp byte [screen_xpos], 80
je putchar_lf
cmp byte [screen_ypos], 25
je putchar_cr
ret
putchar_lf:
mov byte [screen_xpos], 0
add byte [screen_ypos], 1
ret
putchar_cr:
mov byte [screen_xpos], 0
mov byte [screen_ypos], 0
ret

;ps/2 keyboard driver
;utils
;ascii
lf db 0x0a
cr db 0x0d

start:
call disablevgacur
call clear
mov ah, 0x07
mov si, welcome
call puts

hang:
hlt
jmp hang
welcome db "Welcome to MEMEOS!",0
;  ",,,,,^$^^^^^$  |   ",lf,cr \
; ,"....,,,^^$^^$# |   ",lf,cr \
; ,".........,^^$##|___",lf,cr \
; ,"|**|##...,,^%***##|",lf,cr \
; ,"|**|####| |%%****#|",lf,cr \
; ,",,,^,###| |**^^^##|",lf,cr \
; ,",^,^^$##| |**|####|",lf,cr \
; ,",,^^$$^#| |**|####|",lf,cr \
; ,"|*,^$^##| |#*|####|",lf,cr \
; ,"|**|####| |##|####|",lf,cr \
; ,"|**|####| |##|####|",lf,cr \
; ,"|**|####| |#*|####|",lf,cr \
; ,"|**|####|_|^^|^###|",lf,cr \
; ,"|**|####|%@@#@@|^^|",lf,cr \
; ,"|**|####|%@@#@@@@@|",0
keycheck db "Keyboard Checker!",0
