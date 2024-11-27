
#include <stdlib.h>
#include <stdio.h>

FILE *fin, *fout;
int in, out, i;

// decoder for the stardos (C64) cartridge ROM

// D1 and D2 are swapped around, so revert this
int main (int argc, char *argv[])
{
    fin = fopen(argv[1], "rb");
    fout = fopen(argv[2], "wb");
    for (i = 0; i < 0x4000; i++) {
        in = fgetc(fin);
        out = in & 0xf9;
        out |= (in & 2) << 1;
        out |= (in & 4) >> 1;
        fputc(out, fout);
    }
    fclose(fin);
    fclose(fout);
}
