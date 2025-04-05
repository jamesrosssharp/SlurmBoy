    .global main
    .section .vectors
    
_start:
    jal main

_die:
    j _die
