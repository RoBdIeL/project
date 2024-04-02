.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
frame_counter: .res 1
animation_counter: .res 1

frame_counter2: .res 1
animation_counter2: .res 1

frame_counter3: .res 1
animation_counter3: .res 1

frame_counter4: .res 1
animation_counter4: .res 1

.exportzp frame_counter, animation_counter
.exportzp frame_counter2, animation_counter2
.exportzp frame_counter3, animation_counter3
.exportzp frame_counter4, animation_counter4

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

  JSR draw_player
  JSR draw_player2
  JSR draw_player3
  JSR draw_player4

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

; Right
.proc draw_player
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
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F      ; Mask out lower 4 bits
  CMP #$05      ; Check which frame of animation to use
  BCC frame_1   ; If less than 5, use the first frame
  CMP #$0A      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 10, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$10      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$20
  STA $0205
  LDA #$11
  STA $0209
  LDA #$21
  STA $020d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$13      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$23
  STA $0205
  LDA #$14
  STA $0209
  LDA #$24
  STA $020d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$16      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$26
  STA $0205
  LDA #$17
  STA $0209
  LDA #$27
  STA $020d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; Increment frame counter
  INC frame_counter

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Left
.proc draw_player2
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter2
  LDA animation_counter2
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter2
  AND #$0F      ; Mask out lower 4 bits
  CMP #$05      ; Check which frame of animation to use
  BCC frame_1   ; If less than 5, use the first frame
  CMP #$0A      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 10, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$40      ; Use tile number for the third frame of animation
  STA $0211
  LDA #$50
  STA $0215
  LDA #$41
  STA $0219
  LDA #$51
  STA $021d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$43      ; Use tile number for the second frame of animation
  STA $0211
  LDA #$53
  STA $0215
  LDA #$44
  STA $0219
  LDA #$54
  STA $021d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$46      ; Use tile number for the first frame of animation
  STA $0211
  LDA #$56
  STA $0215
  LDA #$47
  STA $0219
  LDA #$57
  STA $021d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  ; Increment frame counter
  INC frame_counter2

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Up
.proc draw_player3
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter3
  LDA animation_counter3
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter3
  AND #$0F      ; Mask out lower 4 bits
  CMP #$05      ; Check which frame of animation to use
  BCC frame_1   ; If less than 5, use the first frame
  CMP #$0A      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 10, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$70     ; Use tile number for the third frame of animation
  STA $0221
  LDA #$80
  STA $0225
  LDA #$71
  STA $0229
  LDA #$81
  STA $022d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$73      ; Use tile number for the second frame of animation
  STA $0221
  LDA #$83
  STA $0225
  LDA #$74
  STA $0229
  LDA #$84
  STA $022d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$76      ; Use tile number for the first frame of animation
  STA $0221
  LDA #$86
  STA $0225
  LDA #$77
  STA $0229
  LDA #$87
  STA $022d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0222
  STA $0226
  STA $022a
  STA $022e

  ; Increment frame counter
  INC frame_counter3

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Down
.proc draw_player4
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter4
  LDA animation_counter4
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter4
  AND #$0F      ; Mask out lower 4 bits
  CMP #$05      ; Check which frame of animation to use
  BCC frame_1   ; If less than 5, use the first frame
  CMP #$0A      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 10, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$B0     ; Use tile number for the third frame of animation
  STA $0231
  LDA #$C0
  STA $0235
  LDA #$B1
  STA $0239
  LDA #$C1
  STA $023d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$B3      ; Use tile number for the second frame of animation
  STA $0231
  LDA #$C3
  STA $0235
  LDA #$B4
  STA $0239
  LDA #$C4
  STA $023d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$B6      ; Use tile number for the first frame of animation
  STA $0231
  LDA #$C6
  STA $0235
  LDA #$B7
  STA $0239
  LDA #$C7
  STA $023d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0232
  STA $0236
  STA $023a
  STA $023e

  ; Increment frame counter
  INC frame_counter4

  ; restore registers and return
skip_animation:
  PLA
  TAY
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

  ;going right

  .byte $80, $10, $00, $70  ; 
  .byte $88, $20, $00, $70  ; 
  .byte $80, $11, $00, $78  ; 
  .byte $88, $21, $00, $78 ; 

  .byte $80, $13, $00, $80; 
  .byte $88, $23, $00, $80  ; 
  .byte $80, $14, $00, $88 ; 
  .byte $88, $24, $00, $88  ; 

  .byte $80, $16, $00, $90  ; 
  .byte $88, $26, $00, $90  ; 
  .byte $80, $17, $00, $98  ; 
  .byte $88, $27, $00, $98  ; 

  ;going left

  .byte $80, $40, $00, $a0 ; 
  .byte $88, $50, $00, $a0  ; 
  .byte $80, $41, $00, $a8  ; 
  .byte $88, $51, $00, $a8  ; 

  ; .byte $20, $43, $00, $20  ; 
  ; .byte $28, $53, $00, $20  ; 
  ; .byte $20, $44, $00, $28  ; 
  ; .byte $28, $54, $00, $28  ; 

  ; .byte $20, $46, $00, $30  ; 
  ; .byte $28, $56, $00, $30  ; 
  ; .byte $20, $47, $00, $38  ; 
  ; .byte $28, $57, $00, $38  ; 

  ; ;going up

  ; .byte $30, $70, $00, $10  ; 
  ; .byte $38, $80, $00, $10  ; 
  ; .byte $30, $71, $00, $18  ; 
  ; .byte $38, $81, $00, $18  ; 

  ; .byte $30, $73, $00, $20  ; 
  ; .byte $38, $83, $00, $20  ; 
  ; .byte $30, $74, $00, $28  ; 
  ; .byte $38, $84, $00, $28  ; 

  ; .byte $30, $76, $00, $30  ; 
  ; .byte $38, $86, $00, $30  ; 
  ; .byte $30, $77, $00, $38  ; 
  ; .byte $38, $87, $00, $38  ; 

  ;going down

  ; .byte $40, $B0, $00, $10  ; 
  ; .byte $48, $C0, $00, $10  ; 
  ; .byte $40, $B1, $00, $18  ; 
  ; .byte $48, $C1, $00, $18  ; 

  ; .byte $40, $B3, $00, $20  ; 
  ; .byte $48, $C3, $00, $20  ; 
  ; .byte $40, $B4, $00, $28  ; 
  ; .byte $48, $C4, $00, $28  ; 

  ; .byte $40, $B6, $00, $30  ; 
  ; .byte $48, $C6, $00, $30  ; 
  ; .byte $40, $B7, $00, $38  ; 
  ; .byte $48, $C7, $00, $38  ; 

  

.segment "CHR"
.incbin "updatedSprites.chr"