stage1Part1:
    .byte $aa,$aa,$aa,$aa
    .byte $84,$0f,$f3,$c2
    .byte $8f,$ff,$f3,$00
    .byte $8f,$00,$03,$3e
    .byte $8f,$ff,$c3,$32
    .byte $80,$00,$c3,$32
    .byte $83,$fc,$c3,$32
    .byte $83,$00,$03,$32
    .byte $83,$ff,$c1,$32
    .byte $00,$00,$c3,$32
    .byte $8f,$ff,$ff,$32
    .byte $80,$00,$10,$32
    .byte $8f,$ff,$ff,$f2
    .byte $80,$00,$00,$02
    .byte $aa,$aa,$aa,$aa

stage1Part2:
    .byte $ff,$ff,$ff,$ff
    .byte $c0,$02,$aa,$ab
    .byte $0a,$a9,$00,$03
    .byte $c8,$00,$aa,$a3
    .byte $ca,$a4,$00,$40
    .byte $c0,$2a,$a0,$ab
    .byte $ca,$a2,$20,$43
    .byte $c8,$00,$2a,$8b
    .byte $ca,$aa,$00,$0b
    .byte $c8,$01,$00,$0b
    .byte $d8,$0a,$aa,$ab
    .byte $ca,$88,$08,$03
    .byte $ca,$98,$aa,$ab
    .byte $c0,$00,$00,$03
    .byte $ff,$ff,$ff,$ff