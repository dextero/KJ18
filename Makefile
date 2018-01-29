DASM = $(shell $(CURDIR)/tools/get-dasm)

default: clean entry.prg

.PHONY: clean
clean:
	rm -f *.prg

%.prg: %.asm $(DASM)
	$(DASM) "$<" -o"$@" -v3
	# on error dasm returns 0 but produces 0-size output
	[ -s "$@" ]
