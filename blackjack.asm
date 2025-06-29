.data		0x10010000
baralho_qtd:		.byte	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 
baralho_valores:	.byte	11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10
cartas_player:		.space 20
cartas_dealer:		.space 20
inicio_instr:		.string "\nDigite 1 para iniciar:\nDigite 0 para encerrar:\n"
bem_vindo:		.string "\n\nBem-vindo(a) ao Blackjack!"

escolha:		.string	"\nDigite 1 para pedir mais uma carta ou 0 para parar a jogada.\n"
vez_do_dealer:		.string "\nVez do dealer."
player_stand_txt:	.string "\nPlayer encerra sua jogada com a mão: "	
dealer_stand_txt:	.string "\nDealer encerra sua jogada com a mão: "	

mostra_mao_1:		.string	"\n\nSua mão contém as cartas: "
mostra_mao_d:		.string "\nA mão do dealer contém as cartas: "
mostra_mao_2:		.string " + "
mostra_mao_3:		.string	" = "

player_recebe:		.string "\nPlayer recebe: "
dealer_recebe:		.string "\nDealer recebe: "
dealer_esconde:		.string "\nDealer esconde uma carta."
dealer_revela_msg: 	.string "\nDealer revela a carta escondida: "
baralho_limite_qtd: 	.string "\nExistem 40 cartas no baralho, a partida será encerrada.\n\n\n"

#dealer_encerra:		.string "\nDealer encerra sua jogada."

total_cartas:		.string "\n\nTotal de Cartas: "
placar:			.string "\nPontuação: "
placar_player:		.string "\n	Player: "
placar_dealer:		.string "\n	Dealer: "
player_pontos:		.word	0
dealer_pontos:		.word	0


teste_valores:		.string	"\nA carta de número "
teste_qtd:		.string	" existe em quantidade: "

venceu_txt:		.string "\n	PLAYER VENCEU\n\n\n"
perdeu_txt:		.string "\n	DEALER VENCEU\n\n\n"
empate_txt:		.string "\n	OS JOGADORES EMPATARAM\n\n\n"
mostrar_soma_player: 	.string "\n\n\n	Soma Player: "
mostrar_soma_dealer: 	.string "\n	Soma Dealer: "

A: 			.string "A"
J:			.string "J"
Q:			.string "Q"
K:			.string "K"

.text		0x400000
	la t0, baralho_qtd
	la t3, baralho_valores
	li s4, 16 # usado para o dealer encerrar a jogada 
	li s9, 52 # usado como count do teste
	li s10, 21
	li s11, 1# Define o valor 1 para o registrador s11, usado para manusear escolhas

	la a0, bem_vindo # Bem vindo ao BlackJack, digite 0/1
	li a7, 4
	ecall

	j inicio

resetar_baralho_qtd:	
	la t0, baralho_qtd
	mv a2, t0
	mv a3, t0
	addi a3, a3, 13
resetar_baralho_qtd_loop:
	li a0, 4
	sb a0, 0(a2)
	addi a2, a2, 1
	blt a2, a3, resetar_baralho_qtd_loop
	
	ret
		
	
escolha_comando:
	# Solicita input do comando
	li a0, 0
	li a7, 5
	ecall
	mv t6, a0
	ret

sortear:
	la t0, baralho_qtd
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
	#add t4, t3, a0 # t4 = $baralho_valores+index
	#lb t5, 0(t4) # t5 = valor em baralho_valores[t4]
	#ret

	mv t5, a0 # Agora passa a salvar o índice sorteado em t5 ao invés do valor
	ret


dar_carta_jogador:
	# Valor da carta a partir do índice que está em t5:
	add t4, t3, t5  # t3 = base de baralho_valores, t5 = índice
	lb a2, 0(t4)    # a2 = valor da carta  OBSERVAÇÃO: Usado o a2 por falta de vetores temporários
	add s0, s0, a2 # Soma no s0, somatório jogador

	beq t5, zero, conta_as_jogador
	j verifica_estouro

conta_as_jogador:
	addi s7, s7, 1 # Contador de As
	j verifica_estouro

verifica_estouro:
	# Se a soma passar de 21, e houver As valendo 11, reduz 10 na soma e diminui o contador de As
	bgt s0, s10, tem_as_para_diminuir
	j salvar_carta_player

tem_as_para_diminuir:
	blez s7, salvar_carta_player  #
	addi s0, s0, -10  # As vira 1
	addi s7, s7, -1 
	# Pode ter mais de um As, então verifica de novo
	bgt s0, s10, tem_as_para_diminuir
	j salvar_carta_player

salvar_carta_player:
	# Salvar o índice da carta (não o valor) no vetor cartas_player:
	sb t5, 0(s5)
	addi s5, s5, 1  # Avança uma posição no vetor
	addi s2, s2, 1  # Incrementa o contador de cartas
	ret


dar_carta_dealer:
	# Obter o valor real da carta:
	add t4, t3, t5
	lb a2, 0(t4)

	# Soma o valor no total do dealer:
	add s1, s1, a2

	beq t5, zero, conta_as_dealer # As indice 0, então contar
	j verifica_estouro_dealer

conta_as_dealer:
	addi s8, s8, 1 # Contador de As do dealer
	j verifica_estouro_dealer

verifica_estouro_dealer:
	# Se a soma do dealer estourar e houver As pra converter de 11 pra 1
	bgt s1, s10, tem_as_para_diminuir_dealer
	j salvar_carta_dealer

tem_as_para_diminuir_dealer:
	blez s8, salvar_carta_dealer  # Se não tem As sobrando, sai
	addi s1, s1, -10
	addi s8, s8, -1
	# Se ainda estiver acima de 21, repete o ajuste
	bgt s1, s10, tem_as_para_diminuir_dealer
	j salvar_carta_dealer

salvar_carta_dealer:
	# Salvar o índice da carta no vetor cartas_dealer:
	sb t5, 0(s6)
	addi s6, s6, 1
	addi s3, s3, 1
	ret
inicio:	
	li s0, 0 # Somatório jogador = 0
	li s1, 0 # Somatório dealer = 0
	li s2, 0 # count player = 0
	li s3, 0 # count dealer = 0
	la s5, cartas_player
	la s6, cartas_dealer
	li s7, 0 # Contador de Ases jogador = 0
	li s7, 0 # Contador de Ases dealer = 0

	#jal resetar_baralho_qtd
	
	la a0, inicio_instr # Bem vindo ao BlackJack, digite 0/1
	li a7, 4
	ecall
	#
	jal escolha_comando # Retorna comando em t6
	beq t6, zero, end
	jal total_cartas_baralho 
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
	addi t5, t5, 1 # incrementa o índice para se adequar ao número da carta
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
	addi t5, t5, 1 # incrementa o índice para se adequar ao número da carta
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
	addi t5, t5, 1 # incrementa o índice para se adequar ao número da carta
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
	#s
	j player_escolha

player_hit:
	# Adicionar carta a player.mao
	jal sortear
	jal dar_carta_jogador	
	jal total_cartas_baralho 
	la a0, player_recebe
	li a7, 4
	ecall
	#
	addi t5, t5, 1 # incrementa o índice para se adequar ao número da carta
	mv a0, t5
	li a7, 1
	ecall
	
	beq s0, s10, player_venceu # Valida a vitória com 21

	bgt s0, s10, dealer_venceu # Valida se passou de 21
	# j playr_escolha

player_escolha:
	jal mostrar_mao
	jal verifica_quarenta # verifica se tem menos de quarenta cartas no baralho
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
	jal dealer_revela
	j dealer_escolha

dealer_escolha:
	jal verifica_quarenta # verifica se tem menos de quarenta cartas no baralho
	bgt s1, s4, dealer_stand
	j dealer_hit

dealer_revela: # Usado para revelar a carta escondida na entrada
	la a0, dealer_revela_msg
	li a7, 4 
	ecall
	la s9, cartas_dealer
	lb a0, 1(s9) # Carrega a segunda carta entregue
	addi a0, a0, 1 # índice = valor -1
	li a7, 1
	ecall
	ret
dealer_hit:
	jal sortear
	jal dar_carta_dealer
	la a0, dealer_recebe
	li a7, 4
	ecall
	#
	addi t5, t5, 1 # incrementa o índice para se adequar ao número da carta
	mv a0, t5
	li a7, 1
	ecall
	# Inserir um print avisando a soma da mão do dealer
	bgt s1, s10, player_venceu
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

mostrar_mao_dealer:
	la t1, cartas_dealer    # Base do vetor de cartas do dealer
	li a3, 0                # Contador de cartas
	mv a4, s3               # Total de cartas do dealer

	# Print da mensagem inicial
	la a0, mostra_mao_d
	li a7, 4
	ecall

imprimir_loop_dealer:
	beq a3, a4, imprimir_fim_dealer

	# Pega o índice da carta na mão do jogador:
	add t2, t1, a3
	lb t0, 0(t2)            # t0 = índice da carta (ex: 0,1,2,...)

	# Exibir o número da carta (exibe o índice direto ou consulta um vetor de strings)
	# Por enquanto, só imprime o número puro como estava
	# Se quiser melhorar depois, podemos usar um vetor de strings tipo "A", "2", ..., "K"
	beq t0, zero, ace_dealer
	j numero_puro_dealer
ace_dealer:
	la a0, A
	li a7, 4
	ecall
	j segue_loop_dealer
numero_puro_dealer:
	# Aqui exemplo de exibir número puro:
	mv a0, t0
	addi a0, a0, 1 # Ajusta o índice com o número da carta
	li a7, 1
	ecall
	j segue_loop_dealer
segue_loop_dealer:
	# Exibir sinal de +
	addi a3, a3, 1
	blt a3, a4, imprimir_sinal_mais_dealer
	j imprimir_loop_dealer

imprimir_sinal_mais_dealer:
	la a0, mostra_mao_2
	li a7, 4
	ecall
	j imprimir_loop_dealer

imprimir_fim_dealer:
	# Exibir o = 
	la a0, mostra_mao_3
	li a7, 4
	ecall

	# Exibir o somatório final (já pronto no s0)
	mv a0, s1
	li a7, 1
	ecall
	ret
mostrar_mao:
	la t1, cartas_player    # Base do vetor de cartas do dealer
	li a3, 0                # Contador de cartas
	mv a4, s2               # Total de cartas do dealer

	# Print da mensagem inicial
	la a0, mostra_mao_1
	li a7, 4
	ecall

imprimir_loop:
	beq a3, a4, imprimir_fim

	# Pega o índice da carta na mão do jogador:
	add t2, t1, a3
	lb t0, 0(t2)            # t0 = índice da carta (ex: 0,1,2,...)

	# Exibir o número da carta (exibe o índice direto ou consulta um vetor de strings)
	# Por enquanto, só imprime o número puro como estava
	# Se quiser melhorar depois, podemos usar um vetor de strings tipo "A", "2", ..., "K"
	beq t0, zero, ace
	j numero_puro
ace:
	la a0, A
	li a7, 4
	ecall
	j segue_loop
numero_puro:
	# Aqui exemplo de exibir número puro:
	mv a0, t0
	addi a0, a0, 1 # Ajusta o índice com o número da carta
	li a7, 1
	ecall
	j segue_loop
jack:
queen:
king:
segue_loop:
	# Exibir sinal de +
	addi a3, a3, 1
	blt a3, a4, imprimir_sinal_mais
	j imprimir_loop

imprimir_sinal_mais:
	la a0, mostra_mao_2
	li a7, 4
	ecall
	j imprimir_loop

imprimir_fim:
	# Exibir o = 
	la a0, mostra_mao_3
	li a7, 4
	ecall

	# Exibir o somatório final (já pronto no s0)
	mv a0, s0
	li a7, 1
	ecall
	ret

compara:
	beq s0, s1, empate
	bgt s0,s1, player_venceu
	j dealer_venceu

mostrar_somas:
	la a0, mostrar_soma_player
	li a7, 4
	ecall
	mv a0, s0
	li a7, 1
	ecall
	
	la a0, mostrar_soma_dealer
	li a7, 4
	ecall
	mv a0, s1
	li a7, 1
	ecall
	ret
player_venceu:
	jal mostrar_mao
	jal mostrar_mao_dealer
	jal mostrar_somas
    la a0, venceu_txt
    li a7, 4
    ecall

    # atualiza o contador de vitórias
    la   a0, player_pontos
    lb   a2, 0(a0)
    addi a2, a2, 1
    sb   a2, 0(a0)

    j fim_rodada

dealer_venceu:
	jal mostrar_mao
	jal mostrar_mao_dealer
	jal mostrar_somas
    la a0, perdeu_txt
    li a7, 4
    ecall

    la   a0, dealer_pontos
    lb   a2, 0(a0)
    addi a2, a2, 1
    sb   a2, 0(a0)

    j fim_rodada

empate:
	jal mostrar_mao
	jal mostrar_mao_dealer
	jal mostrar_somas
    la a0, empate_txt
    li a7, 4
    ecall
    j fim_rodada


verifica_quarenta:
	li s9, 13 # A função usa um blt para caso a quantidade 40 ocorra na entrega de cartas iniciais
	la t0, baralho_qtd
	li a2, 0 # a2 = índice (0 a 12)
	li a3, 0 # a3 = soma total
	li a4, 13 # a4 = tamanho do vetor do baralho
	#j verifica_quarenta_loop

verifica_quarenta_loop:
	beq a2, a4, verifica_quarenta_fim # fim do loop
	add a5, t0, a2			# a5 = endereço do baralho_qtd[a2]
	lb a6, 0(a5)			# a6 = valor em baralho[a2]
	add a3, a3, a6
	addi a2, a2, 1
	j verifica_quarenta_loop

verifica_quarenta_fim: #Retorna normalmente
	blt a3, s9, verifica_quarenta_mensagem
	ret
verifica_quarenta_mensagem:
	la a0, baralho_limite_qtd
	li a7, 4
	ecall
	jal resetar_baralho_qtd
	j inicio

total_cartas_baralho:
	la a0, total_cartas
	li a7, 4
	ecall
	# Incluir em algum registrador um count com o total de cartas
	j total_cartas_num # jump desnecessário

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
	ret
placar_jogo:
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

fim_rodada:

    jal  placar_jogo
	#j end

    j    inicio              # se 1, reinicia


end:
	li a7, 10
	ecall
