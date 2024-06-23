; Code adapted from https://nguillaumin.github.io/perihelion-m68k-tutorials/index.html

NB_LINES    equ 191
MIN_ACCEL   equ 1
MAX_ACCEL   equ 31

    jsr     initialise

    move.l  #screen1,d0             ; put screen1 address in d0
    clr.b   d0                       ; put on 256 byte boundary  
    move.l  d0,next                 ; store address
    add.l   #32000,d0               ; next screen area
    move.l  d0,last                 ; store address

    movem.l palette,d0-d7
    movem.l d0-d7,$ff8240           ; palette moved in

fill_buffers
    move.l #bitmap,a0
    move.l next,a1
    move.l last,a2
    move.w #8000,d0
fill_buffer_loop:
    move.l (a0),(a1)+
    move.l (a0)+,(a2)+
    dbra d0,fill_buffer_loop

    move.l #tilemap_init,tilemap_ptr
    move.l #tiles,tile_ptr

; #####################################################################################

scroll
    move.w  #37,-(sp)           ; wait for vsync
    trap    #14
    addq.l  #2,sp
    move.l next,a5              ; a5 = frame buffer pointer
    add.l #648,a5
    clr.l d1
    move.w tile_line,d1         ; d1 = tile line counter

    move.l tilemap_ptr,a0       ; a0 = pointer in the tilemap
    move.l tile_ptr,a1
    move.l (a0)+,d2
    add.l d2,a1                 ; a1 = pointer to the first tile
    move.l tile_ptr,a2
    move.l (a0)+,d2
    add.l d2,a2                 ; a2 = pointer to the second tile
    move.l tile_ptr,a3
    move.l (a0)+,d2
    add.l d2,a3                 ; a3 = pointer to the third tile
    move.l tile_ptr,a4
    move.l (a0)+,d2
    add.l d2,a4                 ; a4 = pointer to the fourth tile

    move.l #191,d0              ; d0 = line counter
; Draw 192 lines
draw_frame
    move.l (a1)+,(a5)
    move.l (a1)+,8(a5)
    move.l (a1)+,16(a5)
    move.l (a2)+,24(a5)
    move.l (a2)+,32(a5)
    move.l (a2)+,40(a5)
    move.l (a3)+,48(a5)
    move.l (a3)+,56(a5)
    move.l (a3)+,64(a5)
    move.l (a4)+,72(a5)
    move.l (a4)+,80(a5)
    move.l (a4)+,88(a5)
    add.l #160,a5
    dbra d1,end_of_line         ; If we are at the last line of the tiles
    move.l #tiles,a1            ; Switch to the next set of tiles
    move.l (a0)+,d2
    adda.l d2,a1
    move.l #tiles,a2
    move.l (a0)+,d2
    adda.l d2,a2
    move.l #tiles,a3
    move.l (a0)+,d2
    adda.l d2,a3
    move.l #tiles,a4
    move.l (a0)+,d2
    adda.l d2,a4
    move.w #31,d1
end_of_line
    dbra d0,draw_frame

    cmp.b   #$1,$fffc02             ; Escape key pressed?
    beq the_end

    move.w acceleration,d2
    cmp.b   #$39,$fffc02            ; space pressed?
    beq accelerate
    cmp.w #MIN_ACCEL,d2             ; If not, decelerate
    beq move_up                     ; but not below MIN_ACCEL
    sub.w #1,d2
    move.w d2,acceleration
    bra move_up
accelerate                          ; Accelerate
    cmp.w #MAX_ACCEL,d2             ; But not above MAX_ACCEL pixels/vsync
    beq move_up
    add.w #1,d2
    move.w d2,acceleration

move_up
    clr.l d1
    move.w tile_line,d1             ; d1 = line in the tile
    move.l #acceleration,a0         ; d1 += acceleration
    add.w (a0),d1
    btst #5,d1                      ; if d1 >= 32, then change tile
    beq next_tile_line
change_tile
    sub.w #32,d1
    move.w d1,tile_line             ; otherwise, time to get new tiles. tile_line -= 32
    move.l #tiles,a0                ; a0=top address of tiles
    move.w #31,d3                   ; d3 = 31
    sub.w d1,d3                     ; d3 = 31-tile_line
    mulu.w #12,d3                   ; d3 = 12*(31-tile_line)
    add.l d3,a0
    move.l a0,tile_ptr              ; tile_ptr is shifted 12*(31-tile_line) bytes down
    move.l tilemap_ptr,a0           ; a0 = tilemap pointer
    cmpa.l #tilemap,a0              ; If we're at the top of the tilemap
    bne previous_tile
    move.l #tilemap_init-16,a0      ; then reset it
    move.l a0,tilemap_ptr
    bra switch_buffers
previous_tile                       ; Otherwise move to the previous row of tiles
    sub.l #16,a0                    ; a0 -= 16
    move.l a0,tilemap_ptr           ; tilemap_ptr = a0

    bra switch_buffers
next_tile_line
    move.w d1,tile_line             ; save tile_line
    move.l tile_ptr,a1
    mulu.w #12,d2
    sub.l d2,a1
    move.l a1,tile_ptr              ; tile_ptr -= 12*acceleration
switch_buffers
    clr.b   $ffff820d               ; clear STe extra bit 
    move.l  next,d0
    lsr.l   #8,d0    
    move.b  d0,$ffff8203           ; put in mid screen address byte
    lsr.w   #8,d0
    move.b  d0,$ffff8201           ; put in high screen address byte

    move.l  last,a0                ; Switches the two buffers for double buffering
    move.l  next,a1
    move.l  a1,last
    move.l  a0,next

    bra scroll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

the_end              
    jsr     restore
    clr.l   -(a7)
    trap    #1
              
    include  initlib.s

    section data

tilemap
    include scroll2_tilemap.s

; This contains a 32000 bytes file encoding the default screen
; This is used for the right dashboard really
bitmap          incbin goldrunner_screen.bin
;bitmap          incbin goldrunner_6.pi1

; This file contains the 210 48x32 tiles of the game
; encoded in 2 bitplanes (4 bytes per group of 16 pixels)
tiles           incbin goldrunner_rsc2.bin

screen          dc.l   0

palette        dc.w  $0000, $0343, $0232, $0121, $0345, $0744, $0404, $0606, $0552, $0013, $0312, $0625, $0544, $0760, $0641, $0321

next            dc.l   0
last            dc.l   0

tilemap_ptr     dc.l    0
tile_ptr        dc.l    0
tile_line       dc.w    31

acceleration    dc.w    MIN_ACCEL

               section bss
  
               ds.b    256
screen1        ds.b    32000
screen2        ds.b    32000
