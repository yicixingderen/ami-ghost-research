MEMORY
{
  RAM : ORIGIN = 0x80000000, LENGTH = 0x00a00000
}

ENTRY(main)
SECTIONS
{
  . = 0x80000000;
  .text : { *(.text) } > RAM
  .data : {
      . = ALIGN(4);
      *(.data);
      . = ALIGN(4);
  } > RAM
  _end = .;
}
