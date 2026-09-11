# arquitecturaDeProcesadoresG1E1

Arquitectura de Procesadores - Grupo 1 Equipo 1

## Descripción
Este es el repositorio número 1 del la asignatura Arquitectura de Procesadores.

## Integrantes
    * [<!-- David Orlando Torres >](<!https://github.com/davidortorresto-lab>) 
    * [<Luis Cuervo >](<https://github.com/luis-cuervo>)
## 1. Introducción

En este laboratorio se realizó el diseño e implementación de un decodificador BCD a un display de siete segmentos utilizando descripción de hardware HDL y una tarjeta de desarrollo FPGA.

El propósito de la práctica fue comprender cómo una entrada binaria de cuatro bits puede convertirse en las señales necesarias para controlar los siete segmentos de un display y representar diferentes números decimales y hexadecimales.

Inicialmente se estudió el funcionamiento del sistema BCD y la distribución de los segmentos del display. Posteriormente se desarrolló el diseño lógico, se realizó la simulación mediante un testbench y finalmente se llevó el diseño a la tarjeta de desarrollo.

Además, se realizó la integración del decodificador con un sistema sumador/restador de cuatro bits. Para poder representar los resultados de las operaciones en los displays se trabajó con la conversión de números binarios a BCD mediante el algoritmo Double Dabble.

---

# 2. Objetivos

## 2.1 Objetivo general

Diseñar e implementar un decodificador BCD a siete segmentos mediante HDL, permitiendo visualizar números decimales y hexadecimales utilizando una tarjeta de desarrollo FPGA.

## 2.2 Objetivos específicos

- Diseñar un controlador para un display de siete segmentos.
- Comprender el funcionamiento de la representación BCD.
- Identificar la diferencia entre displays de ánodo común y cátodo común.
- Elaborar la tabla de verdad correspondiente al decodificador.
- Implementar el diseño utilizando lenguaje HDL.
- Realizar la simulación del circuito mediante un testbench.
- Implementar el diseño en la tarjeta de desarrollo.
- Integrar el decodificador con un sumador/restador de cuatro bits.
- Convertir los resultados binarios a BCD utilizando el algoritmo Double Dabble.

---

# 3. Marco teórico

## 3.1 BCD

BCD significa **Binary Coded Decimal**, o Decimal Codificado en Binario.

Este sistema utiliza cuatro bits para representar cada dígito decimal. Como el sistema decimal tiene diez dígitos, desde 0 hasta 9, solamente se utilizan diez de las dieciséis combinaciones posibles de cuatro bits.

La tabla básica es:

| Decimal | BCD |
|:-------:|:---:|
| 0 | 0000 |
| 1 | 0001 |
| 2 | 0010 |
| 3 | 0011 |
| 4 | 0100 |
| 5 | 0101 |
| 6 | 0110 |
| 7 | 0111 |
| 8 | 1000 |
| 9 | 1001 |

Las combinaciones restantes pueden utilizarse para representar los valores hexadecimales A, B, C, D, E y F.

| Hexadecimal | Binario |
|:-----------:|:-------:|
| A | 1010 |
| B | 1011 |
| C | 1100 |
| D | 1101 |
| E | 1110 |
| F | 1111 |

---

# 4. Display de siete segmentos

Un display de siete segmentos está formado por siete LED independientes que permiten representar números y algunos caracteres.

Los segmentos normalmente se identifican mediante las letras:

```text
          a
       -------
      |       |
    f |       | b
      |   g   |
       -------
      |       |
    e |       | c
      |       |
       -------
          d

Los siete segmentos son:

-a
-b
-c
-d
-e
-f
-g

Dependiendo de qué segmentos se encuentren encendidos se pueden representar los diferentes números.

Por ejemplo, para representar el número 0 se activan los segmentos:

a, b, c, d, e, f

y el segmento g permanece apagado.

5. Tipos de display

Existen principalmente dos tipos de displays de siete segmentos.

5.1 Cátodo común

En el display de cátodo común, los cátodos de los LED se encuentran conectados a tierra.

Los segmentos se activan aplicando un nivel lógico alto.

          + Señal
             |
             LED
             |
             GND

Por lo tanto:

1 = segmento encendido
0 = segmento apagado
5.2 Ánodo común

En el display de ánodo común, los ánodos de los LED están conectados a la alimentación.

Los segmentos se activan mediante un nivel lógico bajo.

          VCC
           |
          LED
           |
        Señal

En este caso:

0 = segmento encendido
1 = segmento apagado

Esta diferencia debe tenerse en cuenta al realizar la descripción HDL del circuito.

6. Bloque funcional

El decodificador desarrollado recibe una entrada de cuatro bits denominada BCD y genera una salida de siete bits denominada Sseg.

El bloque funcional es:

              ┌─────────────────────────┐
              │                         │
 BCD[3:0] ───►│   DECODIFICADOR BCD     │───► Sseg[6:0]
              │     A 7 SEGMENTOS       │
              │                         │
              └─────────────────────────┘

La entrada contiene el número binario que se desea representar y la salida determina cuáles segmentos del display deben activarse.

7. Tabla de funcionamiento

Una tabla básica para los números decimales es:

Entrada BCD	Decimal	Display
0000	0	0
0001	1	1
0010	2	2
0011	3	3
0100	4	4
0101	5	5
0110	6	6
0111	7	7
1000	8	8
1001	9	9
1010	A	A
1011	B	B
1100	C	C
1101	D	D
1110	E	E
1111	F	F
8. Procedimiento

El desarrollo del laboratorio se realizó siguiendo varias etapas.

8.1 Diseño del bloque

Primero se definió el bloque funcional del decodificador.

La entrada corresponde a un bus de cuatro bits:

BCD[3:0]

y la salida corresponde a siete bits:

Sseg[6:0]
8.2 Descripción funcional

Después de definir el bloque se estableció el comportamiento que debe tener cada combinación de entrada.

Para cada valor de cuatro bits se determina qué segmentos deben estar encendidos.

8.3 Descripción HDL

Posteriormente se realizó la descripción del circuito utilizando HDL.

La lógica principal consiste en recibir la entrada de cuatro bits y generar el patrón correspondiente para el display.

8.4 Simulación

Antes de realizar la implementación física se realizó una simulación mediante un testbench.

La simulación permite verificar que cada combinación de entrada genere la salida esperada.

8.5 Implementación

Finalmente, el diseño se sintetiza y se programa en la tarjeta FPGA.

En esta etapa se realizan las respectivas asignaciones de pines para conectar las entradas y las salidas con los elementos físicos de la tarjeta.

9. Integración con el sumador/restador

Como segunda parte del laboratorio se integró el decodificador de siete segmentos con un sistema sumador/restador de cuatro bits.

El sistema cuenta con dos entradas:

A[3:0]
B[3:0]

y una entrada de control:

Op

La señal Op permite seleccionar la operación que se desea realizar.

El resultado se obtiene mediante:

Resultado[4:0]

También se utiliza una señal:

Signo

para identificar el signo correspondiente cuando se realiza una resta.

La estructura general es:

       A[3:0]
          │
          ▼
     ┌───────────┐
     │           │
     │   SUMA /  │──────► Resultado[4:0]
     │   RESTA   │
     │           │──────► Signo
     └─────┬─────┘
           │
       B[3:0]

           Op
           │
           ▼
     Selección de
       operación
10. Código HDL del sumador/restador

Una parte del código HDL utilizado para realizar las operaciones es:

module SumRestador4b (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Op,
    output reg  [4:0] Resultado,
    output reg        Signo
);

always @(*) begin

    if (Op == 1'b0) begin

        // Operación de suma
        Resultado = A + B;
        Signo = 1'b0;

    end

    else begin

        // Operación de resta
        if (A >= B) begin

            Resultado = A - B;
            Signo = 1'b0;

        end

        else begin

            Resultado = B - A;
            Signo = 1'b1;

        end

    end

end

endmodule

Este código permite seleccionar entre suma y resta mediante la entrada Op.

Cuando:

Op = 0

se realiza una suma.

Cuando:

Op = 1

se realiza una resta.

11. Testbench

Para verificar el funcionamiento del módulo se desarrolló un testbench.

Una estructura de prueba utilizada es:

module SumRestador4b_tb;

reg [3:0] A;
reg [3:0] B;
reg       Op;

wire [4:0] Resultado;
wire       Signo;

SumRestador4b uut (
    .A(A),
    .B(B),
    .Op(Op),
    .Resultado(Resultado),
    .Signo(Signo)
);

initial begin

    A = 4'b0000;
    B = 4'b0000;
    Op = 1'b0;

    #100;

    A = 4'b0101;
    B = 4'b0011;
    Op = 1'b0;

    #100;

    A = 4'b1000;
    B = 4'b0011;
    Op = 1'b1;

    #100;

    A = 4'b0011;
    B = 4'b1000;
    Op = 1'b1;

    #100;

    $finish;

end

endmodule
12. Simulación en GTKWave

La simulación fue visualizada utilizando GTKWave.

En la ventana de simulación se pueden observar las diferentes señales correspondientes al testbench:

A[3:0]
B[3:0]
Op
Resultado[4:0]
Signo
resta[4:0]
suma[4:0]

La estructura observada en GTKWave corresponde al testbench:

SumRestador4b_tb
       │
       └── uut

La señal A[3:0] cambia entre diferentes valores binarios, mientras que B[3:0] corresponde al segundo operando.

La señal Op permite observar el cambio entre la operación de suma y la operación de resta.

12.1 Evidencia de simulación

Figura 1. Simulación del sumador/restador de 4 bits utilizando GTKWave.

La simulación permite observar el comportamiento de las señales durante el tiempo de ejecución del testbench y comprobar la respuesta del circuito frente a diferentes valores de entrada.

13. Análisis de la simulación

En la simulación se pueden observar las entradas A y B, además de la señal Op, que permite seleccionar la operación.

La señal A[3:0] presenta diferentes valores durante el tiempo de simulación. Esto permite realizar varias pruebas sobre el circuito.

También se encuentran disponibles las señales:

suma[4:0]
resta[4:0]

Estas señales permiten analizar los resultados generados por las operaciones de suma y resta.

La simulación permite verificar el funcionamiento del circuito antes de realizar la implementación física en la tarjeta FPGA.

14. Algoritmo Double Dabble

Para visualizar correctamente los resultados de las operaciones en los displays de siete segmentos se necesita convertir el número binario a BCD.

Para realizar esta conversión se utiliza el algoritmo Double Dabble, también conocido como Shift and Add-3.

La regla principal del algoritmo es:

Si un grupo de 4 bits es mayor o igual a 5:

        grupo = grupo + 3

Después:

        desplazar un bit hacia la izquierda

Este procedimiento se repite hasta procesar todos los bits del número binario.

15. Ejemplo Double Dabble

Para convertir:

1110₂

a decimal:

1110₂ = 14₁₀

se utilizan dos grupos BCD:

[Decenas | Unidades]

Inicialmente:

0000 | 0000

Después de realizar los desplazamientos y las correcciones correspondientes se obtiene:

0001 | 0100

Por lo tanto:

0001 = 1
0100 = 4

Resultado:

14
16. Integración completa

La integración de todos los módulos puede representarse mediante el siguiente diagrama:

                  ┌─────────────────┐
                  │                 │
       A[3:0] ──►│                 │
                  │ SUMADOR/RESTA-  │
       B[3:0] ──►│      DOR        │
                  │                 │
        Op ─────►│                 │
                  └────────┬────────┘
                           │
                           ▼
                    Resultado[4:0]
                           │
                           ▼
                  ┌─────────────────┐
                  │                 │
                  │  DOUBLE DABBLE  │
                  │                 │
                  └────────┬────────┘
                           │
                           ▼
                          BCD
                           │
                           ▼
                  ┌─────────────────┐
                  │                 │
                  │ DECODIFICADOR   │
                  │   7 SEGMENTOS   │
                  │                 │
                  └────────┬────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │     DISPLAY     │
                  │ 7 SEGMENTOS FPGA│
                  └─────────────────┘
17. Resultados

![
    
](image-1.png)

Durante el desarrollo del laboratorio se obtuvo un diseño digital capaz de recibir una entrada binaria de cuatro bits y generar las señales necesarias para controlar un display de siete segmentos.

También se trabajó la integración del módulo con un sumador/restador de cuatro bits.

La simulación mediante GTKWave permitió observar las diferentes señales del sistema y comprobar el comportamiento de las entradas y operaciones.

Además, el uso del algoritmo Double Dabble permitió comprender cómo un resultado binario puede convertirse a BCD para posteriormente visualizar sus diferentes dígitos en los displays.

18. Discusión

La realización de la práctica permitió relacionar conceptos de lógica digital, descripción HDL y dispositivos FPGA.

Una de las partes importantes fue comprender que el display no recibe directamente un número decimal, sino un conjunto de señales digitales que determinan qué segmentos deben encenderse.

También fue necesario tener en cuenta el tipo de display utilizado, debido a que la lógica de activación cambia entre ánodo común y cátodo común.

La simulación permitió analizar el comportamiento del diseño antes de realizar la programación de la tarjeta.

Por otra parte, la integración con el sumador/restador permitió trabajar con diferentes módulos digitales dentro de un mismo sistema.

19. Conclusiones
Se comprendió el funcionamiento de un sistema BCD y su utilización para representar números decimales mediante señales binarias.
Se diseñó un decodificador capaz de transformar una entrada de cuatro bits en las señales necesarias para controlar un display de siete segmentos.
Se comprendió la diferencia entre los displays de ánodo común y cátodo común y su importancia al momento de realizar la implementación.
La simulación permitió comprobar el comportamiento del circuito antes de realizar su implementación en la tarjeta de desarrollo.
Se logró relacionar el funcionamiento del sumador/restador de cuatro bits con el sistema de visualización mediante displays de siete segmentos.
El algoritmo Double Dabble permitió comprender el proceso necesario para convertir un número binario a BCD.
La práctica permitió fortalecer los conocimientos sobre diseño digital, HDL, simulación e implementación en dispositivos FPGA.
20. Bibliografía
ECCI. Laboratorio 02: Decodificador BCD a 7 segmentos. Material de laboratorio de Arquitectura de Procesadores.
Documentación de Quartus Prime, herramienta utilizada para la descripción, síntesis e implementación del diseño HDL.
Documentación técnica de la tarjeta FPGA utilizada durante la práctica.
Material de clase de Arquitectura de Procesadores.
21. Entregables

Como evidencia del desarrollo del laboratorio se incluyen:

Descripción HDL del circuito.
Testbench del sumador/restador.
Simulación en GTKWave.
Diseño del decodificador BCD a 7 segmentos.
Conversión de binario a BCD mediante Double Dabble.
Implementación en la tarjeta FPGA.
Evidencias del funcionamiento del sistema.