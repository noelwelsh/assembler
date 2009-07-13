#lang scheme/base

(require (only-in '#%foreign ffi-call)
         "assemble.ss"
         "opcodes.ss"
         "register.ss")

(define the-answer
  (assemble (list
             (push ebp)
             (mov ebp esp)
             (mov 42 eax)
             (pop ebp)
             (ret))))

(define hello
  (assemble (list
             (mov 4 eax)
             (mov 1 ebx)
             (pop ecx)
             (mov 5 edx)
             (int 80)
             (ret))))

(require scheme/foreign)
(unsafe!)
(define libshim  (ffi-lib "shim"))
(define shim
  (get-ffi-obj "shim" libshim (_fun _pointer -> _int)))

(with-output-to-file "dump.o"
  (lambda ()
    (for ([b (in-bytes the-answer)])
         (write-byte b)))
  #:exists 'replace)

(define (run)
  ((ffi-call the-answer null _int32)))

(define hello-fn
  (ffi-call hello (list _pointer) _void))

(define (run-shim)
  (shim the-answer))

(provide the-answer
         hello
         hello-fn
         run
         run-shim
         ffi-call)