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
00000000  55                push bp
00000001  89ED              mov bp,bp
00000003  B82A00            mov ax,0x2a
00000006  0000              add [bx+si],al
00000008  5D                pop bp
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
00000000  B80400            mov ax,0x4
00000003  0000              add [bx+si],al
00000005  BB0100            mov bx,0x1
00000008  0000              add [bx+si],al
0000000A  5D                pop bp
0000000B  59                pop cx
0000000C  BA0500            mov dx,0x5
0000000F  0000              add [bx+si],al
00000011  CD80              int 0x80
00000013  5D                pop bp
00000014  C3                ret
END
)

(define (dump-bytes bytes)
  (with-output-to-file file-name
    (lambda () (write-bytes bytes))
    #:exists 'replace))

;; Natural -> String
(define (ndisasm n-chars)
  (match (process (format "ndisasm ~a" file-name))
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
  (check-ndisasm=? the-answer the-answer-disasm))
   