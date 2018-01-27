LD_LIBRARY_PATH = $(HOME)/tools/wav-prg-4.2.1/libaudiotap 

default: clean entry.prg

%.prg: %.asm
	$(HOME)/tools/dasm/dasm.Linux.x86 $^ -o$@ -v3
	@ls -l $@

clean:
	rm -f *.prg
