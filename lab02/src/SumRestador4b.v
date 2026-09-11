// SumRestador4b.v
// Sumador/restador de 4 bits sin signo (A, B en 0..15)
// Entrega el resultado como MAGNITUD (5 bits, 0..30) + bit de SIGNO
//   Signo = 0 -> positivo
//   Signo = 1 -> negativo

module SumRestador4b(
    input  [3:0] A,
    input  [3:0] B,
    input        Op,          // 0 = suma (A+B) , 1 = resta (A-B)
    output [4:0] Resultado,   // magnitud del resultado
    output       Signo        // 1 = negativo
);

    wire [4:0] suma  = A + B;                       // 0 .. 30
    wire [4:0] resta = (A >= B) ? (A - B) : (B - A); // magnitud de la resta

    assign Signo     = Op & (A < B);   // solo puede ser negativo si se resta y A < B
    assign Resultado = Op ? resta : suma;

endmodule
