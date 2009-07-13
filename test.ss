#lang scheme/base

(require (only-in '#%foreign ffi-call _int32 _pointer _void)
         "assemble.ss"
         "opcodes.ss"
         "register.ss")

(define the-answer
  (assemble (list
             (push ebp)
             (mov esp ebp)
             (mov eax 42)
             (pop ebp)
             (ret))))

(define hello
  (assemble (list
             (mov eax 4)
             (mov ebx 1)
             (pop ecx)
             (mov edx 5)
             (int 80)
             (ret))))

;(require scheme/foreign)
;(unsafe!)
;(define libshim  (ffi-lib "shim"))
;(define shim
;  (get-ffi-obj "shim" libshim (_fun _pointer -> _int)))

(with-output-to-file "dump.o"
  (lambda ()
    (for ([b (in-bytes the-answer)])
         (write-byte b)))
  #:exists 'replace)

(define (run)
  ((ffi-call the-answer null _int32)))

(define hello-fn
  (ffi-call hello (list _pointer) _void))

;(define (run-shim)
;  (shim the-answer))

(provide the-answer
         hello
         hello-fn
         run
 ;        run-shim
         ffi-call)