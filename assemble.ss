#lang scheme/base

(require scheme/foreign
         scheme/port)

(unsafe!)

(define standard-lib (ffi-lib #f))
(define scheme_malloc_code
  (get-ffi-obj
   #"scheme_malloc_code"
   standard-lib
   (_fun (size : _long) -> (_bytes o size))))

;; ((listof opcode) -> bytestring)
(define (assemble opcodes)
  (define code
    (with-output-to-bytes
     (lambda ()
       (for-each
        (lambda (opcode)
          (for-each write-byte opcode))
        opcodes))))
  (define bytes (scheme_malloc_code (bytes-length code)))
  (bytes-copy! bytes 0 code)
  bytes)
  

(provide
 assemble)
  