BITS 64
section	.text
global  blend

blend:
    push rbp
    mov rbp, rsp

    mov rcx, 0

    mov rbx, QWORD [rbp+8]  ;adres poczatku a
    mov rax, QWORD [rbx+2]  ;rozmiar a
    add rbx, rax    ;adres konca a
    push rbx    ;[rbp-4]

    mov rbx, QWORD [rbp+12]  ;adres poczatku b
    mov rax, QWORD [rbx+2]  ;rozmiar b
    add rbx, rax    ;adres konca b
    push rbx    ;[rbp-8]

	mov rbx, QWORD [rbp+8]  ;adres poczatku a
	mov rax, QWORD [rbx+10] ;offset a
	mov rcx, rax
	add rbx, rax    ;adres pixeli(danych) a
	mov rax, QWORD [rbp+24] ;x
;load_x:
    mov rdx, 0
    cmp rax, 0
    jl x_ujemny
	imul rax, 3    ;ilosc pixeli na ilosc bajtow
	add rbx, rax
	add rcx, rax
	push rbx    ;[rbp-12]
	jmp x_ujemny_end
x_ujemny:
    mov rdx, rax
x_ujemny_end:
    mov rbx, QWORD [rbp+12]  ;adres poczatku b
	mov rax, QWORD [rbx+10] ;offset b
	add rbx, rax    ;adres pixeli(danych) b
	sub rbx, rdx
    push rbx    ;[rbp-16]

    mov rbx, QWORD [rbp+8]  ;adres poczatku a
    mov rax, QWORD [rbx+18]  ;szerokosc a
    imul rax, 3 ;zamiana szerokosci, pixele na bajty
    mov rdx, rax
    imul rax, 8 ;zamiana szerokosci, bajty na bity
    add rax, 31 ;dlugosc_lini+=31
    shr rax, 5  ;dlugosc_lini/=32
    shl rax, 2  ;dlugosc_lini*=4
    sub rax, rdx    ;padding
    push rax    ;[rbp-20]

    mov rbx, QWORD [rbp+8]  ;adres poczatku a
	add rbx, QWORD [rbx+10] ;offset a
    add rbx, rdx    ;adres ostatniego bajtu pixeli w lini
    push rbx    ;[rbp-24]

    mov rbx, QWORD [rbp+12]  ;adres poczatku b
    mov rax, QWORD [rbx+18]  ;szerokosc b
    imul rax, 3 ;zamiana szerokosci, pixele na bajty
    mov rdx, rax
    imul rax, 8 ;zamiana szerokosci, bajty na bity
    add rax, 31 ;dlugosc_lini+=31
    shr rax, 5  ;dlugosc_lini/=32
    shl rax, 2  ;dlugosc_lini*=4
    sub rax, rdx    ;padding
    push rax    ;[rbp-28]

    mov rbx, QWORD [rbp-16]  ;adres danych b
    add rbx, rdx    ;adres ostatniego bajtu pixeli w lini
    push rbx    ;[rbp-32]

;szerokosc:
    mov rbx, QWORD [rbp+8]  ;adres poczatku a
    mov rax, QWORD [rbx+18]  ;szerokosc a
    imul rax, 3 ;zamiana szerokosci, pixele na bajty
    push rax    ;[rbp-36]

    mov rbx, QWORD [rbp+12]  ;adres poczatku b
    mov rax, QWORD [rbx+18]  ;szerokosc b
    imul rax, 3 ;zamiana szerokosci, pixele na bajty
    push rax    ;[rbp-40]

    mov rax, QWORD [rbp+28] ;y
    cmp rax, 0
    jl y_minus
    mov rbx, QWORD [rbp+8]  ;adres poczatku a
    mov rdx, QWORD [rbx+18]  ;szerokosc a
    imul rdx, 3
    add rdx, QWORD [rbp-20] ;padding
    imul rax, rdx   ;przesuniecie
    add rcx, rax
    mov	rbx, QWORD [rbp-12] ;poczatek danych a
    add rbx, rax
    mov [rbp-12], rbx
    mov	rbx, QWORD [rbp-24] ;koniec lini
    add rbx, rax
    mov [rbp-24], rbx
    jmp y_minus_end
y_minus:
y_minus_end:

    mov rax, 0
    push rax    ;[rbp-44]

loop1:
    mov	rbx, QWORD [rbp-12] ;poczatek danych a
    mov rax, 0
    mov al, BYTE [rbx]  ;weź bit koloru
    mov	rbx, QWORD [rbp+20] ;poczatek danych a
    add rbx, rcx
    mov rdx, 0
    mov dl, BYTE [rbx]  ;weź bit koloru
testuj:

    mov	rbx, QWORD [rbp-12] ;poczatek danych a
    mov rax, 0
    mov al, BYTE [rbx]  ;weź bit koloru
    and rax, 0xFF    ;maska

    mov [rbp-44], rax
    fild QWORD [rbp-44]    ;bajt koloru na stos FPU
    fld QWORD [rbp+16] ;(float)alfa na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU

    fld1    ;1 na stos
    fld QWORD [rbp+16] ;(float)alfa na stos FPU
    fsubp   ;1-alfa

    inc rbx
    mov [rbp-12], rbx

    mov rbx, QWORD [rbp-16] ;poczatek danych b
    mov rax, 0
    mov al, BYTE [rbx]  ;weź bit koloru
    and rax, 0xFF    ;maska
    mov [rbp-44], rax
    fild QWORD [rbp-44]    ;bajt koloru na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU
    faddp   ;dodanie
    fistp QWORD [rbp-44]   ;zdjecie ze stosu jako int
    mov rax, QWORD [rbp-44]

    inc rbx
    mov [rbp-16], rbx

    mov rbx, QWORD [rbp+20] ;*d
    add rbx, rcx
    mov BYTE [rbx], al  ;zapis
    inc rcx

    mov rax, QWORD [rbp-12] ;aktualny wskaznik a
    mov rbx, QWORD [rbp-24] ;aktualny koniec lini
    cmp rax, rbx
    jg przeskocz_padding

    mov rax, QWORD [rbp-16] ;aktualny wskaznik b
    mov rbx, QWORD [rbp-32] ;aktualny koniec lini
    cmp rax, rbx
    jg przeskocz_padding

    mov rax, QWORD [rbp-12] ;aktualny wskaznik a
    mov rbx, QWORD [rbp-4]  ;koniec a
    cmp rax, rbx
    jg koniec  ;jesli skonczy sie plik podstawowy, to koniec

    mov rax, QWORD [rbp-16] ;aktualny wskaznik b
    mov rbx, QWORD [rbp-8]  ;koniec b
    cmp rax, rbx
    jle loop1   ;jesli nie skonczyl sie jeszcze plik nakladany, to powtarzaj

    jmp koniec  ;koniec funkcji

przeskocz_padding:
    mov rax, QWORD [rbp-12] ;dane a
    mov rbx, QWORD [rbp-24] ;aktualny koniec lini a
    sub rbx, rax    ;tyle zostalo do konca lini
    add rbx, QWORD [rbp-20] ;+ padding
    add rcx, rbx

    mov rbx, QWORD [rbp-24] ;aktualny koniec lini a
    add rbx, QWORD [rbp-20] ;+ padding
    mov rax, QWORD [rbp+24] ;x
    imul rax, 3    ;ilosc pixeli na ilosc bajtow
    cmp rax, 0
    jl bez_przesuniecia
    add rcx, rax    ;przesuniecie o x
	add rbx, rax
bez_przesuniecia:
    mov [rbp-12], rbx

    mov rbx, QWORD [rbp-32] ;aktualny koniec lini b
    add rbx, QWORD [rbp-28] ;+ padding
    ;inc rbx
    mov [rbp-16], rbx

    mov rbx, QWORD [rbp-24] ;aktualny koniec lini a
    mov rax, QWORD [rbp-36] ;dlugosc lini w bajtach
    add rax, QWORD [rbp-20] ;+ padding
    add rbx, rax    ;nowy adres konca linii
    mov [rbp-24], rbx

    mov rbx, QWORD [rbp-32] ;aktualny koniec lini b
    mov rax, QWORD [rbp-40] ;dlugosc lini w bajtach
    add rax, QWORD [rbp-28] ;+ padding
    add rbx, rax    ;nowy adres konca linii
    mov rax, QWORD [rbp+24] ;x
    imul rax, 3
    cmp rax, 0
    jge dalej
    sub rbx, rax
    dalej:
    mov [rbp-32], rbx

    jmp loop1



koniec:
	mov	rax, 0		;return 0
	mov rsp, rbp
	pop	rbp
	ret

