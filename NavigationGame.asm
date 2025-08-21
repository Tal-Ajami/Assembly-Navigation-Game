	; Tal Ajami 
	
	.model small
	.data
	
	PLAYER_LOCATION dw 2000
	PLAYER_SYMBOL db '0'

	POINT_SYMBOL db 64
	
	WALL_MSG db 'You hit the wall',0Ah,0Dh, '$'
	WIN_MSG db 'You Won The Game!! :)',0Ah,0Dh, '$'
	SCORE_MSG db 'Your Score Is: ', '$'
	
	LAST_PRESSED db '*'
	
	WALL1_LOCATION dw 0
	WALL2_LOCATION dw 0
	WALL3_LOCATION dw 0

	CURRENT_WALL db 1  ; Variable to track current wall

	POINT_LOCATION dw ? 
	POINT_TIMER dw 0FFFFh
	END_GAME dw 0
	
	
	.stack 100h
	.code
	
	NEW_ISR proc far uses ax bx dx es
		
		mov ax, END_GAME
		cmp ax, 1
		je END_OF_ISR2
		
	;DI counts the calling to the interupt
		inc di
		
		mov ax, di
		mov bx, 4
		mov dx, 0
		div bx
		
		cmp dx, 0 ;if DI%4=0 
		jne END_OF_ISR
		
		mov al, LAST_PRESSED
		
		cmp al, '*'
		je END_OF_ISR
		
		cmp al, 'W'
		je W_PRESSED_ISR
		cmp al, 'A'
		je A_PRESSED_ISR
		cmp al, 'S'
		je S_PRESSED_ISR
		cmp al, 'D'
		je D_PRESSED_ISR
		cmp al, 'T'
		je T_PRESSED_ISR
		
		W_PRESSED_ISR:
		call W_PRESSED_PROC
		mov di, 0
		jmp END_OF_ISR
		
		A_PRESSED_ISR:
		call A_PRESSED_PROC
		mov di, 0
		jmp END_OF_ISR
		
		S_PRESSED_ISR:
		call S_PRESSED_PROC
		mov di, 0
		jmp END_OF_ISR
		
		D_PRESSED_ISR:
		call D_PRESSED_PROC
		mov di, 0
		jmp END_OF_ISR
		
		T_PRESSED_ISR:
		call T_PRESSED_PROC
		mov di, 0
		jmp END_OF_ISR
		
		
		END_OF_ISR:
		mov ax, POINT_TIMER
		cmp ax, 0FFFFh
		je END_OF_ISR2
		
		cmp ax, 60
		je POINT_TIMER_IS_60
		
		cmp ax, 120
		je POINT_TIMER_IS_120
		
		jmp NOT_60_OR_120
		
		POINT_TIMER_IS_120:
		mov al, POINT_SYMBOL
		dec al
		mov POINT_SYMBOL, al
		
		mov bx, POINT_LOCATION
		mov al, ' '
		mov ah, 0
		mov es:[bx], ax
		call PRINT_POINT
		jmp END_OF_ISR2
		
		POINT_TIMER_IS_60:
		mov bx, POINT_LOCATION
		mov al, POINT_SYMBOL
		mov ah, 0EFh
		mov es:[bx], ax
		
		NOT_60_OR_120:
		mov ax, POINT_TIMER
		inc ax
		mov POINT_TIMER, ax
		
		
		END_OF_ISR2:
		;prev_isr
		int 80h
	
	
		mov al, 20h
		out 20h, al
		
		
		iret
	NEW_ISR endp
	
			
	PRINT_WALL proc uses ax bx dx

	mov ax, 0B800h
	mov es, ax

	FIND_RANDOM_LOCATION_WALL:
	; Read from real time clock: seconds in ah and minutes in al
	mov al, 00h
	out 70h, al
	in al, 71h
	mov ah, al
	mov al, 02h
	out 70h, al
	in al, 71h

	mov bx, 2000
	mov dx, 0
	div word ptr bx
	mov bx, 0
	mov bx, dx
	add bx, bx ; bx now holds the time offset

	CHECK_IF_EMPTY_WALL:
	; Checks if there is a player symbol or a wall in this random location

	; Check if the wall is in the players starting position
	cmp bx, 2000
	je FIND_RANDOM_LOCATION_WALL

	CHECK_WALL1:
	mov ax, WALL1_LOCATION
	cmp ax, 0  
	je CHECK_WALL2  ; If empty, go to next check
	cmp bx, ax
	je FIND_RANDOM_LOCATION_WALL

	CHECK_WALL2:
	mov ax, WALL2_LOCATION
	cmp ax, 0  
	je CHECK_WALL3
	cmp bx, ax
	je FIND_RANDOM_LOCATION_WALL

	CHECK_WALL3:
	mov ax, WALL3_LOCATION
	cmp ax, 0  
	je DETERMINE_WALL_TO_SAVE
	cmp bx, ax
	je FIND_RANDOM_LOCATION_WALL

	DETERMINE_WALL_TO_SAVE:
	; Determine which wall to save based on CURRENT_WALL
	cmp CURRENT_WALL, 1
	je SAVE_LOCATION_WALL1
	cmp CURRENT_WALL, 2
	je SAVE_LOCATION_WALL2
	cmp CURRENT_WALL, 3
	je SAVE_LOCATION_WALL3
	jmp SAVE_LOCATION_WALL1  ; Default case

	SAVE_LOCATION_WALL1:
	mov WALL1_LOCATION, bx
	mov CURRENT_WALL, 2  ; Update to next wall
	jmp PRINT_THE_WALL

	SAVE_LOCATION_WALL2:
	mov WALL2_LOCATION, bx
	mov CURRENT_WALL, 3  ; Update to next wall
	jmp PRINT_THE_WALL

	SAVE_LOCATION_WALL3:
	mov WALL3_LOCATION, bx
	mov CURRENT_WALL, 1  ; Reset to first wall
	jmp PRINT_THE_WALL

	PRINT_THE_WALL:
	; Print new wall
	mov al, '#'
	mov ah, 07h  ; Display attributes (white on black background)
	mov es:[bx], ax

	ret
	PRINT_WALL endp


	
	
	PRINT_POINT proc far uses ax bx dx
	
	FIND_RANDOM_LOCATION:
	;read from real time clock: seconds in ah and minutes in al
	mov al, 00h
	out 70h, al
	in al, 71h
	mov ah, al
	mov al, 02h
	out 70h, al
	in al, 71h
	
	
	mov bx, 2000
	mov dx, 0
	div word ptr bx
	mov ax, dx
	add ax, ax

	
	CHECK_IF_EMPTY:
	;checks if there is a player symbol or a wall in this random location
	mov bx, ax ;bx now holds the time offset
	
	mov ax, WALL1_LOCATION
	cmp bx, ax
	je FIND_RANDOM_LOCATION
	
	
	mov ax, WALL2_LOCATION
	cmp bx, ax
	je FIND_RANDOM_LOCATION
	
	
	mov ax, WALL3_LOCATION
	cmp bx, ax
	je FIND_RANDOM_LOCATION
	
	
	mov ax, PLAYER_LOCATION
	cmp bx, ax
	je FIND_RANDOM_LOCATION
	
	
	;print new point
	mov POINT_LOCATION, bx
	mov ax, 0
	mov al, POINT_SYMBOL
	inc al
	mov POINT_SYMBOL, al
	mov ah, 07h
	mov es:[bx], ax
	mov POINT_TIMER, 0
	
	ret
	PRINT_POINT endp
	
	
	
	
	
	CHECK_FOR_COLLISION proc far uses bx ax cx dx
	
		mov bx, PLAYER_LOCATION
			
		mov ax, WALL1_LOCATION
		cmp bx, ax
		je HIT_A_WALL
		
		mov ax, WALL2_LOCATION
		cmp bx, ax
		je HIT_A_WALL
		
		mov ax, WALL3_LOCATION
		cmp bx, ax
		je HIT_A_WALL
		
		jmp CHECK_FOR_COLLISION_POINT 
		
		HIT_A_WALL:
		;if it is a wall: print a message and end the game
		mov dx, offset WALL_MSG
		mov ah, 9h
		int 21h
		call END_OF_GAME
		
		CHECK_FOR_COLLISION_POINT:
		;checks if the player hit a point
		
		mov ax, POINT_LOCATION
		cmp bx, ax
		je HIT_A_POINT
		jmp END_OF_CHECK_FOR_COLLISION
		
		HIT_A_POINT:
		;if the player hit a point, create a new one
		call PRINT_POINT
		
		;check if the player got 9 points and won the game
		mov bl, POINT_SYMBOL
		cmp bl, 'J' 
		jne END_OF_CHECK_FOR_COLLISION
		
		;if the player got 9 points, print a winning message and end the game
		mov dx, offset WIN_MSG
		mov ah, 9h
		int 21h
		call END_OF_GAME
		
		END_OF_CHECK_FOR_COLLISION:
		
		ret
	CHECK_FOR_COLLISION endp
	
	
	
	
	END_OF_GAME proc
		
		mov END_GAME, 1
		
		ret 
	END_OF_GAME endp
	
	
	
	T_PRESSED_PROC proc
		call END_OF_GAME
		ret
	T_PRESSED_PROC endp 
	
	
	
	
	
	W_PRESSED_PROC proc far uses ax bx
	
		mov bx, PLAYER_LOCATION
		cmp bx, 160   ;check if player is out of screen
		jb OUT_OF_SCREEN_W
		
		mov ah, 0
		mov al, 32
		
		mov es:[bx], ax ;"delete" previous player location by printing space with black background
		sub bx, 160 ;move up
		mov PLAYER_LOCATION, bx
		
		call CHECK_FOR_COLLISION
		
		mov al, PLAYER_SYMBOL
		mov ah, 4
		mov es:[bx], ax ;print the player in the new location
		jmp W_PRESSED_PROC_END
		
		OUT_OF_SCREEN_W:
		call OUT_OF_SCREEN_PROC
		
		W_PRESSED_PROC_END:
		ret
	W_PRESSED_PROC endp 
	
	
	
	
	
	S_PRESSED_PROC proc far uses ax bx
	
		mov bx, PLAYER_LOCATION
		cmp bx, 3840   ;check if player is out of screen
		jae OUT_OF_SCREEN_S
		
		mov al, 32
		mov ah, 0
		mov es:[bx], ax ;"delete" previous player location by printing space with black background
		
		add bx, 160 ;move down
		mov PLAYER_LOCATION, bx
		
		call CHECK_FOR_COLLISION
		
		mov al, PLAYER_SYMBOL
		mov ah, 4
		mov es:[bx], ax ;print the player in the new location
		jmp S_PRESSED_PROC_END
		
		OUT_OF_SCREEN_S:
		call OUT_OF_SCREEN_PROC
		
		S_PRESSED_PROC_END:
		ret
	S_PRESSED_PROC endp 
	
	
	
	
	A_PRESSED_PROC proc far uses ax bx cx dx
	
		mov bx, PLAYER_LOCATION
		
		;check if player is out of screen=
		mov ax, bx
		mov dx, 0
		mov cx, 160
		div word ptr cx
		cmp dx, 0
		je OUT_OF_SCREEN_A
		
		mov al, 32
		mov ah, 0
		mov es:[bx], ax ;"delete" previous player location by printing space with black background
		
		sub bx, 2 ;move left
		mov PLAYER_LOCATION, bx
		
		call CHECK_FOR_COLLISION
		
		mov al, PLAYER_SYMBOL
		mov ah, 4
		mov es:[bx], ax ;print the player in the new location
		jmp A_PRESSED_PROC_END
		
		OUT_OF_SCREEN_A:
		call OUT_OF_SCREEN_PROC
		
		A_PRESSED_PROC_END:
		ret
	
	A_PRESSED_PROC endp 
	
	
	
	
	
	D_PRESSED_PROC proc far uses ax bx cx dx
	
		mov bx, PLAYER_LOCATION
		
		;check if player is out of screen
		push dx
		push cx
		mov ax, bx
		mov dx, 0
		mov cx, 160
		div word ptr cx
		cmp dx, 158
		pop cx
		pop dx
		je OUT_OF_SCREEN_D
		
		mov al, 32
		mov ah, 0
		mov es:[bx], ax ;"delete" previous player location by printing space with black background
		
		add bx, 2 ;move right
		mov PLAYER_LOCATION, bx
		
		call CHECK_FOR_COLLISION
		
		mov al, PLAYER_SYMBOL
		mov ah, 4
		mov es:[bx], ax ;print the player in the new location
		jmp D_PRESSED_PROC_END
		
		OUT_OF_SCREEN_D:
		call OUT_OF_SCREEN_PROC
		
		D_PRESSED_PROC_END:
		ret
	D_PRESSED_PROC endp 
	
	
	
	
	
	OUT_OF_SCREEN_PROC proc far uses dx ax
		mov dx, offset WALL_MSG
		mov ah, 9h
		int 21h
		call END_OF_GAME
		ret
	OUT_OF_SCREEN_PROC endp
	
	

	START:
	
	mov di, -1 	;DI counts the calling to the interupt
	
	mov ax, 0h ; IVT is location is '0000' address of RAM
	mov es, ax
	
	cli ; block interrupts
	
	;moving Int8 into IVT[080h]
	mov ax, es:[32] ;copying old ISR 8 IP to free vector
	mov es: [512], ax
	mov ax, es:[34] ;copying old ISR 8 CS to free vector
	mov es: [514], ax
	
	;moving NEW_ISR into IVT[8]
	mov ax, offset NEW_ISR
	mov es:[32], ax
	mov ax, cs
	mov es:[34], ax
	
	sti ;enable interrupts
	
	
	in al, 21h 
	or al, 02h 
	out 21h, al
	
	;setting data segment
	mov ax, @data
	mov ds, ax
	;setting extra segment to screen mem
	mov ax,0b800h 
	mov es, ax 
	
	;paint the screen black
	mov ah, 0
	mov al, 32
	mov bx, 3998
	PRINT_SPACES:
	mov es:[bx], ax
	sub bx, 2
	cmp bx, 0
	ja PRINT_SPACES
	mov bx, 0
	mov es:[bx], ax
	
	;print the player
	mov bx, PLAYER_LOCATION
	mov al, PLAYER_SYMBOL
	mov ah, 4
	mov es:[bx], ax
	;print 3 walls
	call PRINT_WALL
	call PRINT_WALL
	call PRINT_WALL
	;print point
	call PRINT_POINT

	CheckKeyboard: 
		mov ax, END_GAME
		cmp ax, 1
		je FINISH
		
		in   al, 64h     ; Read the keyboard controller's status port
		test al, 01h     ; Check if data is available 
		jz   NoKey       ; If no input is available, exit the check and continue the main loop

		in   al, 60h     ; store scan code in AL

		test al, 80h     ; Check if the msb (bit 7) is 1 (a key was released)
		jz NoKey       ; If it's a key press (bit 7 is 0), ignore it and exit the check

		KeyReleased:   ;W- 17  A-30  S-31  D-32  T-20
		cmp al, 91h
		je W_PRESSED
		cmp al, 9Eh
		je A_PRESSED
		cmp al, 9Fh
		je S_PRESSED
		cmp al,0A0h
		je D_PRESSED
		cmp al, 94h
		je T_PRESSED
		
		jmp CheckKeyboard


		T_PRESSED:
		mov bl, 'T'
		mov LAST_PRESSED, bl
		jmp CheckKeyboard
	
		W_PRESSED:
		mov bl, 'W'
		mov LAST_PRESSED, bl
		jmp CheckKeyboard
		
		S_PRESSED:
		mov bl, 'S'
		mov LAST_PRESSED, bl
		jmp CheckKeyboard
		
		A_PRESSED:
		mov bl, 'A'
		mov LAST_PRESSED, bl
		jmp CheckKeyboard

		D_PRESSED:
		mov bl, 'D'
		mov LAST_PRESSED, bl
		jmp CheckKeyboard
		
		NoKey: 		
		jmp CheckKeyboard
		
		
		FINISH:
		
		mov bl, POINT_SYMBOL
		sub bl, 17 ;bx now contain the ascii value of the players score

		mov dx, offset SCORE_MSG ;print "your score is"
		mov ah, 9h
		int 21h
	
		mov dl, bl ;print the score
		mov ah, 2h
		int 21h
		
		mov ax, 0
		mov es, ax
		
		cli ; block interrupts
	
		;moving IVT[080h] back into IVT[08]
		mov ax, es:[512]
		mov es: [32], ax
		mov ax, es:[514] 
		mov es: [34], ax
		
		
		in al, 21h 
		and al, 0FDh   
		out 21h, al
					
					
		mov al, 0FFh
		out 60h, al

		sti  ; enable interrupts
		
			
		
		
		
		;return to OS
		mov ax, 4c00h
		int 21h
		
		
	
	End START
