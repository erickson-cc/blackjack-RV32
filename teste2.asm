	.data
cartas_jogador: .space 20   # até 20 cartas
cartas_dealer:  .space 20
baralho:       .byte 4,4,4,4,4,4,4,4,4,4,4,4,4      # 13 cartas
valor_cartas:  .byte 1,2,3,4,5,6,7,8,9,10,10,10,10  # valores
seed:          .word 12345                          # seed inicial

msg_bem_vindo:		.string "Bem-vindo ao Blackjack!"
msg_total_cartas:	.string "Total de cartas: "
msg_jogador_recebe:	.string "O jogador recebe: "
msg_mao:			.string "Sua mão: "
msg_e:			.string " e "
msg_mais:		.string " + "
msg_igual:		.string " = "
msg_nl:			.string "\n"

	.text
.globl main
main:
    # Inicializa somatório e contador do jogador
    li s0, 0      # somatório jogador
    li s1, 0      # contador de cartas do jogador

    call total_cartas
    	
    # Dá 2 cartas para o jogador
    call sortear              # a0 = índice sorteado (0 a 12)
    call dar_carta_jogador
    
    call imprimir_jogador_recebe
    
    call sortear
    call dar_carta_jogador
    
    call imprimir_jogador_recebe
    call imprimir_valor_cartas
    
    mv a0, s0
    li a7, 1
    ecall    
    
    # Finaliza o programa
    li a7, 10
    ecall

dar_carta_jogador:
    # Soma o valor da carta
    la   t1, valor_cartas     # t1 = endereço base do vetor de valores
    add  t2, t1, a0           # t2 = endereço de valor_cartas[a0]
    lb   t3, 0(t2)            # t3 = valor da carta sorteada

    add  s0, s0, t3           # soma o valor da carta ao total do jogador

    # Salvar a carta no vetor cartas_jogador
    la   t4, cartas_jogador   # t4 = base de cartas_jogador
    add  t5, t4, s1           # t5 = endereço da próxima posição livre
    sb   a0, 0(t5)            # salva o índice da carta

    addi s1, s1, 1            # incrementa contador de cartas do jogador

    ret

sortear:
    la t0, baralho
    # Sorteia índice de 0 a 12
    li a0, 0
    li a1, 13
    li a7, 42
    ecall                 # a0 = índice sorteado

    # Verifica se ainda há cartas desse valor
    add t1, t0, a0        # t1 = endereço de baralho[a0]
    lb  t2, 0(t1)         # t2 = baralho[a0]
    beqz t2, sortear      # Se t2 == 0, sorteia de novo

    # Remove a carta (decrementa)
    addi t2, t2, -1
    sb   t2, 0(t1)

    ret

total_cartas:
    la   t0, baralho      # t0 = endereço base do baralho
    li   t1, 0            # t1 = índice (0 a 12)
    li   t2, 0            # t2 = soma total
    li   t5, 13		 # t5 = tamanho do vetor baralho
    
    la   a0, msg_total_cartas
    li   a7, 4
    ecall

total_cartas_loop:
    beq  t1, t5, total_cartas_fim  # se t1 == 13, terminou

    add  t3, t0, t1       # t3 = endereço de baralho[t1]
    lb   t4, 0(t3)        # t4 = valor em baralho[t1]
    add  t2, t2, t4       # soma ao total

    addi t1, t1, 1        # incrementa índice
    j total_cartas_loop

total_cartas_fim:
    mv   a0, t2           # coloca soma em a0
    li   a7, 1            
    ecall

    la   a0, msg_nl
    li   a7, 4
    ecall
    
    ret
            
imprimir_jogador_recebe:
    mv t0, a0
 
    la   a0, msg_jogador_recebe
    li   a7, 4
    ecall
    
    addi t0, t0, 1     # valor da carta = indice + 1
    mv a0, t0
    li   a7, 1
    ecall
    
    la   a0, msg_nl    # imprime nova linha
    li   a7, 4
    ecall
    ret

imprimir_valor_cartas:
    la   t0, cartas_jogador   # t0 = endereço base de cartas_jogador
    li   t1, 0                # t1 = índice (contador)
    mv   t2, s1               # t2 = número de cartas do jogador (s1)

    la   a0, msg_mao          # imprime "Sua mão: "
    li   a7, 4
    ecall

imprimir_loop:
    beq  t1, t2, imprimir_fim # se já imprimiu todas, sai

    add  t3, t0, t1           # t3 = endereço de cartas_jogador[t1]
    lb   t4, 0(t3)            # t4 = índice da carta

    la   t5, valor_cartas     # t5 = base de valor_cartas
    add  t6, t5, t4           # t6 = endereço de valor_cartas[indice]
    lb   a0, 0(t6)            # a0 = valor da carta

    # Imprime valor (como inteiro)
    li   a7, 1
    ecall

    # Imprime " + " se não for a última carta
    addi t1, t1, 1
    blt  t1, t2, imprimir_mais

    j imprimir_loop

imprimir_mais:
    la   a0, msg_mais
    li   a7, 4
    ecall
    j imprimir_loop

imprimir_fim:
    la   a0, msg_nl
    li   a7, 4
    ecall
    ret
