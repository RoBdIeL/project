.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1
pad1: .res 1
frame_counter: .res 1
animation_counter: .res 1
.exportzp player_x, player_y, pad1, frame_counter, animation_counter

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00
  ; read controller
	JSR read_controller1
  ; update tiles *after* DMA transfer
	; and after reading controller state
	JSR update_player
  
  RTI
.endproc

.import reset_handler
; .import draw_starfield we dont need this since we are drawing everything from this file
; .import draw_objects


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

.proc drawRight
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter
  LDA animation_counter
  AND #$03          ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F          ; Mask out lower 4 bits
  CMP #$05          ; Check which frame of animation to use
  BCC frame1Right   ; If less than 5, use the first frame
  CMP #$0A          ; Check if it's the second or third frame
 ; Otherwise, use the third frame
  BCC frame2Right   ; If less than 10, use the second frame
  JMP frame3Right  
trampoline:
  JMP skipAnimation

frame3Right:
  ; Third frame of animation
  LDA #$16      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$17
  STA $0205
  LDA #$26
  STA $0209
  LDA #$27
  STA $020d
  JMP setTile

frame2Right:
  ; Second frame of animation
  LDA #$13      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$14
  STA $0205
  LDA #$23
  STA $0209
  LDA #$24
  STA $020d
  JMP setTile

frame1Right:
  ; First frame of animation
  LDA #$10      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$11
  STA $0205
  LDA #$20
  STA $0209
  LDA #$21
  STA $020d
  JMP setTile

setTile:

  ; write ghost tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; Increment frame counter
  INC frame_counter

  ; restore registers and return
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.proc drawLeft
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter
  LDA animation_counter
  AND #$03         ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F         ; Mask out lower 4 bits
  CMP #$05         ; Check which frame of animation to use
  BCC frame1Left   ; If less than 5, use the first frame
  CMP #$0A         ; Check if it's the second or third frame
  BCC frame2Left   ; If less than 10, use the second frame
  JMP frame3Left   ; Otherwise, use the third frame

trampoline:
  JMP skipAnimation

frame3Left:
  ; Third frame of animation
  LDA #$46      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$47
  STA $0205
  LDA #$56
  STA $0209
  LDA #$57
  STA $020d
  JMP setTile

frame2Left:
  ; Second frame of animation
  LDA #$43      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$44
  STA $0205
  LDA #$53
  STA $0209
  LDA #$54
  STA $020d
  JMP setTile

frame1Left:
  ; First frame of animation
  LDA #$40     ; Use tile number for the first frame of animation
  STA $0201
  LDA #$41
  STA $0205
  LDA #$50
  STA $0209
  LDA #$51
  STA $020d
  JMP setTile

setTile:

  ; write ghost tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; Increment frame counter
  INC frame_counter

  ; restore registers and return
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc drawUp
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter
  LDA animation_counter
  AND #$03          ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F          ; Mask out lower 4 bits
  CMP #$05          ; Check which frame of animation to use
  BCC frame1Up      ; If less than 5, use the first frame
  CMP #$0A          ; Check if it's the second or third frame
  BCC frame2Up      ; If less than 10, use the second frame
  JMP frame3Up      ; Otherwise, use the third frame

trampoline:
  JMP skipAnimation

frame3Up:
  ; Third frame of animation
  LDA #$76     ; Use tile number for the third frame of animation
  STA $0201
  LDA #$77
  STA $0205
  LDA #$86
  STA $0209
  LDA #$87
  STA $020d
  JMP setTile

frame2Up:
  ; Second frame of animation
  LDA #$73      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$74
  STA $0205
  LDA #$83
  STA $0209
  LDA #$84
  STA $020d
  JMP setTile

frame1Up:
  ; First frame of animation
  LDA #$70      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$71
  STA $0205
  LDA #$80
  STA $0209
  LDA #$81
  STA $020d
  JMP setTile

setTile:

  ; write ghost tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; Increment frame counter
  INC frame_counter

  ; restore registers and return
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc drawDown
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter
  LDA animation_counter
  AND #$03         ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F         ; Mask out lower 4 bits
  CMP #$05         ; Check which frame of animation to use
  BCC frame1Down   ; If less than 5, use the first frame
  CMP #$0A         ; Check if it's the second or third frame
  BCC frame2Down   ; If less than 10, use the second frame
  JMP frame3Down   ; Otherwise, use the third frame

trampoline:
  JMP skipAnimation

frame3Down:
  ; Third frame of animation
  LDA #$B6      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$B7
  STA $0205
  LDA #$C6
  STA $0209
  LDA #$C7
  STA $020d
  JMP setTile

frame2Down:
  ; Second frame of animation
  LDA #$B3      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$B4
  STA $0205
  LDA #$C3
  STA $0209
  LDA #$C4
  STA $020d
  JMP setTile

frame1Down:
  ; First frame of animation
  LDA #$B0      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$B1
  STA $0205
  LDA #$C0
  STA $0209
  LDA #$C1
  STA $020d
  JMP setTile

setTile:

  ; write ghost tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; Increment frame counter
  INC frame_counter

  ; restore registers and return
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.proc update_player
  PHP  ; Start by saving registers,
  PHA  
  TXA
  PHA
  TYA
  PHA

  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  JSR drawLeft
  DEC player_x  ; If the branch is not taken, move player left
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  JSR drawRight
  INC player_x
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  JSR drawUp
  DEC player_y
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  JSR drawDown
  INC player_y
done_checking:
  PLA ; Done with updates, restore registers
  TAY ; and return to where we called this
  PLA
  TAX
  PLA
  PLP
  RTS
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

  .byte $A0, $10, $00, $80  ; 
  .byte $A8, $20, $00, $80  ; 
  .byte $A0, $11, $00, $88  ; 
  .byte $A8, $21, $00, $88  ; 

.segment "CHR"
.incbin "updatedSprites.chr"