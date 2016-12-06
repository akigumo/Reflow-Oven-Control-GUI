; nebulaM
; Unit for testing LCD_controller before being integrated into the entire reflow oven control model
$MODDE2
org 0000H
	ljmp MyProgram
;org 000BH
;	ljmp ISR_timer0
;org 002BH
;	ljmp ISR_timer2
	
FREQ   EQU 33333333
BAUD   EQU 115200
T2LOAD EQU 65536-(FREQ/(32*BAUD))
TIMER0_RELOAD EQU 65536-(FREQ/(12*2*100))

CE_ADC EQU P0.3
SCLK EQU P0.2
MOSI EQU P0.1
MISO EQU P0.0


;---------------------------------------------------------------------------------
DSEG at 30H
x:   ds 4
y:   ds 4
bcd: ds 5


FLASHSECTOR: ds 1
;----------------------------------------
soak_temp_LCD: ds 3
soak_time_LCD: ds 3
reflow_temp_LCD: ds 3
reflow_time_LCD:ds 3
;-----------------------------------------
soak_temp_run: ds 1
soak_time_run:ds 1
reflow_temp_run:ds 1
reflow_time_run:ds 1

soak_temp_default: ds 1
soak_time_default:ds 1
reflow_temp_default:ds 1
reflow_time_default:ds 1

;-------------------------------------------
Cnt_10ms:  ds 1
blink_KEY_default_or_not_loop_counter:ds 1
BSEG
mf: dbit 1

$include(math32.asm)
$include(LCD_controller.asm)
$include(LCD_controller_JAPN.asm)
CSEG

;-------------------------------------------------------------------------------------------------------------------------------------------
;SSegs Database	
;-------------------------------------------------------------------------------------------------------------------------------------------
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H 

;-------------------------------------------------------------------------------------------------------------------------------------------
;LCD Database	
;-------------------------------------------------------------------------------------------------------------------------------------------
eece_MSG:
    DB  '    EECE 281',0
reflow_oven_MSG:
	DB  '   Reflow Oven',0
initial_interface_MSG:
	DB  'K3=START K1=LANG',0
blink_initial_interface_k1_MSG:
	DB  'K3=START        ',0
blink_initial_interface_k3_MSG:
	DB  '         K1=LANG',0
next_page_MSG:
	DB  'Next Page: KEY3',0
soak_default_MSG:
	DB  'Soak ',0 ;150C 60s
reflow_default_MSG:
	DB  'Reflow ',0 ;220C 60s
use_default_MSG:
	DB  'Run in Default?', 0
option_MSG:
	DB  'K3=Y K2=N K1=Esc',0
blink_KEY1_Esc_MSG:
	DB  'K3=Y K2=N       ',0
blink_KEY2_N_MSG:
	DB  'K3=Y      K1=Esc',0
blink_KEY3_Y_MSG:
	DB  '     K2=N K1=Esc',0
user_select_line1_MSG:
	DB  'Select K1=RETURN',0
user_select_line2_MSG:
	DB  'K3=NEW K2=SAVED',0
blink_user_K1_MSG:
	DB  'Select          ',0
blink_user_K2_MSG:
	DB  'K3=NEW         ',0
blink_user_K3_MSG:
	DB  '       K2=SAVED',0
preheat_MSG:
	DB  'Preheating',0
soak_MSG:
	DB  'Soaking',0
pre_reflow_MSG:
	DB  'Pre Reflowing'
reflow_MSG:
	DB  'Reflowing',0
cooling_MSG:
	DB  'Cooling',0
lock_door_MSG:
	DB  '   DOOR LOCKED',0
reflow_start_MSG:
	DB  '      START',0
unlock_door_MSG:
	DB  '  DOOR UNLOCKED',0
reflow_end_MSG:
	DB  '      END',0	
finished_MSG:
	DB  '   Reflow Done',0
use_saved_MSG:
	DB  'Run in Saved Mod',0
option_saved_MSG:
	DB  'K3=Y        K1=N',0
blink_option_saved_K1_MSG:
	DB  'K3=Y            ',0
blink_option_saved_K3_MSG:
	DB  '            K1=N',0
user_setting_change_variables_MSG:
	DB  'K3=+ K2=- K1=Nxt',0
user_setting_change_variables_blink_K1_MSG:
	DB  'K3=+ K2=-       ',0
temp_too_low_MSG:
	DB  'TEMP TOO LOW!',0
temp_too_high_MSG:
	DB  'TEMP TOO HIGH!',0
time_too_short_MSG:
	DB	'TIME TOO SHORT!',0
time_too_long_MSG:
	DB	'TIME TOO LONG!',0
soak_change_MSG:
	DB  'Soak',0 
reflow_change_MSG:
	DB  'Reflow',0
save_the_setting_for_later_MSG:
	DB  'Save for later?',0
new_setting_saved_MSG:
	DB  'Saved!',0
run_in_new_setting_confirm_MSG:
	DB	'Run with these?',0
select_language_MSG:
	DB  'Select Language',0
language_option_MSG:
	DB  'K3=ENGL K1=',0C6H,0CEH,0DDH,0BAH,0DEH,0
blink_language_option_k1_MSG:
	DB  'K3=ENGL         ',0 
blink_language_option_k3_MSG:
	DB  '        K1=',0C6H,0CEH,0DDH,0BAH,0DEH,0	
;------------------------------------------------------------------------------------------------	
myLUT_JAPN:
	DB 0B1H, 0B2H, 0B3H, 0B4H, 0B5H ;¤¢
	DB 0B6H, 0B7H, 0B8H, 0B9H, 0BAH ;¤«
	DB 0BBH, 0BCH, 0BDH, 0BEH, 0BFH ;¤µ
	DB 0C0H, 0C1H, 0C2H, 0C3H, 0C4H ;¤¿
	DB 0C5H, 0C6H, 0C7H, 0C8H, 0C9H ;¤Ê
	DB 0CAH, 0CBH, 0CCH, 0CDH, 0CEH ;¤Ï
	DB 0CFH, 0D0H, 0D1H, 0D2H, 0D3H ;¤Þ
	DB 0D4H, 0D5H, 0D6H 			;ya
	DB 0D7H, 0D8H, 0D9H, 0DAH, 0DBH ;RA
	DB 0DCH, 0DDH					;WO,N	
	DB 0A1H, 0B0H ;MARU ,-
	DB 0DEH, 0DFH 
eece_MSG_JAPN:
    DB  '    EECE 281',0
reflow_oven_MSG_JAPN:
	DB  '    ',11011000B, 11001100B, 11011010B, 10110000B, 00010000B, 11011011B, 0
next_page_MSG_JAPN:
	DB  '   ',0C2H,0B7H,0DEH,' : KEY3',0
soak_default_MSG_JAPN:
	DB  0CBH,0C0H,0BDH,'  ',0 ;150C 60s
reflow_default_MSG_JAPN:
	DB  0D8H, 0CCH, 0DBH, 0B0H,'   ',0 ;220C 60s
use_default_MSG_JAPN:
	DB  0B7H,0C4H,0DEH,0B3H,0BCH,0CFH,0BDH,0B6H,0A1H, 0	;Ê¼„Ó¤¹¤ë
option_MSG_JAPN:
	DB  'K3=Y K2=N K1=Esc',0
blink_KEY1_Esc_MSG_JAPN:
	DB  'K3=Y K2=N       ',0
blink_KEY2_N_MSG_JAPN:
	DB  'K3=Y      K1=Esc',0
blink_KEY3_Y_MSG_JAPN:
	DB  '     K2=N K1=Esc',0
user_select_line1_MSG_JAPN:
	DB  0BEH,0DDH,0C0H,0B8H,0BCH,0CFH,0BDH,0A1H,' K1=',0D3H,0C4H,0DEH,0D9H,0
user_select_line2_MSG_JAPN:
	DB  'K3=',0BEH,0AFH,0C3H,0B2H,'K2=SAVED',0
blink_user_K1_MSG_JAPN:
	DB  0BEH,0DDH,0C0H,0B8H,0BCH,0CFH,0BDH,0A1H,'        ',0
blink_user_K2_MSG_JAPN:
	DB  'K3=',0BEH,0AFH,0C3H,0B2H,'        ',0
blink_user_K3_MSG_JAPN:
	DB  '       K2=SAVED',0
preheat_MSG_JAPN:
	DB  'Preheating',0
soak_MSG_JAPN:
	DB  'Soaking',0
pre_reflow_MSG_JAPN:
	DB  'Pre Reflowing'
reflow_MSG_JAPN:
	DB  'Reflowing',0
cooling_MSG_JAPN:
	DB  'Cooling',0
lock_door_MSG_JAPN:
	DB  '   DOOR LOCKED',0
reflow_start_MSG_JAPN:
	DB  '      START',0
unlock_door_MSG_JAPN:
	DB  '  DOOR UNLOCKED',0
reflow_end_MSG_JAPN:
	DB  '      END',0	
finished_MSG_JAPN:
	DB  '   Reflow Done',0
use_saved_MSG_JAPN:
	DB  0B7H,0C4H,0DEH,0B3H,0BCH,0CFH,0BDH,0B6H,0A1H,0
option_saved_MSG_JAPN:
	DB  'K3=Y        K1=N',0
blink_option_saved_K1_MSG_JAPN:
	DB  'K3=Y            ',0
blink_option_saved_K3_MSG_JAPN:
	DB  '            K1=N',0
user_setting_change_variables_MSG_JAPN:
	DB  'K3=+ K2=- K1=',0C2H,0B7H,0DEH,0
user_setting_change_variables_blink_K1_MSG_JAPN:
	DB  'K3=+ K2=-       ',0
temp_too_low_MSG_JAPN:
	DB  0CBH,0B8H,0BDH,0B7H,0DEH,0CFH,0BDH,'!',0
temp_too_high_MSG_JAPN:
	DB  0C0H,0B6H,0BDH,0B7H,0DEH,0CFH,0BDH,'!',0
time_too_short_MSG_JAPN:
	DB	0D0H,0BCH,0DEH,0B6H,0BDH,0B7H,0DEH,0CFH,0BDH,'!',0
time_too_long_MSG_JAPN:
	DB	0C5H,0B6H,0DEH,0BDH,0B7H,0DEH,0CFH,0BDH,'!',0
soak_change_MSG_JAPN:
	DB  0CBH,0C0H,0BDH,0 
reflow_change_MSG_JAPN:
	DB  0D8H, 0CCH, 0DBH, 0B0H,0
save_the_setting_for_later_MSG_JAPN:
	DB  0CEH,0BFH,0DEH,0DDH,0BCH,0CFH,0BDH,0B6H,0A1H,0
new_setting_saved_MSG_JAPN:
	DB  0CEH,0BFH,0DEH,0DDH,0BCH,0CFH,0BCH,0C0H,'!',0
run_in_new_setting_confirm_MSG_JAPN:
	DB  0B7H,0C4H,0DEH,0B3H,0BCH,0CFH,0BDH,0B6H,0A1H, 0	

;------------------------------------------------------------------------------------------------
;Initialization
;------------------------------------------------------------------------------------------------
MyProgram:
    MOV SP, #7FH
    mov LEDRA, #0
    mov LEDRB, #0
    mov LEDRC, #0
    mov LEDG, #0
    mov Cnt_10ms,#0
    mov p0,#0
    mov TMOD,  #00000001B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer

	clr TR0 ; Disable timer 0
	clr TF0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    setb TR0 ; Enable timer 0
    setb ET0 ; Enable timer 0 interrupt
	lcall LCD_clr
	
	mov FLASHSECTOR,#5
	
	mov soak_temp_run,#0
	mov soak_time_run,#0
	mov reflow_temp_run,#0
	mov reflow_time_run,#0
	
	mov soak_temp_default,#110
	mov soak_time_default,#90
	mov reflow_temp_default,#210
	mov reflow_time_default,#45
    
    orl P0MOD, #00001000b ; make CE_ADC (P0.3) output
;    lcall INIT_SPI

;LCD variables
	mov blink_KEY_default_or_not_loop_counter,#3
	setb EA
;Display "EECE 281 Reflow Oven" for 3s
	lcall LCD_reflow_oven        
	lcall wait_halfs
	lcall wait_halfs
;	lcall wait_halfs
;	lcall wait_halfs
;	lcall wait_halfs
;	lcall wait_halfs
;---------------------------------------------------------------------------------------------------------------


;-----------------------------------------------------------------------------------------------------------
;Reflow Oven Central Processing Unit 
;Functions except LCD command are not added yet. 
;In each state, please try to use ONLY ONE lcall per function in order to keep this file neat and tight 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!IMPORTANT:Please only use "soak_temp_run,soak_time_run,reflow_temp_run,reflow_time_run" when the machine starts.
;---------------------------------------------------------------------------------------------------------------------
initial_state:
	;all LCD commands are in the file "LCD_controller.asm"
	lcall LCD_initial_interface_idle
	sjmp state_preheat	

state_preheat:
	lcall LCD_preheat    ;Display "Soak --C --s Reflow--C --S Preheating"
	;------compare temp here,sw17=1 then back to the initial state, also automatic cycle termination is in here
state_preheat_wait:
	sjmp state_preheat_wait
;	sjmp state_soak

state_soak:
	lcall LCD_soak

state_soak_wait:;-----compare second here,>60 next state(default value)
;	sjmp state_prepare_for_reflow


state_prepare_for_reflow:
	lcall LCD_prepare_for_reflow
state_prepare_for_reflow_wait:;------compare temp here, if>220 then to the next state,set sec to 0
;	sjmp state_reflow

state_reflow:
	lcall LCD_reflow
	
state_reflow_wait:;--------compare sec here,if>45 then to the next state
;	sjmp state_cool_down
	
state_cool_down:
	lcall LCD_cool_down

state_cool_down_wait:;------compare temp here,if<60 then to the next state
;	sjmp state_owari

state_owari:
	lcall LCD_done; Display "Unlocked" then "Reflow Down", really, we do not have a device to lock the oven's door, just a concept...

state_owari_wait:;---------------possible feature here,detect if the door is open, if it is open then jump back to initial state,else stay here
	ljmp initial_state

wait_halfs:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
	ret
wait_200ms:
	mov R2, #18
L3_2: 
	mov R1, #250
L2_2: 
	mov R0, #250
L1_2: 
	djnz R0, L1_2
	djnz R1, L2_2
	djnz R2, L3_2
	ret		
END


