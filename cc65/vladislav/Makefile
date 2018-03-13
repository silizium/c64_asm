.PHONY = all

TARGETS=indirect.prg indirect_nsub.prg selfmod.prg selfmod_nsub.prg

all: $(TARGETS)

#cypherbasic.prg: cypherbasic.s Makefile
#	cl65 -o $@ -t c64 -C cypher9000.cfg $<
#	cl65 -o $@ -u __EXEHDR__ -t c64 -C c64-asm.cfg $<
#	ca65 -t c64 $< 
#	ld65 --config c64-asm.cfg -o $@ $(basename $<).o c64.lib

%.prg: %.asm Makefile
	cl65 -o $@ -u __EXEHDR__ -t c64 -C c64-asm.cfg $<
	@rm $(basename $<).o

disasm:
	r2 -a6502 -m0x07ff -A selfmod.prg

clean:
	rm *.o $(TARGETS)
