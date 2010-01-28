#lang scheme/base

(require
 scheme/foreign
 "instruction.ss"
 "integer.ss")

(unsafe!)

(define standard-lib (ffi-lib #f))
(define scheme_malloc_code
  (get-ffi-obj
   #"scheme_malloc_code"
   standard-lib
   (_fun (size : _long) -> (_bytes o size))))


(define-syntax-rule (assemble stmt ...)
  (let* ([code
          (let ([port (open-output-bytes)])
            (with-current-assembler-port port
              (begin stmt ...))
            (get-output-bytes port))]
         [bytes (scheme_malloc_code (bytes-length code))])
    (bytes-copy! bytes 0 code)
    bytes))

(provide
 assemble)
  