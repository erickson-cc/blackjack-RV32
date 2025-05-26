.data
baralho:       .byte 4,4,4,4,4,4,4,4,4,4,4,4,4      # 13 cartas
valor_cartas:  .byte 1,2,3,4,5,6,7,8,9,10,10,10,10  # valores
seed:          .word 12345                          # seed inicial

quebrar_linha:	.string "\n"	
escolha_print:	.string "Digite 0 para encerrar"
.text
.globl main

main:
	la   t0, baralho
	jal carta_aleatoria
	jal escolha
	beq a3, zero, final
	j main
imprimir_num:
	#Imprimir o número da carta sorteada
	mv a0, a2
	li a7, 1          # syscall print integer
	ecall
	ret

final:
	# Finaliza o programa
	li a7, 10
	ecall

# Função: carta_aleatoria
# Entrada: a0 = seed, a1 = range
# Saída: a2 = valor aleatório (0 a 12), a0 = nova seed
carta_aleatoria:
	li a7, 42           # syscall random_int
	li a1, 13		# Limite Superior (0-12)
	ecall               # a0 = nova seed, a1 = valor aleatório
	mv a2, a1           # move valor aleatório para a2
	jal imprimir_num
	ret
escolha:
	la a0, escolha_print
	li a7, 4
	ecall			# Print no console
	
	la a0, quebrar_linha
	li a7, 4
	ecall
	li a7, 5
	ecall			# readInt
	mv a3, a0		# move o input para a3
	ret
