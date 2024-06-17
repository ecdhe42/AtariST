; Code adapted from https://nguillaumin.github.io/perihelion-m68k-tutorials/index.html

NB_LINES    equ 200

    jsr     initialise
    
    move.l  #screen1,d0             ; put screen1 address in d0
    clr.b   d0                      ; put on 256 byte boundary  
    move.l  d0,next                 ; store address
    add.l   #32000,d0               ; next screen area
    move.l  d0,last                 ; store address
    
    movem.l background+2,d0-d7
    movem.l d0-d7,$ff8240           ; palette moved in

    ; Allocate memory in TT RAM
    move.w    #1,-(sp)    ; Offset 6 (mode)
    move.l    #$36B00,-(sp)  ; Offset 2   (amount)
    move.w    #68,-(sp)     ; Offset 0
    trap      #1            ; GEMDOS
    addq.l    #8,sp         ; Correct stack
    move.l    d0,rsc_ptr

    move.l d0,a0

    ; Copy resources to TT RAM
    move.l #background+34,a1    ; a1=background source
    move.l d0,a2                ; a2=background target
    move.l #foreground2+34,a3   ; a3=foreground2 source
    move.l d0,a4
    add.l #32000,a4             ; a4=foreground2 target
    move.l #foreground2_mask,a5 ; a5=foreground2 mask source
    move.l d0,a6
    add.l #64000,a6             ; a6=foreground2 mask target

    move.w #8000,d0
fill_32k
    move.l (a1)+,(a2)+
    move.l (a3)+,(a4)+
    move.l (a5)+,(a6)+
    dbra d0,fill_32k

    move.l #foreground1+34,a1   ; a1=foreground1 source
    move.l a0,a2
    add.l #96000,a2             ; a2=foreground1 target
    move.l #foreground1_mask,a3 ; a3=foreground1 mask source
    move.l a0,a4
    add.l #160000,a4            ; a4=foreground1 mask target
    move.w #16000,d0
fill_64k
    move.l (a1)+,(a2)+
    move.l (a3)+,(a4)+
    dbra d0,fill_64k

; ######################################################################
; rsc_ptr
;      +0: background
;  +32000: foreground 2
;  +64000: foreground 2 mask
;  +96000: foreground 1
; +160000: foreground 1 mask

main
    move.w #0,line                 ; number of lines to draw (+1)

scroll
    move.w  #$25,-(sp)             ; wait for vsync
    trap    #14
    addq.l  #2,sp

    move.w line,d1                 ; d1=nb of lines to draw
    move.w d1,d2                   ; d2=nb of lines to draw
    move.w d2,d3
    mulu #160,d3                   ; d3=nb of bytes for first part
    move.w #NB_LINES-1,d4          ; d4=200
    sub.w d1,d4                    ; d4=200-nb of lines
    move.w d4,d5
    mulu #160,d5                   ; d5=nb of bytes of second part

    ; Fill the first half
    move.l (rsc_ptr),a0
    move.l (rsc_ptr),a1             ; a1=background
    add.l d5,a1

    move.l (rsc_ptr),a2             ; a2=foreground1
    add.l #128000,a2
    sub.l d5,a2
    move.l (rsc_ptr),a3             ; a3=foreground1 mask
    add.l #192000,a3
    sub.l d5,a3

    move.l (rsc_ptr),a4             ; a4=foreground2
    add.l #32000,a4
    move.l (rsc_ptr),a5             ; a5=foreground2 mask
    add.l #64000,a5

    move.l next,a0
    move.w d2,d0
fill1
    REPT 40
    move.l (a1)+,d1
    and.l (a5)+,d1
    or.l (a4)+,d1
    and.l (a3)+,d1
    or.l (a2)+,d1
    move.l d1,(a0)+
    ENDR

    dbra d0,fill1

    ; We drew the frame, time to switch screens
    move.l  next,d0
    lsr.l   #8,d0    
    move.b  d0,$ffff8203           ; put in mid screen address byte
    lsr.w   #8,d0
    move.b  d0,$ffff8201           ; put in high screen address byte

    move.l  last,a0                ; switches screens (double buffering)
    move.l  next,a1                ; 
    move.l  a1,last                ; 
    move.l  a0,next                ; 

    cmp.b   #$1,$fffc02            ; Escape key pressed?
    beq the_end

    add.w #1,line                   ; line++
    cmp #NB_LINES,line              ; if line < NB_LINES
    bne scroll                      ; keep scrolling
    move.w #0,line                  ; Otherwise line = 0

    ; Clear the two buffers
    move.l next,a1
    move.l last,a2
    move.w #8000,d0
fill_last
    clr.l (a1)+
    clr.l (a2)+
    dbra d0,fill_last

    bra scroll
the_end              
    jsr     restore
                
    clr.l   -(a7)
    trap    #1
              
    include  initlib.s

    section data
  
background
    incbin AtariST.pi1

foreground1
    incbin POV.pi1

foreground1_mask
    incbin POV_mask.bin

foreground2
    incbin foreground2.pi1

foreground2_mask
    incbin foreground2_mask.bin

screen  dc.l   0
next            dc.l   0
last            dc.l   0
rsc_ptr         dc.l    0

    section bss
            ds.b    256
screen1     ds.b    32000
screen2     ds.b    32000

line        dc.w   0
