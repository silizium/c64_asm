INSTRUCTIONS:
-------------
(Can be assembled through either ACME or C64STUDIO

Here is a collection of slightly modified sources, based on
Cybernator's Public Domain IRQ TAPE Turbo loader system. 

This tape loader allows you to PLAY MUSIC, LOAD A PICTURE (This version draws it while loading) and DISPLAY
LOADING STRIPES. Loader system is suitable for files up to 198 blocks. (As the saver uses address $c000-$c400). 
It is possible to expand the loader further for even larger files, but you will need to fix this in yourself.

Compiling as such is
pretty much straightforward. The following method applies:

- loader.asm

This is the file that consists of the IRQ turbo tape loader.
The only difference are a couple of alterations I have made
based on the tape loader's appearance. Also, it uses JCH/DMC/Goat Tracker (Avoid $fc-$ff as zero pages), CheeseCutter, etc.
music for playing. Also runs programs that use SYS 2061. All addresses
for init/play music can be altered manually, should you need to. You can
also custom the loading stripes. I made it as a cyberload style loader,
where two coloured stripes are on screen and that you cycle every block 
by incrementing the border colour. It is of course up to you how you would
like to use the loader's features. Also at the end of the loader. I have
embedded a credit (LOADER BY CYBERNATOR/CYBERTRONIC STUDIOS)

- loaderinstall

This is the installation program of the turbo tape loader system. This
needs to be assembled/compiled AFTER [loader.asm] has been compiled. You 
don't need to change anything here. This is the BASIC, RUN installation of
the loader, when you load your programs on to tape.

- saver.asm

This is the basic load+save installation of the tape loader system. The saver installs
the tape turbo loader system on to tape (Using KERNAL save). This is so that you can have
an automatic bootable tape turbo loader (After using SHIFT/RUN STOP) on your Commodore 64.
The MUSIC, KOALA PAINT PICTURE and PROGRAM TO MASTER will load from DISK. Then it will master
to tape. 

- extractor.asm

This is the PROGRAMS IN ONE extraction method. Basically MUSIC, PICTURE and GAME files are all linked together.
The tape turbo loader system stores using KERNAL SAVE. Then the MUSIC, PICTURE and GAME files are extracted to
the tape via tape turbo loader. Be warned that you cannot exceed a certain size for the main program. If program
is too large. An error prompt "FILE IS TO BIG TO FIT EXTRACTOR.PRG" will display.


