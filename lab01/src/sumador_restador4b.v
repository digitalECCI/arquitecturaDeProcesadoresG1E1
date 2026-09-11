`include "sumador1b.v"

module sumador_restador4b(
    input  [3:0] A,
    input  [3:0] B,
    input        Sel,   // 0 = suma (A+B), 1 = resta (A-B)
    output [3:0] S,
    output       Co
);

    wire [3:0] B_xor;
    wire c1, c2, c3;

    // Paso 1 del complemento a 2: si Sel=1 invierte B (complemento a 1)
    // Si Sel=0, B pasa sin cambios
    assign B_xor = B ^ {4{Sel}};

    // Paso 2 del complemento a 2: Sel también entra como acarreo inicial,
    // sumando el "+1" necesario para completar el complemento a 2
    sumador1b bit0(.A(A[0]), .B(B_xor[0]), .Ci(Sel), .S(S[0]), .Co(c1));
    sumador1b bit1(.A(A[1]), .B(B_xor[1]), .Ci(c1),  .S(S[1]), .Co(c2));
    sumador1b bit2(.A(A[2]), .B(B_xor[2]), .Ci(c2),  .S(S[2]), .Co(c3));
    sumador1b bit3(.A(A[3]), .B(B_xor[3]), .Ci(c3),  .S(S[3]), .Co(Co));

endmodule
