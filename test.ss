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
             (pop ebp) ;; Pop off the return address
             (pop ecx) ;; Pop off the first (and only) parameter
             (mov 5 edx)
             (int #x80)
             (pop ebp) ;; Pop the return address back
             (ret))))

(require scheme/foreign)
(unsafe!)
(define libshim  (ffi-lib "shim"))
(define shim
  (get-ffi-obj "shim" libshim (_fun _bytes -> _int)))

(define (dump-bytes bytes file-name)
  (with-output-to-file file-name
    (lambda ()
      (for ([b (in-bytes bytes)])
           (write-byte b)))
    #:exists 'replace))

(dump-bytes the-answer "dump.s")
(dump-bytes hello "hello.s")

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