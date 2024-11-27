#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <c64.h>
#include <cbm.h>

#define VIC_BANK 0xC000

#define SCR_OFFSET 1024l
#define SCR_START (VIC_BANK + SCR_OFFSET)
#define SCR_RAM (unsigned char *)SCR_START

#define BMP_OFFSET 8192l
#define BMP_START (VIC_BANK + BMP_OFFSET)
#define BMP_RAM (unsigned char *)BMP_START

#define SCR_CHAR_WIDTH 40
#define BMP_ROW_COUNT 12
#define BMP_CHR_COUNT BMP_ROW_COUNT *SCR_CHAR_WIDTH

extern void registerIrq(void);
extern void unregisterIrq(void);

int main(void)
{
    registerIrq();

    // Draw an interesting bitmap pattern
    memset(SCR_RAM, ((COLOR_RED << 4) | COLOR_GREEN), BMP_CHR_COUNT);
    memset(COLOR_RAM, COLOR_YELLOW, BMP_CHR_COUNT);
    memset(BMP_RAM, 54, BMP_CHR_COUNT * 8);

    // write text to the bottom part of the screen
    textcolor(COLOR_WHITE);
    cputsxy(0, 13, "this is the text area.");

    // stay in loop until 'q' is pressed
    while (cgetc() != 'q')
        ;

    unregisterIrq();
    return EXIT_SUCCESS;
}

