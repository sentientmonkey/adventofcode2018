#lang racket

(require threading)

(define (eq-case? a b)
  (eq? (char-upcase a) (char-upcase b)))

(define (react? a b)
  (and (not (eq? a b))
       (eq-case? a b)))

(define (remove-polymers polymer)
  (~>> polymer
      (string->list)
      (foldr
       (λ (x ys)
         (cond
           [(empty? ys) (list x)]
           [(react? (car ys) x) (cdr ys)]
           [else (cons x ys)]))
       '())
      (list->string)))

(define (remove-specific-polymer polymer char)
  (~>> polymer
      (string->list)
      (filter (λ (x) (not (eq-case? char x))))
      (list->string)
      (remove-polymers)))

(define (in-char-range a b)
  (for/list ([c (in-range (char->integer a) (char->integer b))])
    (integer->char c)))

(define (find-shortest-polymer polymer)
  (~>> (in-char-range #\a #\z)
       (map (λ (c) (remove-specific-polymer polymer c)))
       (argmin string-length)))

(module+ test
  (require rackunit)

  (define (check-polymers? expected polymer)
    (check-equal? expected (remove-polymers polymer)))

  (define (check-same-polymer? expected)
    (check-equal? expected (remove-polymers expected)))

  (define (check-remove-specific? expected polymer char)
    (check-equal? expected (remove-specific-polymer polymer char)))

  (define (check-string-length? len str)
    (check-equal? len (string-length str)))

  (test-case "remove ploymers for repeating"
    (check-polymers? "dabA" "dabAcC")
    (check-polymers? "dabA" "dabACc")
    (check-polymers? "dabAc" "dabAcAa")
    (check-polymers? "dabAc" "dabAcaA")
    (check-polymers? "bgcDaa" "bgcDaaAAaa"))

  (test-case "does not remove when same case"
    (check-same-polymer? "dabACC")
    (check-same-polymer? "dabAcc")
    (check-same-polymer? "dabAAA")
    (check-same-polymer? "dabaaa"))

  (test-case "removes all polymers"
    (check-polymers? "dabCBAcaDA" "dabAcCaCBAcCcaDA")
    (check-polymers? "dabCBAcaDA" "dabAcCaCBAcCcaDA"))

  (test-case "remove specific polymers"
    (let ([original "dabAcCaCBAcCcaDA"])
      (check-remove-specific? "dbCBcD" original #\a)
      (check-remove-specific? "daCAcaDA" original #\b)
      (check-remove-specific? "daDA" original #\c)
      (check-remove-specific? "abCBAc" original #\d)))

  (test-case "find shortest polymer"
    (check-string-length? 4 (find-shortest-polymer "dabAcCaCBAcCcaDA"))))

(define (read-exercise-data)
  (~> (current-command-line-arguments)
      (vector-ref 0)
      (open-input-file)
      (port->string)
      (string-trim #:right? #t)))

(module+ main
  (let ([exercise-data (read-exercise-data)])
    (println (string-length (remove-polymers exercise-data)))
    (println (string-length (find-shortest-polymer exercise-data)))))
