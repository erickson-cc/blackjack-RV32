.data		0x10010000
baralho_qtd:		.byte	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
baralho_valores:	.byte	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10
cartas_player:		.space 20
cartas_dealer:		.space 20
inicio_instr:		.string "Bem-vindo(a) ao Blackjack!\nDigite 1 para iniciar:\nDigite 0 para encerrar:\n"

escolha:		.string	"\nDigite 1 para pedir mais uma carta ou 0 para parar a jogada.\n"
vez_do_dealer:		.string "\nVez do dealer."
player_stand_txt:	.string "\nPlayer encerra sua jogada com a mão: "	

mostra_mao_1:		.string	"\nSua mão contém as cartas: "
mostra_mao_2:		.string " + "
mostra_mao_3:		.string	"= "

player_recebe:		.string "\nPlayer recebe: "
dealer_recebe:		.string "\nDealer recebe: "
dealer_esconde:		.string "\nDealer esconde uma carta."

dealer_encerra:		.string "\nDealer encerra sua jogada."

total_cartas:		.string "\nTotal de Cartas: "
placar:			.string "\nPontuação: "
placar_player:		.string "\n	Player: "
placar_dealer:		.string "\n	Dealer: "


teste_valores:		.string	"\nA carta de número "
teste_qtd:		.string	" existe em quantidade: "
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
	li s11, 1# Define o valor 1 para o registrador s11, usado para manusear escolhas
	j inicio

escolha_comando:
	# Solicita input do comando
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

dealer_recebe_2:
	jal sortear
	jal dar_carta_dealer
	la a0, dealer_esconde
	li a7, 4
	ecall
	jal mostra_mao
	j player_escolha

player_hit:
	# Adicionar carta a player.mao
	jal sortear
	jal dar_carta_jogador	
	la a0, player_recebe
	li a7, 4
	ecall
	# incluir lógica de receber carta aqui (talvez um JAL)
	mv a0, t5
	li a7, 1
	ecall
	#
	jal mostra_mao
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
	la a0, vez_do_dealer
	ecall
	j dealer_escolha

dealer_escolha:
	#bgt x5, s4, dealer_stand #x5 vai ser o registrador da pontuação do dealer
	j dealer_hit

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
	j end

dealer_stand:
	la a0, dealer_encerra
	li a7, 4
	ecall
	j end

placar_jogo:
	la a0, total_cartas
	li a7, 4
	ecall
        la a0, placar  
	li a7, 4
	ecall
        la a0, placar_player
	li a7, 4
	ecall
        la a0, placar_dealer
	li a7, 4
	ecall
	li a0, 10
	li a7, 11
	ecall
	ret

mostra_mao:
	### Essa função ficou mal-feita, vou otimizar amanhã depois do trabalho
	la a0, cartas_player
	li a2, 0 # contador
	mv a3, s2 # número de cartas player
	#
	la a0, mostra_mao_1
	li a7, 4
	ecall
	#
imprimir_loop:
	beq a2, a3, imprimir_fim
	add a4, a0, a2
	lb s5, 0(a4)
	la t3, baralho_valores# dá pra tirar
	add a5, t3, s5
	lb a0, 0(a5) # valor da carta
	li a7,1
	ecall
	#
	addi a2, a2, 1
	blt a2, a4, imprimir_mais
	j imprimir_loop
imprimir_mais:
	la a0, mostra_mao_2
	li a7, 4
	ecall
	j imprimir_loop
imprimir_fim:
	la a0, mostra_mao_3
	li a7, 4
	ecall
	ret

end:
	li a7, 10
	ecall

