#lang scheme/base

(require
 (only-in '#%foreign ffi-call _int32 _pointer _void)
 "assemble.ss"
 "integer.ss"
 "register.ss")

;; This is a function that returns 42
(define the-answer
  (assemble
   (push ebp)
   (mov esp ebp)
   (mov eax 42)
   (pop ebp)
   (ret)))

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

;; This is a function that adds two numbers together
(define adder
  (assemble
   (pop edx) ;; Save the return address
   (pop eax) ;; Get the first arguments off the stack
   (pop ecx) ;; Get the second arg. Don't use ebx as that is callee save
   (add eax ecx)
   (push edx) ;; Restore return address
   (ret)))

(define (dump-bytes bytes file-name)
  (with-output-to-file file-name
    (lambda ()
      (for ([b (in-bytes bytes)])
           (write-byte b)))
    #:exists 'replace))

;; Dump the code so we can disassemble it, if necessary
(dump-bytes the-answer "the-answer.s")
(dump-bytes hello "hello.s")
(dump-bytes adder "adder.s")

(define (run-the-answer)
  ((ffi-call the-answer null _int32)))

(define (run-hello bytes)
  ((ffi-call hello (list _pointer) _void) bytes))

(define (run-adder a b)
  ((ffi-call adder (list _int32 _int32) _int32) a b))

(provide run-the-answer
         run-hello
         run-adder)

