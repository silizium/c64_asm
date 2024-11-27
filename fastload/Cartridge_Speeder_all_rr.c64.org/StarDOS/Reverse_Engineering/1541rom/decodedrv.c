
#include <stdlib.h>
#include <stdio.h>

FILE *fin, *fout;
int addr, i;

unsigned char buf[0x10000];
unsigned char tmp[0x10000];

// swap A10 and A11

int main (int argc, char *argv[])
{
    fin = fopen(argv[1], "rb");
    fread(&buf[0], 1, 0x4000, fin);
    fclose(fin);

    // write stardos rom at a000
    fout = fopen(argv[2], "wb");
    for (i = 0; i < 0x2000; i++) {
        addr = i & (~(0x0400 | 0x0800));
        addr |= (i & 0x0400) << 1;
        addr |= (i & 0x0800) >> 1;
        fputc(buf[addr], fout);
    }
    fclose(fout);
    // write stardos rom at e000
    fout = fopen(argv[3], "wb");
    for (i = 0x2000; i < 0x4000; i++) {
        addr = i & (~(0x0400 | 0x0800));
        addr |= (i & 0x0400) << 1;
        addr |= (i & 0x0800) >> 1;
        fputc(buf[addr], fout);
    }
    fclose(fout);
}
