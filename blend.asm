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

    mov ecx, 0  ;licznik

loop1:
    mov	ebx, DWORD [ebp-12] ;poczatek danych a
    ;add ebx, ecx    ;wlasciwa komorka
    mov al, BYTE [ebx]  ;weź bit koloru
    and eax, 0xFF    ;maska
    fild eax    ;bajt koloru na stos FPU
    mov eax, DWORD [ebp+16] ;alfa
    fld eax ;(float)alfa na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU
    fistp edx   ;zdjecie ze stosu jako int

    fld1    ;1 na stos
    mov eax, DWORD [ebp+16] ;alfa
    fld eax ;(float)alfa na stos FPU
    fsubp   ;1-alfa

    inc ebx
    move [ebp-12], ebx

    mov ebx, DWORD [ebp-16] ;poczatek danych b
    ;add ebx, ecx
    mov al, BYTE [ebx]  ;weź bit koloru
    and eax, 0xFF    ;maska
    fild eax    ;bajt koloru na stos FPU
    fmulp   ;mnozenie- wynik na stos FPU
    fistp eax   ;zdjecie ze stosu jako int
    add eax, edx    ;nowa wartosc koloru

    inc ebx
    move [ebp-16], ebx

    mov ebx, DWORD [ebp+12] ;*d
    add ebx, ecx
    mov BYTE [ebx], al  ;zapis
    inc ecx
    jmp loop1

koniec:
	mov	eax, 0		;return 0
	pop	ebp
	ret

