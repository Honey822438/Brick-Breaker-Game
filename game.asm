    .MODEL SMALL
    .STACK 100H

    .DATA
        ; Title text and its length
        title_str DB 'B','R','I','C','K',' ','B','R','E','A','K','E','R'
        title_len EQU $ - title_str
        
        ; Individual vibrant colors for each letter of the title
        title_col DB 0Ch, 0Eh, 0Ah, 0Bh, 09h, 00h, 0Dh, 0Ch, 0Eh, 0Ah, 0Bh, 09h, 0Dh
        
        ; Prompt text and its length
        prompt_str DB 'Press ENTER to start...'
        prompt_len EQU $ - prompt_str
        prompt_col DB 0Fh ; White text
        
        ; Name Entry Screen Data
        name_msg_str DB 'Let us know your name who want to break the brick'
        name_msg_len EQU $ - name_msg_str
        
        player_lbl_str DB 'Player Name : '
        player_lbl_len EQU $ - player_lbl_str
        
        continue_msg_str DB 'Press ENTER to continue...'
        continue_msg_len EQU $ - continue_msg_str
        
        playerName DB 'Default', 8 DUP(' ') ; Buffer for 15 characters maximum
        nameLen DW 7                        ; Initial length of the word "Default"

        ; Main Menu Data
        menu_title_str DB 'M','A','I','N',' ','M','E','N','U'
        menu_title_len EQU $ - menu_title_str
        menu_title_col DB 0Ch, 0Eh, 0Ah, 0Bh, 09h, 0Dh, 0Ch, 0Eh, 0Ah

        opt1_str DB '      Start      '
        opt1_len EQU $ - opt1_str
        opt2_str DB '  Instructions   '
        opt2_len EQU $ - opt2_str
        opt3_str DB '   High Scores   '
        opt3_len EQU $ - opt3_str
        opt4_str DB '       Exit      '
        opt4_len EQU $ - opt4_str
        
        menu_sel DB 0 ; 0 to 3 for current menu selection

        lvl_sel_title_str DB 'S','E','L','E','C','T',' ','L','E','V','E','L'
        lvl_sel_title_len EQU $ - lvl_sel_title_str
        lvl_sel_title_col DB 0Ch, 0Eh, 0Ah, 0Bh, 09h, 00h, 0Dh, 0Ch, 0Eh, 0Ah, 0Bh, 09h
        
        lvl_opt1_str DB '     Level 1     '
        lvl_opt1_len EQU $ - lvl_opt1_str
        lvl_opt2_str DB '     Level 2     '
        lvl_opt2_len EQU $ - lvl_opt2_str
        lvl_opt3_str DB '     Level 3     '
        lvl_opt3_len EQU $ - lvl_opt3_str
        lvl_opt4_str DB '     Level 4     '
        lvl_opt4_len EQU $ - lvl_opt4_str
        
        lvl_sel DB 0 ; 0 to 3 for level selection

        welcome_str DB 'Welcome, '
        welcome_len EQU $ - welcome_str
        
        ; HUD Data for Game Screen
        hud_score_str DB 'SCORE: 00000'
        hud_score_len EQU $ - hud_score_str
        
        hud_lives_str DB 'LIVES: 3'
        hud_lives_len EQU $ - hud_lives_str
        
        hud_level_str DB 'LEVEL: 1'
        hud_level_len EQU $ - hud_level_str

        score_msg_str DB 'Score: '
        score_msg_len EQU $ - score_msg_str

        ; Highscore Data
        filename DB 'scores.dat', 0
        hs_title_str DB 'H','I','G','H',' ','S','C','O','R','E','S'
        hs_title_len EQU $ - hs_title_str

        header_str DB 'RANK      NAME                SCORE'
        header_len EQU $ - header_str

        playerNamesArr DB 1500 DUP(' ') ; 100 players * 15 chars
        playerScoresArr DW 100 DUP(0)   ; 100 players * 2 bytes
        playerCount DW 0
        currentScore DW 0 ; Default score for the active session
        score_buffer DB '00000'

        ; Instructions Screen Data
        instr_title_str DB 'INSTRUCTIONS'
        instr_title_len EQU $ - instr_title_str

        instr_line1_str DB 'Use the LEFT and RIGHT arrow keys to move the paddle.'
        instr_line1_len EQU $ - instr_line1_str

        instr_line2_str DB 'Prevent the ball from falling below your paddle.'
        instr_line2_len EQU $ - instr_line2_str

        instr_line3_str DB 'Break all the bricks to advance to the next level.'
        instr_line3_len EQU $ - instr_line3_str

        instr_return_str DB 'Press any key to return to the main menu...'
        instr_return_len EQU $ - instr_return_str

        ; Game State Data
        paddle_col DW 35
        ball_x DW 40
        ball_y DW 22 ; Start above the paddle
        ball_dx DW 1
        ball_dy DW -1 ; Set to -1 to prevent tunneling through bricks
        ball_x_delay DW 0
        lives DW 3
        
        pause_msg_str DB 'GAME PAUSED'
        pause_msg_len EQU $ - pause_msg_str
        
        resume_msg_str DB 'Press R to resume'
        resume_msg_len EQU $ - resume_msg_str
        
        quit_msg_str DB 'Press ESC to go to Main Menu by giving up'
        quit_msg_len EQU $ - quit_msg_str
        
        game_over_msg_str DB 'GAME OVER'
        game_over_msg_len EQU $ - game_over_msg_str
        
        go_quit_msg_str DB 'Press ESC to return to Menu'
        go_quit_msg_len EQU $ - go_quit_msg_str

        level DW 1
        bricks_left DW 0
        game_delay_cx DW 0001h
        game_delay_dx DW 86A0h
        
        lvl_comp_msg_str DB 'LEVEL COMPLETE'
        lvl_comp_msg_len EQU $ - lvl_comp_msg_str
        
        win_msg_str DB 'YOU WIN!'
        win_msg_len EQU $ - win_msg_str
        
        next_lvl_msg_str DB 'Press any key to continue...'
        next_lvl_msg_len EQU $ - next_lvl_msg_str

    .CODE
    MAIN PROC
        ; Initialize Data Segment
        MOV AX, @DATA
        MOV DS, AX
        CLD             ; Clear direction flag to ensure proper string operations

        ; Set Video Mode to 03h (80x25 Text Mode, 16 Colors)
        MOV AX, 0003h
        INT 10h

        ; Hide the blinking text cursor
        MOV AH, 01h
        MOV CX, 2607h
        INT 10h

        ; Set Extra Segment to VRAM (0B800h for Color Text Mode)
        MOV AX, 0B800h
        MOV ES, AX

        ; --- DRAW BRICKS ---
        ; Row 3 (Light Red)
        MOV DI, 520     ; Location: (3 * 80 + 20) * 2 = 520
        MOV CX, 40      ; 40 characters wide
        MOV AL, 0DBh    ; Solid block character
        MOV AH, 0Ch     ; Light Red color
        REP STOSW

        ; Row 4 (Light Green)
        MOV DI, 680     ; Location: (4 * 80 + 20) * 2 = 680
        MOV CX, 40
        MOV AL, 0DBh
        MOV AH, 0Ah     ; Light Green color
        REP STOSW

        ; Row 5 (Light Blue)
        MOV DI, 840     ; Location: (5 * 80 + 20) * 2 = 840
        MOV CX, 40
        MOV AL, 0DBh
        MOV AH, 09h     ; Light Blue color
        REP STOSW

        ; Row 6 (Yellow)
        MOV DI, 1000    ; Location: (6 * 80 + 20) * 2 = 1000
        MOV CX, 40
        MOV AL, 0DBh
        MOV AH, 0Eh     ; Yellow color
        REP STOSW

        ; --- DRAW TITLE ---
        MOV DI, 1666    ; Center title at Row 10, Col 33 => (10 * 80 + 33) * 2 = 1666
        MOV CX, title_len
        LEA SI, title_str
        LEA BX, title_col

    draw_title:
        LODSB           ; Load string character into AL
        MOV AH, [BX]    ; Load specific color attribute into AH
        STOSW           ; Write AX (Char + Color) to VRAM (ES:DI)
        INC BX          ; Move to next color
        LOOP draw_title

        ; --- DRAW PROMPT ---
        MOV DI, 2454    ; Center prompt at Row 15, Col 27 => (15 * 80 + 27) * 2 = 2454
        MOV CX, prompt_len
        LEA SI, prompt_str

    draw_prompt:
        LODSB           ; Load string character into AL
        MOV AH, prompt_col ; Constant color
        STOSW           ; Write to VRAM
        LOOP draw_prompt

        ; --- WAIT FOR KEYPRESS ---
    wait_key:
        MOV AH, 00h
        INT 16h         ; Wait for a key (BIOS Keyboard Services)
        CMP AL, 0Dh     ; Check if the key pressed was ENTER (Carriage Return)
        JNE wait_key    ; If not ENTER, keep waiting loop going

        ; --- NAME ENTRY SCREEN ---
        ; Clear the screen to transition
        MOV AX, 0003h
        INT 10h

        ; Show the blinking text cursor again for typing
        MOV AH, 01h
        MOV CX, 0607h
        INT 10h

        ; Ensure Extra Segment points to VRAM
        MOV AX, 0B800h
        MOV ES, AX

        ; Draw "Let us know your name..." prompt centered at Row 10, Col 15
        MOV DI, 1630
        MOV CX, name_msg_len
        LEA SI, name_msg_str
        MOV AH, 0Eh     ; Yellow text
    draw_name_msg:
        LODSB
        STOSW
        LOOP draw_name_msg

        ; Draw "Player Name : " label at Row 12, Col 25
        MOV DI, 1970
        MOV CX, player_lbl_len
        LEA SI, player_lbl_str
        MOV AH, 0Bh     ; Light Cyan text
    draw_player_lbl:
        LODSB
        STOSW
        LOOP draw_player_lbl

        ; Draw the initial "Default" name right after the label
        MOV DI, 1998    ; Offset for start of input text (Row 12, Col 39)
        MOV CX, [nameLen]
        LEA SI, playerName
        MOV AH, 0Fh     ; White text
    draw_default_name:
        LODSB
        STOSW
        LOOP draw_default_name

        ; Draw "Press ENTER to continue..." label at Row 18, Col 27
        MOV DI, 2934
        MOV CX, continue_msg_len
        LEA SI, continue_msg_str
        MOV AH, 07h     ; Light Gray text
    draw_continue_lbl:
        LODSB
        STOSW
        LOOP draw_continue_lbl

    name_input_loop:
        ; Update visible Hardware Cursor Position
        MOV AH, 02h
        MOV BH, 00h
        MOV DH, 12      ; Cursor Row 12
        MOV DL, 39      ; Cursor Col 39 (start of name input)
        ADD DL, BYTE PTR [nameLen] ; Move cursor to end of the current text
        INT 10h

        ; Wait for keystroke
        MOV AH, 00h
        INT 16h

        CMP AL, 0Dh     ; If ENTER pressed, input is done
        JE name_input_done

        CMP AL, 08h     ; If BACKSPACE pressed, handle erasing
        JE handle_backspace

        ; Ensure the character is an alphabet letter (A-Z, a-z)
        CMP AL, 'A'
        JB check_lowercase
        CMP AL, 'Z'
        JBE valid_char

    check_lowercase:
        CMP AL, 'a'
        JB name_input_loop
        CMP AL, 'z'
        JA name_input_loop

    valid_char:
        ; Enforce max length limit (15 chars)
        CMP WORD PTR [nameLen], 15
        JAE name_input_loop

        ; Add typed character to buffer
        MOV BX, WORD PTR [nameLen]
        MOV [playerName + BX], AL
        INC WORD PTR [nameLen]

        ; Draw new character to VRAM immediately
        MOV DI, 1998
        ADD DI, BX
        ADD DI, BX
        MOV AH, 0Fh     ; White text
        MOV ES:[DI], AX ; Write Char + Color to VRAM

        JMP name_input_loop

    handle_backspace:
        ; Do not erase if length is 0
        CMP WORD PTR [nameLen], 0
        JE name_input_loop

        ; Erase last character in buffer
        DEC WORD PTR [nameLen]
        MOV BX, WORD PTR [nameLen]
        MOV BYTE PTR [playerName + BX], ' '

        ; Erase character visually on screen
        MOV DI, 1998
        ADD DI, BX
        ADD DI, BX
        MOV AL, ' '
        MOV AH, 0Fh
        MOV ES:[DI], AX

        JMP name_input_loop

    name_input_done:
        MOV menu_sel, 0 ; Reset menu selection to "Start" (0)

    draw_main_menu:
        ; Clear screen for Main Menu
        MOV AX, 0003h
        INT 10h
        
        ; Hide text cursor
        MOV AH, 01h
        MOV CX, 2607h
        INT 10h
        
        ; Ensure Extra Segment points to VRAM
        MOV AX, 0B800h
        MOV ES, AX

        ; --- DRAW MENU TITLE ---
        MOV DI, 872     ; Centered at Row 5, Col 36 => (5 * 80 + 36) * 2 = 872
        MOV CX, menu_title_len
        LEA SI, menu_title_str
        LEA BX, menu_title_col
    draw_menu_title_loop:
        LODSB
        MOV AH, [BX]
        STOSW
        INC BX
        LOOP draw_menu_title_loop

        ; --- DRAW WELCOME MESSAGE WITH PLAYER NAME ---
        MOV DI, 1184
        MOV CX, welcome_len
        LEA SI, welcome_str
        MOV AH, 0Fh ; White text
    draw_welcome_loop:
        LODSB
        STOSW
        LOOP draw_welcome_loop

        ; Draw the player's name right after "Welcome, "
        MOV CX, [nameLen]
        LEA SI, playerName
        MOV AH, 0Eh ; Yellow text for the name
    draw_playername_menu_loop:
        LODSB
        STOSW
        LOOP draw_playername_menu_loop

        ; --- DRAW SCORE MESSAGE ---
        MOV DI, 1344 ; Row 8, Col 32 => (8 * 80 + 32) * 2 = 1344
        MOV CX, score_msg_len
        LEA SI, score_msg_str
        MOV AH, 0Fh ; White text
    draw_score_msg_loop:
        LODSB
        STOSW
        LOOP draw_score_msg_loop

        MOV AX, currentScore
        LEA SI, score_buffer
        CALL num_to_str
        MOV CX, 5
        LEA SI, score_buffer
        MOV AH, 0Ah ; Light Green text for the score
    draw_score_val_loop:
        LODSB
        STOSW
        LOOP draw_score_val_loop

        ; --- DRAW MENU OPTIONS ---
        ; Draw Option 1 (Start) at Row 10, Col 31 => (10 * 80 + 31) * 2 = 1662
        MOV DI, 1662
        MOV CX, opt1_len
        LEA SI, opt1_str
        MOV AH, 0Ah     ; Normal State: Light Green text
        CMP menu_sel, 0
        JNE render_opt1
        MOV AH, 70h     ; Highlight State: Black text on Light Gray background
    render_opt1:
        LODSB
        STOSW
        LOOP render_opt1

        ; Draw Option 2 (Instructions) at Row 12, Col 31 => (12 * 80 + 31) * 2 = 1982
        MOV DI, 1982
        MOV CX, opt2_len
        LEA SI, opt2_str
        MOV AH, 0Bh     ; Normal State: Light Cyan text
        CMP menu_sel, 1
        JNE render_opt2
        MOV AH, 70h     ; Highlight State
    render_opt2:
        LODSB
        STOSW
        LOOP render_opt2

        ; Draw Option 3 (High Scores) at Row 14, Col 31 => (14 * 80 + 31) * 2 = 2302
        MOV DI, 2302
        MOV CX, opt3_len
        LEA SI, opt3_str
        MOV AH, 0Eh     ; Normal State: Yellow text
        CMP menu_sel, 2
        JNE render_opt3
        MOV AH, 70h     ; Highlight State
    render_opt3:
        LODSB
        STOSW
        LOOP render_opt3

        ; Draw Option 4 (Exit) at Row 16, Col 31 => (16 * 80 + 31) * 2 = 2622
        MOV DI, 2622
        MOV CX, opt4_len
        LEA SI, opt4_str
        MOV AH, 0Ch     ; Normal State: Light Red text
        CMP menu_sel, 3
        JNE render_opt4
        MOV AH, 70h     ; Highlight State
    render_opt4:
        LODSB
        STOSW
        LOOP render_opt4

    menu_input_loop:
        ; Wait for keystroke
        MOV AH, 00h
        INT 16h

        CMP AH, 48h     ; Scan code for UP arrow
        JE menu_up
        CMP AH, 50h     ; Scan code for DOWN arrow
        JE menu_down
        CMP AL, 0Dh     ; ASCII code for ENTER key
        JE menu_select
        JMP menu_input_loop

    menu_up:
        CMP menu_sel, 0
        JE wrap_up
        DEC menu_sel
        JMP draw_main_menu
    wrap_up:
        MOV menu_sel, 3 ; Wrap to bottom
        JMP draw_main_menu

    menu_down:
        CMP menu_sel, 3
        JE wrap_down
        INC menu_sel
        JMP draw_main_menu
    wrap_down:
        MOV menu_sel, 0 ; Wrap to top
        JMP draw_main_menu

    menu_select:
        CMP menu_sel, 0
        JNE ms_check_1
        JMP start_selected
    ms_check_1:
        CMP menu_sel, 1
        JNE ms_check_2
        JMP inst_selected
    ms_check_2:
        CMP menu_sel, 2
        JNE ms_check_3
        JMP scores_selected
    ms_check_3:
        CMP menu_sel, 3
        JNE ms_done
        JMP exit_game
    ms_done:

    start_selected:
        MOV lvl_sel, 0 ; Reset level selection to Level 1
        
    draw_level_menu:
        MOV AX, 0003h
        INT 10h
        
        MOV AH, 01h
        MOV CX, 2607h
        INT 10h
        
        MOV AX, 0B800h
        MOV ES, AX

        ; --- DRAW LEVEL TITLE ---
        MOV DI, 866     ; Centered at Row 5, Col 33 => (5 * 80 + 33) * 2 = 866
        MOV CX, lvl_sel_title_len
        LEA SI, lvl_sel_title_str
        LEA BX, lvl_sel_title_col
    draw_lvl_title_loop:
        LODSB
        MOV AH, [BX]
        STOSW
        INC BX
        LOOP draw_lvl_title_loop

        ; --- DRAW LEVEL OPTIONS ---
        MOV DI, 1662
        MOV CX, lvl_opt1_len
        LEA SI, lvl_opt1_str
        MOV AH, 0Ah     ; Normal
        CMP lvl_sel, 0
        JNE render_lopt1
        MOV AH, 70h     ; Highlight
    render_lopt1:
        LODSB
        STOSW
        LOOP render_lopt1

        MOV DI, 1982
        MOV CX, lvl_opt2_len
        LEA SI, lvl_opt2_str
        MOV AH, 0Bh
        CMP lvl_sel, 1
        JNE render_lopt2
        MOV AH, 70h
    render_lopt2:
        LODSB
        STOSW
        LOOP render_lopt2

        MOV DI, 2302
        MOV CX, lvl_opt3_len
        LEA SI, lvl_opt3_str
        MOV AH, 0Eh
        CMP lvl_sel, 2
        JNE render_lopt3
        MOV AH, 70h
    render_lopt3:
        LODSB
        STOSW
        LOOP render_lopt3

        MOV DI, 2622
        MOV CX, lvl_opt4_len
        LEA SI, lvl_opt4_str
        MOV AH, 0Ch
        CMP lvl_sel, 3
        JNE render_lopt4
        MOV AH, 70h
    render_lopt4:
        LODSB
        STOSW
        LOOP render_lopt4

    lvl_input_loop:
        MOV AH, 00h
        INT 16h

        CMP AH, 48h     ; UP
        JE lvl_up
        CMP AH, 50h     ; DOWN
        JE lvl_down
        CMP AL, 0Dh     ; ENTER
        JE lvl_select
        JMP lvl_input_loop

    lvl_up:
        CMP lvl_sel, 0
        JE lvl_wrap_up
        DEC lvl_sel
        JMP draw_level_menu
    lvl_wrap_up:
        MOV lvl_sel, 3
        JMP draw_level_menu

    lvl_down:
        CMP lvl_sel, 3
        JE lvl_wrap_down
        INC lvl_sel
        JMP draw_level_menu
    lvl_wrap_down:
        MOV lvl_sel, 0
        JMP draw_level_menu

    lvl_select:
        MOV AL, lvl_sel
        CBW
        INC AX
        MOV level, AX

    start_game_with_level:
        MOV paddle_col, 35  ; Reset paddle starting position
        MOV AX, paddle_col
        ADD AX, 4           ; Center ball roughly above paddle
        MOV ball_x, AX
        MOV ball_y, 22      ; Start ball just above the paddle
        MOV ball_dx, 1      ; Initial horizontal velocity (can be -1 for random start)
        MOV ball_dy, -1     ; Initial vertical velocity
        MOV ball_x_delay, 0
        MOV lives, 3
        MOV currentScore, 0
        MOV game_delay_cx, 0001h
        MOV game_delay_dx, 86A0h
        
    draw_game_screen:
        ; --- DRAW STATIC GAME SCREEN ---
        ; Clear screen
        MOV AX, 0003h
        INT 10h

        ; Hide cursor
        MOV AH, 01h
        MOV CX, 2607h
        INT 10h

        ; Ensure Extra Segment points to VRAM
        MOV AX, 0B800h
        MOV ES, AX

        ; Draw HUD - Score
        MOV DI, 4       ; Row 0, Col 2 => (0 * 80 + 2) * 2 = 4
        MOV CX, hud_score_len
        LEA SI, hud_score_str
        MOV AH, 0Fh     ; White text
    draw_hud_score:
        LODSB
        STOSW
        LOOP draw_hud_score

        ; Draw HUD - Lives
        MOV DI, 72      ; Row 0, Col 36 => (0 * 80 + 36) * 2 = 72
        MOV CX, hud_lives_len
        LEA SI, hud_lives_str
        MOV AH, 0Fh
    draw_hud_lives:
        LODSB
        STOSW
        LOOP draw_hud_lives

        ; Draw HUD - Level
        MOV DI, 140     ; Row 0, Col 70 => (0 * 80 + 70) * 2 = 140
        MOV CX, hud_level_len
        LEA SI, hud_level_str
        MOV AH, 0Fh
    draw_hud_level:
        LODSB
        STOSW
        LOOP draw_hud_level
        
        ; Dynamically update level number
        MOV DI, 154     ; 140 + 7*2
        MOV AX, level
        ADD AL, '0'
        MOV AH, 0Fh
        MOV ES:[DI], AX

        ; --- DRAW RED BOUNDARY ---
        ; Top Boundary (Row 1)
        MOV DI, 160     ; Row 1, Col 0 => (1 * 80) * 2
        MOV CX, 80
        MOV AL, 0DBh
        MOV AH, 04h     ; Red color
        REP STOSW

        ; Side Boundaries (Rows 2 to 23)
        MOV DI, 320
        MOV CX, 22
        MOV AL, 0DBh
        MOV AH, 04h
    draw_side_bounds:
        MOV ES:[DI], AX        ; Left border
        MOV ES:[DI + 158], AX  ; Right border
        ADD DI, 160
        LOOP draw_side_bounds

        ; Bottom Boundary (Row 24)
        MOV DI, 3840    ; Row 24, Col 0 => (24 * 80) * 2
        MOV CX, 80
        MOV AL, 0DBh
        MOV AH, 04h
        REP STOSW

        ; --- DRAW BRICKS ---
        ; Jump to appropriate level drawing
        CMP level, 1
        JE draw_lvl_1
        CMP level, 2
        JE draw_lvl_2
        CMP level, 3
        JE draw_lvl_3
        JMP draw_lvl_4

draw_lvl_1:
        MOV bricks_left, 30
        MOV DI, 500
        MOV AH, 0Ch
        CALL draw_single_row
        MOV DI, 820
        MOV AH, 0Ch
        CALL draw_single_row
        MOV DI, 1140
        MOV AH, 0Ch
        CALL draw_single_row
        JMP draw_bricks_done

draw_lvl_2:
        MOV bricks_left, 40
        MOV DI, 500
        MOV AH, 0Ah     ; Green
        CALL draw_single_row
        MOV DI, 820
        MOV AH, 0Ch     ; Red
        CALL draw_single_row
        MOV DI, 1140
        MOV AH, 0Ch
        CALL draw_single_row
        MOV DI, 1460
        MOV AH, 0Ch
        CALL draw_single_row
        JMP draw_bricks_done

draw_lvl_3:
        MOV bricks_left, 50
        MOV DI, 500
        MOV AH, 09h     ; Blue
        CALL draw_single_row
        MOV DI, 820
        MOV AH, 0Ah     ; Green
        CALL draw_single_row
        MOV DI, 1140
        MOV AH, 0Ch     ; Red
        CALL draw_single_row
        MOV DI, 1460
        MOV AH, 0Ch
        CALL draw_single_row
        MOV DI, 1780
        MOV AH, 0Ch
        CALL draw_single_row
        JMP draw_bricks_done

draw_lvl_4:
        MOV bricks_left, 60
        MOV DI, 500
        MOV AH, 0Eh     ; Yellow
        CALL draw_single_row
        MOV DI, 820
        MOV AH, 09h     ; Blue
        CALL draw_single_row
        MOV DI, 1140
        MOV AH, 0Ah     ; Green
        CALL draw_single_row
        MOV DI, 1460
        MOV AH, 0Ch     ; Red
        CALL draw_single_row
        MOV DI, 1780
        MOV AH, 0Ch
        CALL draw_single_row
        MOV DI, 2100
        MOV AH, 0Ch
        CALL draw_single_row

draw_bricks_done:

        ; --- INITIAL PADDLE DRAW ---
        MOV AX, 23
        MOV BX, 80
        MUL BX
        ADD AX, paddle_col
        SHL AX, 1
        MOV DI, AX
        MOV CX, 10
        MOV AL, 0DBh
        MOV AH, 0Bh
        REP STOSW

    game_loop:
        ; Delay to control game speed
        MOV AH, 86h
        MOV CX, game_delay_cx
        MOV DX, game_delay_dx
        INT 15h

        ; Check for key press (non-blocking)
        MOV AH, 01h
        INT 16h
        JZ update_ball_jmp  ; No key, move ball

        ; Read key
        MOV AH, 00h
        INT 16h
        
        CMP AL, 'a'
        JE move_left
        CMP AL, 'A'
        JE move_left
        
        CMP AL, 'd'
        JE move_right
        CMP AL, 'D'
        JE move_right
        
        CMP AL, 'p'
        JE do_pause
        CMP AL, 'P'
        JE do_pause
        
    update_ball_jmp:
        JMP update_ball

    do_pause:
        JMP pause_game

    move_left:
        CMP paddle_col, 1
        JLE update_ball_jmp
        
        ; Erase old paddle efficiently
        MOV AX, 23
        MOV BX, 80
        MUL BX
        ADD AX, paddle_col
        SHL AX, 1
        MOV DI, AX
        MOV CX, 10
        MOV AL, ' '
        MOV AH, 00h
        REP STOSW
        
        SUB paddle_col, 2
        JMP draw_paddle_update

    move_right:
        CMP paddle_col, 69
        JGE update_ball_jmp
        
        ; Erase old paddle efficiently
        MOV AX, 23
        MOV BX, 80
        MUL BX
        ADD AX, paddle_col
        SHL AX, 1
        MOV DI, AX
        MOV CX, 10
        MOV AL, ' '
        MOV AH, 00h
        REP STOSW
        
        ADD paddle_col, 2

    draw_paddle_update:
        MOV AX, 23
        MOV BX, 80
        MUL BX
        ADD AX, paddle_col
        SHL AX, 1
        MOV DI, AX
        MOV CX, 10
        MOV AL, 0DBh
        MOV AH, 0Bh
        REP STOSW

    update_ball:
        ; Erase old ball
        MOV AX, ball_y
        MOV BX, 80
        MUL BX
        ADD AX, ball_x
        SHL AX, 1
        MOV DI, AX
        MOV AL, ' '
        MOV AH, 00h
        MOV ES:[DI], AX

        ; Update X position
        MOV AX, ball_dx
        ADD ball_x, AX

        ; Check left wall (col 1)
        CMP ball_x, 1
        JG check_right_wall
        MOV ball_x, 1
        NEG ball_dx
        JMP update_y

    check_right_wall:
        ; Check right wall (col 78)
        CMP ball_x, 78
        JL update_y
        MOV ball_x, 78
        NEG ball_dx

    update_y:
        ; Update Y position
        MOV AX, ball_dy
        ADD ball_y, AX

        ; Check top wall (row 2)
        CMP ball_y, 2
        JG check_paddle
        MOV ball_y, 2
        NEG ball_dy
        JMP draw_new_ball

    check_paddle:
        ; Check if it reached paddle row (row 23)
        CMP ball_y, 23
        JNE check_bottom

        ; Check if it hits paddle
        MOV AX, ball_x
        CMP AX, paddle_col
        JL check_bottom   ; missed paddle (left)
        
        MOV BX, paddle_col
        ADD BX, 10
        CMP AX, BX
        JGE check_bottom  ; missed paddle (right)

        ; Hit paddle!
        NEG ball_dy
        MOV ball_y, 22 ; move it just above paddle
        JMP draw_new_ball

    check_bottom:
        ; Check if fell off screen (row 23 or greater if missed)
        CMP ball_y, 23
        JLE check_bricks

        ; Reset ball to paddle
        DEC lives
        CMP lives, 0
        JG lives_not_zero
        JMP do_game_over
    lives_not_zero:
        
        ; Update HUD lives
        MOV DI, 86 ; Row 0, Col 43 => (0 * 80 + 43) * 2 = 86
        MOV AX, lives
        ADD AL, '0'
        MOV AH, 0Fh
        MOV ES:[DI], AX

        MOV AX, paddle_col
        ADD AX, 4
        MOV ball_x, AX
        MOV ball_y, 22
        MOV ball_dy, -1
        JMP draw_new_ball

    check_bricks:
        ; Check if ball is in brick rows (Rows 3 to 13)
        CMP ball_y, 3
        JGE brick_check_row_2
        JMP draw_new_ball
    brick_check_row_2:
        CMP ball_y, 13
        JLE brick_check_ok
        JMP draw_new_ball
    brick_check_ok:
        
        ; Calculate VRAM address of ball
        MOV AX, ball_y
        MOV BX, 80
        MUL BX
        ADD AX, ball_x
        SHL AX, 1
        MOV DI, AX
        
        ; Read VRAM at that position
        MOV AX, ES:[DI]
        CMP AL, 0DBh
        JE is_brick
        JMP draw_new_ball ; Not a block
    is_brick:
        
        ; Bounce
        NEG ball_dy
        
        ; Get current block color from VRAM (ES:[DI+1] because ES:[DI] is character, AH is color)
        MOV AX, ES:[DI]
        MOV DH, AH ; DH has color
        
        ; Default next state
        MOV BL, ' '  ; Char
        MOV BH, 00h  ; Color
        MOV CX, 10   ; Points
        
        CMP DH, 0Eh  ; Yellow (4 hits)
        JNE check_blue
        MOV BL, 0DBh
        MOV BH, 09h  ; Light Blue
        MOV CX, 40
        JMP process_brick
        
    check_blue:
        CMP DH, 09h  ; Light Blue (3 hits)
        JNE check_green
        MOV BL, 0DBh
        MOV BH, 0Ah  ; Light Green
        MOV CX, 30
        JMP process_brick
        
    check_green:
        CMP DH, 0Ah  ; Light Green (2 hits)
        JNE check_red
        MOV BL, 0DBh
        MOV BH, 0Ch  ; Light Red
        MOV CX, 20
        JMP process_brick
        
    check_red:
        ; It's red, gets erased.
        DEC bricks_left
        
    process_brick:
        ; Update block
        MOV SI, ball_x
    scan_left:
        ; Calculate DI
        MOV AX, ball_y
        PUSH BX
        MOV BX, 80
        MUL BX
        POP BX
        ADD AX, SI
        SHL AX, 1
        MOV DI, AX
        
        MOV AX, ES:[DI]
        CMP AL, 0DBh
        JNE scan_right_init
        
        MOV AL, BL
        MOV AH, BH
        MOV ES:[DI], AX
        DEC SI
        JMP scan_left
        
    scan_right_init:
        MOV SI, ball_x
        INC SI
    scan_right:
        MOV AX, ball_y
        PUSH BX
        MOV BX, 80
        MUL BX
        POP BX
        ADD AX, SI
        SHL AX, 1
        MOV DI, AX
        
        MOV AX, ES:[DI]
        CMP AL, 0DBh
        JNE add_score
        
        MOV AL, BL
        MOV AH, BH
        MOV ES:[DI], AX
        INC SI
        JMP scan_right
        
    add_score:
        ADD currentScore, CX
        ; Update HUD score
        MOV AX, currentScore
        LEA SI, score_buffer
        CALL num_to_str
        MOV DI, 18 ; Row 0, Col 9 => (0 * 80 + 9) * 2 = 18
        MOV CX, 5
        LEA SI, score_buffer
        MOV AH, 0Fh ; White
    draw_hud_score_update:
        LODSB
        STOSW
        LOOP draw_hud_score_update

        ; Restore ball Y position so it doesn't overwrite multi-hit bricks
        MOV AX, ball_dy
        ADD ball_y, AX

        ; Check if level complete
        CMP bricks_left, 0
        JLE level_complete
        JMP draw_new_ball

    level_complete:
        MOV AX, 0003h
        INT 10h

        MOV AX, 0B800h
        MOV ES, AX

        CMP level, 4
        JGE game_won

        ; Draw "LEVEL COMPLETE"
        MOV DI, 1662    ; Row 10, Col 31
        MOV CX, lvl_comp_msg_len
        LEA SI, lvl_comp_msg_str
        MOV AH, 0Ah     ; Light Green
    draw_lc_title:
        LODSB
        STOSW
        LOOP draw_lc_title

        ; Draw "Press any key..."
        MOV DI, 1968    ; Row 12, Col 24
        MOV CX, next_lvl_msg_len
        LEA SI, next_lvl_msg_str
        MOV AH, 0Fh     ; White
    draw_nl_msg:
        LODSB
        STOSW
        LOOP draw_nl_msg

        MOV AH, 00h
        INT 16h
        
        INC level
        ; Decrease delay (increase speed)
        SUB game_delay_dx, 1000h
        CMP game_delay_dx, 1000h
        JGE skip_delay_cap
        MOV game_delay_dx, 1000h ; cap speed
    skip_delay_cap:
        
        MOV paddle_col, 35
        MOV AX, paddle_col
        ADD AX, 4
        MOV ball_x, AX
        MOV ball_y, 22
        MOV ball_dy, -1
        
        JMP draw_game_screen

    game_won:
        ; Draw "YOU WIN!"
        MOV DI, 1672    ; Row 10, Col 36
        MOV CX, win_msg_len
        LEA SI, win_msg_str
        MOV AH, 0Eh     ; Yellow
    draw_win_title:
        LODSB
        STOSW
        LOOP draw_win_title
        
        ; Draw "Press ESC to go to Main Menu"
        MOV DI, 1978    ; Row 12, Col 26 => (12 * 80 + 26) * 2 = 1972
        MOV CX, go_quit_msg_len
        LEA SI, go_quit_msg_str
        MOV AH, 0Fh     ; White
    draw_win_quit:
        LODSB
        STOSW
        LOOP draw_win_quit
        
        JMP wait_go_key

    do_game_over:
        MOV AX, 0003h
        INT 10h

        MOV AX, 0B800h
        MOV ES, AX

        ; Draw "GAME OVER"
        MOV DI, 1668    ; Row 10, Col 34 => (10 * 80 + 34) * 2 = 1668
        MOV CX, game_over_msg_len
        LEA SI, game_over_msg_str
        MOV AH, 0Ch     ; Light Red
    draw_go_title:
        LODSB
        STOSW
        LOOP draw_go_title

        ; Draw "Press ESC to go to Main Menu"
        MOV DI, 1978    ; Row 12, Col 26 => (12 * 80 + 26) * 2 = 1972
        MOV CX, go_quit_msg_len
        LEA SI, go_quit_msg_str
        MOV AH, 0Fh     ; White
    draw_go_quit:
        LODSB
        STOSW
        LOOP draw_go_quit

    wait_go_key:
        MOV AH, 00h
        INT 16h
        
        CMP AL, 1Bh     ; ESC key
        JE quit_to_menu_go
        JMP wait_go_key
        
    quit_to_menu_go:
        JMP draw_main_menu

    draw_new_ball:
        ; Draw new ball
        MOV AX, ball_y
        MOV BX, 80
        MUL BX
        ADD AX, ball_x
        SHL AX, 1
        MOV DI, AX
        MOV AL, 09h
        MOV AH, 0Fh
        MOV ES:[DI], AX

        JMP game_loop

    pause_game:
        MOV AX, 0003h
        INT 10h

        MOV AX, 0B800h
        MOV ES, AX

        ; Draw "GAME PAUSED"
        MOV DI, 1668    ; Row 10, Col 34 => (10 * 80 + 34) * 2 = 1668
        MOV CX, pause_msg_len
        LEA SI, pause_msg_str
        MOV AH, 0Eh     ; Yellow
    draw_pause_title:
        LODSB
        STOSW
        LOOP draw_pause_title

        ; Draw "Press R to resume"
        MOV DI, 1982    ; Row 12, Col 31 => (12 * 80 + 31) * 2 = 1982
        MOV CX, resume_msg_len
        LEA SI, resume_msg_str
        MOV AH, 0Fh     ; White
    draw_resume_msg:
        LODSB
        STOSW
        LOOP draw_resume_msg

        ; Draw "Press ESC to go to Main Menu by giving up"
        MOV DI, 2278    ; Row 14, Col 19 => (14 * 80 + 19) * 2 = 2278
        MOV CX, quit_msg_len
        LEA SI, quit_msg_str
        MOV AH, 0Ch     ; Light Red
    draw_quit_msg:
        LODSB
        STOSW
        LOOP draw_quit_msg

    wait_pause_key:
        MOV AH, 00h
        INT 16h
        
        CMP AL, 'r'
        JE resume_game
        CMP AL, 'R'
        JE resume_game
        
        CMP AL, 1Bh     ; ESC key (ASCII 27)
        JE quit_to_menu
        
        JMP wait_pause_key
        
    resume_game:
        ; Jump back and redraw the screen (paddle retains its position!)
        JMP draw_game_screen
        
    quit_to_menu:
        JMP draw_main_menu

    scores_selected:
        JMP show_highscores

    show_highscores:
        ; Set ES to DS so we can easily do array-to-array comparisons/moves
        MOV AX, DS
        MOV ES, AX
        
        ; Open file for reading
        MOV AH, 3Dh
        MOV AL, 2       ; Read/Write mode
        LEA DX, filename
        INT 21h
        JC hs_file_not_found ; If carry flag is set, file does not exist
        
        MOV BX, AX      ; Save File Handle
        
        ; Read player count
        MOV AH, 3Fh
        MOV CX, 2
        LEA DX, playerCount
        INT 21h
        
        ; Read names
        MOV AH, 3Fh
        MOV CX, 1500
        LEA DX, playerNamesArr
        INT 21h
        
        ; Read scores
        MOV AH, 3Fh
        MOV CX, 200
        LEA DX, playerScoresArr
        INT 21h
        
        ; Close file
        MOV AH, 3Eh
        INT 21h
        JMP hs_check_current_player

    hs_file_not_found:
        MOV playerCount, 0

    hs_check_current_player:
        MOV CX, playerCount
        CMP CX, 0
        JE hs_add_new_player
        
        MOV BX, 0       ; Player index iterator
    hs_find_player_loop:
        PUSH CX
        
        MOV AX, 15
        MUL BX
        MOV DI, AX      ; DI offset for playerNamesArr
        
        LEA SI, playerName
        MOV CX, 15
    hs_cmp_name_loop:
        MOV AL, [SI]
        CMP AL, playerNamesArr[DI]
        JNE hs_not_this_player
        INC SI
        INC DI
        LOOP hs_cmp_name_loop
        ; If we get here, name matched!
        JMP hs_player_found_update
        
    hs_not_this_player:
        POP CX
        INC BX
        LOOP hs_find_player_loop
        JMP hs_add_new_player
        
    hs_player_found_update:
        POP CX
        ; Update score if new score is higher
        MOV SI, BX
        SHL SI, 1
        MOV AX, currentScore
        CMP AX, playerScoresArr[SI]
        JBE hs_sort_array  ; If current <= existing, skip updating
        MOV playerScoresArr[SI], AX
        JMP hs_sort_array
        
    hs_add_new_player:
        ; Check if we've hit the 100 player limit
        CMP playerCount, 100
        JAE hs_sort_array
        
        MOV BX, playerCount
        
        ; Copy name
        MOV AX, 15
        MUL BX
        MOV DI, AX
        LEA SI, playerName
        MOV CX, 15
    hs_copy_new_name:
        MOV AL, [SI]
        MOV playerNamesArr[DI], AL
        INC SI
        INC DI
        LOOP hs_copy_new_name
        
        ; Copy score
        MOV SI, BX
        SHL SI, 1
        MOV AX, currentScore
        MOV playerScoresArr[SI], AX
        
        INC playerCount
        
    hs_sort_array:
        ; Bubble Sort (descending)
        MOV CX, playerCount
        DEC CX
        CMP CX, 0
        JLE hs_save_file
        
    hs_outer_loop:
        PUSH CX
        MOV BX, 0       ; Index
    hs_inner_loop:
        MOV SI, BX
        SHL SI, 1
        MOV AX, playerScoresArr[SI]
        MOV DX, playerScoresArr[SI+2]
        
        CMP AX, DX
        JAE hs_no_swap  ; If sorted, continue
        
        ; Swap scores
        MOV playerScoresArr[SI], DX
        MOV playerScoresArr[SI+2], AX
        
        ; Swap names
        PUSH CX
        MOV AX, 15
        MUL BX
        MOV DI, AX      ; DI points to name[BX]
        
        MOV SI, DI
        ADD SI, 15      ; SI points to name[BX+1]
        
        MOV CX, 15
    hs_swap_name_loop:
        MOV AL, playerNamesArr[DI]
        MOV DL, playerNamesArr[SI]
        MOV playerNamesArr[DI], DL
        MOV playerNamesArr[SI], AL
        INC DI
        INC SI
        LOOP hs_swap_name_loop
        POP CX
        
    hs_no_swap:
        INC BX
        LOOP hs_inner_loop
        POP CX
        LOOP hs_outer_loop

    hs_save_file:
        ; Create or Overwrite file
        MOV AH, 3Ch
        MOV CX, 0
        LEA DX, filename
        INT 21h
        JC hs_draw_screen
        MOV BX, AX
        
        MOV AH, 40h
        MOV CX, 2
        LEA DX, playerCount
        INT 21h
        
        MOV AH, 40h
        MOV CX, 1500
        LEA DX, playerNamesArr
        INT 21h
        
        MOV AH, 40h
        MOV CX, 200
        LEA DX, playerScoresArr
        INT 21h
        
        MOV AH, 3Eh ; Close File
        INT 21h

    hs_draw_screen:
        MOV AX, 0003h
        INT 10h

        ; Ensure Extra Segment points to VRAM
        MOV AX, 0B800h
        MOV ES, AX

        ; Draw Screen Title
        MOV DI, 550 ; Row 3, Col 35 => 275 * 2 = 550
        MOV CX, hs_title_len
        LEA SI, hs_title_str
        MOV AH, 0Eh ; Yellow
    draw_hs_title_l:
        LODSB
        STOSW
        LOOP draw_hs_title_l

        ; Draw Tabular Headers at Row 6, Col 20 => (6 * 80 + 20) * 2 = 1000
        MOV DI, 1000
        MOV CX, header_len
        LEA SI, header_str
        MOV AH, 0Bh ; Light Cyan
    draw_hs_header:
        LODSB
        STOSW
        LOOP draw_hs_header

        ; Render Limit to Top 5 Entries
        MOV CX, playerCount
        CMP CX, 5
        JBE top5_ok
        MOV CX, 5
    top5_ok:
        MOV BX, 0 ; Player index
        MOV DI, 1320 ; Start Table Row 8, Col 20 => (8 * 80 + 20) * 2 = 1320
        
    draw_hs_list:
        CMP CX, 0
        JE hs_wait_key
        PUSH CX

        ; Draw Rank (BX + 1)
        MOV AX, BX
        INC AX
        LEA SI, score_buffer
        CALL num_to_str
        
        PUSH DI
        MOV CX, 5
        LEA SI, score_buffer
        MOV AH, 0Fh ; White
    draw_hs_rank_val:
        LODSB
        STOSW
        LOOP draw_hs_rank_val
        POP DI

        ; Draw Found Player Name
        PUSH DI
        ADD DI, 20 ; Move to Name Column (+10 chars = +20 bytes)
        MOV CX, 15
        LEA SI, playerNamesArr
        MOV AX, 15
        PUSH DX
        MUL BX
        POP DX
        ADD SI, AX
        MOV AH, 0Fh
    draw_hs_name:
        LODSB
        STOSW
        LOOP draw_hs_name
        POP DI

        ; Draw Associated Score
        PUSH DI
        ADD DI, 60 ; Move to Score Column (+30 chars = +60 bytes)
        MOV SI, BX
        SHL SI, 1
        MOV AX, playerScoresArr[SI]
        LEA SI, score_buffer
        CALL num_to_str

        MOV CX, 5
        LEA SI, score_buffer
        MOV AH, 0Ah ; Light Green text
    draw_hs_score_val:
        LODSB
        STOSW
        LOOP draw_hs_score_val
        POP DI

        ADD DI, 320 ; Move down 2 entire rows (160 * 2) for the next record
        INC BX
        POP CX
        DEC CX
        JNZ draw_hs_list
        
    hs_wait_key:
        ; Draw Return To Menu Prompt
        MOV DI, 3242 ; Row 20, Col 21
        MOV CX, instr_return_len
        LEA SI, instr_return_str
        MOV AH, 07h
    draw_hs_ret:
        LODSB
        STOSW
        LOOP draw_hs_ret
        
        ; Wait for keypress
        MOV AH, 00h
        INT 16h
        JMP draw_main_menu

    inst_selected:
        JMP show_instructions

    show_instructions:
        ; Clear screen
        MOV AX, 0003h
        INT 10h

        ; Ensure ES is VRAM
        MOV AX, 0B800h
        MOV ES, AX

        ; Draw "INSTRUCTIONS" title at Row 5, Col 34 => (5 * 80 + 34) * 2 = 868
        MOV DI, 868
        MOV CX, instr_title_len
        LEA SI, instr_title_str
        MOV AH, 0Eh ; Yellow
    draw_instr_title:
        LODSB
        STOSW
        LOOP draw_instr_title

        ; Draw line 1 at Row 10, Col 15 => (10 * 80 + 15) * 2 = 1630
        MOV DI, 1630
        MOV CX, instr_line1_len
        LEA SI, instr_line1_str
        MOV AH, 0Fh ; White
    draw_instr_line1:
        LODSB
        STOSW
        LOOP draw_instr_line1

        ; Draw line 2 at Row 12, Col 18 => (12 * 80 + 18) * 2 = 1956
        MOV DI, 1956
        MOV CX, instr_line2_len
        LEA SI, instr_line2_str
        MOV AH, 0Fh ; White
    draw_instr_line2:
        LODSB
        STOSW
        LOOP draw_instr_line2

        ; Draw line 3 at Row 14, Col 17 => (14 * 80 + 17) * 2 = 2274
        MOV DI, 2274
        MOV CX, instr_line3_len
        LEA SI, instr_line3_str
        MOV AH, 0Fh ; White
    draw_instr_line3:
        LODSB
        STOSW
        LOOP draw_instr_line3

        ; Draw return prompt at Row 20, Col 21 => (20 * 80 + 21) * 2 = 3242
        MOV DI, 3242
        MOV CX, instr_return_len
        LEA SI, instr_return_str
        MOV AH, 07h ; Gray
    draw_instr_return:
        LODSB
        STOSW
        LOOP draw_instr_return

        ; Wait for any key press
        MOV AH, 00h
        INT 16h

        ; Go back to the main menu
        JMP draw_main_menu

    exit_game:
        ; --- CLEANUP ---
        ; Restore default video mode 03h to clear screen and show cursor again
        MOV AX, 0003h
        INT 10h

        ; Exit program to DOS
        MOV AX, 4C00h
        INT 21h

    MAIN ENDP

    ; ----------------------------------------------------
    ; Convert 16-bit Integer in AX to ASCII string in buffer pointed to by SI
    ; Safely maintains registers for VRAM manipulation hooks
    ; ----------------------------------------------------
    num_to_str PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        
        MOV BX, 10
        ADD SI, 4       ; Point to end of 5-byte buffer array
        MOV CX, 5
    clear_buf:
        MOV BYTE PTR [SI], ' '
        DEC SI
        LOOP clear_buf
        ADD SI, 5
        
    convert_loop:
        XOR DX, DX
        DIV BX
        ADD DL, '0'
        MOV [SI], DL
        DEC SI
        CMP AX, 0
        JNZ convert_loop
        
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    num_to_str ENDP

    ; ----------------------------------------------------
    ; Draw a single row of 10 bricks
    ; DI: VRAM offset, AH: Color
    ; ----------------------------------------------------
    draw_single_row PROC
        PUSH CX
        PUSH AX
        MOV CX, 10
    draw_sr_loop:
        MOV AL, 0DBh
        STOSW
        STOSW
        STOSW
        STOSW
        STOSW
        MOV AL, ' '
        STOSW
        LOOP draw_sr_loop
        POP AX
        POP CX
        RET
    draw_single_row ENDP

    END MAIN