..DATA

sum dw 0
v dw 2 DUP(0)
v0 dw 10325
v1 dw 20123
delta dw 0130h
;k dw 4 DUP(0),0
k0 dw 1
k1 dw 2
k2 dw 3
k3 dw 4

linefeed db 13, 10, "$"

.CODE

encrypt PROC
    
    mov sum, 0
    
    mov cx, 32

    encryptLoop:
    
        ;sum+=delta
        mov ax, delta
        add sum ,ax
        
        ;(v1<<4)+k0
        mov ax, v1
        shl ax, 4
        add ax, k0
        
        ;v1+sum 
        mov bx, v1
        add bx, sum 
        
        xor ax, bx 
        
        ;(v1>>5)+k1
        mov bx, v1
        shr bx, 5  
        add bx, k1 
        
        xor ax, bx  
        
        ;v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1)
        add v0, ax 

        ;(v0<<4)+k2
        mov ax, v0
        shl ax, 4
        add ax, k2 
        
        ;v0+sum
        mov bx, v0
        add bx, sum 
        
        xor ax, bx
        
        ;(v0>>5) + k3
        mov bx, v0
        shr bx, 5  
        add bx, k3
        
        xor ax, bx  
        ;v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3)
        add v1, ax 

    loop encryptLoop

    ;values[0] = v0
    mov ax, v0
    CALL PRINT
    mov [v] , ax
    
    ;new line
    mov ah, 09
    mov dx, offset linefeed
    int 21h
    

    ;values[1] = v1
    mov ax, v1
    CALL PRINT
    mov [v+2] , ax
    
    ;new line
    mov ah, 09
    mov dx, offset linefeed
    int 21h

    ret

encrypt ENDP
decrypt PROC
    
    ;sum = delta<<5
    mov bx, delta
    shl bx, 5
    AND bx, 0FFFFH 
    mov sum, bx

    ;loop 32 times
    mov cx, 32

    decryptLoop:

        ;(v0<<4)+k2
        mov ax, v0
        shl ax, 4
        add ax, k2 
    
        ;(v0 + sum)
        mov bx, v0
        add bx, sum

        xor ax, bx 
        ;(v0 >> 5) + k3
        mov bx, v0
        shr bx, 5  
        add bx, k3    

        xor ax,bx  

        sub v1, ax 
        
        ;(v1<<4)+k0
        mov ax, v1
        shl ax, 4
        add ax, k0
    
        ;(v1 + sum)
        mov bx, v1
        add bx, sum

        xor ax, bx 

        ;(v1 >> 5) + k1
        mov bx, v1
        shr bx, 5  
        add bx, k1   
        
        xor ax, bx 

        sub v0, ax 


        ;sum -= delta;
        mov ax, delta
        sub sum ,ax

    loop decryptLoop

    ;values[0] = v0
    mov ax, v0
    CALL PRINT
    mov [v] , ax
    
    ;new line
    mov ah, 09
    mov dx, offset linefeed
    int 21h

    ;values[1] = v1
    mov ax, v1
    CALL PRINT
    mov [v+2] , ax
    ;new line
    mov ah, 09
    mov dx, offset linefeed
    int 21h

    ret
decrypt ENDP

;decrybtion function
MOV ESI, OFFSET ENC_string     ; ESI is pointing at the beginig of the encrypted message
MOV EDX, OFFSET ENC_string	; EDX = Begining of ENC_string
ADD EDX, ENC_string		; EDX = MSG_ENC + 4*(Length)
SUB EDX, 8                      ; EDX = MSG_ENC + 4*(Length - 2) "end of string"
MESSAGE_LOOP:
    MOV ECX, 32 
    MOV SUM, 0C6EF3720H
DECRYPTION_LOOP:     ; Calculating V[1]  
        MOV EAX, [ESI]              ; EAX = V[0]
        SHL EAX, 4                  ; EAX = (V[0]<<4)
        ADD EAX, KEY_2              ; EAX = (V[0]<<4 + KEY[2])
        MOV EBX, [ESI]              ; EBX = V[0]
        ADD EBX, SUM                ; EBX = V[0] + sum
        XOR EAX, EBX                ; EAX = (V[0]<<4 + KEY[2]) ^ (V[0] + sum)
        MOV EBX, [ESI]              ; EBX = V[0]
        SHR EBX, 5                  ; EBX = V[0]>>5
        ADD EBX, KEY_3              ; EBX = V[0]>>5 + KEY[3]
        XOR EAX, EBX                ; EAX = (V[0]<<4 + KEY[2]) ^ (V[0] + sum) ^ (V[0]>>5 + KEY[3])
        SUB [ESI+4], EAX            ; V[1] -= (V[0]<<4 + KEY[2]) ^ (V[0] + sum) ^ (V[0]>>5 + KEY[3])

; Calculating V[0]
        MOV EAX, [ESI+4]            ; EAX = V[1]
        SHL EAX, 4                  ; EAX = (V[1]<<4)
        ADD EAX, KEY_0              ; EAX = (V[1]<<4 + KEY[0])
        MOV EBX, [ESI+4]            ; EBX = V[1]
        ADD EBX, SUM                ; EBX = V[1] + sum
        XOR EAX, EBX                ; EAX = (V[1]<<4 + KEY[0]) ^ (V[1] + sum)
        MOV EBX, [ESI+4]            ; EBX = V[1]
        SHR EBX, 5                  ; EBX = V[1]>>5
        ADD EBX, KEY_1              ; EBX = V[1]>>5 + KEY[1]
        XOR EAX, EBX                ; EAX = (V[1]<<4 + KEY[0]) ^ (V[1] + sum) ^ (V[1]>>5 + KEY[1])
        SUB [ESI], EAX              ; V[0] -= (V[1]<<4 + KEY[0]) ^ (V[1] + sum) ^ V[1]>>5 + KEY[1])

        MOV EBX, DELTA              ; EBX =  0x9e3779b9
        SUB SUM, EBX                ; SUM -= 0x9e3779b9

    LOOP DECRYPTION_LOOP

CMP ESI, EDX			; If ESI is at The End of MSG_ENC Then leave
	JZ OUT_OF_LOOP
    ADD ESI, 8                 ; else

JMP MESSAGE_LOOP                  ; return to begining

; Copy The Encrypted Message into The Real Message

MOV EAX, ENC_string_LEN
SHR EAX, 2
MOV ECX, EAX
MOV EBX, 0
MOV EDX, 0
COPY_LOOP:
    MOV EAX, ENC_string[EDX] 
	MOV MSG[EBX], AL
	ADD EBX, 1
	ADD EDX, 4
LOOP COPY_LOOP



combine PROC 

movzx edx, [turn+0] 

mov eax, 0
mov al, [turn+1]
shl eax, 8 

or edx, eax 

mov eax, 0
mov al, [turn+2]
shl eax, 16 

or edx, eax 

mov eax, 0
mov al, [turn+3]
shl eax, 24 

or edx, eax
mov [values+0], edx 

movzx edx, [turn+4] 

mov eax, 0
mov al, [turn+5]
shl eax, 8 

or edx, eax
mov eax, 0
mov al, [turn+6]
shl eax, 16 

or edx, eax 

mov eax, 0
mov al, [turn+7]
shl eax, 24 

or edx, eax
mov [values+4], edx 

ret
combine ENDP
