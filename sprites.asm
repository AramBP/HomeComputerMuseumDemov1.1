
sprite_v_offsets:
.byte 62, 124, 0, 186, 31, 215, 93, 155

.function toSpritePtr(addr){
    .return (addr&$3FFF)/64
}

SpritePtrs:
.byte toSpritePtr(snow_sprite_small), toSpritePtr(snow_sprite_big)
.byte toSpritePtr(snow_sprite_small), toSpritePtr(snow_sprite_big)
.byte toSpritePtr(snow_sprite_small), toSpritePtr(snow_sprite_big)
.byte toSpritePtr(snow_sprite_small), toSpritePtr(snow_sprite_big)

*=$b60 "Sprites"

.align 64

//uncomment wanneer je sprites wil gebruiken

snow_sprite_big:
/*.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $08,$00,$00,$88,$80,$00,$5d,$00
.byte $00,$3e,$00,$00,$7f,$00,$01,$ff
.byte $c0,$00,$7f,$00,$00,$3e,$00,$00
.byte $5d,$00,$00,$88,$80,$00,$08,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$03*/


snow_sprite_small:
/*
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$08,$00
.byte $00,$41,$00,$00,$2a,$00,$00,$00
.byte $00,$00,$aa,$80,$00,$00,$00,$00
.byte $2a,$00,$00,$41,$00,$00,$08,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$03
*/