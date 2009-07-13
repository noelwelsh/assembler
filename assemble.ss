#lang scheme/base

(require scheme/port)

;; ((listof opcode) -> bytestring)
(define (assemble opcodes)
  (with-output-to-bytes
   (lambda ()
     (for-each
      (lambda (opcode)
        (for-each write-byte opcode))
      opcodes))))

(provide
 assemble)
  