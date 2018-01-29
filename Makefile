DASM := $(shell $(CURDIR)/tools/get-dasm)

game: clean entry.prg

.PHONY: clean
clean:
	rm -f *.prg

%.prg: %.asm $(DASM)
	$(DASM) "$<" -o"$@" -v3
	# on error dasm returns 0 but produces 0-size output
	[ -s "$@" ]

run: $(VICE)
	@echo "*****************************"
	@echo "To run the game, type:"
	@echo ""
	@echo "    SYS2064"
	@echo ""
	@echo "in the emulator and hit ENTER"
	@echo "*****************************"

	@$(shell $(CURDIR)/tools/get-vice) entry.prg >/dev/null
