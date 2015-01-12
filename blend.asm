section	.text
global  blend

blend:
    push ebp
    mov ebp, esp

    mov ecx, 0

    mov ebx, DWORD [ebp+8]  ;adres poczatku a
    mov eax, DWORD [ebx+2]  ;rozmiar a
    add ebx, eax    ;adres konca a
    push ebx    ;[ebp-4]

    mov ebx, DWORD [ebp+12]  ;adres poczatku b
    mov eax, DWORD [ebx+2]  ;rozmiar b
    add ebx, eax    ;adres konca b
    push ebx    ;[ebp-8]

	mov ebx, DWORD [ebp+8]  ;adres poczatku a
	mov eax, DWORD [ebx+10] ;offset a
	mov ecx, eax
	add ebx, eax    ;adres pixeli(danych) a
	mov eax, DWORD [ebp+24] ;x
;load_x:
    mov edx, 0
    cmp eax, 0
    jl x_ujemny
	imul eax, 3    ;ilosc pixeli na ilosc bajtow
	add ebx, eax
	add ecx, eax
	push ebx    ;[ebp-12]
	jmp x_ujemny_end
x_ujemny:
    mov edx, eax
x_ujemny_end:
    mov ebx, DWORD [ebp+12]  ;adres poczatku b
	mov eax, DWORD [ebx+10] ;offset b
	add ebx, eax    ;adres pixeli(danych) b
	sub ebx, edx
    push ebx    ;[ebp-16]

    mov ebx, DWORD [ebp+8]  ;adres poczatku a
    mov eax, DWORD [ebx+18]  ;szerokosc a
    imul eax, 3 ;zamiana szerokosci, pixele na bajty
    mov edx, eax
    imul eax, 8 ;zamiana szerokosci, bajty na bity
    add eax, 31 ;dlugosc_lini+=31
    shr eax, 5  ;dlugosc_lini/=32
    shl eax, 2  ;dlugosc_lini*=4
    sub eax, edx    ;padding
    push eax    ;[ebp-20]

    mov ebx, DWORD [ebp+8]  ;adres poczatku a
	add ebx, DWORD [ebx+10] ;offset a
    add ebx, edx    ;adres ostatniego bajtu pixeli w lini
    push ebx    ;[ebp-24]

    mov ebx, DWORD [ebp+12]  ;adres poczatku b
    mov eax, DWORD [ebx+18]  ;szerokosc b
    imul eax, 3 ;zamiana szerokosci, pixele na bajty
    mov edx, eax
    imul eax, 8 ;zamiana szerokosci, bajty na bity
    add eax, 31 ;dlugosc_lini+=31
    shr eax, 5  ;dlugosc_lini/=32
    shl eax, 2  ;dlugosc_lini*=4
    sub eax, edx    ;padding
    push eax    ;[ebp-28]

    mov ebx, DWORD [ebp-16]  ;adres danych b
    add ebx, edx    ;adres ostatniego bajtu pixeli w lini
    push ebx    ;[ebp-32]

;szerokosc:
    mov ebx, DWORD [ebp+8]  ;adres poczatku a
    mov eax, DWORD [ebx+18]  ;szerokosc a
    imul eax, 3 ;zamiana szerokosci, pixele na bajty
    push eax    ;[ebp-36]

    mov ebx, DWORD [ebp+12]  ;adres poczatku b
    mov eax, DWORD [ebx+18]  ;szerokosc b
    imul eax, 3 ;zamiana szerokosci, pixele na bajty
    push eax    ;[ebp-40]

    mov eax, DWORD [ebp+28] ;y
    cmp eax, 0
    jl y_minus
    mov ebx, DWORD [ebp+8]  ;adres poczatku a
    mov edx, DWORD [ebx+18]  ;szerokosc a
    imul edx, 3
    add edx, DWORD [ebp-20] ;padding
    imul eax, edx   ;przesuniecie
    add ecx, eax
    mov	ebx, DWORD [ebp-12] ;poczatek danych a
    add ebx, eax
    mov [ebp-12], ebx
    mov	ebx, DWORD [ebp-24] ;koniec lini
    add ebx, eax
    mov [ebp-24], ebx
    jmp y_minus_end
y_minus:
y_minus_end:

    mov eax, 0
    push eax    ;[ebp-44]

loop1:
    mov	ebx, DWORD [ebp-12] ;poczatek danych a
    mov eax, 0
    mov al, BYTE [ebx]  ;weź bit koloru
    mov	ebx, DWORD [ebp+20] ;poczatek danych a
    add ebx, ecx
    mov edx, 0
    mov dl, BYTE [ebx]  ;weź bit koloru
testuj:

    mov	ebx, DWORD [ebp-12] ;poczatek danych a
    mov eax, 0
    mov al, BYTE [ebx]  ;weź bit koloru
    and eax, 0xFF    ;maska

    mov [ebp-44], eax
    fild DWORD [ebp-44]    ;bajt koloru na stos FPU
    fld DWORD [ebp+16] ;(float)alfa na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU

    fld1    ;1 na stos
    fld DWORD [ebp+16] ;(float)alfa na stos FPU
    fsubp   ;1-alfa

    inc ebx
    mov [ebp-12], ebx

    mov ebx, DWORD [ebp-16] ;poczatek danych b
    mov eax, 0
    mov al, BYTE [ebx]  ;weź bit koloru
    and eax, 0xFF    ;maska
    mov [ebp-44], eax
    fild DWORD [ebp-44]    ;bajt koloru na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU
    faddp   ;dodanie
    fistp DWORD [ebp-44]   ;zdjecie ze stosu jako int
    mov eax, DWORD [ebp-44]

    inc ebx
    mov [ebp-16], ebx

    mov ebx, DWORD [ebp+20] ;*d
    add ebx, ecx
    mov BYTE [ebx], al  ;zapis
    inc ecx

    mov eax, DWORD [ebp-12] ;aktualny wskaznik a
    mov ebx, DWORD [ebp-24] ;aktualny koniec lini
    cmp eax, ebx
    jg przeskocz_padding

    mov eax, DWORD [ebp-16] ;aktualny wskaznik b
    mov ebx, DWORD [ebp-32] ;aktualny koniec lini
    cmp eax, ebx
    jg przeskocz_padding

    mov eax, DWORD [ebp-12] ;aktualny wskaznik a
    mov ebx, DWORD [ebp-4]  ;koniec a
    cmp eax, ebx
    jg koniec  ;jesli skonczy sie plik podstawowy, to koniec

    mov eax, DWORD [ebp-16] ;aktualny wskaznik b
    mov ebx, DWORD [ebp-8]  ;koniec b
    cmp eax, ebx
    jle loop1   ;jesli nie skonczyl sie jeszcze plik nakladany, to powtarzaj

    jmp koniec  ;koniec funkcji

przeskocz_padding:
    mov eax, DWORD [ebp-12] ;dane a
    mov ebx, DWORD [ebp-24] ;aktualny koniec lini a
    sub ebx, eax    ;tyle zostalo do konca lini
    add ebx, DWORD [ebp-20] ;+ padding
    add ecx, ebx

    mov ebx, DWORD [ebp-24] ;aktualny koniec lini a
    add ebx, DWORD [ebp-20] ;+ padding
    mov eax, DWORD [ebp+24] ;x
    imul eax, 3    ;ilosc pixeli na ilosc bajtow
    cmp eax, 0
    jl bez_przesuniecia
    add ecx, eax    ;przesuniecie o x
	add ebx, eax
bez_przesuniecia:
    mov [ebp-12], ebx

    mov ebx, DWORD [ebp-32] ;aktualny koniec lini b
    add ebx, DWORD [ebp-28] ;+ padding
    ;inc ebx
    mov [ebp-16], ebx

    mov ebx, DWORD [ebp-24] ;aktualny koniec lini a
    mov eax, DWORD [ebp-36] ;dlugosc lini w bajtach
    add eax, DWORD [ebp-20] ;+ padding
    add ebx, eax    ;nowy adres konca linii
    mov [ebp-24], ebx

    mov ebx, DWORD [ebp-32] ;aktualny koniec lini b
    mov eax, DWORD [ebp-40] ;dlugosc lini w bajtach
    add eax, DWORD [ebp-28] ;+ padding
    add ebx, eax    ;nowy adres konca linii
    mov eax, DWORD [ebp+24] ;x
    imul eax, 3
    cmp eax, 0
    jge dalej
    sub ebx, eax
    dalej:
    mov [ebp-32], ebx

    jmp loop1



koniec:
	mov	eax, 0		;return 0
	mov esp, ebp
	pop	ebp
	ret

