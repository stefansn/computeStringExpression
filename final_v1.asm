.386
.model flat,stdcall

includelib msvcrt.lib
extern exit:proc
extern scanf:proc
extern printf:proc
extern strlen:proc
extern atoi:proc
extern strcmp:proc

public start

.data
	mesaj_citire db "----->Give an expression: ",13,10,0
	format_expresie db "%s",0
	expresie db 20 dup('#'),0
	lungime_sir db 0
	format_rez db "%d",0
	array dd 40 dup (?)
	numar_format dd 0
	putere db 0 
	eroare db "eroare",13,10,0 
	zece db 10
	cod_exit db "exit",0
	rezultat_anterior dd 0
.code
;#########################


;#########################
start:	
	again:
	mov edi,esp 
	citire:
		push offset mesaj_citire
		call printf
		add esp,4
	
		push offset expresie
		push offset format_expresie
		call scanf
		add esp,8
		
		push offset expresie
		push offset cod_exit
		call strcmp
		add esp,8
		
		cmp al,0
		je exit_out
	
		push offset expresie
		call strlen
		add esp,4
		
		mov ecx,eax
		mov lungime_sir,cl ;lungimea expresiei citite
	
		xor edx,edx
		mov esi,0
		
		mov ebx,0
		parcurgere_expresie:
			mov eax,0
			
			mov bl,expresie[esi]
			
			cmp bl,'0'
			jb is_operator
			cmp bl,'9'
			ja is_operator
			
			to_number:				;aici formez numerele, ex: 123 : 1+0*10   ->   2+1*10    >    3+12*10 = 123
				mov ebx,0
				mov bl,expresie[esi]		
				
				cmp bl,'='
				je is_operator				
				cmp bl,'0'
				jb place_number
				cmp bl,'9'
				ja place_number
				
				
				sub bl,'0'
				mul zece 
				add eax,ebx
				
				inc esi
			jmp to_number
			
			place_number:
			push eax
			
			
			is_operator:
				mov bl,expresie[esi]
				cmp bl,'='
				je parcurgere_stack
				
				cmp bl,'*'
				je efectuare_inmultire
				
				cmp bl,'/'
				je efectuare_impartire			
				
				push ebx
				inc esi
									
		
		jmp parcurgere_expresie
		
		efectuare_inmultire: ;am numarul din stanga, stiu ca urmeaza dupa acesta *, nevoie deci de numarul din dreapta
			
			mov eax,0
			to_number1:
				inc esi
				mov bl,expresie[esi]
				cmp bl,'0'
				jb not_number1
				cmp bl,'9'
				ja not_number1
				
				sub bl,'0'
				mul zece
				add eax,ebx					
			jmp to_number1			
			not_number1:
			pop ebx
			mul ebx			
			push eax
		jmp parcurgere_expresie
		
		efectuare_impartire:
			mov edx,0
			mov eax,0
			to_number2:
				inc esi
				mov bl,expresie[esi]
				cmp bl,'0'
				jb not_number2
				cmp bl,'9'
				ja not_number2
				
				sub bl,'0'
				mul zece
				add eax,ebx
			jmp to_number2

			not_number2:
			mov ebx,0
			pop ebx
			xchg eax,ebx
			cmp ebx,0
			je error_la_impartire
			div ebx
			push eax
		jmp parcurgere_expresie
	

;################## aici calcul + - in stiva #############################	
		parcurgere_stack:
		push eax
		push '='
		
			verificare_primul_element:

				mov eax,[edi-4]
				cmp eax,'-'
				jne temp
				
				
				je scadere_primul_element
				temp:
				cmp eax,'+'
				je adunare_un_singur_element				
			
				
				sub edi,4
				jmp calcul_final
				
				scadere_primul_element:
				mov ebx,0
				mov ebx,rezultat_anterior
				sub ebx,[edi-8]
				
				jmp over
				
				adunare_un_singur_element:
				mov ebx,0
				mov ebx,rezultat_anterior
				add ebx,[edi-8]
			
				
				over:
				
				sub edi,4
				mov [edi-4],ebx
				sub edi,4
				
				mov eax,ebx
				mov ecx,'='	
				pop edx
				cmp [edi-4],ecx
				je afisare	
				push edx
	
			calcul_final:
				mov eax,[edi]
				mov ebx,[edi-4]
				mov ecx,[edi-8]
				
				cmp ebx,'-'
				je scadere_finala
				
				add eax,ecx
				sub edi,8
				mov [edi],eax
				
				jmp salt
				
				scadere_finala:
				sub eax,ecx
				sub edi,8
				mov [edi],eax
			salt:
			mov ecx,'='
			cmp [edi-4],ecx
			je afisare
			jmp calcul_final
			
				
		
		afisare:
		mov rezultat_anterior,eax
		push eax
		push offset format_rez
		call printf
		add esp,8
		
	
		
		
		jmp again
		
		
				
	
		error_la_impartire:
		push offset eroare
		call printf
		add esp,4
		
		
		jmp again
		
		
		exit_out:
push 0
call exit
end start