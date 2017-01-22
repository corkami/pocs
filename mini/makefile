all: mini.class mini.elf mini.exe mini.macho rgb.gif

mini.class: class.asm
	nasm -o mini.class class.asm

mini.elf: elf.asm
	nasm -o mini.elf elf.asm

mini.exe: pe.asm
	nasm -o mini.exe pe.asm

mini.macho: macho.asm
	nasm -o mini.macho macho.asm

rgb.gif: gif.asm
	nasm -o rgb.gif gif.asm
