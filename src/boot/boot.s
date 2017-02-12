BITS 16
jmp start
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

start:
mov ax, 0x07c0
mov ds, ax
xor ax, ax
mov ss, ax
mov sp, 0x9c00

hang:
hlt
jmp hang
times 510-($-$$) db 0
db 0x55
db 0xAA
