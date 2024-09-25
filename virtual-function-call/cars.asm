%include "io.inc"

section .data

vtable_car dd ptintInfoCar, ptintInfoCar2
vtable_BMW dd ptintInfoBMW, ptintInfoBMW2
vtable_VW dd ptintInfoVW, ptintInfoVW2

section .text

;   This is pseudo code, it's not fully correct according to c++ standarts
;
;   class car {
;       vtable* ptr = vtable_car;
;       virtual void printInfo();
;       virtual void printInfo2();
;   };
;
;   class BMW : public car {
;       vtable* ptr = vtable_BMW;
;       void printInfo() override;
;       void printInfo2() override;
;   };
;
;   class Volkswagen : public car {
;       vtable* ptr = vtable_VW;
;       void printInfo() override;
;       void printInfo2() override;
;   };
;
;   void sillyFunc(car* car) {      //this silly function doesn't know about exact type of an argument
;       (*car).ptintInfo2();
;   }


ptintInfoCar:
    PRINT_STRING "This is a car"
    NEWLINE
    ret

ptintInfoCar2:
    PRINT_STRING "This is a car 2"
    NEWLINE
    ret

ptintInfoBMW:
    PRINT_STRING "This is BMW"
    NEWLINE
    ret

ptintInfoBMW2:
    PRINT_STRING "This is BMW 2"
    NEWLINE
    ret
    
ptintInfoVW:
    PRINT_STRING "This is Volkswagen"
    NEWLINE
    ret

ptintInfoVW2:
    PRINT_STRING "This is Volkswagen 2"
    NEWLINE
    ret
    

; void sillyFunc(car* pcar)
sillyFunc:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]  ; eax = *pcar (=car)
    mov eax, [eax]      ; eax = **pcar (=car.vtable)
    call [eax]          ; (*pcar).printInfo() (call car.vtable[0])
    
    mov eax, [ebp + 8]  ; eax = *pcar (=car)
    mov eax, [eax]      ; eax = **pcar (=car.vtable)
    add eax, 4          ; eax = car.vtable + 4 (&car.vtable[1])
    call [eax]          ; (*pcar).printInfo() (call car.vtable[1])
    
    leave
    ret


global CMAIN
CMAIN:
    push ebp
    mov ebp, esp
    
    ;car car1; //(&car1 = ebp - 4)
    ;car1.printInfo();
    push vtable_car
    mov eax, [ebp - 4]  ; eax = *vtable_car 
    call [eax]          ; call (*vtable_car)[0] - calling first function in vtablr_car
    
    
    ;BMW bmw1; (&bmw1 = ebp - 8)
    push vtable_BMW
    mov eax, [ebp - 8]
    call [eax]
    
    
    ;Volkswagen vw1; (&vw1 = ebp - 12)
    push vtable_VW
    mov eax, [ebp - 12]     ; eax = *vtable_VW
    add eax, 4              ; eax = *vtable_VW + 4 (*(*vtable_VW + 4) = (*vtable_VW)[1])
    call [eax]              ; call (*vtable_VW)[1] (ptintInfoVW2)
    
    NEWLINE
    
    
    ; Now we have 3 variables:
    ; car1 (ebp - 4)
    ; bmw1 (ebp - 8)
    ; vw1  (ebp - 12)
    
    
    PRINT_STRING "Now you need to write an offset to pass one of our object's address to the sillyFunc()."
    NEWLINE
    PRINT_STRING "'4' - car1, '8' - bmw1, '12' - vw1"
    NEWLINE
    NEWLINE
    
    
    GET_DEC 4, ebx      ; ebx = offset
    mov ecx, ebp
    sub ecx, ebx        ; ecx = address of the argument (ebp - offset)
    
    lea eax, [ecx]      ; eax = ebp - offset
    push eax            ; pushing an argument to stack
    call sillyFunc
    add esp, 4          ; cleaning stack
    
    xor eax, eax
    leave
    ret
