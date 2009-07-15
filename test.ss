#lang scheme/base

(require (only-in '#%foreign ffi-call)
         "assemble.ss"
         "opcodes.ss"
         "register.ss")

;; This is a function that returns 42
(define the-answer
  (assemble (list
             (push ebp)
             (mov ebp esp)
             (mov 42 eax)
             (pop ebp)
             (ret))))

;; This is a function that takes a pointer to character data
;; and prints it on the console via an OS call (Linux only)
(define hello
  (assemble (list
             (mov 4 eax)
             (mov 1 ebx)
             (pop ebp) ;; Pop off the return address
             (pop ecx) ;; Pop off the first (and only) parameter
             (mov 5 edx)
             (int #x80)
             (pop ebp) ;; Pop the return address back
             (ret))))

(require scheme/foreign)
(unsafe!)

(define (dump-bytes bytes file-name)
  (with-output-to-file file-name
    (lambda ()
      (for ([b (in-bytes bytes)])
           (write-byte b)))
    #:exists 'replace))

;; Dump the code so we can disassemble it, if necessary
(dump-bytes the-answer "the-answer.s")
(dump-bytes hello "hello.s")

(define (run-the-answer)
  ((ffi-call the-answer null _int32)))

(define (run-hello bytes)
  ((ffi-call hello (list _pointer) _void)) bytes)

(provide run-the-answer
         run-hello)