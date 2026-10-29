;;@details: Suma de dos dígitos. Leer dos dígitos decimales entre 0 y 9, calcular su suma y mostrar el resultado decimal correcto, incluso si es de dos dígitos.
;;@param: n1, n2, números enteros positivos 
;;
;; @return: un número entero 

section .data ;sección de declaración de variables con valor inicial

msg1 db "Ingresa un digito del 0 al 9 y presiona enter", 10
len1 equ $-msg1

msg2 db "Ingresa otro digito del 0 al 9 y presiona Enter: ", 10
len2 equ $-msg2

msg3 db "La suma es : ", 10
len3 equ $-msg3

msg4 db "Error, por favor escribe un solo digito entre 0 y 9 ", 10
len4 equ $-msg4

section .bss ;sección para declarar variables sin inicializar 
	buf resb 16    ;guarda lo que usuario teclea 
	salida resb 4 ;resultado 

section .text  ;sección de las instrucciones
	global _start 

_start:
	push dword len1 ;guarda mensajes al usuario a la pila y manda a llamar a la función 
	push dword msg1 
	call print 
	add esp, 8 
	call leer_digito 
	mov esi, eax 

	push dword len2
	push dword msg2
	call print
	add  esp, 8
	call leer_digito ;el segundo dígito queda en eax
	
	add eax, esi ;eax=eax+esi
	
	push eax
	push dword salida
	call int_to_str 
	add  esp, 8
	mov  esi, eax  ;guarda la longitud de caracteres de texto

	push dword len3
	push dword msg3
	call print
	add  esp, 8
	
	; muestra el resultado de la suma 
	push esi
	push dword salida ;dirección del texto del resultado
	call print 
	add esp, 8
	mov eax, 1
	xor ebx, ebx
	int 0x80

print: 
	push ebp     ;Prologo 
	mov ebp, esp	; EBP ahora marca el inicio de esta función en la pila
	push ebx	 ; guarda EBX porque lo vamos a modificar
	
	mov eax, 4
	mov ebx, 1 
	mov ecx, [ebp+8] ;ecx=dirección del texto
	mov edx, [ebp+12]; edx= longitud
	int  0x80

	pop ebx
	mov esp, ebp 
	pop ebp
	ret 

int_to_str:
	push ebp
	mov ebp, esp
	push edi
	
	mov eax, [ebp+12] 
	mov edi, [ebp+8] 
	xor edx, edx 
	mov ecx, 10 
	div ecx ;eax=eax/10 y edx=residuo

	cmp eax, 0
	je .unidades
	add al, '0'
	mov [edi], al
	inc edi
	
.unidades:
	add  dl, '0'            ; convierte las unidades a carácter
	mov  [edi], dl          
	inc  edi                
	mov  byte [edi], 10    
	inc  edi                
	sub  edi, [ebp+8] 
	mov  eax, edi
	pop  edi                ; restaura EDI
	mov  esp, ebp           ; epílogo
	pop  ebp
	ret

leer_digito:
	push ebp
	mov ebp, esp
	push ebx

	mov eax, 3 
	mov ebx, 0
	mov ecx, buf
	mov edx, 16
	int 0x80

	;validaciones
	cmp eax, 2 
	jne .error
	cmp byte [buf+1], 10
	jne .error
	
	movzx eax, byte [buf]
	sub eax, '0'
	cmp eax, 9
	ja  .error

	pop ebx
	mov esp, ebp
	pop ebp
	ret

.error:
	push dword len4
	push dword msg4
	call print 
	add esp, 8 
	mov eax,1
	mov ebx, 1
	int 0x80
