BITS 64
section	.text
global  blend

blend:
    push rbp
    mov rbp, rsp

    push rdi    ;[rbp-8] a
    push rsi    ;[rbp-16] b
    push rdx    ;[rbp-24] d
    push rcx    ;[rbp-32] x
    ;r8 - y
    ;XMM0 - c alfa

    mov rcx, 0

    mov rbx, QWORD [rbp-8]  ;adres poczatku a
    mov eax, DWORD [rbx+2]  ;rozmiar a
    add rbx, rax    ;adres konca a
    push rbx    ;[rbp-40] adres konca a
    ;mov rax, [rbp-40]
    ;test0:

    mov rbx, QWORD [rbp-16]  ;adres poczatku b
    mov eax, DWORD [rbx+2]  ;rozmiar b
    add rbx, rax    ;adres konca b
    push rbx    ;[rbp-48]

	mov rbx, QWORD [rbp-8]  ;adres poczatku a
	mov eax, DWORD [rbx+10] ;offset a
	mov rcx, rax
	;test1:
	add rbx, rax    ;adres pixeli(danych) a
	mov rax, QWORD [rbp-32] ;x
;load_x:
    mov rdx, 0
    cmp rax, 0
    jl x_ujemny
	imul rax, 3    ;ilosc pixeli na ilosc bajtow
	add rbx, rax
	add rcx, rax
	push rbx    ;[rbp-56] wsk a
	mov r9, rbx ;wsk a
	jmp x_ujemny_end
x_ujemny:   ;ten przypadek nie powinien miec miejsca dla przyjetych zalozen
    mov rdx, rax
x_ujemny_end:
    mov rbx, QWORD [rbp-16]  ;adres poczatku b
	mov eax, DWORD [rbx+10] ;offset b
	add rbx, rax    ;adres pixeli(danych) b
	sub rbx, rdx
    push rbx    ;[rbp-64] wsk b
    mov r10, rbx    ;wsk b
    ;test2:

    mov rbx, QWORD [rbp-8]  ;adres poczatku a
    mov eax, DWORD [rbx+18]  ;szerokosc a
    imul rax, 3 ;zamiana szerokosci, pixele na bajty
    mov rdx, rax
    imul rax, 8 ;zamiana szerokosci, bajty na bity
    add rax, 31 ;dlugosc_lini+=31
    shr rax, 5  ;dlugosc_lini/=32
    shl rax, 2  ;dlugosc_lini*=4
    sub rax, rdx    ;padding
    push rax    ;[rbp-72] padding a
    ;mov rbx, QWORD [rbp+8]  ;adres poczatku a
	;add rbx, DWORD [rbx+10] ;offset a
	mov rbx, r9 ;wsk a
    add rbx, rdx    ;adres ostatniego bajtu pixeli w lini
    push rbx    ;[rbp-80] koniec lini a

    mov rbx, QWORD [rbp-16]  ;adres poczatku b
    mov eax, DWORD [rbx+18]  ;szerokosc b
    imul rax, 3 ;zamiana szerokosci, pixele na bajty
    mov rdx, rax
    imul rax, 8 ;zamiana szerokosci, bajty na bity
    add rax, 31 ;dlugosc_lini+=31
    shr rax, 5  ;dlugosc_lini/=32
    shl rax, 2  ;dlugosc_lini*=4
    sub rax, rdx    ;padding
    push rax    ;[rbp-88] padding b
    ;mov rbx, QWORD [rbp-64]  ;wsk b
    ;add rbx, rdx    ;adres ostatniego bajtu pixeli w lini
    ;push rbx    ;[rbp-96] koniec lini b
    add rdx, r10    ;adres konca linii b
    push rdx    ;[rbp-96] koniec lini b

;szerokosc:
    mov rbx, QWORD [rbp-8]  ;adres poczatku a
    mov eax, DWORD [rbx+18]  ;szerokosc a
    imul rax, 3 ;zamiana szerokosci, pixele na bajty
    push rax    ;[rbp-104] szerokosc a w bajtach

    mov rbx, QWORD [rbp-16]  ;adres poczatku b
    mov eax, DWORD [rbx+18]  ;szerokosc b
    imul rax, 3 ;zamiana szerokosci, pixele na bajty
    push rax    ;[rbp-112] szerokosc b w bajtach

    ;mov rax, QWORD [rbp+8] ;y
    mov rax, r8 ;y
    cmp rax, 0
    jl y_minus
    mov rbx, QWORD [rbp-8]  ;adres poczatku a
    mov edx, DWORD [rbx+18]  ;szerokosc a
    imul rdx, 3
    add rdx, QWORD [rbp-72] ;padding a
    imul rax, rdx   ;przesuniecie
    add rcx, rax
    ;mov	rbx, QWORD [rbp-56] ;poczatek danych a (wsk)
    ;add rbx, rax
    ;mov [rbp-56], rbx
    add r9, rax ;przesuniecie wsk a o y
    mov	rbx, QWORD [rbp-80] ;koniec lini a
    add rbx, rax
    mov [rbp-80], rbx
    jmp y_minus_end
y_minus:
y_minus_end:

    mov rax, 0
    push rax    ;[rbp-120]

    push rax    ;[rbp-128]
    ;fstp QWORD [rbp-128] ; alfa
    movups [rbp-128], XMM0


loop1:
    ;mov	rbx, QWORD [rbp-56] ;poczatek danych a (wsk)
    ;mov rax, 0
    ;mov al, BYTE [rbx]  ;weź bit koloru
    ;and rax, 0xFF    ;maska
    mov al, BYTE [r9]  ;weź bit koloru

    mov [rbp-120], rax
    fild QWORD [rbp-120]    ;bajt koloru na stos FPU
    fld QWORD [rbp-128] ;(float)alfa na stos FPU
    testf:
    fmulp   ;mnozenie- wynik na stos FPU

    fld1    ;1 na stos
    fld QWORD [rbp-128] ;(float)alfa na stos FPU
    fsubp   ;1-alfa

    ;inc rbx
    ;mov [rbp-56], rbx   ;zpisz wsk a
    inc r9

    ;mov rbx, QWORD [rbp-64] ;poczatek danych b (wsk)
    ;mov rax, 0
    ;mov al, BYTE [rbx]  ;weź bit koloru
    ;and rax, 0xFF    ;maska
    mov al, BYTE [r10]  ;weź bit koloru
    mov [rbp-120], rax
    fild QWORD [rbp-120]    ;bajt koloru na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU
    faddp   ;dodanie
    fistp QWORD [rbp-120]   ;zdjecie ze stosu jako int
    mov rax, QWORD [rbp-120]

    ;inc rbx
    ;mov [rbp-64], rbx   ;zapisz wsk b
    inc r10

    mov rbx, QWORD [rbp-24] ;*d
    add rbx, rcx
    mov BYTE [rbx], al  ;zapis
    inc rcx

    ;mov rax, QWORD [rbp-56] ;aktualny wskaznik a
    mov rbx, QWORD [rbp-80] ;aktualny koniec lini
    ;cmp rax, rbx
    cmp r9, rbx
    jg przeskocz_padding

    ;mov rax, QWORD [rbp-64] ;aktualny wskaznik b
    mov rbx, QWORD [rbp-96] ;aktualny koniec lini
    ;cmp rax, rbx
    cmp r10, rbx
    jg przeskocz_padding

    ;mov rax, QWORD [rbp-56] ;aktualny wskaznik a
    mov rbx, QWORD [rbp-40]  ;koniec a
    ;cmp rax, rbx
    cmp r9, rbx
    jg koniec  ;jesli skonczy sie plik podstawowy, to koniec

    ;mov rax, QWORD [rbp-64] ;aktualny wskaznik b
    mov rbx, QWORD [rbp-48]  ;koniec b
    ;cmp rax, rbx
    cmp r10, rbx
    jle loop1   ;jesli nie skonczyl sie jeszcze plik nakladany, to powtarzaj

    jmp koniec  ;koniec funkcji

przeskocz_padding:
    ;mov rax, QWORD [rbp-56] ;dane a
    mov rbx, QWORD [rbp-80] ;aktualny koniec lini a
    ;sub rbx, rax    ;tyle zostalo do konca lini
    sub rbx, r9    ;tyle zostalo do konca lini
    add rbx, QWORD [rbp-72] ;+ padding
    add rcx, rbx

    mov rbx, QWORD [rbp-80] ;aktualny koniec lini a
    add rbx, QWORD [rbp-72] ;+ padding
    mov rax, QWORD [rbp-32] ;x
    cmp rax, 0
    jl bez_przesuniecia
    imul rax, 3    ;ilosc pixeli na ilosc bajtow
    ;add rcx, rax    ;przesuniecie o x
	;add rbx, rax
bez_przesuniecia:
    ;mov [rbp-56], rbx   ;wsk a
    mov r9, rbx   ;wsk a

    mov rbx, QWORD [rbp-96] ;aktualny koniec lini b
    add rbx, QWORD [rbp-88] ;+ padding
    ;inc rbx
    ;mov [rbp-64], rbx   ;wsk b
    mov r10, rbx   ;wsk b

    mov rbx, QWORD [rbp-80] ;aktualny koniec lini a
    mov rax, QWORD [rbp-104] ;dlugosc lini w bajtach
    add rax, QWORD [rbp-72] ;+ padding
    add rbx, rax    ;nowy adres konca linii
    mov [rbp-80], rbx

    mov rbx, QWORD [rbp-96] ;aktualny koniec lini b
    mov rax, QWORD [rbp-112] ;dlugosc lini w bajtach
    add rax, QWORD [rbp-88] ;+ padding
    add rbx, rax    ;nowy adres konca linii
    mov rax, QWORD [rbp-32] ;x
    cmp rax, 0
    imul rax, 3
    jge dalej
    sub rbx, rax
    dalej:
    mov [rbp-96], rbx   ;koniec lini b

    jmp loop1



koniec:
	mov	rax, 0		;return 0
	mov rsp, rbp
	pop	rbp
	ret

