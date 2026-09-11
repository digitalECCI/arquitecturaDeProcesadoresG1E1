// DoubleDabble.v
// Convierte un binario de 5 bits (0 a 30) a dos digitos BCD: Decenas (0-3) y Unidades (0-9)
// Algoritmo Double Dabble (shift-and-add-3), tal como se describe en la guia del Lab02
//
// Registro de trabajo de 13 bits: [12:9]=Decenas  [8:5]=Unidades  [4:0]=bits binarios restantes

module DoubleDabble(
    input      [4:0] Binario,   // 0 a 30
    output reg [3:0] Decenas,
    output reg [3:0] Unidades
);

    integer i;
    reg [12:0] reg_trabajo;

    always @(*) begin
        reg_trabajo        = 13'b0;
        reg_trabajo[4:0]   = Binario;   // se carga el binario en la parte baja del registro

        for (i = 0; i < 5; i = i + 1) begin
            // Paso 1: si algun nibble BCD es >= 5, se le suma 3 (ajuste double dabble)
            if (reg_trabajo[8:5] >= 4'd5)
                reg_trabajo[8:5] = reg_trabajo[8:5] + 4'd3;

            if (reg_trabajo[12:9] >= 4'd5)
                reg_trabajo[12:9] = reg_trabajo[12:9] + 4'd3;

            // Paso 2: desplazar todo el registro un bit a la izquierda
            reg_trabajo = reg_trabajo << 1;
        end

        Unidades = reg_trabajo[8:5];
        Decenas  = reg_trabajo[12:9];
    end

endmodule
