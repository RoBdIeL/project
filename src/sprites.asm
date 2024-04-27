.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1
pad1: .res 1
tile_to_display: .res 1
high_byte_nametable_address: .res 1
low_byte_nametable_address: .res 1
current_byte: .res 1
fix_low_byte_row_index: .res 1
choose_which_background: .res 1
current_stage: .res 1
ppuctrl_settings: .res 1
change_background_flag: .res 1
scroll: .res 1
flag_scroll: .res 1
frame_counter: .res 1
animation_counter: .res 1
.exportzp scroll, flag_scroll,frame_counter, animation_counter,player_x, player_y, pad1

.segment "CODE"
.proc irq_handler
  RTI
.endproc


.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
 
  JSR read_controller1

  JSR update_player

  LDA change_background_flag
  CMP #$01
  BNE skip_change_background

    LDA current_stage 
    EOR #%11
    STA current_stage

    jsr display_stage_background
    lda #$00
    sta change_background_flag
    
    reset_scrolling:
      
      STA scroll
      STA flag_scroll
      STA PPUSCROLL
      STA PPUSCROLL

  skip_change_background:

  LDA flag_scroll
  CMP #$00
  BEQ skip_ppuscroll_write

  INC scroll
  LDA scroll
  BNE skip_scroll_reset
    LDA #255
    STA scroll 
  
  skip_scroll_reset:
  STA PPUSCROLL
  LDA #$00  
  STA PPUSCROLL

  skip_ppuscroll_write:

  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDX PPUSTATUS 
  LDX #$3f 
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  load_palettes:
    LDA palettes, X
    STA PPUDATA
    INX
    CPX #$20 
    BNE load_palettes

lda #$01
sta current_stage
JSR display_stage_background


vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000
  STA PPUCTRL
  sta ppuctrl_settings
  LDA #%00011110  ; turn on screen
  STA PPUMASK


  init_ppuscroll:
    LDA #$00
    STA PPUSCROLL
    STA PPUSCROLL

forever:
  JMP forever
.endproc

.proc display_tile
  LDA PPUSTATUS; 
  LDA $02
  STA PPUADDR
  LDA $01
  STA PPUADDR
  LDA $00
  STA PPUDATA
  
  rts
.endproc

.proc display_stage_background
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  disable_rendering:
    LDA #%00000000
    STA PPUMASK

    
    LDA ppuctrl_settings  ;turn off NMI
    AND #%01111000
    STA PPUCTRL
    STA ppuctrl_settings

  LDA current_stage
  CMP #$02
  BEQ prep_stage_2

  prep_stage_1:
    LDA #$00
    sta choose_which_background 

  JMP finished_preparing

  prep_stage_2:
    LDA #$02
    sta choose_which_background


  finished_preparing:
  LDY #$00
  sty fix_low_byte_row_index
  STY low_byte_nametable_address

  LDA #$20
  STA high_byte_nametable_address

  JSR display_one_nametable_background

      LDA choose_which_background
      clc
      adc #$01
      sta choose_which_background
    

  LDY #$00
  sty fix_low_byte_row_index
  STY low_byte_nametable_address

  LDA #$24
  STA high_byte_nametable_address

  JSR display_one_nametable_background

  enable_rendering:

    LDA #%10010000
    STA PPUCTRL
    STA ppuctrl_settings
    LDA #%00011110  ; turn on screen
    STA PPUMASK


  PLA
  TAY
  PLA
  TAX
  PLA
  PLP 
RTS
.endproc

.proc display_one_nametable_background
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

load_background:
  LDA choose_which_background
  CMP #$00
  BNE stage_1_part_2

    LDA stage1Part1, Y
    JMP background_selected

stage_1_part_2:
  CMP #$01
  BNE stage_2_part_1

    LDA stage1Part2, Y
    JMP background_selected
stage_2_part_1:
  CMP #$02
  BNE stage_2_part_2

    LDA stage2Part1, Y
    jmp background_selected

stage_2_part_2:
    LDA stage2Part2, Y

  background_selected:
  
  STA current_byte
  JSR display_byte

  INY
  increment_fix_low_byte_row_index:
    lda fix_low_byte_row_index
    clc
    adc #$01
    sta fix_low_byte_row_index
  lda fix_low_byte_row_index
  cmp #$04
  BNE skip_low_byte_row_fix
    lda low_byte_nametable_address
    clc
    adc #$20 
    sta low_byte_nametable_address
    bcc skip_overflow_fix_2
      lda high_byte_nametable_address
      clc
      adc #$01
      sta high_byte_nametable_address
    skip_overflow_fix_2:
      LDA #$00
      sta fix_low_byte_row_index

  skip_low_byte_row_fix:
    cpy #$3C
    bne load_background

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP 
RTS
.endproc

.proc display_byte
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  ldx #$00 
  process_byte_of_tiles_loop:
    LDA #$00
    STA tile_to_display 
    ASL current_byte
 
    ROL tile_to_display 
    ASL current_byte

    ROL tile_to_display
    lda current_stage
    CMP #$01
    BEQ skip_addition_to_display
      lda tile_to_display
      clc
      adc #$04
      sta tile_to_display

    skip_addition_to_display:
    JSR display_tiles

    LDA low_byte_nametable_address
    CLC 
    ADC #$02 
    STA low_byte_nametable_address
    
    BCC skip_overflow_fix
    LDA high_byte_nametable_address
    CLC
    ADC #$01
    sta high_byte_nametable_address

    skip_overflow_fix:
      INX
      CPX #$04
      BNE process_byte_of_tiles_loop

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP   



RTS
.endproc

.proc display_tiles
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

LDA PPUSTATUS
  LDA high_byte_nametable_address
  STA PPUADDR
  LDA low_byte_nametable_address
  STA PPUADDR
  LDA tile_to_display
  STA PPUDATA

  LDA high_byte_nametable_address
  STA PPUADDR
  LDA low_byte_nametable_address
  CLC
  ADC #$01
  STA PPUADDR
  LDA tile_to_display
  STA PPUDATA



  ; bottom LEFT
  LDX #$00
  JSR handle_left_or_right

  ; bottom RIGHT
  ldx #$01
  jsr handle_left_or_right

   PLA
  TAY
  PLA
  TAX
  PLA
  PLP


RTS
.endproc

.proc handle_left_or_right
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  TXA
  CMP #$01
  beq add_to_low_byte_right_version

  LDA low_byte_nametable_address
  CLC
  ADC #$20
  jmp check_overflow

add_to_low_byte_right_version:
  LDA low_byte_nametable_address
  CLC
  ADC #$21

check_overflow:
  BCC add_with_no_overflow
  LDA high_byte_nametable_address
  clc 
  adc #$01
  sta PPUADDR
  TXA
  cmp #$01
  beq store_low_byte_for_right

  ; LOW BYTE FOR LEFT
  lda low_byte_nametable_address
  clc 
  adc #$20
  STA PPUADDR 
  jmp store_tile_to_ppu

  store_low_byte_for_right:
  lda low_byte_nametable_address
  clc 
  adc #$21
  STA PPUADDR
  jmp store_tile_to_ppu
  
add_with_no_overflow: 
  LDA high_byte_nametable_address
  sta PPUADDR
  TXA
  cmp #$01
  beq store_low_byte_for_right_no_overflow

  LDA low_byte_nametable_address
  CLC
  ADC #$20 
  sta PPUADDR
  jmp store_tile_to_ppu

store_low_byte_for_right_no_overflow:
  LDA low_byte_nametable_address
  CLC 
  ADC #$21 
  sta PPUADDR

store_tile_to_ppu:

  LDA tile_to_display
  STA PPUDATA

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
RTS
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

.proc read_controller1
  PHA
  TXA
  PHA
  PHP

  LDA #1
  STA pad1 ; store it with 1 so that when that 1 gets passed to the carry flag after 8 left shifts, we can break out of the loop

  ; write a 1, then a 0, to CONTROLLER1
  ; to latch button states
  LatchController:
    LDA #$01
    STA CONTROLLER1
    LDA #$00
    STA CONTROLLER1

  LDA #%00000001
  STA pad1

get_buttons:
  LDA CONTROLLER1 ; Read next button's state
  LSR A           ; Shift button state right, into carry flag
  ROL pad1        ; Rotate button state from carry flag
                  ; onto right side of pad1
                  ; and leftmost 0 of pad1 into carry flag
  BCC get_buttons ; Continue until original "1" is in carry flag
ReadA:
  LDA pad1
  AND #%10000000
  beq ReadADone

  lda #$01
  sta change_background_flag

  ReadADone:

; reads B to start scroll
ReadB: 
  LDA pad1
  AND #%01000000 
  BEQ ReadBDone

  LDA #$01
  STA flag_scroll  

  ReadBDone:
  PLP
  PLA
  TAX
  PLA
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
.include "maps/first_stage.asm"
.include "maps/second_stage.asm"



palettes:
.byte $0f, $16, $21, $30
.byte $0f, $10, $18, $20
.byte $0f, $19, $2A, $09
.byte $0f, $16, $09, $20

.byte $0f, $29, $19, $09
.byte $0f, $2C, $16, $09
.byte $0f, $04, $28, $11 
.byte $0f, $04, $28, $11

sprites:

  .byte $A0, $10, $00, $80  ; 
  .byte $A8, $20, $00, $80  ; 
  .byte $A0, $11, $00, $88  ; 
  .byte $A8, $21, $00, $88  ;  

.segment "CHR"
.incbin "updatedSprites.chr"
