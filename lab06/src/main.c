/*
 *  PicoSoC Shell - DE10-Lite (MAX10, 50 MHz)
 *  Consola UART: help, led, leds, sw, calc, blink, knight (comando propio)
 *
 *  Version compacta: el #pragma de abajo hace que el compilador optimice
 *  por tamano (-Os) aunque el Makefile no tenga esa opcion, para que el
 *  firmware quepa en la memoria del procesador.
 */
#pragma GCC optimize ("Os")

#include <stdint.h>

/* Hardware (definido al final del archivo) */
void     uart_putchar(char c);
int      uart_getchar_nb(void);
void     write_leds(uint32_t v);
uint32_t read_switches(void);
uint32_t read_keys(void);      /* bit0 = KEY0 presionado */

/* ---------------- UART ---------------- */
static void uart_puts(const char *s) {
    while (*s) uart_putchar(*s++);
}

static void uart_put_dec(int v) {
    char buf[12];
    int  i = 0;
    unsigned u = (v < 0) ? (unsigned)(-v) : (unsigned)v;
    if (v < 0) uart_putchar('-');
    do { buf[i++] = '0' + (u % 10); u /= 10; } while (u);
    while (i) uart_putchar(buf[--i]);
}

static void uart_put_bin4(uint32_t v) {
    int i;
    uart_puts("0b");
    for (i = 3; i >= 0; i--) uart_putchar(((v >> i) & 1) ? '1' : '0');
}

/* ---------------- Utilidades ---------------- */
static int str_eq(const char *a, const char *b) {
    while (*a && *a == *b) { a++; b++; }
    return *a == *b;
}

/* decimal (con signo) o hexadecimal 0x..; ok=0 si es invalido */
static int parse_int(const char *s, int *ok) {
    int sign = 1, val = 0, base = 10, d;
    *ok = 0;
    if (*s == '-') { sign = -1; s++; }
    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) { base = 16; s += 2; }
    if (!*s) return 0;
    for (; *s; s++) {
        if (*s >= '0' && *s <= '9')      d = *s - '0';
        else if (*s >= 'a' && *s <= 'f') d = *s - 'a' + 10;
        else if (*s >= 'A' && *s <= 'F') d = *s - 'A' + 10;
        else return 0;
        if (d >= base) return 0;
        val = val * base + d;
    }
    *ok = 1;
    return sign * val;
}

static int tokenize(char *line, char *argv[], int max) {
    int n = 0;
    while (*line) {
        while (*line == ' ') line++;
        if (!*line) break;
        if (n < max) argv[n++] = line;
        while (*line && *line != ' ') line++;
        if (*line) *line++ = 0;
    }
    return n;
}

static void delay_cycles(uint32_t n) {
    volatile uint32_t i;
    for (i = 0; i < n; i++);
}

/* ---------------- LEDs ---------------- */
static uint8_t led_state = 0;

static void set_leds(uint8_t v) {
    led_state = v;
    write_leds(v);
}

/* devuelve el numero de LED (0-3) o -1 si es invalido */
static int get_led(const char *s) {
    int ok, n = parse_int(s, &ok);
    return (ok && n >= 0 && n <= 3) ? n : -1;
}

/* ---------------- Comandos ---------------- */
static void cmd_help(void) {
    uart_puts("help\r\n"
              "led <n> <on|off>\r\n"
              "leds <valor 0-15 o 0x0-0xF>\r\n"
              "sw\r\n"
              "calc <a> <op> <b>  (+ - * /)\r\n"
              "blink <n> <veces>\r\n"
              "knight [ciclos]  (tecla = parar)\r\n"
              "KEY0 = resultado de sw, KEY1 = reset\r\n");
}

static void cmd_led(int argc, char *argv[]) {
    int n;
    if (argc < 3 || (n = get_led(argv[1])) < 0) { uart_puts("uso: led <0-3> <on|off>\r\n"); return; }
    if      (str_eq(argv[2], "on"))  set_leds(led_state |  (1 << n));
    else if (str_eq(argv[2], "off")) set_leds(led_state & ~(1 << n));
    else { uart_puts("usa on/off\r\n"); return; }
    uart_puts("ok\r\n");
}

static void cmd_leds(int argc, char *argv[]) {
    int ok, v = 0;
    if (argc >= 2) v = parse_int(argv[1], &ok);
    if (argc < 2 || !ok || v < 0 || v > 15) { uart_puts("uso: leds <0-15>\r\n"); return; }
    set_leds((uint8_t)v);
    uart_puts("LEDs = ");
    uart_put_bin4(v);
    uart_puts("\r\n");
}

static void cmd_sw(void) {
    uart_puts("switches = ");
    uart_put_bin4(read_switches() & 0x0F);
    uart_puts("\r\n");
}

static void cmd_blink(int argc, char *argv[]) {
    int ok = 0, n, v = 0, i;
    uint8_t saved = led_state;
    if (argc >= 3) v = parse_int(argv[2], &ok);
    if (argc < 3 || (n = get_led(argv[1])) < 0 || !ok || v < 1 || v > 20) {
        uart_puts("uso: blink <0-3> <1-20>\r\n");
        return;
    }
    for (i = 0; i < v; i++) {
        set_leds(saved |  (1 << n)); delay_cycles(200000);
        set_leds(saved & ~(1 << n)); delay_cycles(200000);
    }
    set_leds(saved);
    uart_puts("ok\r\n");
}

static void cmd_calc(int argc, char *argv[]) {
    int ok1, ok2, a, b, r;
    char op;
    if (argc < 4) { uart_puts("uso: calc <a> <op> <b>\r\n"); return; }
    a = parse_int(argv[1], &ok1);
    b = parse_int(argv[3], &ok2);
    op = argv[2][0];
    if (!ok1 || !ok2) { uart_puts("numeros invalidos\r\n"); return; }
    switch (op) {
        case '+': r = a + b; break;
        case '-': r = a - b; break;
        case '*': r = a * b; break;
        case '/':
            if (b == 0) { uart_puts("division por cero\r\n"); return; }
            r = a / b; break;
        default: uart_puts("operador invalido\r\n"); return;
    }
    uart_put_dec(a); uart_putchar(' '); uart_putchar(op); uart_putchar(' ');
    uart_put_dec(b); uart_puts(" = "); uart_put_dec(r); uart_puts("\r\n");
}

/* Comando propio: "auto fantastico" (K.I.T.T.). Un LED recorre la barra
   0-1-2-3-2-1 de ida y vuelta; cualquier tecla lo detiene. */
static void cmd_knight(int argc, char *argv[]) {
    static const uint8_t seq[6] = {0, 1, 2, 3, 2, 1};
    int ok = 1, ciclos = 5, c, i;
    uint8_t saved = led_state;
    if (argc >= 2) ciclos = parse_int(argv[1], &ok);
    if (!ok || ciclos < 1 || ciclos > 50) { uart_puts("uso: knight [1-50]\r\n"); return; }
    for (c = 0; c < ciclos; c++) {
        for (i = 0; i < 6; i++) {
            set_leds(1 << seq[i]);
            delay_cycles(150000);
            if (uart_getchar_nb() >= 0) { c = ciclos; break; }
        }
    }
    set_leds(saved);
    uart_puts("ok\r\n");
}

/* ---------------- Shell ---------------- */
static void shell_exec(char *line) {
    char *argv[4];
    int   argc = tokenize(line, argv, 4);
    if (argc == 0) return;

    if      (str_eq(argv[0], "help"))   cmd_help();
    else if (str_eq(argv[0], "led"))    cmd_led(argc, argv);
    else if (str_eq(argv[0], "leds"))   cmd_leds(argc, argv);
    else if (str_eq(argv[0], "sw"))     cmd_sw();
    else if (str_eq(argv[0], "calc"))   cmd_calc(argc, argv);
    else if (str_eq(argv[0], "blink"))  cmd_blink(argc, argv);
    else if (str_eq(argv[0], "knight")) cmd_knight(argc, argv);
    else uart_puts("comando desconocido (help)\r\n");
}

/* ---------------- Boton KEY0: activa el resultado ----------------
   KEY1 no se maneja aqui: resetea todo el SoC por hardware (top.v). */
static uint8_t key0_prev = 0;

/* Al presionar KEY0: lee los switches, los muestra en los LEDs y envia el
   resultado por la UART. Devuelve 1 si imprimio. */
static int check_button(void) {
    uint8_t k = read_keys() & 1;
    uint8_t v;
    if (k == key0_prev) return 0;
    delay_cycles(10000);                        /* antirrebote */
    k = read_keys() & 1;
    if (k == key0_prev) return 0;
    key0_prev = k;
    if (!k) return 0;                           /* solo al presionar */
    v = read_switches() & 0x0F;
    set_leds(v);
    uart_puts("\r\nKEY0 -> resultado: sw = ");
    uart_put_bin4(v);
    uart_puts(" (");
    uart_put_dec(v);
    uart_puts(")\r\n");
    return 1;
}

static void readline(char *buf, int max) {
    int i = 0;
    for (;;) {
        int r;
        char c;
        while ((r = uart_getchar_nb()) < 0) {
            if (check_button()) {               /* reimprime prompt y lo escrito */
                int j;
                uart_puts("> ");
                for (j = 0; j < i; j++) uart_putchar(buf[j]);
            }
        }
        c = (char)r;
        if (c == '\r' || c == '\n') { uart_puts("\r\n"); buf[i] = 0; return; }
        else if (c == 0x7f || c == 0x08) {
            if (i > 0) { i--; uart_puts("\b \b"); }
        }
        else if (c >= 32 && c < 127 && i < max - 1) {
            buf[i++] = c;
            uart_putchar(c);
        }
    }
}

/* ---------------- Hardware - DE10-Lite ---------------- */
#define REG_UART_CLK  (*(volatile uint32_t *)0x02000004)
#define REG_UART_DATA (*(volatile uint32_t *)0x02000008)
#define REG_LEDS      (*(volatile uint32_t *)0x03000000)
#define REG_SWITCHES  (*(volatile uint32_t *)0x03000004)
#define REG_KEYS      (*(volatile uint32_t *)0x03000008)

#define CLK_FREQ   50000000
#define BAUD_RATE  115200

void     uart_putchar(char c)    { REG_UART_DATA = (uint8_t)c; }
int      uart_getchar_nb(void)   { return (int)(int32_t)REG_UART_DATA; }
void     write_leds(uint32_t v)  { REG_LEDS = v; }
uint32_t read_switches(void)     { return REG_SWITCHES; }
uint32_t read_keys(void)         { return REG_KEYS; }

int main(void) {
    char line[48];

    REG_UART_CLK = CLK_FREQ / BAUD_RATE;
    write_leds(0);
    key0_prev = read_keys() & 1;        /* sin aviso al arrancar */

    uart_puts("\r\npicoSoC Shell - escribe 'help'\r\n");

    for (;;) {
        uart_puts("> ");
        readline(line, sizeof(line));
        shell_exec(line);
    }
    return 0;
}
