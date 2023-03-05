OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

MEMORY
{
	bootrom  : ORIGIN = 0xFFFF0000, LENGTH = 16K
}

SECTIONS
{
	.bootrom :
	{
		bootrom.o (.text)
		spiboot.o (.text)
	} > bootrom
}
