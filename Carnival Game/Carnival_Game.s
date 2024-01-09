; Author: Brenden Moran

    
	   THUMB
       AREA    DATA, ALIGN=4

	   ALIGN 


QUARTERSEC         DCD 4000000      ; approximately 0.25s delay at ~16 MHz clock

	
; System Timer Address
NVIC_ST_CTRL_R          EQU   0xE000E010
NVIC_ST_RELOAD_R        EQU   0xE000E014
NVIC_ST_CURRENT_R       EQU   0xE000E018
	
	
; memory address for Port B control registers

GPIO_PORTB_DATA_R       EQU   0x400053FC		; 8 Accesable Pins
GPIO_PORTB_DIR_R        EQU   0x40005400
GPIO_PORTB_DEN_R        EQU   0x4000551C
GPIO_PORTB_PUR_R        EQU   0x40005510
GPIO_PORTB_PDR_R        EQU   0x40005514
	
	
; memory addresses for Port F control registers. 

GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_PUR_R        EQU   0x40025510 	; PULL UP RESISTOR MEMORY LOCATION 

; System control register use either one to turn on the clock for any port

SYSCTL_RCGC2_R          EQU   0x400FE118
	
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
   


       AREA    |.text|, CODE, READONLY, ALIGN=2

	   EXPORT  Start



Start	proc
	
	BL Ports_Init
	BL SysTick_Init
	
	LDR		R8, =NVIC_ST_CTRL_R
Loop
	LDR R0, =GPIO_PORTB_DATA_R
	LDR R2, [R0]
	ORR R2, #0x01
	AND R2, #0x01
	
	STR R2, [R0]
	BL Delay_Loser					; Quarter Second delay of pin B0 being lit

	
Shift_L	
	LSL R2, #1						; This constantly shift the bit being lit left 
	STR R2, [R0]					; Which will light the LEDs in order from right to left
	
	LDR R5, =GPIO_PORTF_DATA_R
	LDR R6, [R5]
	AND R6, #0x10
	CMP R6, #0x00					; If the button is pressed before the green LED is shown then the user
	BEQ Normal_LEDL					; Lost the game
	
	CMP R2, #0x08
	BEQ Possible_winL				; When the Green LED is lit make sure to check if the button was pressed.
	B Normal_LEDL
Possible_winL
	BL Delay_Win					; Quarter second delay where the user might win the game
	B End_L
Normal_LEDL
	BL Delay_Loser					; Quarter second delay where the user might have lost
End_L
	CMP R2, #0x40					; If the shift has shifted the bit to the last LED on the left
	BNE Shift_L						; Then start shifting it right
	
Shift_R
	LSR R2, #1						; This constatly shift the bit being lit right
	STR R2, [R0]					; Which will light the LEDs in order from left to right
	
	LDR R5, =GPIO_PORTF_DATA_R
	LDR R6, [R5]
	AND R6, #0x10
	CMP R6, #0x00					; If the button is pressed before the green LED is shown then the user
	BEQ Normal_LEDR					; Lost the game
	
	CMP R2, #0x08					; When the Green LED is lit make sure to check if the button was pressed.
	BEQ Possible_winR
	B Normal_LEDR
Possible_winR						; Quarter second delay where the user might win the game
	BL Delay_Win
	B End_R
Normal_LEDR						
	BL Delay_Loser					; Quarter second delay where the user might have lost
End_R
	CMP R2, #0x01					
	BNE Shift_R						; If the shift has shifted the bit to the last LED on the right
	B Shift_L  						; then start the loop over again

	
Winner_Loop							; This is the counter for the winner loop
	MOV R3, #10
Loop_Win
	LDR R0, =GPIO_PORTB_DATA_R		; If the user has won then flash the green LED
	LDR R2, [R0]
	EOR R2, #0x08
	STR R2, [R0]
	BL Delay
	SUBS R3, #1
	BNE Loop_Win
	B Loop

Loser_Loop
	MOV R3, #10						; Counter for the loser loop
Loop_lost
	LDR R0, =GPIO_PORTB_DATA_R		; If the user has lost then flash the red LEDs
	LDR R2, [R0]
	EOR R2, #0x63
	STR R2, [R0]
	BL Delay
	SUBS R3, #1
	BNE Loop_lost
	B Loop
	
Delay
	LDR	R1, [R8]
	AND	R1, #0x10000
	CMP	R1, #0x10000
	BNE Delay
	BX LR
	

Delay_Loser
	LDR R3, =GPIO_PORTF_DATA_R
	LDR R4, [R3]
	AND R4, #0x10
	CMP R4, #0x00
	BEQ Loser_Loop
	LDR	R1, [R8]
	AND	R1, #0x10000
	CMP	R1, #0x10000
	BNE Delay_Loser
	BX LR

Delay_Win
	LDR R3, =GPIO_PORTF_DATA_R
	LDR R4, [R3]
	AND R4, #0x10
	CMP R4, #0x00
	BEQ Winner_Loop
	LDR	R1, [R8]
	AND	R1, #0x10000
	CMP	R1, #0x10000
	BNE Delay_Win
	BX LR


Ports_Init
	LDR R0, =SYSCTL_RCGCGPIO_R		;Initialize Port B,F clock
	LDR R1, [R0]
	ORR R1, #0x22				
	STR R1, [R0]

	NOP
	NOP
	NOP

	LDR R0, =GPIO_PORTF_DIR_R		; initializes pin 4 as input
	LDR R1, [R0]
	BIC R1, #0x10
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTB_DIR_R		; initializes pins 0-6
	LDR R1, [R0]
	ORR R1, #0x7F
	STR R1, [R0]

	LDR R0, =GPIO_PORTF_DEN_R		; Digital enables pins 4
	LDR R1, [R0]
	ORR R1, #0x10
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTB_DEN_R		; Digital enables pins 0-6
	LDR R1, [R0]
	ORR R1, #0x7F
	STR R1, [R0]

	
	LDR R0, =GPIO_PORTF_PUR_R
	LDR R1, [R0]
	EOR R1, #0x10					; Creates pull up resistor for input
	STR R1, [R0]
	
	BX LR

SysTick_Init
	LDR R7, =QUARTERSEC
	LDR R7, [R7]
	
	MOV R1, #0x00
	LDR R0, =NVIC_ST_CTRL_R			; Clears systick
	STR R1, [R0]
		
	LDR R0, =NVIC_ST_RELOAD_R		; Store the value to countdown from
	MOV R1, R7						; Num_Cycles=0.25s*16MHz
	STR R1, [R0]					; Num_cycles=0.25*16(10^6)=4000000
		
	LDR R0, =NVIC_ST_CURRENT_R		; Clears the register
	STR R1, [R0]
		
	MOV R1, #0x05
	LDR R0, =NVIC_ST_CTRL_R			; Enable systick
	STR R1, [R0]

	BX		LR	
	
	

       
; -----------END of program---------------------	   
	   ALIGN      
       ENDP 
       END 

