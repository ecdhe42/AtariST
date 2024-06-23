; Code adapted from https://nguillaumin.github.io/perihelion-m68k-tutorials/index.html

NB_LINES    equ 200

    jsr     initialise
    
    move.l  #screen1,d0             ; put screen1 address in d0
    clr.b   d0                      ; put on 256 byte boundary  
    move.l  d0,next                 ; store address
    add.l   #32000,d0               ; next screen area
    move.l  d0,last                 ; store address
    
    movem.l bitmap+2,d0-d7
    movem.l d0-d7,$ff8240           ; palette moved in

main
    move.w #0,line                  ; screen line

scroll
    move.w  #$25,-(sp)               ; wait vbl
    trap    #14
    addq.l  #2,sp

    move.w line,d1                  ; d1=nb of lines to draw
    move.w d1,d2                    ; d2=nb of lines to draw
;    mulu #4,d2                     ; d2=nb of long words for first part
    move.w d2,d3
    mulu #160,d3                    ; d3=nb of bytes for first part
    move.w #NB_LINES-1,d4             ; d4=200
    sub.w d1,d4                     ; d4=200-nb of lines
;    mulu #40,d4                     ; d4=nb of bytes of second part
    move.w d4,d5
    mulu #160,d5                      ; d5=nb of bytes of second part

    ; Fill the first half
    move.l #bitmap+34,a0
    add.l d5,a0
    move.l next,a1
    move.w d2,d0
fill1
    ; By copying one whole line per iteration (40 move.l operations)
    ; we are able to draw 156 lines per frame on a 68000 at 8Mhz
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
    dbra d0,fill1

    ; By using the a more standard single move.l per iteration (see below)
    ; we can draw at most 100 lines per frame on a 68000 at 8 MHz
;    move.l (a0)+,(a1)+
;    dbra d0,fill1

    ; Fill the second half
;    move.l #bitmap+34,a0
;    move.w d4,d0
;fill2
;    move.l (a0)+,(a1)+
;    dbra d0,fill2

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

    move.l #bitmap+34,a0            ; And copy 
    move.l next,a1
    move.w #8000,d0
fill_last
    move.l (a0)+,(a1)+
    dbra d0,fill_last

    bra scroll
the_end              
    jsr     restore
                
    clr.l   -(a7)
    trap    #1
              
    include  initlib.s

    section data
  
bitmap
    incbin genmicros.pi1

screen  dc.l   0
next            dc.l   0
last            dc.l   0

    section bss
            ds.b    256
screen1     ds.b    32000
screen2     ds.b    32000

line        dc.w   0
