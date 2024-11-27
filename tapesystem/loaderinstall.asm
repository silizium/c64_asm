;BEFORE INSTALLING THIS LOADER.
;ASSEMBLE/COMPILE LOADER.ASM

!to "loaderinstall.prg",cbm
							*=$0801	
							!basic 2064
							*=$0810 
							ldx #$00  
copyloader		lda LoaderStart,x
							sta $0400,x 
							lda LoaderStart+$100,x
							sta $0500,x
							lda LoaderStart+$200,x
							sta $0600,x
							lda LoaderStart+$2e8,x
							sta $06e8,x
							lda #0
							sta $d800,x 
							sta $d900,x 
							sta $da00,x 
							sta $dae8,x 
							inx
							bne copyloader
							jmp $0400
							
LoaderStart
							!bin "loader.prg",,2
							
								