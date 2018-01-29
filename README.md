# "Trainsmission"

Global Game Jam 2018 entry by dextero & mcpgnz

Github repository: https://github.com/dextero/KJ18


## Compiling

### Linux

    make

This will try to find DASM in system PATH, or if not available - download it from the internet. If it doesn't work, download [DASM](http://dasm-dillon.sourceforge.net/) manually and try again. If it still doesn't work - well, shit. Maybe [raise an issue](https://github.com/dextero/KJ18/issues) or something?


## Running

### Linux

To run the game on an VICE emulator, run:

    make run

After loading the PRG file onto Commodore64, type

    SYS 2064

within the emulator, hit ENTER and enjoy!

Note: ``make run`` will try to find VICE emulator in system PATH, or if not available - compile it from sources. If it doesn't work, get it from [VICE project page](http://vice-emu.sourceforge.net/) and run ``x64 entry.prg``.


## Playing

Press FIRE button to press clutch, then use joystick to shift gears. The train speeds up automatically. Reach finish line as fast as possible. Be aware of massive cows roaming the realm - they have the ability to stop the train if you hit them too hard.

