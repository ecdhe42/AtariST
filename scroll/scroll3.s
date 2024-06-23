; Code adapted from https://nguillaumin.github.io/perihelion-m68k-tutorials/index.html
; and from the Return to Genesis game

NB_LINES    equ 191
;    move.l  initialstack,a7
    jsr     initialise
    
    move.l  #screen1,d0             ; put screen1 address in d0
    clr.b   d0                       ; put on 256 byte boundary  
    move.l  d0,next                 ; store address
    add.l   #32000,d0               ; next screen area
    move.l  d0,last                 ; store address
    
    movem.l palette,d0-d7
    movem.l d0-d7,$ff8240           ; palette moved in

main
    move.l  next,d0                 ; d0 = next frame buffer
    clr.b   $ffff820d               ; clear STe extra bit  
    lsr.l   #8,d0    
    move.b  d0,$ffff8203           ; put in mid screen address byte
    lsr.w   #8,d0
    move.b  d0,$ffff8201           ; put in high screen address byte

;    move.l #tilemap,a0
;    move.l a0,tilemap_top
;    move.l #rsc,a0
;    move.l a0,rsc_ptr
    move.w #0,d7

loop
    move.l #15,d5               ; d5 = number of pixel shifts (16)
    move.l #tilemap,a0
    move.l a0,tilemap_top
    move.l #rsc,a0
    move.l a0,rsc_ptr

;    add.l #$180,a2
;    move.l a2,a3
;    add.l #$180,a3
;    move.l a3,a4
;    add.l #$180,a4
;    move.l a4,a5
;    add.l #$180,a5
;    move.l a5,a6
;    add.l #$180,a6

display_screen
;    movem.l a1-a6/d5,regs
    move.w  #37,-(sp)               ; wait vbl
    trap    #14
    addq.l  #2,sp  
;    movem.l regs,a1-a6/d5

;    move.l rsc_ptr,a7

    move.l #tilemap,a0
    move.l a0,tilemap_top
    move.l next,a0
    add.l #8,a0
    move.l a0,screen_ptr

    move.l #5,d6                    ; d6 = number of tile rows (6)
display_row
    move.l tilemap_top,a0          ; a0 = ptr to the tilemap

    move.l (rsc_ptr),a1
    move.w (a0)+,d0
    add.w d0,a1
    move.l (rsc_ptr),a2
    move.w (a0)+,d0
    add.w d0,a2
    move.l (rsc_ptr),a3
    move.w (a0)+,d0
    add.w d0,a3
    move.l (rsc_ptr),a4
    move.w (a0)+,d0
    add.w d0,a4
    move.l (rsc_ptr),a5
    move.w (a0)+,d0
    add.w d0,a5
    move.l (rsc_ptr),a6
    move.w (a0)+,d0
    add.w d0,a6

    move.l a0,tilemap_top
    move.l screen_ptr,a0
    cmpi.w #0,d7
    bne test_2shift
    include scroll3_row_0shift.s
    bra display_row_done
test_2shift
    cmpi.w #1,d7
    bne test_3shift
    include scroll3_row_1shift.s
    bra display_row_done
test_3shift
    include scroll3_row_2shift.s
display_row_done
    move.l a0,screen_ptr

    dbra d6,display_row

    move.l  next,d4
    lsr.l   #8,d4    
    move.b  d4,$ffff8203           ; put in mid screen address byte
    lsr.w   #8,d4
    move.b  d4,$ffff8201           ; put in high screen address byte

    movem.l a5-a6,regs
    move.l  last,a5                ; Switches screens for double buffering
    move.l  next,a6
    move.l  a6,last
    move.l  a5,next
    movem.l regs,a5-a6

    cmp.b   #$1,$fffc02           ; Escape key pressed?
    beq the_end

    cmp.b   #$39,$fffc02           ; space pressed?
    beq fast_scroll

    move.l rsc_ptr,a0
    add.l #$3480,a0
    move.l a0,rsc_ptr

;    add.l #$2880,a1
;    add.l #$2880,a2
;    add.l #$2880,a3
;    add.l #$2880,a4
;    add.l #$2880,a5
;    add.l #$2880,a6

    dbra d5,display_screen

;loop
;    cmp.b   #$1,$fffc02            ; Escape key pressed?
;    beq the_end

;    cmp.b   #$39,$fffc02           ; space pressed?
;    beq the_end
fast_scroll
    add.w #1,d7
    cmpi #3,d7
    bne loop


    move.l #tilemap,a0
    move.l #tilemap,a1

    add.l #2,a1
    move.w (a0),d0
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w d0,(a0)+

    add.l #2,a1
    move.w (a0),d0
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w d0,(a0)+

    add.l #2,a1
    move.w (a0),d0
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w d0,(a0)+

    add.l #2,a1
    move.w (a0),d0
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w d0,(a0)+

    add.l #2,a1
    move.w (a0),d0
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w d0,(a0)+

    add.l #2,a1
    move.w (a0),d0
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w (a1)+,(a0)+
    move.w d0,(a0)+

    move.w #0,d7

    bra loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

the_end              
    jsr     restore
    clr.l   -(a7)
    trap    #1
              
    include  initlib.s

    section data

      ds.b     $100          ; stack size
initialstack:    ds.b     4

rsc            incbin genesis_rsc.bin

screen          dc.l   0

palette         dc.w $0000, $0556, $0731, $0577, $0747, $0445, $0334, $0640, $0054, $0545, $0323, $0754, $0023, $0604, $0335, $0777

row_nb          dc.w 0
tilemap_top     dc.l 0
rsc_ptr         dc.l 0
screen_ptr      dc.l 0

tilemap
    dc.w $2A00, $0300, $0300, $2B80, $0C00, $0F00
    dc.w $2700, $2880, $2700, $2880, $0D80, $1080
    dc.w $2D00, $2E80, $3180, $0600, $0C00, $1200
    dc.w $2D00, $0180, $0480, $0600, $0D80, $0F00
    dc.w $2A00, $2B80, $2A00, $2B80, $0C00, $1080
    dc.w $2700, $3000, $3000, $2880, $0D80, $1200

next            dc.l   0
last            dc.l   0
line            dc.w   0

regs            dc.w 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

    section bss

               ds.b    256
screen1        ds.b    32000
screen2        ds.b    33000
