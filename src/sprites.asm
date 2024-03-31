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

  ;going right

  .byte $10, $10, $00, $10  ; 
  .byte $18, $20, $00, $10  ; 
  .byte $10, $11, $00, $18  ; 
  .byte $18, $21, $00, $18  ; 

  .byte $10, $13, $00, $20  ; 
  .byte $18, $23, $00, $20  ; 
  .byte $10, $14, $00, $28 ; 
  .byte $18, $24, $00, $28  ; 

  .byte $10, $16, $00, $30  ; 
  .byte $18, $26, $00, $30  ; 
  .byte $10, $17, $00, $38  ; 
  .byte $18, $27, $00, $38  ; 

  ;going left

  .byte $20, $40, $00, $10  ; 
  .byte $28, $50, $00, $10  ; 
  .byte $20, $41, $00, $18  ; 
  .byte $28, $51, $00, $18  ; 

  .byte $20, $43, $00, $20  ; 
  .byte $28, $53, $00, $20  ; 
  .byte $20, $44, $00, $28  ; 
  .byte $28, $54, $00, $28  ; 

  .byte $20, $46, $00, $30  ; 
  .byte $28, $56, $00, $30  ; 
  .byte $20, $47, $00, $38  ; 
  .byte $28, $57, $00, $38  ; 

  ;going up

  .byte $30, $70, $00, $10  ; 
  .byte $38, $80, $00, $10  ; 
  .byte $30, $71, $00, $18  ; 
  .byte $38, $81, $00, $18  ; 

  .byte $30, $73, $00, $20  ; 
  .byte $38, $83, $00, $20  ; 
  .byte $30, $74, $00, $28  ; 
  .byte $38, $84, $00, $28  ; 

  .byte $30, $76, $00, $30  ; 
  .byte $38, $86, $00, $30  ; 
  .byte $30, $77, $00, $38  ; 
  .byte $38, $87, $00, $38  ; 

  ;going down

  .byte $40, $B0, $00, $10  ; 
  .byte $48, $C0, $00, $10  ; 
  .byte $40, $B1, $00, $18  ; 
  .byte $48, $C1, $00, $18  ; 

  .byte $40, $B3, $00, $20  ; 
  .byte $48, $C3, $00, $20  ; 
  .byte $40, $B4, $00, $28  ; 
  .byte $48, $C4, $00, $28  ; 

  .byte $40, $B6, $00, $30  ; 
  .byte $48, $C6, $00, $30  ; 
  .byte $40, $B7, $00, $38  ; 
  .byte $48, $C7, $00, $38  ; 

  

.segment "CHR"
.incbin "updatedSprites.chr"