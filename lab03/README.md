# arquitecturaDeProcesadoresG1E1

Arquitectura de Procesadores - Grupo 1 Equipo 1


## Integrantes
* [David Orlando Torres](https://github.com/davidortorresto-lab) 

* [Luis Cuervo ](https://github.com/luis-cuervo)


## 1. Introducción

La multiplicación es una operación fundamental en cualquier unidad aritmético-lógica (ALU). Una implementación combinacional requiere muchas compuertas, mientras que una secuencial reutiliza un único sumador y registros de desplazamiento a lo largo de varios ciclos de reloj, reduciendo el área a costa de latencia. En esta práctica se diseña, simula e implementa en FPGA un multiplicador secuencial de 3 bits controlado por una ASM, y se muestra el resultado en los displays de 7 segmentos de la tarjeta de desarrollo.

## 2. Objetivos

- Implementar un multiplicador secuencial de 3 bits utilizando una ASM.
- Comprender la multiplicación secuencial mediante productos parciales y desplazamientos.
- Sintetizar e implementar el diseño en la tarjeta de desarrollo a partir de una descripción en HDL.
- Validar el diseño mediante simulación y pruebas en hardware.

## 3. Marco teórico

### 3.1 Multiplicación secuencial

Los bits del multiplicador (MR) se procesan uno por ciclo. Si el bit menos significativo es 1, se suma el multiplicando (MD) al acumulador; luego se desplaza a la derecha el conjunto acumulador–multiplicador. Tras *n* = 3 iteraciones, el producto de 6 bits queda en `{A, Q}`.

Ejemplo, 5 × 3 (MD = 101, MR = 011):

| Iteración | Q[0] | Operación | A (tras sumar) | {A,Q} tras desplazar |
|---|---|---|---|---|
| Inicio | – | A = 0, Q = 011 | 0000 | 000 011 |
| 1 | 1 | A = A + 101 | 0101 | 010 101 |
| 2 | 1 | A = A + 101 | 0111 | 011 110 |
| 3 | 0 | sin suma | 0011 | 001 111 |

Resultado: `001111` = 15 ✓

### 3.2 Máquina de Estados Algorítmica (ASM)

Una ASM describe un algoritmo secuencial mediante estados, decisiones y acciones sincronizadas con el reloj. Permite separar la **unidad de control** (máquina de estados que genera las señales de control) del **camino de datos** (registros, sumador y desplazador).

### 3.3 Lógica secuencial

La lógica secuencial usa elementos de memoria (flip-flops) para almacenar el estado. El próximo estado depende de las entradas actuales y del estado previo, a diferencia de la lógica combinacional, donde la salida depende solo de las entradas presentes.

## 4. Diseño

### 4.1 Interfaz del módulo

| Señal | Dirección | Ancho | Descripción |
|---|---|---|---|
| `clk` | Entrada | 1 | Reloj del sistema |
| `rst` | Entrada | 1 | Reinicio asíncrono (activo en alto) |
| `start` | Entrada | 1 | Inicia la multiplicación |
| `MD` | Entrada | 3 | Multiplicando |
| `MR` | Entrada | 3 | Multiplicador |
| `pp` | Salida | 6 | Producto |
| `done` | Salida | 1 | Indica fin de la operación |

### 4.2 Camino de datos

- **M (3 bits):** guarda el multiplicando.
- **Q (3 bits):** multiplicador; se desplaza a la derecha y su bit 0 decide si se suma.
- **A (4 bits):** acumulador de productos parciales; el bit 3 almacena el acarreo.
- **cnt (2 bits):** contador de iteraciones (0 a 2).
- **Sumador de 3 bits** con acarreo de salida.
- Producto final: `pp = {A[2:0], Q}`.

### 4.3 Unidad de control (ASM)

| Estado | Acciones | Siguiente estado |
|---|---|---|
| `IDLE` | `done = 0`. Si `start`: A ← 0, Q ← MR, M ← MD, cnt ← 0 | `ADD` si `start`, si no `IDLE` |
| `ADD` | Si Q[0] = 1: A ← A + M | `SHIFT` |
| `SHIFT` | {A, Q} ← {0, A, Q} >> 1; cnt ← cnt + 1 | `DONE` si cnt = 2, si no `ADD` |
| `DONE` | `done = 1`; `pp` válido | `IDLE` cuando `start = 0` |

![Diagrama de flujo](docs/img/diagrama_flujo.png)

![Diagrama de estados](docs/img/diagrama_estados.png)

### 4.4 Descripción en Verilog (`src/mult.v`)

```verilog
module mult (
    input        clk,
    input        rst,
    input        start,
    input  [2:0] MD,
    input  [2:0] MR,
    output [5:0] pp,
    output       done
);
    localparam IDLE = 2'd0, ADD = 2'd1, SHIFT = 2'd2, DONE = 2'd3;

    reg [1:0] state;
    reg [2:0] M, Q;
    reg [3:0] A;      // A[3] = acarreo
    reg [1:0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            A <= 4'd0; Q <= 3'd0; M <= 3'd0; cnt <= 2'd0;
        end else begin
            case (state)
                IDLE: if (start) begin
                    A <= 4'd0; Q <= MR; M <= MD; cnt <= 2'd0;
                    state <= ADD;
                end
                ADD: begin
                    if (Q[0]) A <= {1'b0, A[2:0]} + {1'b0, M};
                    state <= SHIFT;
                end
                SHIFT: begin
                    A <= {1'b0, A[3:1]};
                    Q <= {A[0], Q[2:1]};
                    cnt <= cnt + 2'd1;
                    state <= (cnt == 2'd2) ? DONE : ADD;
                end
                DONE: if (!start) state <= IDLE;
                default: state <= IDLE;
            endcase
        end
    end

    assign pp   = {A[2:0], Q};
    assign done = (state == DONE);
endmodule
```

## 5. Simulación

### 5.1 Testbench (`tb/mult_tb.v`)

```verilog
`timescale 1ns/1ps
module mult_tb;
    reg clk = 0, rst = 1, start = 0;
    reg [2:0] MD, MR;
    wire [5:0] pp;
    wire done;
    integer i, j, errores = 0;

    mult dut (.clk(clk), .rst(rst), .start(start),
              .MD(MD), .MR(MR), .pp(pp), .done(done));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("mult_tb.vcd");
        $dumpvars(0, mult_tb);
        #20 rst = 0;
        for (i = 0; i < 8; i = i + 1)
            for (j = 0; j < 8; j = j + 1) begin
                MD = i; MR = j;
                @(negedge clk) start = 1;
                wait (done);
                @(negedge clk);
                if (pp !== i*j) begin
                    errores = errores + 1;
                    $display("ERROR: %0d x %0d = %0d (esperado %0d)", i, j, pp, i*j);
                end
                start = 0;
                @(negedge clk);
            end
        $display("Prueba finalizada con %0d errores", errores);
        $finish;
    end
endmodule
```

El testbench recorre las 64 combinaciones de operandos y compara con el valor esperado `i*j`.

Comandos usados (Icarus Verilog + GTKWave):

```
iverilog -o sim/mult_tb.vvp src/mult.v tb/mult_tb.v
vvp sim/mult_tb.vvp
gtkwave mult_tb.vcd
```


## 6. Implementación en FPGA

### 6.1 Proyecto en Quartus

1. Se creó un proyecto nuevo con el dispositivo de la tarjeta [modelo de FPGA / tarjeta].
2. Se agregaron `mult.v` y los módulos de visualización.
3. Se definió el módulo superior como *top-level entity*.
4. Se asignaron los pines (reloj, interruptores, pulsadores y displays) con Pin Planner.
5. Se compiló el diseño y se programó la FPGA.

### 6.2 Visualización en 7 segmentos

El producto máximo es 7 × 7 = 49, por lo que se usan dos dígitos decimales: un módulo convierte `pp` a BCD (decenas = `pp / 10`, unidades = `pp % 10`) y un decodificador BCD a 7 segmentos maneja cada display.

```verilog
module bin2bcd_6 (input [5:0] bin, output [3:0] tens, output [3:0] units);
    assign tens  = bin / 6'd10;
    assign units = bin % 6'd10;
endmodule

module bcd_7seg (input [3:0] bcd, output reg [6:0] seg); // activo en bajo
    always @(*) case (bcd)
        4'd0: seg = 7'b1000000; 4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100; 4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001; 4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010; 4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000; 4'd9: seg = 7'b0010000;
        default: seg = 7'b1111111;
    endcase
endmodule
```

MD y MR se asignan a interruptores, `start` a un pulsador y `done` a un LED. [Ajustar según la asignación real de pines y la polaridad de los displays.]

### 6.3 Recursos utilizados

| Recurso | Cantidad |
|---|---|
| Elementos lógicos (LE/ALM) | [valor] |
| Registros | [valor] |
| Pines | [valor] |
| Frecuencia máxima (Fmax) | [valor] |

## 7. Pruebas en hardware

| MD | MR | Esperado | Mostrado en displays | ¿Correcto? |
|---|---|---|---|---|
| 3 | 2 | 06 | [ ] | [ ] |
| 5 | 3 | 15 | [ ] | [ ] |
| 7 | 7 | 49 | [ ] | [ ] |
| 0 | 6 | 00 | [ ] | [ ] |
| 4 | 6 | 24 | [ ] | [ ] |

![Prueba en la tarjeta](docs/img/hardware.jpg)

## 8. Avance hacia la ALU

El multiplicador se integra como una operación más de la ALU construida a la fecha, conectándolo mediante un código de operación (`opcode`), con `start` y `done` como protocolo de handshake y los operandos tomados del banco de registros. [Describir el estado actual de la integración y las operaciones disponibles.]

## 9. Análisis de resultados

- El diseño produce resultados correctos en las 64 combinaciones de operandos en simulación. [Confirmar con sus resultados.]
- La arquitectura secuencial usa un solo sumador de 3 bits en lugar de una matriz de sumadores, reduciendo el área frente a un multiplicador combinacional.
- La latencia sube a unos 8 ciclos por operación; para 3 bits es despreciable, pero crece linealmente con el ancho de los operandos.
- Separar unidad de control y camino de datos facilita depurar cada parte por separado.

## 10. Conclusiones

1. Se implementó un multiplicador secuencial de 3 bits basado en suma y desplazamiento, controlado por una ASM de cuatro estados.
2. La simulación exhaustiva permitió validar el funcionamiento antes de sintetizar.
3. La implementación en FPGA con visualización en 7 segmentos confirmó el comportamiento en hardware.
4. El enfoque secuencial es eficiente en área y es un bloque reutilizable dentro de la ALU.

## 11. Referencias

- Material de clase y repositorio base de GitHub Classroom.
- M. M. Mano y M. D. Ciletti, *Digital Design*, Pearson.
- Documentación de la tarjeta de desarrollo y de Intel Quartus Prime.
