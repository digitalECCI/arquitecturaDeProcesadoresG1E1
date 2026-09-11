`include "sumador1b.v"

module sumador4b(
    input  [3:0] A,
    input  [3:0] B,
    input        Ci,
    output [3:0] S,
    output       Co
);

    // Acarreos internos entre etapas
    wire c1, c2, c3;

    // Instanciación de 4 sumadores de 1 bit encadenados (ripple carry)
    sumador1b bit0(.A(A[0]), .B(B[0]), .Ci(Ci), .S(S[0]), .Co(c1));
    sumador1b bit1(.A(A[1]), .B(B[1]), .Ci(c1), .S(S[1]), .Co(c2));
    sumador1b bit2(.A(A[2]), .B(B[2]), .Ci(c2), .S(S[2]), .Co(c3));
    sumador1b bit3(.A(A[3]), .B(B[3]), .Ci(c3), .S(S[3]), .Co(Co));

endmodule
