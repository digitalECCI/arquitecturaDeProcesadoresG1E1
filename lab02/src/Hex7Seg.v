// Hex7Seg.v
// Decodificador de 4 bits (0-F) a display de 7 segmentos, ANODO COMUN (activo en bajo)
// Incluye codigos especiales para signo (guion) y apagado (blank)
//
// Sseg = {g,f,e,d,c,b,a}, cada bit en 0 enciende el segmento correspondiente

module Hex7Seg(
    input      [3:0] BCD,     // valor a mostrar (0-15)
    input             blank,   // 1 = apaga el display (tiene la mayor prioridad)
    input             dash,    // 1 = muestra un guion "-" (para el signo)
    output reg [6:0] Sseg     // {g,f,e,d,c,b,a} activo en bajo
);

    always @(*) begin
        if (blank)
            Sseg = 7'b1111111;          // todo apagado
        else if (dash)
            Sseg = 7'b0111111;          // solo segmento g encendido -> "-"
        else begin
            case (BCD)
                4'h0: Sseg = 7'b1000000;
                4'h1: Sseg = 7'b1111001;
                4'h2: Sseg = 7'b0100100;
                4'h3: Sseg = 7'b0110000;
                4'h4: Sseg = 7'b0011001;
                4'h5: Sseg = 7'b0010010;
                4'h6: Sseg = 7'b0000010;
                4'h7: Sseg = 7'b1111000;
                4'h8: Sseg = 7'b0000000;
                4'h9: Sseg = 7'b0010000;
                4'hA: Sseg = 7'b0001000;
                4'hB: Sseg = 7'b0000011;
                4'hC: Sseg = 7'b1000110;
                4'hD: Sseg = 7'b0100001;
                4'hE: Sseg = 7'b0000110;
                4'hF: Sseg = 7'b0001110;
                default: Sseg = 7'b1111111;
            endcase
        end
    end

endmodule
