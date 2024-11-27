
all: decodedrv stardosdriverom.bin

decodedrv: decodedrv.c
	gcc -o decodedrv decodedrv.c
	
stardos1541romv1-4.bin stardos1541romv1-4-a000-decoded.bin stardos1541romv1-4-e000-decoded.bin: decodedrv
	./decodedrv stardos1541romv1-4.bin stardos1541romv1-4-a000-decoded.bin stardos1541romv1-4-e000-decoded.bin

stardosdriverom.bin: stardos1541romv1-4-a000-decoded.bin stardos1541romv1-4-e000-decoded.bin
	cat dos1541-c000.bin > stardosdriverom.bin
	cat stardos1541romv1-4-e000-decoded.bin >> stardosdriverom.bin

clean:
	$(RM) decodedrv
	$(RM) stardosdriverom.bin
