.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00
  STA $2005
  STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  ; write sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$ff       ; # Sprites x 4 bytes
  BNE load_sprites

      ; First Tile
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$85
	STA PPUADDR
	LDX #$19
	STX PPUDATA

    ; Second tile
    LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$86
	STA PPUADDR
	LDX #$1D
	STX PPUDATA

  ; third tile
    LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$87
	STA PPUADDR
	LDX #$49
	STX PPUDATA

  ;fourth tile
    LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$88
	STA PPUADDR
	LDX #$4D
	STX PPUDATA

  ;fifth tile
    LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$89
	STA PPUADDR
	LDX #$89
	STX PPUDATA

  ;sixth tile

      LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8A
	STA PPUADDR
	LDX #$8D
	STX PPUDATA


  ;seventh tile
    LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8B
	STA PPUADDR
	LDX #$B9
	STX PPUDATA

  ;eight tile
    LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8C
	STA PPUADDR
	LDX #$BD
	STX PPUDATA

    ; attribute table First Stage
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDA #%00001000
	STA PPUDATA

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $0f, $12, $1A, $27
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

.byte $0f, $2d, $10, $15
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29

sprites:
  .byte $70, $23, $00, $80  ; Data for first sprite
  .byte $78, $33, $00, $80  ; Data for second sprite
  .byte $70, $24, $00, $88  ; Data for third sprite
  .byte $78, $34, $00, $88  ;

  .byte $70, $26, $00, $90  ; 
  .byte $78, $36, $00, $90  ; 
  .byte $70, $27, $00, $98  ; 
  .byte $78, $37, $00, $98  ; 

  .byte $88, $53, $00, $80  ; 
  .byte $90, $63, $00, $80  ; 
  .byte $88, $54, $00, $88  ; 
  .byte $90, $64, $00, $88  ; Data for second sprite

  .byte $88, $56, $00, $90  ; 
  .byte $90, $66, $00, $90  ;
  .byte $88, $57, $00, $98  ; 
  .byte $90, $67, $00, $98  ; 

  

.segment "CHR"
.incbin "updatedSprites.chr"