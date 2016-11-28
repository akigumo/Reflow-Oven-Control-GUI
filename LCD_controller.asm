$NOLIST
;--------------------------------------------------------------------------------------------------
; 
;LCD_controller for reflow oven
;--------------------------------------------------------------------------------------------------
;Select a language
;------------------------------------------------------------------------------------------------
LCD_initial_interface_idle:	
	lcall LCD_initial_interface
LCD_initial_interface_wait:
	jnb key.3,to_LCD_initial_state_L1
	jnb key.1,to_select_language_LCD
	sjmp LCD_initial_interface_wait
to_LCD_initial_state_L1:
	lcall LCD_blink_initial_interface_k3
	lcall wait_200ms
	lcall LCD_blink_initial_interface_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_initial_state_L1
	mov blink_KEY_default_or_not_loop_counter,#3	
	sjmp LCD_initial_state
to_select_language_LCD:
	lcall LCD_blink_initial_interface_k1
	lcall wait_200ms
	lcall LCD_blink_initial_interface_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_select_language_LCD
	mov blink_KEY_default_or_not_loop_counter,#3	

	lcall LCD_language_info	
select_language_LCD:
	jnb key.3,to_LCD_initial_interface_idle
	jnb key.1,to_LCD_NIHONGO
	sjmp select_language_LCD
to_LCD_initial_interface_idle:
	lcall LCD_blink_language_info_k3
	lcall wait_200ms
	lcall LCD_blink_language_info_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_initial_interface_idle
	mov blink_KEY_default_or_not_loop_counter,#3	
	sjmp LCD_initial_interface_idle

to_LCD_NIHONGO:
	lcall LCD_blink_language_info_k1
	lcall wait_200ms
	lcall LCD_blink_language_info_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_NIHONGO
	mov blink_KEY_default_or_not_loop_counter,#3		
	lcall LCD_NIHON_initial_state
	ret		;return to preheating state
;--------------------------------------------------------------------------------------------------------------
LCD_initial_state:
	lcall LCD_clr
	mov soak_temp_run,soak_temp_default
	mov soak_time_run,soak_time_default
	mov reflow_temp_run,reflow_temp_default
	mov reflow_time_run,reflow_time_default
	lcall LCD_setting_page1    ;Display default setting(Soak 150C,60s, NextPage key3(wait0.5s),Reflow 220,60s,NextPage key3 )
	lcall LCD_wait_display_setting
LCD_use_default_interace:
	lcall LCD_use_default		 ;Display ("Use Default?" k3 Yes k2 No k1 Esc)
	lcall wait_halfs
LCD_waiting_for_a_command:	
	;key3 use default setting,key2 use user's own setting,k1 back to initial
	jnb key.1,to_LCD_initial_state
	jnb key.2,to_LCD_user_setting
	jnb key.3,LCD_default_setting
	sjmp LCD_waiting_for_a_command
to_LCD_initial_state:
	lcall LCD_clr
	lcall LCD_blink_KEY1_Esc
	lcall wait_200ms
	lcall LCD_use_default
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_initial_state
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall LCD_clr
	Ljmp LCD_initial_interface_idle

LCD_default_setting: ;blinking "KEY3=Y" for 0.5s then jump to state preheat
	lcall LCD_clr
	lcall LCD_blink_KEY3_Y
	lcall wait_200ms
	lcall LCD_use_default
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,LCD_default_setting
	mov blink_KEY_default_or_not_loop_counter,#3
	mov soak_temp_run,soak_temp_default
	mov soak_time_run,soak_time_default
	mov reflow_temp_run,reflow_temp_default
	mov reflow_time_run,reflow_time_default
	ret		;return to cpu's initial_state using the default setting, next state is soak preheating	

to_LCD_user_setting:
	lcall LCD_clr
	lcall LCD_blink_KEY2_N
	lcall wait_200ms
	lcall LCD_use_default
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_user_setting
	mov blink_KEY_default_or_not_loop_counter,#3
LCD_user_setting:    ;Display "Select K1=Return K3=Y K2=N"
	lcall LCD_clr
	lcall LCD_user_own
LCD_wait3:
	jnb key.1,to_LCD_user_setting_return
	jnb key.2,to_saved_value_LCD
	jnb key.3,to_new_value_LCD
	sjmp LCD_wait3

to_LCD_user_setting_return:
	lcall LCD_clr
	lcall LCD_blink_user_select_key1
	lcall wait_200ms
	lcall LCD_user_own
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_user_setting_return
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall LCD_clr
	ljmp LCD_use_default_interace
to_new_value_LCD:
	lcall LCD_clr
	lcall LCD_blink_user_select_key3
	lcall wait_200ms
	lcall LCD_user_own
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_new_value_LCD
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall LCD_clr
	ljmp user_setting_change_value_soak_temp_LCD
to_saved_value_LCD:
	lcall LCD_clr
	lcall LCD_blink_user_select_key2
	lcall wait_200ms
	lcall LCD_user_own
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_saved_value_LCD
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall ReadConfig
	lcall LCD_clr
	lcall LCD_setting_page1
	lcall LCD_wait_display_setting	
	lcall LCD_clr
	lcall LCD_run_saved		;Display "Run in Saved Mod"
	lcall wait_halfs
LCD_run_saved_wait_command:	
	jnb key.3,to_preheat_use_saved_mode
	jnb key.1,to_old_new_option_page
	sjmp LCD_run_saved_wait_command
to_preheat_use_saved_mode:
	lcall LCD_clr
	lcall LCD_blink_run_saved_k3
	lcall wait_200ms
	lcall LCD_run_saved
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_preheat_use_saved_mode
	mov blink_KEY_default_or_not_loop_counter,#3	
	ret		;return to cpu's initial_state using user saved mode, next state is soak preheating
to_old_new_option_page:
	lcall LCD_clr
	lcall LCD_blink_run_saved_k1
	lcall wait_200ms
	lcall LCD_run_saved
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_old_new_option_page
	mov blink_KEY_default_or_not_loop_counter,#3	
	ljmp LCD_user_setting
;----------------------------------------------------------------------------------------------------------------
;The following code allows user to change settings
;-------------------------------------------------------------------------------------------------------------
user_setting_change_value_soak_temp_LCD:
	lcall LCD_user_setting_change_soak_temp
check_soak_temp_key_LCD:
	jnb key.1,to_user_setting_change_value_soak_time_LCD
	jnb key.2,soak_temp_sub_LCD
	jnb key.3,soak_temp_add_LCD
	sjmp check_soak_temp_key_LCD
soak_temp_sub_LCD:
	mov a,soak_temp_run
	subb a,#120
	cjne a,#0,soak_temp_sub_yes_LCD
	lcall LCD_too_low
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	sjmp user_setting_change_value_soak_temp_LCD
soak_temp_sub_yes_LCD:
	mov a, soak_temp_run
	subb a,#1
	mov soak_temp_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_soak_temp_LCD
soak_temp_add_LCD:
	mov a,soak_temp_run
	cjne a,#130,soak_temp_add_yes_LCD
	lcall LCD_too_high
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	sjmp user_setting_change_value_soak_temp_LCD
soak_temp_add_yes_LCD:
	mov a, soak_temp_run
	add a,#1
	mov soak_temp_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_soak_temp_LCD

to_user_setting_change_value_soak_time_LCD:
	lcall LCD_blink_user_setting_k1_next
	lcall wait_200ms
	lcall LCD_blink_user_setting_k1_next_2
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_user_setting_change_value_soak_time_LCD
	mov blink_KEY_default_or_not_loop_counter,#3	


user_setting_change_value_soak_time_LCD:
	lcall LCD_user_setting_change_soak_time
check_soak_time_key_LCD:
	jnb key.1,to_user_setting_change_value_reflow_temp_LCD
	jnb key.2,soak_time_sub_LCD
	jnb key.3,soak_time_add_LCD
	sjmp check_soak_time_key_LCD
soak_time_sub_LCD:
	mov a,soak_time_run
	subb a,#60
	cjne a,#0,soak_time_sub_yes_LCD
	lcall LCD_too_short
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	sjmp user_setting_change_value_soak_time_LCD
soak_time_sub_yes_LCD:
	mov a, soak_time_run
	subb a,#1
	mov soak_time_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_soak_time_LCD
soak_time_add_LCD:
	mov a,soak_time_run
	cjne a,#120,soak_time_add_yes_LCD
	lcall LCD_too_long
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	sjmp user_setting_change_value_soak_time_LCD
soak_time_add_yes_LCD:
	mov a, soak_time_run
	add a,#1
	mov soak_time_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_soak_time_LCD

to_user_setting_change_value_reflow_temp_LCD:
	lcall LCD_blink_user_setting_k1_next
	lcall wait_200ms
	lcall LCD_blink_user_setting_k1_next_2
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_user_setting_change_value_reflow_temp_LCD
	mov blink_KEY_default_or_not_loop_counter,#3	

user_setting_change_value_reflow_temp_LCD:
	lcall LCD_user_setting_change_reflow_temp
check_reflow_temp_key_LCD:
	jnb key.1,to_user_setting_change_value_reflow_time_LCD
	jnb key.2,reflow_temp_sub_LCD
	jnb key.3,reflow_temp_add_LCD
	sjmp check_reflow_temp_key_LCD
reflow_temp_sub_LCD:
	mov a,reflow_temp_run
	subb a,#200
	cjne a,#0,reflow_temp_sub_yes_LCD
	lcall LCD_too_low
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	sjmp user_setting_change_value_reflow_temp_LCD
reflow_temp_sub_yes_LCD:
	mov a, reflow_temp_run
	subb a,#1
	mov reflow_temp_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_reflow_temp_LCD
reflow_temp_add_LCD:
	mov a,reflow_temp_run
	cjne a,#220,reflow_temp_add_yes_LCD
	lcall LCD_too_high
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	sjmp user_setting_change_value_reflow_temp_LCD
reflow_temp_add_yes_LCD:
	mov a, reflow_temp_run
	add a,#1
	mov reflow_temp_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_reflow_temp_LCD


to_user_setting_change_value_reflow_time_LCD:
	lcall LCD_blink_user_setting_k1_next
	lcall wait_200ms
	lcall LCD_blink_user_setting_k1_next_2
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_user_setting_change_value_reflow_time_LCD
	mov blink_KEY_default_or_not_loop_counter,#3	


user_setting_change_value_reflow_time_LCD:
	lcall LCD_user_setting_change_reflow_time
check_reflow_time_key_LCD:
	jnb key.1,to_user_setting_save_later_LCD
	jnb key.2,reflow_time_sub_LCD
	jnb key.3,reflow_time_add_LCD
	sjmp check_reflow_time_key_LCD
reflow_time_sub_LCD:
	mov a,reflow_time_run
	subb a,#30
	cjne a,#0,reflow_time_sub_yes_LCD
	lcall LCD_too_short
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	sjmp user_setting_change_value_reflow_time_LCD
reflow_time_sub_yes_LCD:
	mov a, reflow_time_run
	subb a,#1
	mov reflow_time_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_reflow_time_LCD
reflow_time_add_LCD:
	mov a,reflow_time_run
	cjne a,#60,reflow_time_add_yes_LCD
	lcall LCD_too_long
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	sjmp user_setting_change_value_reflow_time_LCD
reflow_time_add_yes_LCD:
	mov a, reflow_time_run
	add a,#1
	mov reflow_time_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_reflow_time_LCD

to_user_setting_save_later_LCD:
	lcall LCD_blink_user_setting_k1_next
	lcall wait_200ms
	lcall LCD_blink_user_setting_k1_next_2
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_user_setting_save_later_LCD
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall LCD_save_the_setting_for_later
wait_a_command_setting_later_LCD:
	jnb key.3,to_yes_save_it_LCD
	jnb key.1,to_no_do_not_save_it_LCD
	sjmp wait_a_command_setting_later_LCD
to_yes_save_it_LCD:
	lcall LCD_blink_option_k3
	lcall wait_200ms
	lcall LCD_blink_option_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_yes_save_it_LCD
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall SaveConfig
	lcall LCD_new_setting_saved
	lcall wait_halfs
	lcall wait_halfs
	sjmp run_in_new_setting_LCD
to_no_do_not_save_it_LCD:
	lcall LCD_blink_option_k1
	lcall wait_200ms
	lcall LCD_blink_option_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_no_do_not_save_it_LCD
	mov blink_KEY_default_or_not_loop_counter,#3
run_in_new_setting_LCD:
	lcall LCD_clr
	lcall LCD_setting_page1 	
	lcall LCD_wait_display_setting
	lcall LCD_run_in_new_setting_confirm
	lcall wait_halfs
run_in_new_mode_confirm_wait_LCD:
	jnb key.3,to_yes_run_it
	jnb key.1,to_no_back_to_select_interface
	sjmp run_in_new_mode_confirm_wait_LCD

to_yes_run_it:
	lcall LCD_blink_option_k3
	lcall wait_200ms
	lcall LCD_blink_option_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_yes_run_it
	mov blink_KEY_default_or_not_loop_counter,#3	
	ret		;return to cpu's initial_state using the default setting, next state is soak preheating	

to_no_back_to_select_interface:
	lcall LCD_blink_option_k1
	lcall wait_200ms
	lcall LCD_blink_option_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_no_back_to_select_interface
	mov blink_KEY_default_or_not_loop_counter,#3
	ljmp LCD_user_setting


;-------------------------------------------------------------------------------------------------------------------------
LCD_wait_display_setting:	
	jnb key.3,LCD_cont1
	sjmp LCD_wait_display_setting
LCD_cont1:
	lcall LCD_setting_page2
	lcall wait_halfs
LCD_wait2:	
	jnb key.3,LCD_cont2
	sjmp LCD_wait2
LCD_cont2:
	ret
;-----------------------------------------------------------------------------------------------------
; Send a constant-zero-terminated string to the LCD
;-----------------------------------------------------------------------------------------------------
SendString:
    CLR A
    MOVC A, @A+DPTR
    JZ SSDone
    LCALL LCD_put
    INC DPTR
    SJMP SendString
SSDone:
    ret
;-----------------------------------------------------------------------------------------------------------------------
;Some small LCD display functions
;-----------------------------------------------------------------------------------------------------------------------

LCD_initial_interface:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #reflow_oven_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #initial_interface_MSG
	lcall SendString
	ret	
LCD_blink_initial_interface_full:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #initial_interface_MSG
	lcall SendString
	ret	
LCD_blink_initial_interface_k1:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_initial_interface_k1_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_blink_initial_interface_k3:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_initial_interface_k3_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_language_info:	
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #select_language_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #language_option_MSG
	lcall SendString
	ret	
LCD_blink_language_info_full:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #language_option_MSG
	lcall SendString
	ret	
LCD_blink_language_info_k1:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_language_option_k1_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_blink_language_info_k3:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_language_option_k3_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	


LCD_reflow_oven:
	mov a, #080H ;Line 1 starts at 080H
	lcall LCD_command
	mov dptr,#eece_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #reflow_oven_MSG
	lcall SendString
	ret
LCD_setting_page1:
	mov a, #080H
	lcall LCD_command
	mov dptr, #soak_default_MSG
	lcall SendString
	
	lcall LCD_convert_soak_temp
	mov a,soak_temp_LCD+2
	lcall LCD_put
	mov a,soak_temp_LCD+1
	lcall LCD_put
	mov a,soak_temp_LCD+0
	lcall LCD_put
	mov a,#0DFH
	lcall LCD_put
	mov a,#'C'
	lcall LCD_put	
	
	mov a,#' '
	lcall LCD_put
	lcall LCD_convert_soak_time
	mov a,soak_time_LCD+2
	cjne a,#30H,do_not_skip_digit3_LCD
	sjmp skip_digit3_LCD
do_not_skip_digit3_LCD:
	lcall LCD_put
	sjmp skip_space_LCD
skip_digit3_LCD:
	mov a,#' '
	lcall LCD_put
skip_space_LCD:
	mov a,soak_time_LCD+1
	lcall LCD_put
	mov a,soak_time_LCD+0
	lcall LCD_put
	mov a,#'s'
	lcall LCD_put	
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #next_page_MSG
	lcall SendString
	ret
LCD_setting_page2:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #reflow_default_MSG
	lcall SendString
	
	lcall LCD_convert_reflow_temp
	mov a,reflow_temp_LCD+2
	lcall LCD_put
	mov a,reflow_temp_LCD+1
	lcall LCD_put
	mov a,reflow_temp_LCD+0
	lcall LCD_put
	mov a,#0DFH
	lcall LCD_put
	mov a,#'C'
	lcall LCD_put	
	
	mov a,#' '
	lcall LCD_put
	lcall LCD_convert_reflow_time
	mov a,reflow_time_LCD+1    ;reflow time needs only 2 digits
	lcall LCD_put
	mov a,reflow_time_LCD+0
	lcall LCD_put
	mov a,#'s'
	lcall LCD_put	
	
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #next_page_MSG
	lcall SendString
	ret

;------------------------------------------------------------------------------------------------------------	

	



LCD_use_default:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #use_default_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #option_MSG
	lcall SendString
	ret	
LCD_blink_KEY1_Esc:
	mov a, #080H
	lcall LCD_command
	mov dptr, #use_default_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_KEY1_Esc_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret		
LCD_blink_KEY2_N:
	mov a, #080H
	lcall LCD_command
	mov dptr, #use_default_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_KEY2_N_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_blink_KEY3_Y:
	mov a, #080H
	lcall LCD_command
	mov dptr, #use_default_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_KEY3_Y_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret		
;---------------------------------------------------------------------------------------------------
LCD_user_own:
	mov a,#080H
	lcall LCD_command
	mov dptr, #user_select_line1_MSG
	lcall SendString
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #user_select_line2_MSG
	lcall SendString
	ret	
LCD_blink_user_select_key1:
	mov a, #080H
	lcall LCD_command
	mov dptr, #blink_user_K1_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #user_select_line2_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret		
LCD_blink_user_select_key2:
	mov a, #080H
	lcall LCD_command
	mov dptr, #user_select_line1_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr,#blink_user_K2_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_blink_user_select_key3:
	mov a, #080H
	lcall LCD_command
	mov dptr, #user_select_line1_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr,#blink_user_K3_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
;------------------------------------------------------------------------------------------------------------------------	
LCD_run_saved:
	mov a, #080H
	lcall LCD_command
	mov dptr, #use_saved_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #option_saved_MSG
	lcall SendString
	ret
LCD_blink_run_saved_k1:
	mov a, #080H
	lcall LCD_command
	mov dptr, #use_saved_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_option_saved_K1_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret
LCD_blink_run_saved_k3:
	mov a, #080H
	lcall LCD_command
	mov dptr, #use_saved_MSG
	lcall SendString
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_option_saved_K3_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
	
LCD_blink_option_full:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #option_saved_MSG
	lcall SendString
	ret
LCD_blink_option_k1:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_option_saved_K1_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	

LCD_blink_option_k3:
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #blink_option_saved_K3_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	

;-------------------------------------------------------------------------------------------------------------------------------
LCD_user_setting_change_soak_temp:
	mov a, #080H
	lcall LCD_command
	mov dptr, #soak_change_MSG
	lcall SendString
	
	mov a,#07EH
	lcall LCD_put
	lcall LCD_convert_soak_temp
	mov a,soak_temp_LCD+2
	lcall LCD_put
	mov a,soak_temp_LCD+1
	lcall LCD_put
	mov a,soak_temp_LCD+0
	lcall LCD_put
	mov a,#0DFH
	lcall LCD_put
	mov a,#'C'
	lcall LCD_put	
	
	mov a,#' '
	lcall LCD_put
	mov a,soak_time_LCD+2
	cjne a,#30H,do_not_skip_digit3_L2_LCD
	sjmp skip_digit3_L2_LCD
do_not_skip_digit3_L2_LCD:
	lcall LCD_put
	sjmp skip_space_L2_LCD
skip_digit3_L2_LCD:
	mov a,#' '
	lcall LCD_put
skip_space_L2_LCD:
	mov a,soak_time_LCD+1
	lcall LCD_put
	mov a,soak_time_LCD+0
	lcall LCD_put
	mov a,#'s'
	lcall LCD_put	

	mov a, #0C0H
	lcall LCD_command
	mov dptr, #user_setting_change_variables_MSG
	lcall SendString
	ret	

LCD_blink_user_setting_k1_next:	

	mov a, #0C0H
	lcall LCD_command
	mov dptr, #user_setting_change_variables_blink_K1_MSG
	lcall SendString
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_blink_user_setting_k1_next_2:	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #user_setting_change_variables_MSG
	lcall SendString
	ret	
LCD_user_setting_change_soak_time:
	mov a, #080H
	lcall LCD_command
	mov dptr, #soak_change_MSG
	lcall SendString
	
	mov a,#' '
	lcall LCD_put
	mov a,soak_temp_LCD+2
	lcall LCD_put
	mov a,soak_temp_LCD+1
	lcall LCD_put
	mov a,soak_temp_LCD+0
	lcall LCD_put
	mov a,#0DFH
	lcall LCD_put
	mov a,#'C'
	lcall LCD_put	
	
	mov a,#07EH
	lcall LCD_put
	lcall LCD_convert_soak_time
	mov a,soak_time_LCD+2
	cjne a,#30H,do_not_skip_digit3_L4_LCD
	sjmp skip_digit3_L4_LCD
do_not_skip_digit3_L4_LCD:
	lcall LCD_put
	sjmp skip_space_L4_LCD
skip_digit3_L4_LCD:
	mov a,#' '
	lcall LCD_put
skip_space_L4_LCD:
	mov a,soak_time_LCD+1
	lcall LCD_put
	mov a,soak_time_LCD+0
	lcall LCD_put
	mov a,#'s'
	lcall LCD_put	

	mov a, #0C0H
	lcall LCD_command
	mov dptr, #user_setting_change_variables_MSG
	lcall SendString
	ret	
LCD_user_setting_change_reflow_temp:
	mov a, #080H
	lcall LCD_command
	mov dptr, #reflow_change_MSG
	lcall SendString
	
	mov a,#07EH
	lcall LCD_put
	lcall LCD_convert_reflow_temp
	mov a,reflow_temp_LCD+2
	lcall LCD_put
	mov a,reflow_temp_LCD+1
	lcall LCD_put
	mov a,reflow_temp_LCD+0
	lcall LCD_put
	mov a,#0DFH
	lcall LCD_put
	mov a,#'C'
	lcall LCD_put	
	
	mov a,#' '
	lcall LCD_put
	mov a,reflow_time_LCD+1    ;reflow time needs only 2 digits
	lcall LCD_put
	mov a,reflow_time_LCD+0
	lcall LCD_put
	mov a,#'s'
	lcall LCD_put	
	

	mov a, #0C0H
	lcall LCD_command
	mov dptr, #user_setting_change_variables_MSG
	lcall SendString
	ret	

LCD_user_setting_change_reflow_time:
	mov a, #080H
	lcall LCD_command
	mov dptr, #reflow_default_MSG
	lcall SendString
	
	mov a,reflow_temp_LCD+2
	lcall LCD_put
	mov a,reflow_temp_LCD+1
	lcall LCD_put
	mov a,reflow_temp_LCD+0
	lcall LCD_put
	mov a,#0DFH
	lcall LCD_put
	mov a,#'C'
	lcall LCD_put	
	
	mov a,#07EH
	lcall LCD_put
	lcall LCD_convert_reflow_time
	mov a,reflow_time_LCD+1    ;reflow time needs only 2 digits
	lcall LCD_put
	mov a,reflow_time_LCD+0
	lcall LCD_put
	mov a,#'s'
	lcall LCD_put	
	
	
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #user_setting_change_variables_MSG
	lcall SendString
	ret


LCD_too_low:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #temp_too_low_MSG
	lcall SendString
	ret

LCD_too_high:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #temp_too_high_MSG
	lcall SendString
	ret

LCD_too_short:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #time_too_short_MSG
	lcall SendString
	ret

LCD_too_long:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #time_too_long_MSG
	lcall SendString
	ret

LCD_save_the_setting_for_later:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #save_the_setting_for_later_MSG
	lcall SendString
	
	mov a,#0C0H
	lcall LCD_command
	mov dptr, #option_saved_MSG
	lcall SendString
	ret

LCD_new_setting_saved:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #new_setting_saved_MSG
	lcall SendString
	ret

LCD_run_in_new_setting_confirm:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #run_in_new_setting_confirm_MSG
	lcall SendString
	
	mov a,#0C0H
	lcall LCD_command
	mov dptr, #option_saved_MSG
	lcall SendString
	ret


;---------------------------------------------------------------------------------------------------------------------------------
LCD_preheat:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #reflow_start_MSG
	lcall SendString
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #lock_door_MSG
	lcall SendString
	lcall wait_halfs
	lcall wait_halfs
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #preheat_MSG
	lcall SendString
	ret

LCD_soak:
	lcall LCD_clr
	mov a,#080H
	lcall LCD_command
	mov dptr, #soak_MSG
	lcall SendString
	ret
	
LCD_prepare_for_reflow:
	lcall LCD_clr
	mov a,#080H
	lcall LCD_command
	mov dptr, #pre_reflow_MSG
	lcall SendString
	ret

LCD_reflow:
	lcall LCD_clr
	mov a,#080H
	lcall LCD_command
	mov dptr, #reflow_MSG
	lcall SendString
	ret	
LCD_cool_down:
	lcall LCD_clr
	mov a,#080H
	lcall LCD_command
	mov dptr, #cooling_MSG
	lcall SendString
	ret
	
LCD_done:
	lcall LCD_clr
	mov a, #080H
	lcall LCD_command
	mov dptr, #reflow_end_MSG
	lcall SendString
	mov a, #0C0H
	lcall LCD_command
	mov dptr, #unlock_door_MSG
	lcall SendString
	lcall wait_halfs
	lcall wait_halfs
	lcall wait_halfs
	lcall wait_halfs
	mov a,#080H
	lcall LCD_command
	mov dptr,#finished_MSG
	lcall SendString
	ret
;---------------------------------------------------------------------------------------------
;The following code breaks a 3-digit BCD number and save each digit into a register 
;----------------------------------------------------------------------------------------------
LCD_Convert_data:
	push acc
	mov a,R0	;R0 holds the number to be converted
	mov b,#100
	div ab
	mov R2,a	;R2 holds digit 3
	mov b,#100
	mul ab
	mov R3,a

	mov a,R0
	subb a,R3
	mov R0,a
	mov b,#10
	div ab
	mov R1,a
	mov b,#10
	mul ab
	mov R3,a
	clr c
	mov a,R0
	subb a,R3
	mov R0,a
	pop acc
	ret
LCD_convert_soak_temp:
	mov R0,soak_temp_run
	lcall LCD_Convert_data
	mov a,R2
	orl a,#30H
	mov soak_temp_LCD+2,a
	mov a,R1
	orl a,#30H
	mov soak_temp_LCD+1,a
	mov a,R0
	orl a,#30H
	mov soak_temp_LCD+0,a
	ret
LCD_convert_soak_time:
	mov R0,soak_time_run
	lcall LCD_Convert_data
	mov a,R2
	orl a,#30H
	mov soak_time_LCD+2,a
	mov a,R1
	orl a,#30H
	mov soak_time_LCD+1,a
	mov a,R0
	orl a,#30H
	mov soak_time_LCD+0,a
	ret
LCD_convert_reflow_temp:
	mov R0,reflow_temp_run
	lcall LCD_Convert_data
	mov a,R2
	orl a,#30H
	mov reflow_temp_LCD+2,a
	mov a,R1
	orl a,#30H
	mov reflow_temp_LCD+1,a
	mov a,R0
	orl a,#30H
	mov reflow_temp_LCD+0,a
	ret

LCD_convert_reflow_time:
	mov R0,reflow_time_run
	lcall LCD_Convert_data
	mov a,R2
	orl a,#30H
	mov reflow_time_LCD+2,a
	mov a,R1
	orl a,#30H
	mov reflow_time_LCD+1,a
	mov a,R0
	orl a,#30H
	mov reflow_time_LCD+0,a
	ret
;------------------------------------------------------------------------------------------------
;The following code is given. It is used to display something on LCD
;-----------------------------------------------------------------------------------------------
LCD_command:
	mov	LCD_DATA, A
	clr	LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us

LCD_put:
	mov	LCD_DATA, A
	setb LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us
    
LCD_clr:
    setb LCD_ON
    clr LCD_EN  ; Default state of enable must be zero
    lcall Wait40us
    
    mov LCD_MOD, #0xff ; Use LCD_DATA as output port
    clr LCD_RW ;  Only writing to the LCD in this code.
	
	mov a, #0ch ; Display on command
	lcall LCD_command
	mov a, #38H ; 8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
	mov a, #01H ; Clear screen (Warning, very slow command!)
	lcall LCD_command
    
    ; Delay loop needed for 'clear screen' command above (1.6ms at least!)
    mov R1, #40
Clr_loop:
	lcall Wait40us
	djnz R1, Clr_loop
	ret
;------------------------------------------------------------------------------------------------------------------------
Wait40us:
	mov R0, #149
X1: 
	nop
	nop
	nop
	nop
	nop
	nop
	djnz R0, X1 ; 9 machine cycles-> 9*30ns*149=40us
    ret	

;-----------------------------------------------------------------------------------
;The following code is given by Dr.Jesus. It is used to save variables to flash memory.
;----------------------------------------------------------------------------------
Read_Flash:
	mov FLASH_MOD, #0x00 ; Set data port for input
	mov FLASH_ADD0, dpl
	mov FLASH_ADD1, dph
	mov FLASH_ADD2, #FLASHSECTOR
	mov FLASH_CMD, #0111B ; FL_CE_N=0, FL_OE_N=1
	mov FLASH_CMD, #0011B ; FL_CE_N=0, FL_OE_N=0
	nop
	mov a, FLASH_DATA
	nop
	mov FLASH_CMD, #0111B ; FL_CE_N=0, FL_OE_N=1
	mov FLASH_CMD, #1111B ; FL_CE_N=1, FL_OE_N=1
	ret
	
; To write a byte to flash memory, put the address in dptr
; and the byte to write in acc.
Write_Flash:
	mov FLASH_MOD, #0ffh ; Set data port for output
	mov FLASH_ADD0, dpl
	mov FLASH_ADD1, dph
	mov FLASH_ADD2, #FLASHSECTOR
	mov FLASH_DATA, a
	mov FLASH_CMD, #0111B ; FL_CE_N=0, FL_WE_N=1
	mov FLASH_CMD, #0101B ; FL_CE_N=0, FL_WE_N=0
	mov FLASH_CMD, #0111B ; FL_CE_N=0, FL_WE_N=1
	mov FLASH_CMD, #1111B ; FL_CE_N=1, FL_WE_N=1
	ret
Write_Constant_Flash mac
	mov dptr, #%0
	mov a, #%1
	lcall Write_Flash
Endmac
EraseSector:
	Write_Constant_Flash( 0x0AAA, 0xAA )
	Write_Constant_Flash( 0x0555, 0x55 )
	Write_Constant_Flash( 0x0AAA, 0x80 )
	Write_Constant_Flash( 0x0AAA, 0xAA )
	Write_Constant_Flash( 0x0555, 0x55 )
	Write_Constant_Flash( 0x0000, 0x30 )
; Check using DQ7 Data# polling when the erasing is done
EraseSector_L0:
	mov dptr, #0
	lcall Read_Flash
	cpl a
	jnz EraseSector_L0
	ret
Flash_Byte:
	push dph
	push dpl
	push acc
	Write_Constant_Flash( 0x0AAA, 0xAA )
	Write_Constant_Flash( 0x0555, 0x55 )
	Write_Constant_Flash( 0x0AAA, 0xA0 )
	pop acc
	pop dpl
	pop dph
	mov r0, a ; Used later when checking...
	lcall Write_Flash
;Check using DQ7 Data# polling when operation is done
Flash_Byte_L0:
	lcall Read_Flash
	clr c
	subb a, r0
	jnz Flash_Byte_L0
	ret	

SaveConfig:
	lcall EraseSector ; We need to erase whole sector 
	mov dptr, #0
	mov a, soak_temp_run
	lcall Flash_Byte
	inc dptr
	mov a, soak_time_run
	lcall Flash_Byte
	inc dptr
	mov a, reflow_temp_run
	lcall Flash_Byte
	inc dptr
	mov a, reflow_time_run
	lcall Flash_Byte
	inc dptr
	mov a, #055H
	lcall Flash_Byte
	inc dptr
	mov a, #0aaH
	lcall Flash_Byte
	ret

ReadConfig:
	mov dptr, #5
	lcall Read_Flash
	cjne a, #0aah, done_ReadConfig
	dec dpl
	lcall Read_Flash
	cjne a, #055h, done_ReadConfig
	dec dpl
	lcall Read_Flash
	mov reflow_time_run, a
	dec dpl
	lcall Read_Flash
	mov reflow_temp_run, a
	dec dpl
	lcall Read_Flash
	mov soak_time_run, a
	dec dpl
	lcall Read_Flash
	mov soak_temp_run, a
done_ReadConfig:
	ret

























$LIST