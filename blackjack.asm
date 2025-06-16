.data		0x10010000
baralho_qtd:		.byte	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
baralho_valores:	.byte	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10
cartas_player:		.space 20
cartas_dealer:		.space 20
inicio_instr:		.string "\n\nBem-vindo(a) ao Blackjack!\nDigite 1 para iniciar:\nDigite 0 para encerrar:\n"

escolha:		.string	"\nDigite 1 para pedir mais uma carta ou 0 para parar a jogada.\n"
vez_do_dealer:		.string "\nVez do dealer."
player_stand_txt:	.string "\nPlayer encerra sua jogada com a mão: "	
dealer_stand_txt:	.string "\nDealer encerra sua jogada com a mão: "	

mostra_mao_1:		.string	"\nSua mão contém as cartas: "
mostra_mao_2:		.string " + "
mostra_mao_3:		.string	" = "

player_recebe:		.string "\nPlayer recebe: "
dealer_recebe:		.string "\nDealer recebe: "
dealer_esconde:		.string "\nDealer esconde uma carta."

#dealer_encerra:		.string "\nDealer encerra sua jogada."

total_cartas:		.string "\nTotal de Cartas: "
placar:			.string "\nPontuação: "
placar_player:		.string "\n	Player: "
placar_dealer:		.string "\n	Dealer: "
player_pontos:		.word	0
dealer_pontos:		.word	0


teste_valores:		.string	"\nA carta de número "
teste_qtd:		.string	" existe em quantidade: "

venceu_txt:		.string "\nPlayer venceu"
perdeu_txt:		.string "\nDealer venceu"
empate_txt:		.string "\nOs jogadores empataram"
.text		0x400000
	li s0, 0 # Somatório jogador
	li s1, 0 # Somatório dealer
	li s2, 0 # count player
	li s3, 0 # count dealer
	la t0, baralho_qtd
	la t3, baralho_valores
	li s4, 16 # usado para o dealer encerrar a jogada 
	la s5, cartas_player
	la s6, cartas_dealer
	li s9, 52 # usado como count do teste
	li s10, 21
	li s11, 1# Define o valor 1 para o registrador s11, usado para manusear escolhas
	j inicio

escolha_comando:
	# Solicita input do comando
	li a0, 0
	li a7, 5
	ecall
	mv t6, a0
	ret

sortear:
	#la t0, baralho_qtd
	#la t3, baralho_valores
	# Sorteia o índice de 0-12
	li a0, 0
	li a1, 13
	li a7, 42 # RandIntRange
	ecall
	#
	# verifica se ainda há cartas desse valor
	add t1, t0, a0
	lb t2, 0(t1) #--- Load
	beqz t2, sortear # se a qtd = 0, repete função
	#
	# Subtrair da quantidade da carta no baralho
	addi t2, t2, -1
	sb t2, 0(t1) #--- Store
	#
	# Adiciona o valor de baralho_valores[t1] em t5
	add t4, t3, a0 # t4 = $baralho_valores+index
	lb t5, 0(t4) # t5 = valor em baralho_valores[t4]
	ret

valor_do_as: # falta fazer o call
	la a2, cartas_player
	lb a3, 0(a2)
	bne a3, s11, nao_e_um_as
	# comparar se o as valendo 11 ultrapassa 21 e substituir caso não
	addi a3, a3, 10
	add s7, a3, s0
	bgt s7, s10, super_as_ultrapassa
	sb a3, 0(a2) # Talvez remover essa parte, pois o 1 é uma carta e pode valer 11
	addi s0, s0, 10 # Adiciona o somatório
	# j nao_e_um_as

super_as_ultrapassa: # Rótulo inútil
nao_e_um_as:
	addi a2, a2, 1
	blt a2, s5, valor_do_as
	ret

dar_carta_jogador:
	add s0, s0, t5 # soma o valor da carta ao total do jogador
	#
	# Salvar a carta no vetor cartas_player *s5
	sb t5, 0(s5)
	addi s5, s5, 1 #incrementa a próxima posição em cartas_player
	addi s2, s2, 1 # incrementa o contado r de cartas do player
	ret
	
dar_carta_dealer:
	add s1, s1, t5
	#
	# Salvar a carta no vetor cartas_dealer *s6
	sb t5, 0(s6)
	addi s6, s6, 1 # Somando 1 byte após adição no byte anterior (TESTAR)
	addi s3, s3, 1
	ret

inicio:	
	#Fim dos testes, interface começa aqui
	la a0, inicio_instr # Bem vindo ao BlackJack, digite 0/1
	li a7, 4
	ecall
	#
	jal escolha_comando # Retorna comando em t6
	beq t6, zero, end
	jal placar_jogo
	beq t6, s11, player_recebe_1 # inicia o Jogo
	j inicio	

player_recebe_1:
	# Adicionar carta a player.mao
	jal sortear
	jal dar_carta_jogador
	la a0, player_recebe
	li a7, 4
	ecall
	#
	mv a0, t5
	li a7, 1
	ecall
	#
	# incluir lógica de receber carta aqui (talvez um JAL)
	# j player_recebe_2

player_recebe_2:
	# Adicionar carta a player.mao
	jal sortear
	jal dar_carta_jogador
	la a0, player_recebe
	li a7, 4
	ecall
	#
	mv a0, t5
	li a7, 1
	ecall
	# j dealer_recebe_1

dealer_recebe_1:
	jal sortear
	jal dar_carta_dealer
	la a0, dealer_recebe
	li a7, 4
	ecall
	#
	mv a0, t5
	li a7, 1
	ecall
	# j dealer_recebe_2

dealer_recebe_2:
	jal sortear
	jal dar_carta_dealer
	la a0, dealer_esconde
	li a7, 4
	ecall
	# imprimir um \n para embelezar
	li a0, 10
	li a7, 11
	ecall
	#
	j player_escolha

player_hit:
	# Adicionar carta a player.mao
	jal sortear
	jal dar_carta_jogador	
	la a0, player_recebe
	li a7, 4
	ecall
	#
	mv a0, t5
	li a7, 1
	ecall
	jal mostrar_mao
	bgt s0, s10, dealer_venceu
	# j playr_escolha

player_escolha:
	la a0, escolha
	li a7, 4
	ecall
	jal escolha_comando
	beq t6, zero, player_stand
	beq t6, s11, player_hit
	j player_escolha

player_stand:
	la a0, player_stand_txt
	li a7, 4
	ecall
	#
	mv a0, s0
	li a7, 1
	ecall
	#
	la a0, vez_do_dealer
	li a7, 4
	ecall
	j dealer_escolha

dealer_escolha:
	#bgt x5, s4, dealer_stand #x5 vai ser o registrador da pontuação do dealer
	bgt s1, s4, dealer_stand

dealer_hit:
	jal sortear
	jal dar_carta_dealer
	la a0, dealer_recebe
	li a7, 4
	ecall
	#
	mv a0, t5
	li a7, 1
	ecall
	# incluir lógica de receber carta aqui (talvez um JAL)
	j dealer_escolha
dealer_stand:
	la a0, dealer_stand_txt
	li a7, 4
	ecall
	#
	mv a0, s1
	li a7, 1
	ecall
	#	
	j compara

mostrar_mao:
	la t1, cartas_player ## pensar num registrador melhor pois já é usado para cartas_baralho[id]
	li a3, 0	# a0 = indice (contador)
	mv a4, s2 	# a4 número de cartas do jogador
	#
	la a0, mostra_mao_1
	li a7, 4
	ecall
	#j imprimir_loop

imprimir_loop:
	beq a3, a4, imprimir_fim
	add t2, t1, a3 #a5 = endereço de cartas-jogador[a3]
	#addi a3, a3, 1
	lb a0, 0(t2) # a6 = índice da carta
	
	#la t3, baralho_valores # base de baralho_valor
	#add a6, t3, a6
	lb a0, 0(t2)
	#addi a0, a0, -1
	li a7, 1
	ecall
	# imprime + se não for a última carta
	addi a3, a3, 1
	blt a3, a4, imprimir_sinal_mais
	j imprimir_loop
imprimir_sinal_mais:
	la a0, mostra_mao_2
	li a7, 4
	ecall
	j imprimir_loop
imprimir_fim:
	la a0, mostra_mao_3
	li a7, 4
	ecall
	mv a0, s0
	li a7, 1
	ecall
	ret
compara:
	beq s0, s1, empate
	bgt s0,s1, player_venceu
	j dealer_venceu

empate:
	la a0, empate_txt
	li a7, 4
	ecall
	j end
player_venceu:
	la a0, venceu_txt
	li a7, 4
	ecall
	la a0, player_pontos
	lb a2, 0(a0)
	addi a2, a2, 1
	sb a2, 0(a0)
	j inicio
dealer_venceu:
	la a0, perdeu_txt
	li a7, 4
	ecall
	la a0, dealer_pontos
	lb a2, 0(a0)
	addi a2, a2, 1
	sb a2, 0(a0)
	j inicio

placar_jogo:
	la a0, total_cartas
	li a7, 4
	ecall
	# Incluir em algum registrador um count com o total de cartas
	j total_cartas_num

total_cartas_num:
	la t0, baralho_qtd
	li a2, 0 # a2 = índice (0 a 12)
	li a3, 0 # a3 = soma total
	li a4, 13 # a4 = tamanho do vetor do baralho
	#j total_cartas_loop
total_cartas_loop:
	beq a2, a4, total_cartas_fim	# se o índice == tamanho do vetor
	add a5, t0, a2			# a5 = endereço do baralho_qtd[a2]
	lb a6, 0(a5)			# a6 = valor em baralho[a2]
	add a3, a3, a6
	addi a2, a2, 1
	j total_cartas_loop
total_cartas_fim:
	mv a0, a3
	li a7, 1
	ecall
	#j total_cartas_print
total_cartas_print:
        la a0, placar  
	li a7, 4
	ecall
        la a0, placar_player
	li a7, 4
	ecall
	#
	la a0, player_pontos
	lb a2, 0(a0)
	mv a0, a2
	li a7, 1
	ecall
	#
        la a0, placar_dealer
	li a7, 4
	ecall
	#
	la a0, dealer_pontos
	lb a2, 0(a0)
	mv a0, a2
	li a7, 1
	ecall
	#
	li a0, 10
	li a7, 11
	ecall
	ret
end:
	li a7, 10
	ecall

