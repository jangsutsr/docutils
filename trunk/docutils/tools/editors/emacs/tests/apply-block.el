;; Tests for various functions around applying a function to an indented block

(add-to-list 'load-path ".")
(load "init" nil t)
(init-rst-ert t)

(ert-deftest apply-block-asserts ()
  "Check some assertions."
  (should (equal ert-Buf-point-char "\^@"))
  (should (equal ert-Buf-mark-char "\^?"))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun find-leftmost-column ()
  "Call `rst-find-leftmost-column' with current region."
  (rst-find-leftmost-column (region-beginning) (region-end)))

(ert-deftest rst-find-leftmost-column ()
  "Tests for `rst-find-leftmost-column'."
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "\^@abc
\^?"
	   t
	   0))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
\^@abc
\^?"
	   t
	   0))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
\^@  abc
\^?"
	   t
	   2))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
\^@  abc
def
\^?"
	   t
	   0))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
\^@  abc
    def
\^?"
	   t
	   2))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
\^@    abc
    def
\^?"
	   t
	   4))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   ; Empty lines contain spaces
	   "
\^@
  
    abc
  
    def
  
\^?"
	   t
	   4))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "  abc\^@
def\^?"
	   t
	   0))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
  abc\^@
    def
\^?"
	   t
	   2))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "  a\^@b\^?c
def"
	   t
	   2))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
\^@    abc
\^?  def
"
	   t
	   4))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
\^@    abc
 \^? def
"
	   t
	   2))
  (should (ert-equal-buffer-return
	   (find-leftmost-column)
	   "
\^@    abc
  d\^?ef
"
	   t
	   2))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun bullet-list-region (all)
  "Call `rst-bullet-list-region' with current region and ALL."
  (rst-bullet-list-region (region-beginning) (region-end) all))

(ert-deftest rst-bullet-list-region ()
  "Tests for `rst-bullet-list-region'."
  (let ((rst-preferred-bullets '(?*)))
    (should (ert-equal-buffer
	     (bullet-list-region nil)
	     "
\^@
eins
one

zwei
two
\^?"
	     "
\^@
* eins
  one

* zwei
  two
\^?"))
    (should (ert-equal-buffer
	     (bullet-list-region nil)
	     "
\^@
eins
one

  intermediate

zwei
two
\^?"
	     "
\^@
* eins
  one

    intermediate

* zwei
  two
\^?"))
    (should (ert-equal-buffer
	     (bullet-list-region nil)
	     "
\^@
eins
one

zwei
two\^?"
	     "
\^@
* eins
  one

* zwei
  two\^?"))
    (should (ert-equal-buffer
	     (bullet-list-region t)
	     "
\^@
eins
zwei

drei

  vier
\^?"
	     "
\^@
* eins
* zwei

* drei

    vier
\^?"))
    ))

(ert-deftest rst-bullet-list-region-error ()
  "Tests for `rst-bullet-list-region' ending in an error."
  (let ((rst-preferred-bullets nil))
    (should-error (ert-equal-buffer
		   (bullet-list-region nil)
		   ""
		   t
		   )
		  :type 'error)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun enumerate-region (all)
  "Call `rst-enumerate-region' with current region and ALL."
  (rst-enumerate-region (region-beginning) (region-end) all))

(ert-deftest rst-enumerate-region ()
  "Tests for `rst-enumerate-region'."
  (should (ert-equal-buffer
	   (enumerate-region nil)
	   "
\^@eins
one

zwei
two
\^?"
	   "
\^@1. eins
   one

2. zwei
   two
\^?"))
  (should (ert-equal-buffer
	   (enumerate-region nil)
	   "
\^@eins
one

  intermediate

zwei
two
\^?"
	   "
\^@1. eins
   one

     intermediate

2. zwei
   two
\^?"))
  (should (ert-equal-buffer
	   (enumerate-region t)
	   "
\^@eins
zwei

drei
\^?"
	   "
\^@1. eins
2. zwei

3. drei
\^?"))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun line-block-region (empty)
  "Call `rst-line-block-region' with current region and EMPTY."
  (rst-line-block-region (region-beginning) (region-end) empty))

(ert-deftest rst-line-block-region ()
  "Tests for `rst-line-block-region'."
  (should (ert-equal-buffer
	   (line-block-region nil)
	   "
\^@
eins
one

zwei
\^?"
	   "
\^@
| eins
| one

| zwei
\^?"))
  (should (ert-equal-buffer
	   (line-block-region nil)
	   "
\^@
eins
  one

zwei
    two
\^?"
	   "
\^@
| eins
|   one

| zwei
|     two
\^?"))
  (should (ert-equal-buffer
	   (line-block-region nil)
	   "
\^@
    eins
  one

    zwei
    two
\^?"
	   "
\^@
  |   eins
  | one

  |   zwei
  |   two
\^?"))
  (should (ert-equal-buffer
	   (line-block-region t)
	   "
\^@
eins
one

zwei
\^?"
	   "
\^@| 
| eins
| one
| 
| zwei
\^?"))
  (should (ert-equal-buffer
	   (line-block-region t)
	   "
\^@
eins
  one

zwei
\^?"
	   "
\^@| 
| eins
|   one
| 
| zwei
\^?"))
  (should (ert-equal-buffer
	   (line-block-region t)
	   "
\^@
    eins
  one

    zwei
\^?"
	   "
\^@  | 
  |   eins
  | one
  | 
  |   zwei
\^?"))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun indented-block-params (count firstp subp emptyp relind lastret)
  "Return LASTRET appended by a list of current column and the other parameters."
  (append lastret
	  (list (list (current-column) count firstp subp emptyp relind))))

(defun apply-indented-blocks (ind fun)
  "Call `rst-apply-indented-blocks' on current region with IND and FUN."
  (rst-apply-indented-blocks (region-beginning) (region-end) ind fun))

(ert-deftest rst-apply-indented-blocks ()
  "Tests for `rst-apply-indented-blocks'."
  (should (ert-equal-buffer-return
	   (apply-indented-blocks 0 indented-block-params)
	   "\^@abc
\^?"
	   t
	   '((0 1 t   nil nil 0)
	     )))
  (should (ert-equal-buffer-return
	   (apply-indented-blocks 0 indented-block-params)
	   "a\^@b\^?c"
	   t
	   '((0 1 t   nil nil 0)
	     )))
  (should (ert-equal-buffer-return
	   (apply-indented-blocks 2 indented-block-params)
	   "\^@  
  abc
\^?"
	   t
	   '((2 0 nil nil t   nil)
	     (2 1 t   nil nil 0)
	     )))
  (should (ert-equal-buffer-return
	   (apply-indented-blocks 2 indented-block-params)
	   "\^@
  abc

    def
\^?"
	   t
	   '((0 0 nil nil t   nil)
	     (2 1 t   nil nil 0)
	     (0 1 nil t   t   nil)
	     (4 1 nil t   nil 2)
	     )))
  (should (ert-equal-buffer-return
	   (apply-indented-blocks 2 indented-block-params)
	   "\^@
  abc

    def
      ghi
  
\^?"
	   t
	   '((0 0 nil nil t   nil)
	     (2 1 t   nil nil 0)
	     (0 1 nil t   t   nil)
	     (4 1 nil t   nil 2)
	     (6 1 nil t   nil 4)
	     (2 1 nil t   t   nil)
	     )))
  (should (ert-equal-buffer-return
	   (apply-indented-blocks 0 indented-block-params)
	   "\^@\^?abc"
	   t
	   nil))
  (should (ert-equal-buffer-return
	   (apply-indented-blocks 2 indented-block-params)
	   "\^@
  abc

  def
    ghi
\^?"
	   t
	   '((0 0 nil nil t   nil)
	     (2 1 t   nil nil 0)
	     (0 1 nil t   t   nil)
	     (2 2 t   nil nil 0)
	     (4 2 nil t   nil 2)
	     )))
  (should (ert-equal-buffer-return
	   (apply-indented-blocks 2 indented-block-params)
	   "\^@
  abc

def

    ghi
  jkl
  mno
\^?"
    t
    '((0 0 nil nil t   nil)
      (2 1 t   nil nil 0)
      (0 1 nil t   t   nil)
      (2 2 t   nil nil 0)
      (2 2 nil nil nil 0)
      )))
  )
