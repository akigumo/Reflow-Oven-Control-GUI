$NOLIST
;--------------------------------------------------------------------------------------------------
; 
;LCD_controller for reflow oven, JAPN ver.
;--------------------------------------------------------------------------------------------------

LCD_JAPN_initial_state:
	lcall LCD_JAPN_clr
	mov soak_temp_run,soak_temp_default
	mov soak_time_run,soak_time_default
	mov reflow_temp_run,reflow_temp_default
	mov reflow_time_run,reflow_time_default
	lcall LCD_JAPN_setting_page1    ;Display default setting(Soak 150C,60s, NextPage key3(wait0.5s),Reflow 220,60s,NextPage key3 )
	lcall LCD_JAPN_wait_display_setting
LCD_JAPN_use_default_interace:
	lcall LCD_JAPN_use_default		 ;Display ("Use Default?" k3 Yes k2 No k1 Esc)
	lcall wait_halfs
LCD_JAPN_waiting_for_a_command:	
	;key3 use default setting,key2 use user's own setting,k1 back to initial
	jnb key.1,to_LCD_JAPN_initial_state
	jnb key.2,to_LCD_JAPN_user_setting
	jnb key.3,LCD_JAPN_default_setting
	sjmp LCD_JAPN_waiting_for_a_command
to_LCD_JAPN_initial_state:
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_blink_KEY1_Esc
	lcall wait_200ms
	lcall LCD_JAPN_use_default
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_JAPN_initial_state
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall LCD_JAPN_clr
	ljmp LCD_initial_interface_idle

LCD_JAPN_default_setting: ;blinking "KEY3=Y" for 0.5s then jump to state preheat
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_blink_KEY3_Y
	lcall wait_200ms
	lcall LCD_JAPN_use_default
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,LCD_JAPN_default_setting
	mov blink_KEY_default_or_not_loop_counter,#3
	mov soak_temp_run,soak_temp_default
	mov soak_time_run,soak_time_default
	mov reflow_temp_run,reflow_temp_default
	mov reflow_time_run,reflow_time_default
	ret		;return to cpu's initial_state using the default setting, next state is soak preheating	

to_LCD_JAPN_user_setting:
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_blink_KEY2_N
	lcall wait_200ms
	lcall LCD_JAPN_use_default
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_JAPN_user_setting
	mov blink_KEY_default_or_not_loop_counter,#3
LCD_JAPN_user_setting:    ;Display "Select K1=Return K3=Y K2=N"
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_user_own
LCD_JAPN_wait3:
	jnb key.1,to_LCD_JAPN_user_setting_return
	jnb key.2,to_saved_value_LCD_JAPN
	jnb key.3,to_new_value_LCD_JAPN
	sjmp LCD_JAPN_wait3

to_LCD_JAPN_user_setting_return:
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_blink_user_select_key1
	lcall wait_200ms
	lcall LCD_JAPN_user_own
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_LCD_JAPN_user_setting_return
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall LCD_JAPN_clr
	ljmp LCD_JAPN_use_default_interace
to_new_value_LCD_JAPN:
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_blink_user_select_key3
	lcall wait_200ms
	lcall LCD_JAPN_user_own
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_new_value_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall LCD_JAPN_clr
	ljmp user_setting_change_value_soak_temp_LCD_JAPN
to_saved_value_LCD_JAPN:
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_blink_user_select_key2
	lcall wait_200ms
	lcall LCD_JAPN_user_own
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_saved_value_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall ReadConfig
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_setting_page1
	lcall LCD_JAPN_wait_display_setting	
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_run_saved		;Display "Run in Saved Mod"
	lcall wait_halfs
LCD_JAPN_run_saved_wait_command:	
	jnb key.3,to_preheat_use_saved_mode_LCD_JAPN
	jnb key.1,to_old_new_option_page_LCD_JAPN
	sjmp LCD_JAPN_run_saved_wait_command
to_preheat_use_saved_mode_LCD_JAPN:
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_blink_run_saved_k3
	lcall wait_200ms
	lcall LCD_JAPN_run_saved
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_preheat_use_saved_mode_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3	
	ret		;return to cpu's initial_state using user saved mode, next state is soak preheating
to_old_new_option_page_LCD_JAPN:
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_blink_run_saved_k1
	lcall wait_200ms
	lcall LCD_JAPN_run_saved
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_old_new_option_page_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3	
	ljmp LCD_JAPN_user_setting
;----------------------------------------------------------------------------------------------------------------
;The following code allows user to change settings
;-------------------------------------------------------------------------------------------------------------
user_setting_change_value_soak_temp_LCD_JAPN:
	lcall LCD_JAPN_user_setting_change_soak_temp
check_soak_temp_key_LCD_JAPN:
	jnb key.1,to_user_setting_change_value_soak_time_LCD_JAPN_JAPN
	jnb key.2,soak_temp_sub_LCD_JAPN
	jnb key.3,soak_temp_add_LCD_JAPN
	sjmp check_soak_temp_key_LCD_JAPN
soak_temp_sub_LCD_JAPN:
	mov a,soak_temp_run
	subb a,#110
	cjne a,#0,soak_temp_sub_yes_LCD_JAPN
	lcall LCD_JAPN_too_low
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	sjmp user_setting_change_value_soak_temp_LCD_JAPN
soak_temp_sub_yes_LCD_JAPN:
	mov a, soak_temp_run
	subb a,#1
	mov soak_temp_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_soak_temp_LCD_JAPN
soak_temp_add_LCD_JAPN:
	mov a,soak_temp_run
	cjne a,#130,soak_temp_add_yes_LCD_JAPN
	lcall LCD_JAPN_too_high
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	sjmp user_setting_change_value_soak_temp_LCD_JAPN
soak_temp_add_yes_LCD_JAPN:
	mov a, soak_temp_run
	add a,#1
	mov soak_temp_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_soak_temp_LCD_JAPN

to_user_setting_change_value_soak_time_LCD_JAPN_JAPN:
	lcall LCD_JAPN_blink_user_setting_k1_next
	lcall wait_200ms
	lcall LCD_JAPN_blink_user_setting_k1_next_2
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_user_setting_change_value_soak_time_LCD_JAPN_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3	


user_setting_change_value_soak_time_LCD_JAPN:
	lcall LCD_JAPN_user_setting_change_soak_time
check_soak_time_key_LCD_JAPN:
	jnb key.1,to_user_setting_change_value_reflow_temp_LCD_JAPN_JAPN
	jnb key.2,soak_time_sub_LCD_JAPN
	jnb key.3,soak_time_add_LCD_JAPN
	sjmp check_soak_time_key_LCD_JAPN
soak_time_sub_LCD_JAPN:
	mov a,soak_time_run
	subb a,#60
	cjne a,#0,soak_time_sub_yes_LCD_JAPN
	lcall LCD_JAPN_too_short
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	sjmp user_setting_change_value_soak_time_LCD_JAPN
soak_time_sub_yes_LCD_JAPN:
	mov a, soak_time_run
	subb a,#1
	mov soak_time_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_soak_time_LCD_JAPN
soak_time_add_LCD_JAPN:
	mov a,soak_time_run
	cjne a,#120,soak_time_add_yes_LCD_JAPN
	lcall LCD_JAPN_too_long
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	sjmp user_setting_change_value_soak_time_LCD_JAPN
soak_time_add_yes_LCD_JAPN:
	mov a, soak_time_run
	add a,#1
	mov soak_time_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_soak_time_LCD_JAPN

to_user_setting_change_value_reflow_temp_LCD_JAPN_JAPN:
	lcall LCD_JAPN_blink_user_setting_k1_next
	lcall wait_200ms
	lcall LCD_JAPN_blink_user_setting_k1_next_2
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_user_setting_change_value_reflow_temp_LCD_JAPN_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3	

user_setting_change_value_reflow_temp_LCD_JAPN:
	lcall LCD_JAPN_user_setting_change_reflow_temp
check_reflow_temp_key_LCD_JAPN:
	jnb key.1,to_user_setting_change_value_reflow_time_LCD_JAPN_JAPN
	jnb key.2,reflow_temp_sub_LCD_JAPN
	jnb key.3,reflow_temp_add_LCD_JAPN
	sjmp check_reflow_temp_key_LCD_JAPN
reflow_temp_sub_LCD_JAPN:
	mov a,reflow_temp_run
	subb a,#200
	cjne a,#0,reflow_temp_sub_yes_LCD_JAPN
	lcall LCD_JAPN_too_low
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	sjmp user_setting_change_value_reflow_temp_LCD_JAPN
reflow_temp_sub_yes_LCD_JAPN:
	mov a, reflow_temp_run
	subb a,#1
	mov reflow_temp_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_reflow_temp_LCD_JAPN
reflow_temp_add_LCD_JAPN:
	mov a,reflow_temp_run
	cjne a,#220,reflow_temp_add_yes_LCD_JAPN
	lcall LCD_JAPN_too_high
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	sjmp user_setting_change_value_reflow_temp_LCD_JAPN
reflow_temp_add_yes_LCD_JAPN:
	mov a, reflow_temp_run
	add a,#1
	mov reflow_temp_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_reflow_temp_LCD_JAPN


to_user_setting_change_value_reflow_time_LCD_JAPN_JAPN:
	lcall LCD_JAPN_blink_user_setting_k1_next
	lcall wait_200ms
	lcall LCD_JAPN_blink_user_setting_k1_next_2
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_user_setting_change_value_reflow_time_LCD_JAPN_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3	


user_setting_change_value_reflow_time_LCD_JAPN:
	lcall LCD_JAPN_user_setting_change_reflow_time
check_reflow_time_key_LCD_JAPN:
	jnb key.1,to_user_setting_save_later_LCD_JAPN
	jnb key.2,reflow_time_sub_LCD_JAPN
	jnb key.3,reflow_time_add_LCD_JAPN
	sjmp check_reflow_time_key_LCD_JAPN
reflow_time_sub_LCD_JAPN:
	mov a,reflow_time_run
	subb a,#30
	cjne a,#0,reflow_time_sub_yes_LCD_JAPN
	lcall LCD_JAPN_too_short
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	sjmp user_setting_change_value_reflow_time_LCD_JAPN
reflow_time_sub_yes_LCD_JAPN:
	mov a, reflow_time_run
	subb a,#1
	mov reflow_time_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_reflow_time_LCD_JAPN
reflow_time_add_LCD_JAPN:
	mov a,reflow_time_run
	cjne a,#60,reflow_time_add_yes_LCD_JAPN
	lcall LCD_JAPN_too_long
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	sjmp user_setting_change_value_reflow_time_LCD_JAPN
reflow_time_add_yes_LCD_JAPN:
	mov a, reflow_time_run
	add a,#1
	mov reflow_time_run,a
	lcall wait_200ms
	lcall wait_200ms
	sjmp user_setting_change_value_reflow_time_LCD_JAPN

to_user_setting_save_later_LCD_JAPN:
	lcall LCD_JAPN_blink_user_setting_k1_next
	lcall wait_200ms
	lcall LCD_JAPN_blink_user_setting_k1_next_2
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_user_setting_save_later_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall LCD_JAPN_save_the_setting_for_later
wait_a_command_setting_later_LCD_JAPN:
	jnb key.3,to_yes_save_it_LCD_JAPN
	jnb key.1,to_no_do_not_save_it_LCD_JAPN
	sjmp wait_a_command_setting_later_LCD_JAPN
to_yes_save_it_LCD_JAPN:
	lcall LCD_JAPN_blink_option_k3
	lcall wait_200ms
	lcall LCD_JAPN_blink_option_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_yes_save_it_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3
	lcall SaveConfig
	lcall LCD_JAPN_new_setting_saved
	lcall wait_halfs
	lcall wait_halfs
	sjmp run_in_new_setting_LCD_JAPN
to_no_do_not_save_it_LCD_JAPN:
	lcall LCD_JAPN_blink_option_k1
	lcall wait_200ms
	lcall LCD_JAPN_blink_option_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_no_do_not_save_it_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3
run_in_new_setting_LCD_JAPN:
	lcall LCD_JAPN_clr
	lcall LCD_JAPN_setting_page1 	
	lcall LCD_JAPN_wait_display_setting
	lcall LCD_JAPN_run_in_new_setting_confirm
	lcall wait_halfs
run_in_new_mode_confirm_wait_LCD_JAPN:
	jnb key.3,to_yes_run_it_LCD_JAPN
	jnb key.1,to_no_back_to_select_interface_LCD_JAPN
	sjmp run_in_new_mode_confirm_wait_LCD_JAPN

to_yes_run_it_LCD_JAPN:
	lcall LCD_JAPN_blink_option_k3
	lcall wait_200ms
	lcall LCD_JAPN_blink_option_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_yes_run_it_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3	
	ret		;return to cpu's initial_state using the default setting, next state is soak preheating	

to_no_back_to_select_interface_LCD_JAPN:
	lcall LCD_JAPN_blink_option_k1
	lcall wait_200ms
	lcall LCD_JAPN_blink_option_full
	lcall wait_200ms
	mov a,blink_KEY_default_or_not_loop_counter
	cjne a,#0,to_no_back_to_select_interface_LCD_JAPN
	mov blink_KEY_default_or_not_loop_counter,#3
	ljmp LCD_JAPN_user_setting


;-------------------------------------------------------------------------------------------------------------------------
LCD_JAPN_wait_display_setting:	
	jnb key.3,LCD_JAPN_cont1
	sjmp LCD_JAPN_wait_display_setting
LCD_JAPN_cont1:
	lcall LCD_JAPN_setting_page2
	lcall wait_halfs
LCD_JAPN_wait2:	
	jnb key.3,LCD_JAPN_cont2
	sjmp LCD_JAPN_wait2
LCD_JAPN_cont2:
	ret
;-----------------------------------------------------------------------------------------------------
; Send a constant-zero-terminated string to the LCD_JAPN
;-----------------------------------------------------------------------------------------------------
SendString_LCD_JAPN:
    CLR A
    MOVC A, @A+DPTR
    JZ SSDone_LCD_JAPN
    LCALL LCD_JAPN_put
    INC DPTR
    SJMP SendString_LCD_JAPN
SSDone_LCD_JAPN:
    ret
;-----------------------------------------------------------------------------------------------------------------------
;Some small LCD_JAPN display functions
;-----------------------------------------------------------------------------------------------------------------------
LCD_JAPN_reflow_oven:
	mov a, #080H ;Line 1 starts at 080H
	lcall LCD_JAPN_command
	mov dptr,#eece_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #reflow_oven_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret
LCD_JAPN_setting_page1:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #soak_default_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	lcall LCD_JAPN_convert_soak_temp
	mov a,soak_temp_LCD+2
	lcall LCD_JAPN_put
	mov a,soak_temp_LCD+1
	lcall LCD_JAPN_put
	mov a,soak_temp_LCD+0
	lcall LCD_JAPN_put
	mov a,#0DFH
	lcall LCD_JAPN_put
	mov a,#'C'
	lcall LCD_JAPN_put	
	
	mov a,#' '
	lcall LCD_JAPN_put
	lcall LCD_JAPN_convert_soak_time
	mov a,soak_time_LCD+2
	cjne a,#30H,do_not_skip_digit3_LCD_JAPN
	sjmp skip_digit3_LCD_JAPN
do_not_skip_digit3_LCD_JAPN:
	lcall LCD_JAPN_put
	sjmp skip_space_LCD_JAPN
skip_digit3_LCD_JAPN:
	mov a,#' '
	lcall LCD_JAPN_put
skip_space_LCD_JAPN:
	mov a,soak_time_LCD+1
	lcall LCD_JAPN_put
	mov a,soak_time_LCD+0
	lcall LCD_JAPN_put
	mov a,#'s'
	lcall LCD_JAPN_put	
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #next_page_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret
LCD_JAPN_setting_page2:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #reflow_default_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	lcall LCD_JAPN_convert_reflow_temp
	mov a,reflow_temp_LCD+2
	lcall LCD_JAPN_put
	mov a,reflow_temp_LCD+1
	lcall LCD_JAPN_put
	mov a,reflow_temp_LCD+0
	lcall LCD_JAPN_put
	mov a,#0DFH
	lcall LCD_JAPN_put
	mov a,#'C'
	lcall LCD_JAPN_put	
	
	mov a,#' '
	lcall LCD_JAPN_put
	lcall LCD_JAPN_convert_reflow_time
	mov a,reflow_time_LCD+1    ;reflow time needs only 2 digits
	lcall LCD_JAPN_put
	mov a,reflow_time_LCD+0
	lcall LCD_JAPN_put
	mov a,#'s'
	lcall LCD_JAPN_put	
	
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #next_page_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

;------------------------------------------------------------------------------------------------------------	
LCD_JAPN_use_default:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #use_default_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #option_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret	
LCD_JAPN_blink_KEY1_Esc:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #use_default_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #blink_KEY1_Esc_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret		
LCD_JAPN_blink_KEY2_N:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #use_default_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #blink_KEY2_N_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_JAPN_blink_KEY3_Y:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #use_default_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #blink_KEY3_Y_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret		
;---------------------------------------------------------------------------------------------------
LCD_JAPN_user_own:
	mov a,#080H
	lcall LCD_JAPN_command
	mov dptr, #user_select_line1_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #user_select_line2_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret	
LCD_JAPN_blink_user_select_key1:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #blink_user_K1_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #user_select_line2_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret		
LCD_JAPN_blink_user_select_key2:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #user_select_line1_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr,#blink_user_K2_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_JAPN_blink_user_select_key3:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #user_select_line1_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr,#blink_user_K3_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
;------------------------------------------------------------------------------------------------------------------------	
LCD_JAPN_run_saved:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #use_saved_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #option_saved_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret
LCD_JAPN_blink_run_saved_k1:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #use_saved_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #blink_option_saved_K1_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret
LCD_JAPN_blink_run_saved_k3:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #use_saved_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #blink_option_saved_K3_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
	
LCD_JAPN_blink_option_full:
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #option_saved_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret
LCD_JAPN_blink_option_k1:
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #blink_option_saved_K1_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	

LCD_JAPN_blink_option_k3:
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #blink_option_saved_K3_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	

;-------------------------------------------------------------------------------------------------------------------------------
LCD_JAPN_user_setting_change_soak_temp:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #soak_change_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a,#07EH
	lcall LCD_JAPN_put
	lcall LCD_JAPN_convert_soak_temp
	mov a,soak_temp_LCD+2
	lcall LCD_JAPN_put
	mov a,soak_temp_LCD+1
	lcall LCD_JAPN_put
	mov a,soak_temp_LCD+0
	lcall LCD_JAPN_put
	mov a,#0DFH
	lcall LCD_JAPN_put
	mov a,#'C'
	lcall LCD_JAPN_put	
	
	mov a,#' '
	lcall LCD_JAPN_put
	mov a,soak_time_LCD+2
	cjne a,#30H,do_not_skip_digit3_L2_LCD_JAPN
	sjmp skip_digit3_L2_LCD_JAPN
do_not_skip_digit3_L2_LCD_JAPN:
	lcall LCD_JAPN_put
	sjmp skip_space_L2_LCD_JAPN
skip_digit3_L2_LCD_JAPN:
	mov a,#' '
	lcall LCD_JAPN_put
skip_space_L2_LCD_JAPN:
	mov a,soak_time_LCD+1
	lcall LCD_JAPN_put
	mov a,soak_time_LCD+0
	lcall LCD_JAPN_put
	mov a,#'s'
	lcall LCD_JAPN_put	

	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #user_setting_change_variables_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret	

LCD_JAPN_blink_user_setting_k1_next:	

	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #user_setting_change_variables_blink_K1_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a,blink_KEY_default_or_not_loop_counter
	dec a
	mov blink_KEY_default_or_not_loop_counter,a
	ret	
LCD_JAPN_blink_user_setting_k1_next_2:	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #user_setting_change_variables_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret	
LCD_JAPN_user_setting_change_soak_time:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #soak_change_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a,#' '
	lcall LCD_JAPN_put
	mov a,soak_temp_LCD+2
	lcall LCD_JAPN_put
	mov a,soak_temp_LCD+1
	lcall LCD_JAPN_put
	mov a,soak_temp_LCD+0
	lcall LCD_JAPN_put
	mov a,#0DFH
	lcall LCD_JAPN_put
	mov a,#'C'
	lcall LCD_JAPN_put	
	
	mov a,#07EH
	lcall LCD_JAPN_put
	lcall LCD_JAPN_convert_soak_time
	mov a,soak_time_LCD+2
	cjne a,#30H,do_not_skip_digit3_L4_LCD_JAPN
	sjmp skip_digit3_L4_LCD_JAPN
do_not_skip_digit3_L4_LCD_JAPN:
	lcall LCD_JAPN_put
	sjmp skip_space_L4_LCD_JAPN
skip_digit3_L4_LCD_JAPN:
	mov a,#' '
	lcall LCD_JAPN_put
skip_space_L4_LCD_JAPN:
	mov a,soak_time_LCD+1
	lcall LCD_JAPN_put
	mov a,soak_time_LCD+0
	lcall LCD_JAPN_put
	mov a,#'s'
	lcall LCD_JAPN_put	

	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #user_setting_change_variables_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret	
LCD_JAPN_user_setting_change_reflow_temp:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #reflow_change_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a,#07EH
	lcall LCD_JAPN_put
	lcall LCD_JAPN_convert_reflow_temp
	mov a,reflow_temp_LCD+2
	lcall LCD_JAPN_put
	mov a,reflow_temp_LCD+1
	lcall LCD_JAPN_put
	mov a,reflow_temp_LCD+0
	lcall LCD_JAPN_put
	mov a,#0DFH
	lcall LCD_JAPN_put
	mov a,#'C'
	lcall LCD_JAPN_put	
	
	mov a,#' '
	lcall LCD_JAPN_put
	mov a,reflow_time_LCD+1    ;reflow time needs only 2 digits
	lcall LCD_JAPN_put
	mov a,reflow_time_LCD+0
	lcall LCD_JAPN_put
	mov a,#'s'
	lcall LCD_JAPN_put	
	

	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #user_setting_change_variables_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret	

LCD_JAPN_user_setting_change_reflow_time:
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #reflow_change_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a,#' '
	lcall LCD_JAPN_put	
	mov a,reflow_temp_LCD+2
	lcall LCD_JAPN_put
	mov a,reflow_temp_LCD+1
	lcall LCD_JAPN_put
	mov a,reflow_temp_LCD+0
	lcall LCD_JAPN_put
	mov a,#0DFH
	lcall LCD_JAPN_put
	mov a,#'C'
	lcall LCD_JAPN_put	
	
	mov a,#07EH
	lcall LCD_JAPN_put
	lcall LCD_JAPN_convert_reflow_time
	mov a,reflow_time_LCD+1    ;reflow time needs only 2 digits
	lcall LCD_JAPN_put
	mov a,reflow_time_LCD+0
	lcall LCD_JAPN_put
	mov a,#'s'
	lcall LCD_JAPN_put	
	
	
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #user_setting_change_variables_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret


LCD_JAPN_too_low:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #temp_too_low_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

LCD_JAPN_too_high:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #temp_too_high_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

LCD_JAPN_too_short:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #time_too_short_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

LCD_JAPN_too_long:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #time_too_long_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

LCD_JAPN_save_the_setting_for_later:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #save_the_setting_for_later_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a,#0C0H
	lcall LCD_JAPN_command
	mov dptr, #option_saved_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

LCD_JAPN_new_setting_saved:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #new_setting_saved_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

LCD_JAPN_run_in_new_setting_confirm:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #run_in_new_setting_confirm_MSG_JAPN
	lcall SendString_LCD_JAPN
	
	mov a,#0C0H
	lcall LCD_JAPN_command
	mov dptr, #option_saved_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret


;---------------------------------------------------------------------------------------------------------------------------------
LCD_JAPN_preheat:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #reflow_start_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #lock_door_MSG_JAPN
	lcall SendString_LCD_JAPN
	lcall wait_halfs
	lcall wait_halfs
	lcall wait_halfs
	lcall wait_halfs
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #preheat_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

LCD_JAPN_soak:
	lcall LCD_JAPN_clr
	mov a,#080H
	lcall LCD_JAPN_command
	mov dptr, #soak_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret
	
LCD_JAPN_prepare_for_reflow:
	lcall LCD_JAPN_clr
	mov a,#080H
	lcall LCD_JAPN_command
	mov dptr, #pre_reflow_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret

LCD_JAPN_reflow:
	lcall LCD_JAPN_clr
	mov a,#080H
	lcall LCD_JAPN_command
	mov dptr, #reflow_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret	
LCD_JAPN_cool_down:
	lcall LCD_JAPN_clr
	mov a,#080H
	lcall LCD_JAPN_command
	mov dptr, #cooling_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret
	
LCD_JAPN_done:
	lcall LCD_JAPN_clr
	mov a, #080H
	lcall LCD_JAPN_command
	mov dptr, #reflow_end_MSG_JAPN
	lcall SendString_LCD_JAPN
	mov a, #0C0H
	lcall LCD_JAPN_command
	mov dptr, #unlock_door_MSG_JAPN
	lcall SendString_LCD_JAPN
	lcall wait_halfs
	lcall wait_halfs
	lcall wait_halfs
	lcall wait_halfs
	mov a,#080H
	lcall LCD_JAPN_command
	mov dptr,#finished_MSG_JAPN
	lcall SendString_LCD_JAPN
	ret
;---------------------------------------------------------------------------------------------
;The following code breaks a 3-digit BCD number and save each digit into a register 
;----------------------------------------------------------------------------------------------
LCD_JAPN_Convert_data:
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
LCD_JAPN_convert_soak_temp:
	mov R0,soak_temp_run
	lcall LCD_JAPN_Convert_data
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
LCD_JAPN_convert_soak_time:
	mov R0,soak_time_run
	lcall LCD_JAPN_Convert_data
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
LCD_JAPN_convert_reflow_temp:
	mov R0,reflow_temp_run
	lcall LCD_JAPN_Convert_data
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

LCD_JAPN_convert_reflow_time:
	mov R0,reflow_time_run
	lcall LCD_JAPN_Convert_data
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
;The following code is given. It is used to display something on LCD_JAPN
;-----------------------------------------------------------------------------------------------
LCD_JAPN_command:
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
	ljmp Wait40uS_LCD_JAPN

LCD_JAPN_put:
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
	ljmp Wait40uS_LCD_JAPN
    
LCD_JAPN_clr:
    setb LCD_ON
    clr LCD_EN  ; Default state of enable must be zero
    lcall Wait40uS_LCD_JAPN
    
    mov LCD_MOD, #0xff ; Use LCD_JAPN_DATA as output port
    clr LCD_RW ;  Only writing to the LCD_JAPN in this code.
	
	mov a, #0ch ; Display on command
	lcall LCD_JAPN_command
	mov a, #38H ; 8-bits interface, 2 lines, 5x7 characters
	lcall LCD_JAPN_command
	mov a, #01H ; Clear screen (Warning, very slow command!)
	lcall LCD_JAPN_command
    
    ; Delay loop needed for 'clear screen' command above (1.6ms at least!)
    mov R1, #40
Clr_loop_LCD_JAPN:
	lcall Wait40uS_LCD_JAPN
	djnz R1, Clr_loop_LCD_JAPN
	ret
;------------------------------------------------------------------------------------------------------------------------
Wait40uS_LCD_JAPN:
	mov R0, #149
X1_LCD_JAPN: 
	nop
	nop
	nop
	nop
	nop
	nop
	djnz R0, X1_LCD_JAPN ; 9 machine cycles-> 9*30ns*149=40us
    ret	
$LIST
