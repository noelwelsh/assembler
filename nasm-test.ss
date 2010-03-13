#lang scheme/base

;; Functional tests, comparing against NDISASM results
;; I.e. check the NDISASM disassembles our assembly into the expected text

(require
 scheme/match
 scheme/system
 (planet schematics/schemeunit:3)
 "assemble.ss"
 "integer.ss"
 "register.ss")

(define file-name "test.s")

(define the-answer
  (assemble
   (push ebp)
   (mov esp ebp)
   (mov eax 42)
   (pop ebp)
   (ret)))

(define the-answer-disasm
  #<<END
00000000  55                push ebp
00000001  89EC              mov esp,ebp
00000003  B82A000000        mov eax,0x2a
00000008  5D                pop ebp
00000009  C3                ret
END
)

;; This is a function that takes a pointer to character data
;; and prints it on the console via an OS call (Linux only)
(define hello
  (assemble 
   (mov eax 4)
   (mov ebx 1)
   (pop ebp) ;; Pop off the return address
   (pop ecx) ;; Pop off the first (and only) parameter
   (mov edx 5)
   (int #x80)
   (pop ebp) ;; Pop the return address back
   (ret)))

(define hello-disasm
  #<<END
00000000  B804000000        mov eax,0x4
00000005  BB01000000        mov ebx,0x1
0000000A  5D                pop ebp
0000000B  59                pop ecx
0000000C  BA05000000        mov edx,0x5
00000011  CD80              int 0x80
00000013  5D                pop ebp
00000014  C3                ret
END
)

(define jumps
  (assemble
   (jmp -16)
   (jmp -512)
   (jmp eax)))

(define jumps-disasm
  #<<END
00000000  E9F0FFFFFF        jmp dword 0xfffffff5
00000005  E900020000        jmp dword 0x20a
0000000A  FFE0              jmp eax
END
)

(define (dump-bytes bytes)
  (with-output-to-file file-name
    (lambda () (write-bytes bytes))
    #:exists 'replace))

;; Natural -> String
(define (ndisasm n-chars)
  (match (process (format "ndisasm -u ~a" file-name))
    [(list out in pid err status)
     (status 'wait)
     (begin0
         (read-string n-chars out)
       (close-input-port out)
       (close-output-port in)
       (close-input-port err))]))

(define-check (check-ndisasm=? bytes expected)
  (dump-bytes bytes)
  (check string=? (ndisasm (string-length expected)) expected))
  

(define/provide-test-suite nasm-tests
  (check-ndisasm=? hello hello-disasm)
  (check-ndisasm=? the-answer the-answer-disasm)
  (check-ndisasm=? jumps jumps-disasm))
   