.DATA

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
main PROC
         MOV AX,@DATA
         MOV DS,AX
         
         ;Print initial value in v0
         mov ax,v0
         CALL PRINT
         
         ;new line
         mov ah, 09
         mov dx, offset linefeed
         int 21h
         
         ;Print initial value in v1
         mov ax,v1
         CALL PRINT
         
         ;new line
         mov ah, 09
         mov dx, offset linefeed
         int 21h
         
         
         ;Do encryption for (v0 & v1)
         CALL encrypt
         
         ;new line
         mov ah, 09
         mov dx, offset linefeed
         int 21h 
         
         ;Do encryption for (v0 & v1)
         CALL decrypt
         
         ;new line
         mov ah, 09
         mov dx, offset linefeed
         int 21h
         
         
         ;interrupt to exit			
	     MOV AH,4CH
	     INT 21H

            
          
            
            
            
            
            
main ENDP


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

PRINT PROC		
	
	;initialize count
	mov cx,0
	mov dx,0
	label1:
		; if ax is zero
		cmp ax,0
		je print1	
		
		;initialize bx to 10
		mov bx,10	
		
		; extract the last digit
		div bx				
		
		;push it in the stack
		push dx			
		
		;increment the count
		inc cx			
		
		;set dx to 0
		xor dx,dx
		jmp label1
	print1:
		;check if count
		;is greater than zero
		cmp cx,0
		je exit
		
		;pop the top of stack
		pop dx
		
		;add 48 so that it
		;represents the ASCII
		;value of digits
		add dx,48
		
		;interrupt to print a
		;character
		mov ah,02h
		int 21h
		
		;decrease the count
		dec cx
		
		jmp print1
exit:
ret
PRINT ENDP
END main
.EXIT
END
