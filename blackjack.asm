.data		0x10010000
baralho_qtd:		.byte	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
baralho_valores:	.byte	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10
inicio_instr:		.string "Bem-vindo(a) ao Blackjack!\nDigite 1 para iniciar:\nDigite 0 para encerrar:\n"

escolha:		.string	"Digite 1 para pedir mais uma carta ou 0 para parar a jogada.\n"
vez_do_dealer:		.string "Vez do dealer."
player_stand_txt:	.string "Player encerra sua jogada com a mão: "	

mostra_mao_1:		.string	"Sua mão contém as cartas: "
mostra_mao_2:		.string " + "
mostra_mao_3:		.string	"= "

player_recebe:		.string "Player recebe: "
dealer_recebe:		.string "Dealer recebe: "
dealer_esconde:		.string "Dealer recebe uma carta."





teste_valores:		.string	"A carta de número "
teste_qtd:		.string	" existe em quantidade: "
.text		0x400000
	li s9, 52 # usado como count do teste
	li s11, 1# Define o valor 1 para o registrador s11, usado para manusear escolhas
	j inicio
escolha_comando:
	# Solicita input do comando
	li a7, 5
	ecall
	mv t6, a0
	ret
dar_carta:
	la t0, baralho_qtd
	ret
sortear:
	# Sorteia o índice de 0-12
	li a0, 0
	li a1, 13
	li a7, 42 # RandIntRange
	ecall

	# verifica se ainda há cartas desse valor
	add t1, t0, a0
	lb t2, 0(t1) #--- Load
	beqz t2, sortear # se a qtd = 0, repete função
	
	# Subtrair da quantidade da carta no baralho
	addi t2, t2, -1
	sb t2, 0(t1) #--- Store
	ret
inicio:	
	#esses tres abaixo vão ser movidos para outro estado
	call dar_carta
	call sortear
	call imprimir_teste
	addi s9, s9, -1
	bne s9, zero, inicio
	
	#Fim dos testes, interface começa aqui
	la a0, inicio_instr
	li a7, 4
	ecall

	jal escolha_comando
	beq t6, zero, end
	beq t6, s11, player_recebe_1 
	j inicio	
player_recebe_1:
	# Adicionar carta a player.mao
	la a0, player_recebe
	li a7, 4
	ecall
player_recebe_2:
	# Adicionar carta a player.mao
	la a0, player_recebe
	li a7, 4
	ecall
	j player_escolha
player_hit:
	# Adicionar carta a player.mao
	la a0, player_recebe
	li a7, 4
	ecall
player_escolha:
	la a0, escolha
	li a7, 4
	ecall
	jal escolha_comando
	beq t6, zero, player_stand
	beq t6, s11, player_hit
	
player_stand:
	la a0, player_stand_txt
	li a7, 4
	ecall
	j dealer_escolha
dealer_escolha:
	la a0, vez_do_dealer

end:
	li a7, 10
	ecall
imprimir_teste:
	mv s8, a0 # Salva o índice para poder usar o a0
	# Imprimir texto
	la a0, teste_valores
	li a7, 4
	ecall
	#imprime o índice sorteado
	mv a0, s8
	li a7, 1
	ecall
	# Imprimir texto
	la a0, teste_qtd
	li a7, 4
	ecall
	#imprime o índice sorteado
	mv a0, s8
	la t1, baralho_qtd # t1 = endereço do vetor
	add t2, t1, a0	# t2 = endereço do baralho_qtd[a0]
	lb a0, 0(t2)	# a0 = valor do baralho_qtd[a0]
	li a7, 1
	ecall
	#imprime quebra de linha (ASCII 10)
	li a0, 10
	li a7, 11
	ecall
	ret
	
