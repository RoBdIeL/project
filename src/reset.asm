.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, scroll, flag_scroll

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX PPUCTRL
  STX PPUMASK
  STX $4010
  BIT PPUSTATUS
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

	LDX #$00
	LDA #$FF
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

vblankwait2:
  BIT $2002
  BPL vblankwait2

; initialize zero-page values
  LDA #$00
  STA scroll
  STA flag_scroll

; set x, y coords for player_1
  LDA #$00
  STA player_x
  LDA #$BF
  STA player_y
  JMP main
.endproc
