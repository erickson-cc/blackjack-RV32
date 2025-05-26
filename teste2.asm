.data
baralho:       .byte 4,4,4,4,4,4,4,4,4,4,4,4,4      # 13 cartas
valor_cartas:  .byte 1,2,3,4,5,6,7,8,9,10,10,10,10  # valores
seed:          .word 12345                          # seed inicial

.text
.globl main
	li a4, 54 
main:
    call dar_carta         # a0 = índice da carta sorteada (0 a 12)

    # Imprime o índice sorteado
    li a7, 1
    ecall


    # Imprime o valor atualizado em baralho[a0]
    la t1, baralho         # t1 = endereço do vetor
    add t2, t1, a0        # t2 = endereço de baralho[a0]
    lb  a0, 0(t2)         # a0 = valor em baralho[a0]

    li a7, 1              # syscall print integer
    ecall
    # Imprime uma quebra de linha
    li a7, 11
    li a0, 10
    ecall
	addi a4, a4, -1
	beq a4, zero, finaliza
	j main
finaliza:
    # Finaliza o programa
    li a7, 10
    ecall

dar_carta:
    la t0, baralho        # t0 = endereço do baralho

sortear:
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
