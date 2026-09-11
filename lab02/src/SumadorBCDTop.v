// SumadorBCDTop.v
// Integracion completa Lab02 (segunda parte):
//   SumRestador4b -> DoubleDabble -> 3x Hex7Seg
// Muestra en 3 displays: [Signo] [Decenas] [Unidades]

module SumadorBCDTop(
    input  [3:0] A,
    input  [3:0] B,
    input        Op,             // 0 = suma, 1 = resta
    output [6:0] Sseg_Signo,     // display izquierdo: '-' si es negativo, apagado si es positivo
    output [6:0] Sseg_Decenas,
    output [6:0] Sseg_Unidades
);

    wire [4:0] Resultado;
    wire       Signo;
    wire [3:0] Decenas, Unidades;

    SumRestador4b u_sum (
        .A         (A),
        .B         (B),
        .Op        (Op),
        .Resultado (Resultado),
        .Signo     (Signo)
    );

    DoubleDabble u_dd (
        .Binario  (Resultado),
        .Decenas  (Decenas),
        .Unidades (Unidades)
    );

    Hex7Seg u_disp_signo (
        .BCD   (4'b0000),
        .blank (~Signo),   // positivo -> apagado
        .dash  (Signo),    // negativo -> guion
        .Sseg  (Sseg_Signo)
    );

    Hex7Seg u_disp_decenas (
        .BCD   (Decenas),
        .blank (1'b0),
        .dash  (1'b0),
        .Sseg  (Sseg_Decenas)
    );

    Hex7Seg u_disp_unidades (
        .BCD   (Unidades),
        .blank (1'b0),
        .dash  (1'b0),
        .Sseg  (Sseg_Unidades)
    );

endmodule
