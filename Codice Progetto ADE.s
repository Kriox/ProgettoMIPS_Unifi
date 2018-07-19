#FONTANI ALESSIO - alessio.fontani@stud.unifi.it - Consegnato il 18/05/2018

.data

fnf:	.asciiz "File not found: "

pin:	.asciiz	"pendenzaIN.txt"

sin:	.asciiz	"sterzoIN.txt"

din:	.asciiz	"distanzaIN.txt"

pout:	.asciiz "correttezzaPendenzaOUT.txt"

sout:	.asciiz	"correttezzaSterzoOUT.txt"

dout:	.asciiz	"correttezzaDistanzaOUT.txt"

puno:	.asciiz	"correttezzaP1.txt"

pdue:	.asciiz "correttezzaP2.txt"

ptre:	.asciiz "correttezzaP3.txt"

jtab:	.word case0, case1, case2, case3

buff:	.space 512

arr:	.space 400

arr2: 	.space 100

out1: 	.space 199

out2:	.space 199

out3:	.space 199


.text

.globl main

main:	addi $sp, $sp, -4		#il frame di stack e' di 4 byte
		sw $ra, ($sp)			#salva l'indirizzo di ritorno
		jal pend				#jal alla prima procedura
		jal ster				#jal alla seconda procedura
		jal dist				#jal alla terza procedura
		jal corp				#jal alla quarta ed ultima procedura
		lw $ra, ($sp)			#ripristina l'indirizzo di ritorno
		addi $sp, $sp, 4		#rimuove il frame di stack
fine:	li $v0, 10				#inserisco in v0 il codice di chiusura programma
		syscall					#chiude il programma

#APERTURA FILE PER LETTURA

apriL:	li $v0, 13				#inserisco in v0 il codice per aprire file
		li $a1, 0 				#read-only flag
		li $a2, 0				#(ignored)
		syscall
		move $t0, $v0			#sposto il descrittore in t0
		blt $t0,0,err1 			#se il file non esiste restituisce errore
		jr $ra					#torna al chiamante

#APERTURA FILE PER SCRITTURA

apriS:	li $v0, 13				#inserisco in v0 il codice per aprire file
		li $a1, 1 				#write-only flag
		li $a2, 0				#(ignored)
		syscall
		move $t0, $v0			#sposto il descrittore in t0
		blt $t0,0,err1 			#se il file non esiste va ad err1
		jr $ra					#torna al chiamante

#LETTURA FILE

leggi:	li $v0, 14				#inserisco in v0 il codice per la lettura del file
		la $a1, buff 			#scelgo dove mettere i dati
		li $a2, 508 			#lunghezza del buff
		syscall
		jr $ra					#torna al chiamante

#SCRITTURA FILE

scrivi:	li $v0, 15 				#inserisco in v0 il codice di scrittura su file
		syscall
		jr $ra					#torna al chiamante

#ERRORE FILE NON TROVATO

err1:	li $v0, 4				#inserisco in v0 il codice per il print-string
		move $t0, $a0		
		la $a0, fnf				#metto in a0 l'indirizzo al messaggio di errore
		syscall					#stampa il messaggio d'errore
		move $a0, $t0			#metto in a0 l'indirizzo al nome del file mancante
		syscall					#stampa il file mancante
		j fine					#jump a fine

#PULIZIA BUFFER

pulizia:la $t0, buff			#carico l'indirizzo di buff
rin:	lw $t1, ($t0)			#mette in t1 una word del buff 
		beqz $t1, back  		#se t1 e' null esce dal loop (rin)
		sw $zero, ($t0)			#mette null nell'indirizzo t0
		addi $t0, $t0, 4		#aumenta l'indirizzo
		j rin					#jump a rin
back:	jr $ra					#torna all'indirizzo chiamante


#CONVERSIONE DA CHAR AD INTEGER	

iniCon:	la $s3, buff			#carica in s3 l'indirizzo di buff
		la $s5, arr				#carica in s5 l'indirizzo di arr
		li $t6, 0				#variabile usata per controllare se un numero e' negativo
		li $s2, 0				#inizializzo s2, variabile contenente l'intero ottenuto dalla conversione
		li $t3, 32				#valore corrispondente a SPACE
		li $t4, 45				#valore corrispondente a -
		li $t5, 10				#valore di moltiplicazione
loop:	lbu $t1, ($s3)   	  	#carica in t1 un carattere del buffer
		beq $t1, $t3 , FIN		#se il carattere e' SPACE salta a FIN
		beq $t1, $zero, FIN		#se il carattere e' NULL salta a FIN
		bne $t1, $t4, GO		#se non e' un meno salta a GO
		seq $t6, $t1, $t4 		#mette t6 ad 1, cosi che capisco che devo convertire il numero in un negativo
GO:		blt $t1, 48, error		#controlla che il carattere sia un numero(ascii<'0'), se non lo e' va ad error
		bgt $t1, 57, error 		#controlla che il carattere sia un numero(ascii>'9'), se non lo e' va ad error
		addi $t1, $t1, -48 		#converte il numero da char a decimale
		mul $s2, $s2, $t5  		#moltiplica per 10 il valore in s2
		add $s2, $s2, $t1 	 	#somma la nuova unita', che in presenza di nuova cifra, viene moltiplicata per 10 al prossimo giro
		addi $s3, $s3, 1    	#incremento indirizzo
		j loop              	#jump per riiniziare il loop
FIN:	beqz $t6, cont			#se il numero e' positivo salta, altrimenti
		move $s4, $s2			#trasforma il numero da positivo a negativo
		sub $s2, $s2,$s4		#facendo sostanzialmente x=x-2x
		sub $s2, $s2,$s4
cont:	sw $s2, ($s5)			#mette il numero nell'array
		addi $s5, $s5, 4		#aumenta l'indirizzo dell'array
		addi $s3, $s3, 1		#aumenta l'indirizzo del buffer
		li $s2, 0				#pulisce s2 per il numero successivo
		li $t6, 0				#la variabile di controllo dei num. negativi torna a 0
		bne $t1, $zero, loop	#se t1 e' zero significa che gli input sono finiti ed esegue il ritorno
		jr $ra					#altrimenti riinizia il loop

error: 	addi $s3, $s3, 1		#aumenta l'indirizzo del buffer dopo aver trovato un char che non e' un numero
		j loop					#jump a loop


#SALVATAGGIO TIPO E DISTANZA

inisv:	li $t0, 0				#variabile di controllo primo char
		li $s0, 0				#inizializzazione di s0
		li $t6, 32				#valore corrispondente a SPACE
		li $t7, 16				#valore di moltiplicazione
		la $t2, buff			#carico l'indirizzo di buff in t2
		la $t4, arr2			#carico l'indirizzo di arr2 in t4
		la $t5, arr				#carico l'indirizzo di arr in t5
while:	lb $t3, ($t2)			#carico in t3 un char del buff
		addi $t2, $t2, 1		#aumento l'indirizzo
		beq $t3, $zero, AZZ		#se e' fine buffer, va ad esc 
		bne $t0, $zero, DOV		#salta a DOV se non e' il primo char
		sb $t3, ($t4)			#mette il tipo in arr2
		addi $t4, $t4, 1		#aumenta l'indirizzo in t4
		addi $t0, $t0, 1		#mette la variabile di controllo ad 1
		j while					#jump a while
DOV:	beq $t3, $t6, AZZ		#se il char e' uno SPACE va ad AZZ
		blt $t3, 65, NUM		#salta se il carattere e' un numero
		addi $t3, $t3, -55		#trova il decimale corrispondente al char lettera
		j AVA					#continua da AVA
NUM:	addi $t3, $t3, -48		#trova il decimale corrispondente al char numero
AVA:	mul $s0, $s0, $t7		#moltiplica per 16 il valore in s0
		add $s0, $s0, $t3		#somma la nuova unita', che in presenza di nuova cifra, viene moltiplicata per 16 al prossimo giro
		j while					#jump a while2
AZZ:	sw $s0, ($t5)			#mette il valore della distanza in arr
		beq $t3, $zero, ESC		#se il buffer e' finito esce
		li $t0, 0				#mette 0 in t0, facendo capire alla procedura che il prossimo char e' un primo char
		addi $t5, $t5, 4		#aumenta l'indirizzo di arr
		li $s0, 0				#pulisce s0 per il numero successivo
		j while					#jump a while2
ESC:	jr $ra					#torna all'indirizzo chiamante
	
#CONTROLLO PENDENZA

pend:	addi $sp, $sp, -4 		#alloca 4 byte nello stack	
		sw $ra, 0($sp)			#salva l'indirizzo di ritorno
		la $a0, pin				#Imposto pendenzaIn.txt come file da aprire
		jal apriL				#Chiamo la procedura per aprire un file in readonly
		move $a0, $v0			#Metto in $a0 il descrittore per leggere il file
		jal leggi				#Chiamo la procedura per leggere il file, mette i dati in buff
		jal iniCon				#Chiamo la procedura per la conversione
	
		li $t1, 0				#contatore per concludere il loop
		li $t7, 32				#variabile contenente il decimale corrispondente allo spazio
		li $t8, 49				#variabile contenente il decimale corrispondente all' 1
		li $t9, 48				#variabile contenente il decimale corrispondente allo 0
		li $t5, 100				#variabile controllo fine array
		la $t2, arr				#carico l'indirizzo dell'array
		la $t4, out1			#carico l'indirizzo in cui inserire i valori di output
loopP:	beq $t1, $t5, prin1		#quando arriva al centesimo valore, va a prin1 per stampare out1 e quindi esce dal loopP
		lw $t3, ($t2)			#mette in t3 i valori dell'array
		addi $t2, $t2, 4		#aumenta l'indirizzo dell'array
		bgt $t3, 59, false		#se t3 e' maggiore di 59 salta a false
		blt $t3, -59,false		#se t3 e' minore di -59 salta a false
		sb $t8, ($t4)			#mette uno nei dati in output
		j true					#jump all'etichetta true
false:	sb $t9, ($t4)			#mette zero nei dati in output
true:	sb $t7, 1($t4)			#mette uno spazio dopo il valore di correttezza
		addi $t4, $t4, 2		#aumenta l'indirizzo di out1
		addi $t1, $t1, 1		#aumenta il contatore( il contatore conclude il ciclo quando arriva a 100)
		j loopP					#riparte il loopP

prin1:	la $a0, pout			#carica in a0 il file da aprire
		jal apriS				#chiama la procedura di apertura del file, write-only
		move $a0, $v0			#mette il descrittore in a0
		la $a1, out1 			#mette in a1 l'indirizzo di out1, out1 viene scritto nel file
		li $a2, 199				#decide lo spazio da riservare
		jal scrivi				#richiama la procedura di scrittura
		jal pulizia				#richiama la procedura di pulizia di buff
		lw $ra, ($sp)			#ripristina l'indirizzo di ritorno
		addi $sp, $sp, 4		#rimuove lo stack frame
		jr $ra					#jump alla procedura chiamante

#CONTROLLO STERZO

ster:	addi $sp, $sp, -4 		#alloca 4 byte nello stack
		sw $ra, ($sp)			#salva l'indirizzo di ritorno
		la $a0, sin				#Imposto sterzoIn.txt come file da aprire
		jal apriL				#Chiamo la procedura per aprire un file in readonly
		move $a0, $v0			#Metto in $a0 il descrittore per leggere il file
		jal leggi				#Chiamo la procedura per leggere il file, mette i dati in buff
		jal iniCon				#Chiamo la procedura per la conversione
	
		li $t0, 0				#inizializzo t0 a 0, e' il contatore per uscire prima della fine dell'array
		li $t1, 100				#variabile controllo fine array
		la $t3, arr				#carico l'indirizzo dell'array
		la $t5, out2			#carico l'indirizzo in cui inserire i valori in output
		li $t6, 0				#variabile che, quando e' a zero, significa che il loop e' al suo primo ciclo
		li $s0, 32				#variabile contenente il decimale corrispondente allo spazio
		li $s1, 48				#variabile contenente il decimale corrispondente allo zero
		li $s2, 49				#variabile contenente il decimale corrispondente all'1
loop1:	beq $t0, $t1, prin2		#esce dal loop1 se si e' raggiunto l'ultimo valore
		lw $t4, ($t3)			#carica in t4 i valori in arr
		addi $t3, $t3, 4		#aumenta l'indirizzo di arr
		ble $t4, $zero, false2	#salta se il valore e' minore di 1
		bge $t4, $t1, false2	#salta se il valore e' maggiore di 99
		bne $t6, $zero, check	#se non e' il primo inserimento salta a check
		sb $s2, ($t5)			#mette 1 nell'array in uscita (out2)
		li $t6, 1				#mette ad 1 t6, cosi capiamo che il primo valore e' stato letto
		j true2					#jump a true2
check:	bgt $t7, $t4, cas2		#se t7 e' maggiore di t4 va a cas2
		sub $s5, $t4, $t7		#mette il risultato di t4-t7 in s5
		j check2				#jump a check2
cas2:	sub $s5, $t7, $t4		#mette il risultato di t7-t4 in s5
check2:	bgt $s5, 10, false2 	#se s5>10 va a false
		sb $s2, ($t5)			#mette 1 nell'array in uscita (out2)
		j true2					#jump a true2
false2:	sb $s1, ($t5)			#mette 0 nell'array in uscita (out2)
true2:	sb $s0, 1($t5)			#mette uno spazio nell'array in uscita (out2)
		addi $t5, $t5, 2		#aumenta l'indirizzo di out2
		addi $t0, $t0, 1		#aumenta il contatore (che quando arriva a 100 esce dal loop)
		move $t7, $t4			#mette in t7 il valore in t4 per il controllo successivo, t7 sara' il valore precedente
		j loop1					#jump a loop1

prin2:	la $a0, sout			#carica in a0 il file da aprire
		jal apriS				#chiama la procedura di apertura del file, write-only
		move $a0, $v0			#mette il descrittore in a0
		la $a1, out2 			#mette in a1 l'indirizzo di out2, out2 viene scritto nel file
		li $a2, 199				#decide lo spazio da riservare
		jal scrivi				#richiama la procedura di scrittura
		jal pulizia				#richiama la procedura di pulizia di buff
		lw $ra, ($sp)			#ripristina l'indirizzo di ritorno
		addi $sp, $sp, 4		#rimuove lo stack frame
		jr $ra					#jump alla procedura chiamante

#CONTROLLO DISTANZA

dist:	addi $sp, $sp, -4 		#Alloca 4 byte nello stack	
		sw $ra, ($sp)			#Salva l'indirizzo di ritorno
		la $a0, din				#Imposto distanzaIn.txt come file da aprire
		jal apriL				#Chiamo la procedura per aprire un file in readonly
		move $a0, $v0			#Metto in $a0 il descrittore per leggere il file
		jal leggi				#Chiamo la procedura per leggere il file, mette i dati in buff
		jal inisv				#Chiamo la procedura di salvataggio tipo di ostacolo
		
		li $t0, 100				#variabile controllo fine array
		li $t6, 0				#contatore fine array
		li $s3, 48				#variabile con valore decimale corrispondente al CHAR 0
		li $s4, 49				#variabile con valore decimale corrispondente al CHAR 1
		li $s5, 32				#variabile con valore decimale corrispondente al CHAR SPACE
		la $s0, arr				#carico in s0 l'indirizzo di arr
		la $s1, arr2			#carico in s1 l'indirizzo di arr2
		la $s2, out3			#carico in s2 l'indirizzo di out3
loop3:	beq $t6, $t0, prin3		#se l'array e' finito va a prin3
		lw $t5, ($s0)			#carico in t5 il valore all'indirizzo s0
		bgt $t5, 50, false3		#salta a false3 se il valore e' maggiore di 50
		beq $t5, $zero, false3 	#salta a false3 se il valore e' 0
		bgt $t6, 1, CAS			#se siamo alla terza cifra, salta a CAS
		j true3					#jump a true3
CAS:	lw $t4, -4($s0)			#mette il valore precedente a quello corrente, in t4
		bne $t5, $t4, true3		#se i valori sono diversi, salta a true3
		lw $t3, -8($s0)			#carica il valore due posizioni piu indietro di quello corrente, in t3
		bne $t3, $t5, true3		#se i valori sono diversi, salta a true3
		lb $t4, -1($s1)			#mette il tipo del valore precedente a quello corrente in t4
		lb $t3, ($s1)			#mette il tipo del valore corrente in t3
		bne $t3, $t4, true3		#se i tipi sono diversi salta a true3
		lb $t4, -2($s1)			#mette il tipo del valore due posizioni piu indietro di quello corrente, in t4
		bne $t3, $t4, true3		#se i tre valori precedenti sono diversi, salta a true3
false3:	sb $s3, ($s2)			#mette zero come risultato in out3	
		j GO3					#jump a GO3
true3:	sb $s4, ($s2)			#mette uno come risultato in out3
GO3:	sb $s5, 1($s2)			#mette SPACE in out3+1
		addi $s2, $s2, 2		#aumenta l'indirizzo di out3
		addi $s0, $s0, 4		#aumenta l'indirizzo di arr
		addi $s1, $s1, 1		#aumenta l'indirizzo di arr2
		addi $t6, $t6, 1		#aumenta il contatore
		j loop3					#jump a loop3

prin3:	la $a0, dout			#carica in a0 il file da aprire
		jal apriS				#chiama la procedura di apertura del file, write-only
		move $a0, $v0			#mette il descrittore in a0
		la $a1, out3 			#mette in a1 l'indirizzo di out3, out3 viene scritto nel file
		li $a2, 199				#decide lo spazio da riservare
		jal scrivi				#richiama la procedura di scrittura
		lw $ra, ($sp)			#ripristina l'indirizzo di ritorno
		addi $sp, $sp, 4		#rimuove il frame di stack
		jr $ra					#jump alla procedura chiamante

corp: 	addi $sp, $sp, -4 		#alloca 4 byte nello stack	
		sw $ra, ($sp)			#salva l'indirizzo di ritorno
		la $t0,	out1			#carico in t0 l'indirizzo di t
		la $t1,	out2			#carico in t1 l'indirizzo di out2
		la $t2, out3			#carico in t2 l'indirizzo di out3
		la $s4, jtab			#carico in s4 l'indirizzo della jumptable
		li $t8, 0				#contatore per controllo fine array
		li $s5, 48				#variabile con il decimale corrispondente a CHAR 0
		li $s6, 49				#variabile con il decimale corrispondente a CHAR 1
		li $t3, 100				#variabile controllo fine array
		li $t4, 4				#valore di moltiplicazione
loop4:	beq $t8, $t3, prin4		#se l'array e' finito va a prin4
		li $t6, 0				#inizializzo la variabile t6
		move $s7, $s4			#metto in s7 l'indirizzo della jump table
		addi $t8, $t8, 1		#aumento il contatore
		lb $s0, ($t0)			#metto in s0 il valore all'indirizzo $t0
		lb $s1, ($t1)			#metto in s1 il valore all'indirizzo $t1
		lb $s2, ($t2)			#metto in s2 il valore all'indirizzo $t2
		addi $s0, $s0, -48		#trasformo il valore in s0 in decimale, per poter effettuare la somma
		addi $s1, $s1, -48		#trasformo il valore in s1 in decimale, per poter effettuare la somma
		addi $s2, $s2, -48		#trasformo il valore in s2 in decimale, per poter effettuare la somma	
		add $t6, $t6, $s0		#sommo in t6 il valore di correttezza presente in s0
		add $t6, $t6, $s1		#sommo in t6 il valore di correttezza presente in s1
		add $t6, $t6, $s2		#sommo in t6 il valore di correttezza presente in s2
		mul $t6, $t6, $t4		#moltiplico per 4 il valore in t6
		add $s7, $s7, $t6		#metto in s7 il valore corrispondente all'indirizzo contenente l'indirizzo a cui saltare
		lw $s7, ($s7)			#metto in s7 l'indirizzo a cui saltare
		jr $s7					#jump all'indirizzo contenuto in s7

case0:	sb $s5, ($t2)			#metto 0 in out3 (che corrisponde a correttezzaP3)
		sb $s5, ($t1)			#metto 0 in out2 (che corrisponde a correttezzaP2)
		sb $s5, ($t0)			#metto 0 in out1 (che corrisponde a correttezzaP1)
		addi $t0, $t0, 2		#aumento l'indirizzo
		addi $t1, $t1, 2		#aumento l'indirizzo
		addi $t2, $t2, 2		#aumento l'indirizzo
		j loop4					#jump a loop4

case1:	sb $s6, ($t2)			#metto 1 in out3 (che corrisponde a correttezzaP3)
		sb $s5, ($t1)			#metto 0 in out2 (che corrisponde a correttezzaP2)
		sb $s5, ($t0)			#metto 0 in out1 (che corrisponde a correttezzaP1)
		addi $t0, $t0, 2		#aumento l'indirizzo
		addi $t1, $t1, 2		#aumento l'indirizzo
		addi $t2, $t2, 2		#aumento l'indirizzo
		j loop4					#jump a loop4
	
case2:	sb $s6, ($t2)			#metto 1 in out3 (che corrisponde a correttezzaP3)
		sb $s6, ($t1)			#metto 1 in out2 (che corrisponde a correttezzaP2)
		sb $s5, ($t0)			#metto 0 in out1 (che corrisponde a correttezzaP1)
		addi $t0, $t0, 2		#aumento l'indirizzo
		addi $t1, $t1, 2		#aumento l'indirizzo
		addi $t2, $t2, 2		#aumento l'indirizzo
		j loop4					#jump a loop4

case3:	sb $s6, ($t2)			#metto 1 in out3 (che corrisponde a correttezzaP3)
		sb $s6, ($t1)			#metto 1 in out2 (che corrisponde a correttezzaP2)
		sb $s6, ($t0)			#metto 1 in out1 (che corrisponde a correttezzaP1)
		addi $t0, $t0, 2		#aumento l'indirizzo
		addi $t1, $t1, 2		#aumento l'indirizzo
		addi $t2, $t2, 2		#aumento l'indirizzo
		j loop4					#jump a loop4

prin4:	la $a0, puno			#carica in a0 il file da aprire
		jal apriS				#chiama la procedura di apertura del file, write-only
		move $a0, $v0			#mette il descrittore in a0
		la $a1, out1 			#mette in a1 l'indirizzo di out1, out1 viene scritto nel file
		li $a2, 199				#decide lo spazio da riservare
		jal scrivi				#richiama la procedura di scrittura
		la $a0, pdue			#carica in a0 il file da aprire
		jal apriS				#chiama la procedura di apertura del file, write-only
		move $a0, $v0			#mette il descrittore in a0
		la $a1, out2 			#mette in a1 l'indirizzo di out2, out2 viene scritto nel file
		li $a2, 199				#decide lo spazio da riservare
		jal scrivi				#richiama la procedura di scrittura
		la $a0, ptre			#carica in a0 il file da aprire
		jal apriS				#chiama la procedura di apertura del file, write-only
		move $a0, $v0			#mette il descrittore in a0
		la $a1, out3 			#mette in a1 l'indirizzo di out3, out3 viene scritto nel file
		li $a2, 199				#decide lo spazio da riservare
		jal scrivi				#richiama la procedura di scrittura
		lw $ra, ($sp)			#ripristina l'indirizzo di ritorno
		addi $sp, $sp, 4		#rimuove il frame di stack
		jr $ra					#ritorna alla procedura chiamante
