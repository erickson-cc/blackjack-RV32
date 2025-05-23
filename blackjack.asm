.data		0x10010000
escolha:	.string	"Digite 1 para pedir mais uma carta ou 0 para parar a jogada.\n"
.text		0x400000
main:
	la a0, escolha
	li a7, 4
	ecall

end:
	li a7, 10
	ecall
