stage2Part1:
    .byte $ff,$ff,$ff,$ff;1
    .byte $c0,$00,$00,$03;2
    .byte $ea,$80,$00,$23;3
    .byte $c0,$2a,$ff,$23;4
    .byte $00,$00,$02,$20;5
    .byte $c0,$2a,$a7,$7b;6
    .byte $ea,$a8,$22,$03;7
    .byte $d0,$08,$a2,$83;8
    .byte $ca,$90,$06,$83;9
    .byte $c1,$20,$aa,$03;1011
    .byte $ca,$88,$20,$43;11
    .byte $c0,$1a,$a0,$8b;12
    .byte $da,$80,$00,$8b;13
    .byte $c0,$aa,$aa,$ab;14
    .byte $ff,$ff,$ff,$ff;15


stage2Part2:
    .byte $aa,$aa,$aa,$aa;1
    .byte $8f,$cf,$cf,$c2;2
    .byte $84,$4c,$cc,$32;3
    .byte $8f,$cc,$cf,$c2;4
    .byte $0c,$cc,$c4,$32;5
    .byte $8c,$c7,$cd,$c2;6
    .byte $8c,$f0,$0c,$02 ;7
    .byte $8c,$00,$0c,$3e;8
    .byte $8f,$0f,$cf,$c2;9
    .byte $8c,$c3,$04,$32;10
    .byte $84,$33,$0f,$12;11
    .byte $8c,$33,$0c,$32;12
    .byte $8c,$43,$0c,$30;13
    .byte $8f,$05,$4f,$3e;15
    .byte $aa,$aa,$aa,$aa