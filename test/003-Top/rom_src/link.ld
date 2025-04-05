
BOOTROM_SIZE    = 0x400;
SCRATCHPAD_SIZE = 0x400;



MEMORY {
	rom (x) : ORIGIN = 0x00000000, LENGTH = BOOTROM_SIZE
    ram (wx) : ORIGIN = 0x10000000, LENGTH = SCRATCHPAD_SIZE
}

SECTIONS {

	.text : {
		KEEP(*(.vectors .vectors.*))
		*( .text .text.* )
	} > rom


    .rodata : {
        . = ALIGN(4);
        *( .rodata .rodata.*)
        . = ALIGN(4);
    } > rom

    
	.data (NOLOAD) : {
		. = ALIGN(4);
		*( .data .data.* )
	} > ram

	.bss (NOLOAD): {
		. = ALIGN(4);
		_szero = .;
		*( .bss .bss.* )
		_ezero = .;
	} > ram


}
