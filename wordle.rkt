;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname wordle) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)
(require 2htdp/batch-io)
(require "./hashtable-extras.rkt")

(define NORMAL-SQUARE (overlay (square 90 "solid" "light grey") (square 100 "solid" "dark grey")))
(define LOCKED-SQUARE (overlay (square 90 "solid" "light grey") (square 100 "solid" (make-color 150 150 150))))
(define YELLOW-SQUARE (overlay (square 90 "solid" "light goldenrod") (square 100 "solid" "orange")))
(define GREEN-SQUARE (overlay (square 90 "solid" "light green") (square 100 "solid" "seagreen")))

;; A Color is one of the following:
(define GREY "grey")
(define YELLOW "yellow")
(define GREEN "green")
(define BLACK "black")

(define BCKG-ROW (beside NORMAL-SQUARE NORMAL-SQUARE NORMAL-SQUARE NORMAL-SQUARE NORMAL-SQUARE))
(define BCKG (above BCKG-ROW BCKG-ROW BCKG-ROW BCKG-ROW BCKG-ROW BCKG-ROW))

(define VALID-WORDS (read-words "shuffled_real_wordles.txt"))
(define VALID-GUESSES (read-words "combined_wordlist.txt"))

(define-struct world [letters words secret])
;; A WorldState is a (make-world [List-of 1String] [List-of String] String)
;; (make-world l w s) represents a WorldState with secret word s,
;; previously guesses words w, and currently types letters l (max length 5)
;; where the first letter in l is the most recently typed
;; note that the game ends once the length of words is 6

(define EXAMPLE-WORLD-0 (make-world '() '() "apple"))
(define EXAMPLE-WORLD-1 (make-world '() (list "elope") "apple"))
(define EXAMPLE-WORLD-2 (make-world (list "l" "k" "n" "a") (list "elope") "apple"))
(define EXAMPLE-WORLD-3 (make-world (list "e" "l" "k" "n" "a") (list "elope") "apple"))
(define EXAMPLE-WORLD-4 (make-world '() (list "elope" "ankle") "apple"))

;; on-letter : WorldState Alphabetic-1String
;; handles keypresses where a letter is typed
(define (on-letter ws c)
  (if (>= (length (world-letters ws)) 5)
      ws
      (make-world (cons c (world-letters ws)) (world-words ws) (world-secret ws))))

(check-expect (on-letter EXAMPLE-WORLD-2 "e") EXAMPLE-WORLD-3)
(check-expect (on-letter EXAMPLE-WORLD-3 "e") EXAMPLE-WORLD-3)

;; on-backspace : WorldState
;; handles keypresses where a backspace is entered
(define (on-backspace ws)
  (if (zero? (length (world-letters ws)))
      ws
      (make-world (rest (world-letters ws)) (world-words ws) (world-secret ws))))

(check-expect (on-backspace EXAMPLE-WORLD-3) EXAMPLE-WORLD-2)
(check-expect (on-backspace EXAMPLE-WORLD-0) EXAMPLE-WORLD-0)

;; on-enter : WorldState
;; handles keypresses where an enter is entered
(define (on-enter ws)
  (cond
    [(< (length (world-letters ws)) 5) ws]
    [(member (foldr (lambda (x acc) (string-append acc x)) "" (world-letters ws)) VALID-GUESSES)
     ;; note that sorting the file would allow for using binary search for faster lookup
     (make-world '()
                  (append (world-words ws) (list (foldr (lambda (x acc) (string-append acc x)) "" (world-letters ws))))
                  (world-secret ws))]
    [else ws]))

(check-expect (on-enter EXAMPLE-WORLD-2) EXAMPLE-WORLD-2)
(check-expect (on-enter EXAMPLE-WORLD-3) EXAMPLE-WORLD-4)
(check-expect (on-enter (make-world (list "a" "a" "a" "a" "a") (list "elope") "apple"))
              (make-world (list "a" "a" "a" "a" "a") (list "elope") "apple"))

;; note that I am omitting tests using the image functions because I don't want to write them

;; draw-world : WorldState -> Image
;; draws the entire world
(define (draw-world ws)
  (overlay/align "left" "top"
                 (above/align "left" empty-image
                              (foldr above empty-image
                                     (map (lambda (w)
                                            (draw-word (explode (world-secret ws))
                                                       (make-color-struct
                                                        (explode w)
                                                        (list BLACK BLACK BLACK BLACK BLACK)
                                                        (make-ht (explode (world-secret ws))))))
                                          (world-words ws))) (draw-letters (world-letters ws))) BCKG))

;; make-ht [List-of 1String] [Hash-Table-of 1String Nat] -> [Hash-Table-of 1String Nat]
;; makes a HashTable of characters with values corresponding to how many times they occur
(define (make-ht loc)
  (foldr (lambda (c acc)
           (if (hash-has-key? acc c)
               (hash-set acc c (+ 1 (hash-ref acc c)))
               (hash-set acc c 1))) (make-hash empty) loc))

(check-expect (make-ht (explode "apple")) (make-hash (list (list "a" 1)
                                                           (list "p" 2)
                                                           (list "l" 1)
                                                           (list "e" 1))))

;; draw-letters : [List-of 1String] -> Image
;; draws the current letters (no coloring)
;; note that the first of l is the rightmost letter
(define (draw-letters l)
  (foldr (lambda (x acc) (beside acc x)) empty-image (map (lambda (c) (draw-letter c GREY)) l)))

(define-struct color-struct [letters cl ht])
;; A ColorStruct is a (make-color-struct [List-of 1String] [List-of Color] [Hash-Table-of 1String Nat])
;; (make-color-struct letters cl ht) represents a word with letters, colors given by cl,
;; and with a secret word with unused letter frequencies given by the values of ht

;; draw-word : [List-of 1String] ColorStruct -> Image
;; draws a word, with the correct colors based on secret
(define (draw-word secret cs)
  (local ([define green-cs (make-greens secret cs)])
    (foldr beside empty-image
           (map draw-letter (color-struct-letters cs) (make-yellows (make-greens secret cs))))))

;; make-yellows : ColorStruct -> [List-of Color]
;; generates a list of colors including yellow letters, based on the hash map
(define (make-yellows cs)
  (cond
    [(empty? (color-struct-cl cs)) '()]
    [(equal? GREEN (first (color-struct-cl cs))) (cons GREEN (make-yellows (make-color-struct
                                                                            (rest (color-struct-letters cs))
                                                                            (rest (color-struct-cl cs))
                                                                            (color-struct-ht cs))))]
    [(hash-has-key? (color-struct-ht cs) (first (color-struct-letters cs)))
     (cons YELLOW (make-yellows (make-color-struct
                                 (rest (color-struct-letters cs))
                                 (rest (color-struct-cl cs))
                                 (decrement (first (color-struct-letters cs)) (color-struct-ht cs)))))]
    [else (cons BLACK (make-yellows (make-color-struct
                                    (rest (color-struct-letters cs))
                                    (rest (color-struct-cl cs))
                                    (color-struct-ht cs))))]))

(check-expect (make-yellows (make-color-struct (explode "ankle")
                                 (list GREEN BLACK BLACK GREEN GREEN)
                                 (make-ht (explode "apple")))) (list GREEN BLACK BLACK GREEN GREEN))
(check-expect (make-yellows (make-color-struct (explode "speed")
                                 (list BLACK BLACK GREEN BLACK BLACK)
                                 (make-ht (explode "crepe")))) (list BLACK YELLOW GREEN YELLOW BLACK))

;; make-greens : [List-of 1String] ColorStruct -> ColorStruct
;; updates ColorStruct to contain green letters if they appear in the correct position
(define (make-greens secret cs)
  (local ([define cur-index (- 5 (length secret))])
    (cond
      [(zero? (length secret)) cs]
      [(equal? (first secret) (n-th (color-struct-letters cs) cur-index))
       (make-greens (rest secret) (make-color-struct (color-struct-letters cs)
                                                     (greenify (color-struct-cl cs) cur-index)
                                                     (decrement (first secret) (color-struct-ht cs))))]
      [else (make-greens (rest secret) cs)])))

(check-expect (make-greens (explode "apple") (make-color-struct (explode "ankle")
                                                                (list BLACK BLACK BLACK BLACK BLACK)
                                                                (make-ht (explode "apple"))))
              (make-color-struct (explode "ankle") (list GREEN BLACK BLACK GREEN GREEN)
                                 (make-hash (list (list "p" 2)))))

;; greenify : [List-of Color] Nat -> [List-of Color]
;; makes the n-th element in lc green
(define (greenify lc n)
  (if (= n 0)
      (cons GREEN (rest lc))
      (cons (first lc) (greenify (rest lc) (- n 1)))))

(check-expect (greenify (list BLACK BLACK BLACK BLACK BLACK) 0) (list GREEN BLACK BLACK BLACK BLACK))
(check-expect (greenify (list BLACK BLACK BLACK BLACK BLACK) 4) (list BLACK BLACK BLACK BLACK GREEN))

;; decrement : 1String [Hash-Table-of 1String Nat] -> [Hash-Table-of 1String Nat]
;; decrements the value associated with c in the HashTable by one,
;; and deletes the key-value pair if the current value is 1
(define (decrement c ht)
  (cond
    [(not (hash-has-key? ht c)) (error "the hash table should always have the key, since it is a match")]
    [(= 1 (hash-ref ht c)) (hash-remove ht c)]
    [else (hash-set ht c (- (hash-ref ht c) 1))]))

(check-expect (decrement "a" (make-hash (list (list "a" 1) (list "p" 2) (list "l" 1) (list "e" 1))))
              (make-hash (list (list "p" 2) (list "l" 1) (list "e" 1))))

(check-expect (decrement "p" (make-hash (list (list "a" 1) (list "p" 2) (list "l" 1) (list "e" 1))))
              (make-hash (list (list "a" 1) (list "p" 1) (list "l" 1) (list "e" 1))))

;; draw-letter : 1String Color -> Image
(define (draw-letter c color)
  (overlay/offset (text (string-upcase c) 80 "black") 0 -6 (cond
                                                             [(equal? color GREY) NORMAL-SQUARE]
                                                             [(equal? color YELLOW) YELLOW-SQUARE]
                                                             [(equal? color GREEN) GREEN-SQUARE]
                                                             [(equal? color BLACK) LOCKED-SQUARE])))

;; you-win : WorldState -> Image
;; draws the world when you win
(define (you-win ws)
  (overlay (if
            (= (length (world-words ws)) 1)
            (overlay/offset (text "You won in\n1 guess!" 80 "black")
                            2 2
                            (text "You won in\n1 guess!" 80 "black"))
            (overlay/offset
             (text (string-append "You won in\n" (number->string (length (world-words ws))) " guesses!") 80 "black")
             2 2
             (text (string-append "You won in\n" (number->string (length (world-words ws))) " guesses!") 80 "white")))
           (rectangle 500 600 "solid" (make-color 0 255 0 100))
           (draw-world ws)))

;; you-lose : WorldState -> Image
;; draws the world when you lose
(define (you-lose ws)
  (overlay (overlay/offset
            (text (string-append "You lose!\nThe correct\nword was\n" (string-upcase (world-secret ws))) 80 "black")
            2 2
            (text (string-append "You lose!\nThe correct\nword was\n" (string-upcase (world-secret ws))) 80 "white"))
           (rectangle 500 600 "solid" (make-color 255 0 0 100))
           (draw-world ws)))

(define (play word)
  (big-bang (make-world '() '() word)
    (on-key (lambda (ws ke) (cond
                              [(and (= 1 (string-length ke)) (string-alphabetic? ke)) (on-letter ws ke)]
                              [(string=? "\r" ke) (on-enter ws)]
                              [(string=? "\b" ke) (on-backspace ws)]
                              [else ws])))
    (to-draw draw-world)
    (stop-when (lambda (ws) (or (member? (world-secret ws) (world-words ws))
                                (= (length (world-words ws)) 6)))
               (lambda (ws) (if (member? (world-secret ws) (world-words ws))
                                (you-win ws)
                                (you-lose ws))))))

;; n-th : [NE-List-of X] Nat
;; returns the n-th element of alist, where 0 <= n < (length alist)
(define (n-th alist n)
  (cond
    [(zero? n) (first alist)]
    [(empty? (rest alist)) (first alist)] ;; this shouldn't ever get called
    [else (n-th (rest alist) (- n 1))]))

(check-expect (n-th (list 0 1 2 3) 1) 1)

(play (n-th VALID-WORDS (random (length VALID-WORDS))))