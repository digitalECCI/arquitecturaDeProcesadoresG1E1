`timescale 1ns/1ps
// ============================================================================
//  tb_consola.v - Simula la consola UART del picoSoC (PicoRV32)
//
//  - Genera el reloj de 50 MHz.
//  - "Teclea" comandos por la linea rx (115200 baudios, divisor 434).
//  - Decodifica la linea tx y muestra en la terminal lo que imprime el
//    firmware (banner, prompt y respuestas).
//  - Muestra cada cambio de los LEDs y deja un VCD para GTKWave.
//
//  Uso (en la carpeta del proyecto, despues de `make`):
//    iverilog -o sim_consola tb_consola.v top.v picosoc_noflash.v picorv32.v simpleuart.v progmem.v
//    vvp sim_consola
//    gtkwave consola.vcd
//
//  Para probar tambien blink y knight (la simulacion tarda mucho mas):
//    iverilog -DPROBAR_LENTOS -o sim_consola ...
// ============================================================================

module tb_consola;

  localparam CLK_HALF = 10;      // 50 MHz -> periodo 20 ns
  localparam BIT_NS   = 8680;    // 434 ciclos * 20 ns  (divisor de la UART = 434)

`ifdef PROBAR_LENTOS
  localparam TIMEOUT_NS = 2000000000;   // 2 s simulados
`else
  localparam TIMEOUT_NS = 300000000;    // 300 ms simulados
`endif

  reg        clk = 0;
  reg        rx  = 1;            // linea hacia el SoC (reposo = 1)
  reg  [3:0] sw  = 4'b0000;
  reg  [1:0] key = 2'b11;       // botones sin presionar (activos en bajo)
  wire       tx;
  wire [3:0] led;

  // --- Dispositivo bajo prueba (puertos segun top.v: clk, led, rx, sw, tx) ---
  top uut (
    .clk (clk),
    .led (led),
    .rx  (rx),
    .sw  (sw),
    .key (key),
    .tx  (tx)
  );

  always #CLK_HALF clk = ~clk;

  // ------------------------------------------------------------------------
  // Receptor UART: decodifica tx y lo imprime como texto
  // ------------------------------------------------------------------------
  reg [7:0] rx_byte = 0;
  reg [7:0] prev    = 0;
  reg [7:0] prev2   = 0;
  reg       prompt_seen = 0;
  integer   k;

  initial begin
    wait (tx === 1'b1);                  // espera a que la linea este en reposo
    forever begin
      @(negedge tx);                     // bit de inicio
      #(BIT_NS * 3 / 2);                 // centro del bit 0
      for (k = 0; k < 8; k = k + 1) begin
        rx_byte[k] = tx;
        #(BIT_NS);
      end                                // ahora en el centro del bit de parada
      if (rx_byte != 8'h0D) $write("%c", rx_byte);
      // el prompt real "> " va siempre al inicio de linea (despues de un salto);
      // asi no se confunde con los "> " que aparecen dentro del texto de help
      if (prev2 == 8'h0A && prev == ">" && rx_byte == " ") prompt_seen = 1;
      prev2 = prev;
      prev  = rx_byte;
    end
  end

  // ------------------------------------------------------------------------
  // Transmisor UART: envia un byte por rx
  // ------------------------------------------------------------------------
  task uart_send(input [7:0] b);
    integer i;
    begin
      rx = 0;  #(BIT_NS);                          // bit de inicio
      for (i = 0; i < 8; i = i + 1) begin
        rx = b[i];  #(BIT_NS);                     // datos, LSB primero
      end
      rx = 1;  #(BIT_NS);                          // bit de parada
    end
  endtask

  // Espera el prompt, escribe el comando caracter por caracter y pulsa Enter
  task send_cmd(input [8*24-1:0] s);
    integer i;
    reg [7:0] c;
    begin
      wait (prompt_seen == 1);
      prompt_seen = 0;
      #(BIT_NS * 12);
      for (i = 23; i >= 0; i = i - 1) begin
        c = s[8*i +: 8];
        if (c != 0) begin
          uart_send(c);
          #(BIT_NS * 12);                          // pausa entre teclas
        end
      end
      uart_send(8'h0D);                            // Enter
    end
  endtask

  // ------------------------------------------------------------------------
  // Registro de cambios en los LEDs
  // ------------------------------------------------------------------------
  always @(led)
    $display("\n[LED] t=%0t ns  led = %b", $time, led);

  // ------------------------------------------------------------------------
  // Secuencia de pruebas
  // ------------------------------------------------------------------------
  initial begin
    $dumpfile("consola.vcd");
    $dumpvars(1, tb_consola);          // solo clk, rx, tx, led, sw (VCD pequeno)

    sw = 4'b0101;                      // valor que se leera con el comando sw

    send_cmd("help");
    send_cmd("led 1 on");
    send_cmd("led 3 on");
    send_cmd("led 1 off");
    send_cmd("leds 0xA");
    send_cmd("sw");
    // se ajustan los switches; el resultado no sale hasta presionar KEY0
    wait (prompt_seen == 1);  prompt_seen = 0;   // prompt tras la respuesta de sw
    sw = 4'b1100;
    #(BIT_NS * 5);
    key[0] = 0;  #30000000;  key[0] = 1;         // KEY0 presionado 30 ms (activar)
    wait (prompt_seen == 1);  prompt_seen = 0;   // resultado + prompt reimpreso
    // KEY1 resetea todo el SoC: el firmware vuelve a arrancar (banner y prompt)
    key[1] = 0;  #1000;  key[1] = 1;
    wait (prompt_seen == 1);
    send_cmd("calc 6 * 7");
    send_cmd("calc 100 / 7");
    send_cmd("calc 5 / 0");
    send_cmd("led 9 on");              // error: LED fuera de rango
    send_cmd("hola");                  // error: comando desconocido

`ifdef PROBAR_LENTOS
    send_cmd("blink 0 1");
    send_cmd("knight 1");
    #2000000;
    uart_send("x");                    // una tecla detiene knight
`endif

    wait (prompt_seen == 1);
    #(BIT_NS * 20);
    $display("\n\n--- fin de la simulacion ---");
    $finish;
  end

  // Seguridad: si algo se cuelga, termina igual
  initial begin
    #(TIMEOUT_NS);
    $display("\n\n--- TIMEOUT: la simulacion no termino a tiempo ---");
    $finish;
  end

endmodule
