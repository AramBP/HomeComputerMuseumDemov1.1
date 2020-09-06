// $1000-$1b9f Music
.var music = LoadSid("DemoSong.sid")
.var picture1 = LoadBinary("HCMlogo.kla", BF_KOALA)
.var picture2 = LoadBinary("HCMlogo.kla", BF_KOALA)

:BasicUpstart2(start)

start:
    lda #%00110110
    sta $0001

    lda #music.startSong-1
    jsr music.init

    //cls
    jsr $e544

    jsr recolor

    ldx #$ff

!fill:  lda #0
    sta bitMap_1 + picture1.getBitmapSize() - 640,x
    dex
    bne !fill-
    ldx #$40
!fill:  lda #0
    sta bitMap_1 + picture1.getBitmapSize() - 384,x
    dex
    bne !fill-
    ldx #$ff
!fill:  lda #0
    sta bitMap_2 + picture2.getBitmapSize() - 640,x
    dex
    bne !fill-
    ldx #$40
!fill:  lda #0
    sta bitMap_2 + picture2.getBitmapSize() - 384,x
    dex
    bne !fill-

    // disable the interrupts
    sei 

    setupirq(240, irq1);

    lda #%01111011
    sta $dc0d

    lda #%10000001
    sta $d01a

    cli
/////////////SPRITES////////////////////
    lda #%00000000
    sta $d01c

    lda #%11111111
    sta $d015
    ldx #$7 

!loop:
    lda SpritePtrs,x
    sta screenRam_1 + 1016,x
    lda 0
    sta screenRam_2 + 1016,x
    rndGen(%1111);
    sta $d027,x
    dex 
    bpl !loop-
    lda #10
    sta $d000
    lda #52
    sta $d002
    lda #94
    sta $d004
    lda #136
    sta $d006
    lda #178
    sta $d008
    lda #220
    sta $d00a
    lda #%11000000
    sta $d010
    lda #6
    sta $d00c
    lda #48
    sta $d00e

//////////////MAIN LOOP/////////////////////

main:
    lda $d012
    cmp #50
    beq !ahead+
    jmp main

!ahead:
    ldx #7
    ldy #15

!loop:
    lda sprite_v_offsets,x
    sta $d000,y
    rndGen(1);
    beq !ahead+
    inc sprite_v_offsets,x

!ahead:
    inc sprite_v_offsets,x
    lda sprite_v_offsets,x
    cmp #214
    beq !reset+
    cmp #215
    beq !reset+
    jmp !ahead+
!reset:
    lda #0
    sta sprite_v_offsets,x
    rndGen(%1111);
    sta $d027,x
!ahead:
    dey
    dey
    dex
    txa
    bne !loop-
    jmp main
/////////////END MAIN LOOP/////////////////  


    
recolor:
    inc screen_state
    lda screen_state
    cmp #3
    bne !skip+
    lda #1
    sta screen_state

!skip:
    cmp #2
    beq screen2

    .macro recolorMacro(colormap, bg, linecolor) {
        ldx #0
        !loop:
            .for (var i=0; i<4; i++) {
                lda colormap+i*$100,x
                sta $d800+i*$100,x
            }
        inx
        bne !loop-
        lda #bg
        sta $d020
        sta $d021
        lda #linecolor
    }

screen1:
    recolorMacro(colorRam_1, picture1.getBackgroundColor(), 7);
    jmp !skip+
screen2:
    recolorMacro(colorRam_2, picture2.getBackgroundColor(), 1);
!skip:
    ldx #$D8
!fill:
    sta $dae8,x
    inx
    bne !fill-

    rts

scroll_message:

    vicbank(%00000011);
    delay(54);
    lda #%00011011
    sta $d011
      lda #%11110100
    sta $d018
    dec raster_h_offset
    lda raster_h_offset
    sta $d016
    bne !exit+
    lda #7
    sta raster_h_offset

    ldx msg_offset
    cpx msg_length
    bne !skip+
    ldx #0
    stx msg_offset
!skip:
    ldy #0
printchr:
    lda msg_text, x
    sta $3fc0, y
    inx
    cpx msg_length
    bne !skip+
    ldx #0
!skip: iny
    cpy #40
    bne printchr

    inc msg_offset
!exit:
    rts


.macro ack() {
    lda #%11111111
    sta $d019
}


.macro exitirq() {
    pla
    tay
    pla
    tax
    pla
}


.macro setupirq(line, irq) {
    lda #line
    sta $d012
    lda #<irq
    sta $0314
    lda #>irq
    sta $0315
}

irq1:
    ack();
    jsr scroll_message
    jsr music.play
    setupirq(10, irq2);
    exitirq();
    rti



irq2:
    ack();

    lda screen_state
    cmp #2
    beq s2
    vicbank(%00000011);
    jmp !ahead+
s2:
   
    vicbank(%00000010); // bank1
!ahead:

   
    lda #%00111011
    sta $d011

    lda #%00111000
    sta $d018
    
    lda #%11011000
    sta $d016

    inc counter
    lda counter
    cmp #255
    bne !skip+
    jsr recolor
    lda #0
    sta counter
!skip:

    // jump to irq1 at line 240
    setupirq(240, irq1);
    exitirq();
    rti


screen_state: .byte 0
counter: .byte 0

#import "text.asm"
#import "sprites.asm"


* = $0c00 "ScreenRam_1"; screenRam_1: .fill picture1.getScreenRamSize(), picture1.getScreenRam(i)
* = $1c00 "ColorRam_1:"; colorRam_1: .fill picture1.getColorRamSize(), picture1.getColorRam(i)
* = $2000 "Bitmap_1"; bitMap_1: .fill picture1.getBitmapSize(), picture1.getBitmap(i)

* = music.location "Music"
.fill music.size, music.getData(i)

* = $4c00 "ScreenRam_2"; screenRam_2: .fill picture2.getScreenRamSize(), picture2.getScreenRam(i)
* = $6000 "Bitmap_2"; bitMap_2: .fill picture2.getBitmapSize(), picture2.getBitmap(i)
* = $7f40 "ColorRam_2:"; colorRam_2: .fill picture2.getColorRamSize(), picture2.getColorRam(i)


.macro vicbank(pattern) {
    lda $dd00
    and #%11111100
    ora #pattern
    sta $dd00
}



.macro delay(count) {
    .for (var i=0; i<=count; i++) {
        nop
    }
}



.macro rndGen(mask) {
    // first we read the current raster line (0-255)
    lda $d012
    // then we xor it with timer A (low byte)
    eor $dc04
    // then we subtract it with timer A (high byte)
    sbc $dc05
    // finally we mask it so we can have a number between 0 and bits^2
    and #mask
}
















