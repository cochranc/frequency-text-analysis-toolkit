#lang racket
(require loudhum)

; example text
(define dorian (file->string "dorian-gray-chapter-1.txt"))

;;; Procedure:
;;;   invert-hash
;;; Parameters:
;;;   hash, a hash-table
;;; Purpose:
;;;   to invert a hash-table 
;;; Produces:
;;;   invert, a hash-table
;;; Preconditions:
;;;   [no additional]
;;; Postconditons:
;;;   * If hash is empty, invert is also empty
;;;   * If one or more keys, k1, k2, ..., share the same value, v in hash:
;;;     (hash-ref hash k1) = v, (hash-ref hash k2) = v ...
;;;     , then (hash-ref invert v) = '(k1 k2 ...)
;;;   * If only one key, k, is paired with a value, v, in hash:
;;;     (hash-ref hash k) = v, then (hash-ref invert v) = '(k)
;;;   * (length (hash-keys hash)) >= (length (hash-keys invert))
(define invert-hash
  (lambda (hash)
    (let ([inverse (make-hash)])
      (let kernel ([keys (hash-keys hash)])
        (cond
          [(null? keys)
           inverse]
          [(hash-has-key? inverse
                          (hash-ref hash (car keys)))
           (hash-set! inverse 
                      (hash-ref hash (car keys)) 
                      (append (list (car keys))
                              (hash-ref inverse (hash-ref hash (car keys)))))
           (kernel (cdr keys))]
          [(hash-set! inverse
                      (hash-ref hash (car keys))
                      (list (car keys)))
           (kernel (cdr keys))])))))


;;; Procedure:
;;;   clean-up
;;; Parameters:
;;;   str, a string
;;; Purpose:
;;;   to create a list of words (any sequence of letters without spaces)
;;;   found in str, and downcase them
;;; Produces:
;;;   words, a list of strings
;;; Preconditions:
;;;   [no additional]
;;; Postconditions:
;;;   * empty str, will result in empty words
;;;   * given a non-empty str, all strings in words will be lower-case and contain
;;;     only letters found in the English alphabet
(define clean-up
  (lambda (str)
    (regexp-match* #px"[a-z]+" (string-downcase str))))


;;; Procedure:
;;;   frequency-tally
;;; Parameters:
;;;   txt, a string
;;; Purpose:
;;;   to create a hash-table representing the number
;;;   of appearances of each word in txt
;;; Produces:
;;;   tally, a hash-table
;;; Preconditions:
;;;   For best usage of frequency-tally, txt should
;;;   be free of spelling errors
;;; Postconditions:
;;;   * All keys in tally will be a positive integer
;;;   * All values in tally will be a list of string(s)
;;;   * Each key represents the number of times, it's corresponding value appears within txt
;;;   * If two or more strings appear the same amount of times in txt, their corresponding
;;;     key will be the number of appearances for one string
(define frequency-tally
  (lambda (txt)
    (let* ([words (clean-up txt)]
           [tally (make-hash)]
           [tally-key (lambda (key hash)
                        (if (hash-has-key? hash key) 
                            (hash-set! hash key (+ (hash-ref hash key) 1)) 
                            (hash-set! hash key 1)))])
      (for-each (section tally-key <> tally) words)
      (invert-hash tally))))

;;; Procedure:
;;;   take20%
;;; Parameters:
;;;   txt, a string
;;;   base-case, a symbol
;;; Purpose:
;;;   to track the top 20% words, sorted by frequency, in txt
;;;   and their total number of appearances in txt
;;; Produces:
;;;   * either 20%, a list of strings
;;;   * or total, a non-negative integer
;;; Preconditions:
;;;   For best usage of frequency-tally, txt should
;;;   be free of spelling errors
;;; Postconditions:
;;;   * If (not (equal? base-case 'total)), 20%, which is a list of the top
;;;     20% of words, sorted by frequency, in txt, will be returned.
;;;   * If (equal? base-case 'total), total, which is the total sum of all 
;;;     appearances of 20%, will be returned
(define take20%
  (lambda (txt base-case)
    (let* ([tally (frequency-tally txt)]
           [20% (inexact->exact (ceiling (* .20 (length (clean-up txt)))))]
           [num-org 20%])
      (let kernel ([num-left 20%] ; how many words we have left to pull from tally
                   [lst (list)] ; the list we are building from words from tally
                   [keys (sort (hash-keys tally) >)]
                   [total 0])
        (cond
          [(zero? num-left)
           (if (equal? base-case 'total)
               total
               (reverse lst))]
          [(< num-left 0) ; possibility that we grab too many elements
           (if (equal? base-case 'total)
               total
               (reverse (drop lst (- (length lst) num-org))))] ; drop extra elements
          [(null? keys) ; possibility that we run out of keys before we want recursion to finish
           (kernel num-left
                   lst
                   keys
                   total)]
          [(let* ([key-num (car keys)] ; keys are a list of numbers, so key-num is one number
                  [val-lst (hash-ref tally key-num)] ; the list of strings asociated with key-num
                  [num-left (- num-left (length val-lst))])
             (kernel num-left
                     (append val-lst
                             lst) ; update the list we are building
                     (cdr keys)
                     (if
                      (< num-left 0) ; possibility that we overadd to total
                      (+ (* key-num (- (length val-lst) (abs num-left))) ; subtract overadding error
                         total)
                      (+ (* key-num (length val-lst))
                         total))))])))))

;;; Citation:
;;;  "How to Calculate the Margin of Error for a Sample Proportion"
;;;  by Deborah J. Rumsey
;;;  https://www.dummies.com/education/math/statistics/how-to-calculate-the-margin-of-error-for-a-sample-proportion/


;;; Procedure:
;;;   margin-of-error
;;; Parameters:
;;;   proportion, a real number between 0 and 1 inclusive
;;;   sample-size, a non-negative integer
;;;   confidence-level, either the number 99, 95, or 90
;;; Purpose:
;;;   to calculate the margin-of-error given a sample-size,
;;;   a proportion of interest, and a level of confidence
;;; Produces:
;;;   margin, a real number
;;; Preconditions:
;;;   [no additional]
;;; Postconditions:
;;;   [no additional]
(define margin-of-error
  (lambda (proportion sample-size confidence-level)
    (let ([z-score (cond
                     [(= 99 confidence-level)
                      2.58]
                     [(= 95 confidence-level)
                      1.96]
                     [(= 90 confidence-level) ; anything less than 90 would not be statistically important
                      1.645])])               
      (* z-score (sqrt (/ (* proportion (- 1 proportion)) sample-size))))))


;;; Procedure:
;;;   pareto?
;;; Parameters:
;;;   txt, a string
;;;   confidence-level, either the number 99, 95, or 90
;;; Purpose:
;;;   to test whether the pareto principle applies to txt, within
;;;   a confidence level
;;; Produces:
;;;   pass?, a boolean or a non-negative real number
;;; Preconditions:
;;;   txt should be free of spelling errors for best usage of pareto?
;;; Postconditions:
;;;   * If the top 20% of words within txt, as sorted by frequency,
;;;     compromise 80% of the text within a margin-of-error (as determined
;;;     by confidence-level), #t is returned
;;;   * If the top 20% of words within txt, as sorted by frequency, does not
;;;     compromise 80% of the text within a margin-of-error (as determined
;;;     by confidence-level), the percentage made up by the top 20% is returned
(define pareto?
  (lambda (txt confidence-level)
    (let* ([sample-size (length (clean-up txt))]
           [raw-proportion (/ (take20% txt 'total) sample-size)]
           [margin-of-error (margin-of-error raw-proportion sample-size confidence-level)])
      (if (or
       (and (>= raw-proportion (- .80 margin-of-error))
            (< raw-proportion (+ .80 margin-of-error)))
       (and (> raw-proportion (- .80 margin-of-error))
            (<= raw-proportion (+ .80 margin-of-error))))
          #t
          (* 100 (exact->inexact raw-proportion))))))


          


