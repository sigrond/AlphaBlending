section	.text
global  blend

blend:
    push ebp
	mov ebp, esp

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
	add ebx, eax    ;adres pixeli(danych) a
	mov eax, DWORD [ebp+20] ;x
	imul eax, 3
	add ebx, eax
    push ebx    ;[ebp-12]

    mov ebx, DWORD [ebp+12]  ;adres poczatku b
	mov eax, DWORD [ebx+10] ;offset b
	add ebx, eax    ;adres pixeli(danych) b
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

    mov ebx, DWORD [ebp-12]  ;adres danych a
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

    mov ebx, DWORD [ebp+8]  ;adres poczatku a
    mov eax, DWORD [ebx+18]  ;szerokosc a
    imul eax, 3 ;zamiana szerokosci, pixele na bajty
    push eax    ;[ebp-36]
    mov edx, DWORD [ebp-24] ;padding a
    add eax, edx    ;dlugosc lini z paddingiem
    mov edx, [ebp+24]   ;y
    imul eax, edx   ;przesuniecie w pionie
    mov	ebx, DWORD [ebp-12] ;poczatek danych a
    add ebx, eax    ;adres po przesunieciu w dol
    mov [ebp-12], ebx


    mov ebx, DWORD [ebp+12]  ;adres poczatku b
    mov eax, DWORD [ebx+18]  ;szerokosc b
    imul eax, 3 ;zamiana szerokosci, pixele na bajty
    push eax    ;[ebp-40]

    mov ebx, DWORD [ebp+8]  ;adres poczatku a
	mov eax, DWORD [ebx+10] ;offset a
    mov ecx, eax  ;licznik

loop1:
    mov	ebx, DWORD [ebp-12] ;poczatek danych a
    ;add ebx, ecx    ;wlasciwa komorka
    mov al, BYTE [ebx]  ;weź bit koloru
    and eax, 0xFF    ;maska
    fild DWORD [eax]    ;bajt koloru na stos FPU
    mov eax, DWORD [ebp+16] ;alfa
    fld DWORD [eax] ;(float)alfa na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU
    fistp DWORD [edx]   ;zdjecie ze stosu jako int

    fld1    ;1 na stos
    mov eax, DWORD [ebp+16] ;alfa
    fld DWORD [eax] ;(float)alfa na stos FPU
    fsubp   ;1-alfa

    inc ebx
    mov [ebp-12], ebx

    mov ebx, DWORD [ebp-16] ;poczatek danych b
    ;add ebx, ecx
    mov al, BYTE [ebx]  ;weź bit koloru
    and eax, 0xFF    ;maska
    fild DWORD [eax]    ;bajt koloru na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU
    fistp DWORD [eax]   ;zdjecie ze stosu jako int
    add eax, edx    ;nowa wartosc koloru

    inc ebx
    mov [ebp-16], ebx

    mov ebx, DWORD [ebp+12] ;*d
    add ebx, ecx
    mov BYTE [ebx], al  ;zapis
    inc ecx

    mov eax, DWORD [ebp-12] ;aktualny wskaznik a
    mov ebx, DWORD [ebp-24] ;aktualny koniec lini
    cmp eax, ebx
    jge przeskocz_padding

    mov eax, DWORD [ebp-16] ;aktualny wskaznik b
    mov ebx, DWORD [ebp-32] ;aktualny koniec lini
    cmp eax, ebx
    jge przeskocz_padding

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
    mov ebx, DWORD [ebp-24] ;aktualny koniec lini a
    add ebx, DWORD [ebp-20] ;+ padding
    mov eax, DWORD [ebp+20] ;x
	add ebx, eax
    inc ebx
    mov [ebp-12], ebx

    mov ebx, DWORD [ebp-32] ;aktualny koniec lini b
    add ebx, DWORD [ebp-28] ;+ padding
    inc ebx
    mov [ebp-16], ebx

    mov ebx, DWORD [ebp-24] ;aktualny koniec lini a
    mov eax, DWORD [ebp-36] ;dlugosc lini w bajtach
    add ebx, eax    ;nowy adres konca linii
    mov [ebp-24], ebx

    mov ebx, DWORD [ebp-32] ;aktualny koniec lini b
    mov eax, DWORD [ebp-40] ;dlugosc lini w bajtach
    add ebx, eax    ;nowy adres konca linii
    mov [ebp-32], ebx

    jmp loop1


koniec:
	mov	eax, 0		;return 0
	mov esp, ebp
	pop	ebp
	ret

