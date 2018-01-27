LD_LIBRARY_PATH = $(HOME)/tools/wav-prg-4.2.1/libaudiotap 

default: clean main.prg

%.prg: %.asm
	$(HOME)/tools/dasm/dasm.Linux.x86 $^ -o$@
	@ls -l $@

clean:
	rm -f *.prg
