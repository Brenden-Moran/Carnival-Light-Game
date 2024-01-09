# Carnival-Light-Game
All of the Assembly Code can be found in the Carnival_Game.s file

This is a program created for the Tiva TM4C123G microcontroller, it outputs to 7 different colored  LEDs and waits for the user’s input. In order to win the game the user must click the button when the green LED is on. The program makes use of ports B for output and F for input and uses the built in SysTick timer for each LED cycle. The program is created with ARM Architecture Assembly Language. 

The provided assembly code is a program for the Tiva TM4C123G microcontroller that acts as a carnival game, as previously explained. Here's a description of the key elements in the assembly code:

Constants:
QUARTERSEC: Represents the number of cycles for a quarter-second delay, which is approximately 0.25 seconds at a 16 MHz clock.

Register Definitions:
Defines memory addresses for system timer control registers (NVIC_ST_CTRL_R, NVIC_ST_RELOAD_R, NVIC_ST_CURRENT_R).
Defines memory addresses for Port B control registers (GPIO_PORTB_DATA_R, GPIO_PORTB_DIR_R, GPIO_PORTB_DEN_R, GPIO_PORTB_PUR_R) and Port F control registers (GPIO_PORTF_DATA_R, GPIO_PORTF_DIR_R, GPIO_PORTF_DEN_R, GPIO_PORTF_PUR_R).

System Control Registers:
Defines memory addresses for system control registers (SYSCTL_RCGC2_R, SYSCTL_RCGCGPIO_R), used to enable clock signals for specific ports.

Initialization Functions:
Ports_Init: Initializes the necessary ports for the LEDs and the button. Configures Port B as output for LEDs and Port F as input for the button with a pull-up resistor.
SysTick_Init: Initializes the SysTick timer for a quarter-second delay.

Main Loop (Start Procedure):
The program enters an infinite loop where it continuously shifts a bit through the LEDs from right to left and then from left to right.
It checks if the button is pressed during specific LED states (green LED). Depending on the condition, it enters either the winner loop or loser loop, introducing delays for visual effects.
The loop repeats, creating a shifting LED pattern until a win or loss condition is met.

Winner and Loser Loops:
Winner_Loop: Flashes the green LED multiple times in the case of a win.
Loser_Loop: Flashes the red LEDs multiple times in the case of a loss.

Delay Functions:
Delay: Provides a general delay function.
Delay_Loser and Delay_Win: Specific delays for loser and winner scenarios.

The program effectively creates a carnival game where the LEDs shift and the user must press the button at the right time to win. The code demonstrates the use of assembly language to control GPIO ports, implement timing delays, and handle user input. The game logic includes visual feedback through LED patterns for both winning and losing conditions.
