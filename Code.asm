.386
.MODELSMALL
.DATA


sum dd 0
values dd 2 DUP(0)
v0 dd ?
v1 dd ?
delta dd 9e3779b9h ;constant
key dd 4 DUP(0)


.CODE

encrypt procedure
    mov sum, 0
    mov eax, [values]
    mov v0, eax
    mov eax, [values+4]
    mov v1, eax
    mov ecx, 32
    encryptLoop:
        mov eax, delta
        add sum ,eax
        mov eax, v1
        shl eax, 4
        add eax, [key] ; eax =(v1 << 4) + key[0])
        mov ebx, v1
        add ebx, sum ; ebx = (v1 + sum)
        xor eax, ebx ; eax = (v1 << 4) + key[0]) ^ (v1 + sum)
        mov ebx, v1
        shr ebx, 5  ;ebx = (v1 >> 5)
        add ebx, [key+4]    ;ebx =(v1 >> 5) + key[1]
        xor eax, ebx  ; eax = ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
        add v0, eax ;v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
        mov eax, v0
        shl eax, 4
        add eax, [key+8] ; eax =(v0 << 4) + key[2])
        mov ebx, v0
        add ebx, sum ; ebx = (v0 + sum)
        xor eax, ebx ; eax = (v0 << 4) + key[2]) ^ (v0 + sum)
        mov ebx, v0
        shr ebx, 5  ;ebx = (v0 >> 5)
        add ebx, [key+12]    ;ebx =(v0 >> 5) + key[3]
        xor eax, ebx  ; eax = ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
        add v1, eax ;v1 += ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
    loop encryptLoop
    mov eax, v0
    mov [values] , eax
    mov eax, v1
    mov [values+4] , eax

    ret

encrypt ENDP
