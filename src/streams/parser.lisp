;; Core Server: Web Application Server

;; Copyright (C) 2006-2008  Metin Evrim Ulu, Aycan iRiCAN

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :tr.gen.core.server)
;;(declaim (optimize (speed 3) (space 2) (safety 0) (debug 0) (compilation-speed 0)))

;;;-----------------------------------------------------------------------------
;;; HENRY G. BAKER PARSER GENERATOR WITH EXTENDED GRAMMAR
;;; http://linux.rice.edu/~rahul/hbaker/Prag-Parse.html
;;;-----------------------------------------------------------------------------
;;;-----------------------------------------------------------------------------
;;; Simple Type Definitions - Kludge macros since CL doesn't have Mr. Curry.
;;;-----------------------------------------------------------------------------
(defmacro defatom (name args &rest body)
  "Match definition macro that provides a common lexical environment for matchers."
  `(progn
     (declaim (inline ,name))
     (defun ,name ,(if args (list 'c '&aux args) '(c))
       (if c
	   (let ((c (if (characterp c) (char-code c) c)))
	     (declare (type (unsigned-byte 8) c))
	     ,@body)))
     (export ',name)
     (deftype ,name ()
       `(satisfies ,',name))))

;;; http://www.w3.org/Protocols/rfc2616/rfc2616-sec2.html#sec2
(defatom bit? ()
  (or (= c 0)
      (= c 1)))

(defatom octet? ()
  (and (> c -1) (< c 256)))

(defatom char? ()
  (and (> c -1) (< c 128)))

(defatom upalpha? ()
  (and (> c 64) (< c 91)))

(defatom loalpha? ()
  (and (> c 96) (< c 123)))

(defatom alpha? ()
  (or (loalpha? c)
      (upalpha? c)))

(defatom digit? ()
  (and (> c 47) (< c 58)))

(defatom alphanum? ()
  (or (alpha? c) (digit? c)))

(defatom control? ()
  (or (= c 127) (and (> c -1) (< c 32))))

(defatom carriage-return? ()
  (= c 13))

(defatom linefeed? ()
  (= c 10))

(defatom space? ()
  (= c 32))

(defatom tab? ()
  (= c 9))

(defatom no-break-space? ()
  (= c 160))

(defatom double-quote? ()
  (= c 34))

(defatom return? ()
  (= c 13))

(defatom white-space? ()
  (or (space? c)
      (tab? c)
      (no-break-space? c)))

(defatom visible-char? ()
  (and (> c 32)
       (< c 127)))

(defatom hex-upchar? ()
  (and (> c 64) (< c 71)))

(defatom hex-lochar? ()
  (and (> c 96) (< c 103)))

(defatom hex-char? ()
  (or (hex-upchar? c) (hex-lochar? c)))

(defatom hex? ()
  (or (digit? c) (hex-char? c)))

(defatom upper-case? ()
  (and (> c 64) (< c 91)))

(defatom lower-case? ()
  (and (> c 96) (< c 123)))

;;;---------------------------------------------------------------------------
;;; Parser
;;;---------------------------------------------------------------------------
(eval-when (:compile-toplevel :execute :load-toplevel)
  (defgeneric expand-parser (form expander stream &optional continue
				  checkpoint)
    (:documentation "special dsl for parsing"))

  (defmethod expand-parser ((form t) (expander function) (stream symbol)
			   &optional (continue nil) (checkpoint nil))
    (declare (ignore continue checkpoint))
    `(when (eq (peek-stream ,stream) ,(if (characterp form)
					  (char-code form)
					  form))
       (read-stream ,stream)))

  (defmethod expand-parser ((form operator) (expander function)
			    (stream symbol)
			    &optional (continue nil) (checkpoint nil))
    (expand-grammar form expander stream continue checkpoint)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro defparser (name args &rest body)
    "Parser rule defining macro that provides a common lexical
environment for rules."
    (with-unique-names (stream)
      (flet ((rule-args ()
	       (if args
		   (list* stream '&aux args)
		   (list stream))))
	`(defun ,name ,(rule-args)
	   (block rule-block
	     (let ((cp (current-checkpoint ,stream)))
	       (declare (ignorable cp))
	       ,(expand-parser (walk-grammar `(:checkpoint ,@body))
			       #'expand-parser stream)
	       nil)))))))

(defmacalias defparser defrule)

(defparser crlf? ()
  (:or (:checkpoint #\Return #\Newline (:commit))
       #\Newline)
  (:return t))

(defparser lwsp? ()
  (:zom (:type (or space? tab? carriage-return? linefeed?)))
  (:return t))

(defparser hex-value? (a b)
  (:or (:and (:type digit? a)
	     (:do (setq a (- (the (unsigned-byte 8) a) 48))))
       (:and (:type hex-upchar? a)
	     (:do (setq a (+ 10 (- (the (unsigned-byte 8) a) 65)))))
       (:and (:type hex-lochar? a)
	     (:do (setq a (+ 10 (- (the (unsigned-byte 8) a) 97))))))
  (:or (:and (:type digit? b)
	     (:do (setq b (- (the (unsigned-byte 8) b) 48))))
       (:and (:type hex-upchar? b)
	     (:do (setq b (+ 10 (- (the (unsigned-byte 8) b) 65)))))
       (:and (:type hex-lochar? b)
	     (:do (setq b (+ 10 (- (the (unsigned-byte 8) b) 97))))))
  (:return (+ (* (the (unsigned-byte 8) a) 16) (the (unsigned-byte 8) b))))

(defparser hex-value*? (a acc)
  (:zom (:or (:and (:type digit? a)
		   (:do (setq a (- (the (unsigned-byte 8) a) 48))))
	     (:and (:type hex-upchar? a)
		   (:do (setq a (+ 10 (- (the (unsigned-byte 8) a) 65)))))
	     (:and (:type hex-lochar? a)
		   (:do (setq a (+ 10 (- (the (unsigned-byte 8) a) 97))))))
	(:do (push a acc)))
  (:return (reduce (lambda (acc a)
		     (+ (ash acc 4) a))
		   (reverse acc) :initial-value 0)))


;;       escaped       = "%" hex hex
(eval-when (:load-toplevel :compile-toplevel :execute)
  (defparser escaped? (hex)  
    #\% (:hex-value? hex) (:return hex)))

(defparser digit-value? (d)
  (:type digit? d)
  (:return (- (the (unsigned-byte 8) d) 48)))

(eval-when (:load-toplevel :compile-toplevel :execute)
  (defparser fixnum? ((acc (make-accumulator)) c)
    (:type digit? c) (:collect c acc)
    (:zom (:type digit? c)
	  (:collect c acc))
    (:return (parse-integer acc))))

(defparser string? (c (acc (make-accumulator)))
  (:zom (:type visible-char? c)
	(:collect c acc))
  (:return acc))

(defparser float? ((acc (make-accumulator)) c)
  (:and (:zom (:type digit? c) (:collect c acc))
	(:and #\. (:collect #\. acc))
	(:oom (:type digit? c) (:collect c acc)))
  (:return acc))

(eval-when (:load-toplevel :compile-toplevel :execute)
  (defparser version? (version d)
    (:fixnum? d) (:do (push d version))
    (:zom #\. (:fixnum? d) (:do (push d version)))
    (:return (nreverse version))))

(eval-when (:load-toplevel :compile-toplevel :execute)
  (defparser utf-escaped? (f1 f2 f3 f4)
    (:sci "%u")
    (:type hex? f1)  (:type hex? f2) (:type hex? f3) (:type hex? f4)
    ;; (:do (describe (list f1 f2 f3 f4)))
    (:return ;;(+ (- f1 48) (* 8 (- f2 48)) (* 16 (- f3 48)) (* 32 (- f4 48)))
      (with-input-from-string (s (format nil "#x~C~C~C~C"
					 (code-char f1) (code-char f2)
					 (code-char f3) (code-char f4)))
	(read s)))))

;; ie. \u0040 -> @ symbol
;; used in javascript
(defparser utf-escaped2? (f1 f2 f3 f4)
  (:seq "\\u")
  (:type hex? f1)  (:type hex? f2) (:type hex? f3) (:type hex? f4)
  ;; (:do (describe (list f1 f2 f3 f4)))
  (:return ;;(+ (- f1 48) (* 8 (- f2 48)) (* 16 (- f3 48)) (* 32 (- f4 48)))
    (with-input-from-string (s (format nil "#x~C~C~C~C"
				       (code-char f1) (code-char f2)
				       (code-char f3) (code-char f4)))
      (read s))))

(defparser escaped-string? (c (acc (make-accumulator :byte)))
  (:oom (:or (:utf-escaped2? c) (:escaped? c) (:type octet? c))
	(:collect c acc))
  (:return (if (> (length acc) 0)
	       (octets-to-string acc :utf-8)
	       acc)))

(defparser quoted? (c acc identifier)
  (:or (:and #\' (:do (setq identifier #.(char-code #\'))))
       (:and #\" (:do (setq identifier #.(char-code #\")))))
  (:or (:and (:if (eq identifier #.(char-code #\'))
		  #\'
		  #\")
	     (:return ""))
       (:and (:do (setq acc (make-accumulator :byte)))
	     (:oom (:if (eq identifier #.(char-code #\'))
			(:not #\')
			(:not #\"))
		   (:or (:utf-escaped2? c)
			(:escaped? c)
			(:and #\\ (:type octet? c))
			(:type octet? c))
		   (:collect c acc))
	     (:return (octets-to-string acc :utf-8))))

;; (defparser quoted? (c (acc (make-accumulator :byte)))
;;   (:or (:and #\'
;; 	     (:zom (:or (:and (:seq "\\\'") (:do (setq c #.(char-code #\'))))
;; 			(:and (:not #\')
;; 			      (:or (:escaped? c)
;; 				   (:type octet? c))))
;; 		   (:collect c acc))
;; 	     (:return (octets-to-string acc :utf-8)))
;;        (:and #\"
;; 	     (:zom
;; 	      (:or
;; 	       (:and (:seq "\\\"") (:do (setq c #.(char-code #\"))))
;; 	       (:and (:not #\")
;; 		     (:or (:escaped? c)
;; 			  (:type octet? c))))
;; 	      (:collect c acc))
;; 	     (:return (octets-to-string acc :utf-8)))))

  (defparser parse-line? (c (acc (make-accumulator)))
    (:zom (:or (:and #\Newline (:return acc))
	       (:and (:type octet? c) (:collect c acc))))
    (:return acc)))

(defparser lines? (c (acc (make-accumulator)) lst)
  (:oom (:or (:and #\Newline (:do (push acc lst)
				  (setq acc (make-accumulator))))
	     (:and (:type octet? c) (:collect c acc))))
  (:return (nreverse
	    (if (> (length acc) 0)
		(cons acc lst)
		lst))))

(defparser words? (c (acc (make-accumulator)) lst)
  (:lwsp?)
  (:zom (:or (:and #\Space (:do (push acc lst)
				(setq acc (make-accumulator))))
	     (:and (:type octet? c) (:collect c acc))))
  (:do (if (> (length acc) 0 ) (push acc lst)))
  (:return (reverse lst)))

;; (declaim (inline match-atom))
;; (defun match-atom (stream atom)
;;   (let ((c (peek-stream stream)))    
;;     (cond
;;       ((and (characterp atom) (> (char-code atom) 127)) ;;utf-8
;;        (prog1 t
;; 	 (checkpoint-stream stream) 
;; 	 (prog1 t
;; 	   (reduce #'(lambda (acc atom)
;; 		       (declare (ignore acc))
;; 		       (if (eq (the (unsigned-byte 8) atom) (the (unsigned-byte 8) c))
;; 			   (progn
;; 			     (read-stream c) (setq c (peek-stream stream)))
;; 			   (progn
;; 			     (rewind-stream stream)
;; 			     (return-from match-atom nil)))
;; 		       nil)
;; 		   (string-to-octets (string atom) :utf-8) :initial-value nil))
;; 	 (commit-stream stream)))
;;       ((characterp atom) (eq c (char-code atom)))
;;       (t (eq atom c)))))

;; (defmacro match/stream (stream atom)
;;   `(when (match-atom ,stream ,atom)
;;      (read-stream ,stream)))

;; (defmacro match-type/stream (stream type var)
;;   `(when (typep (peek-stream ,stream) ',type)
;;     ,(if (null var)
;;          `(read-stream ,stream)
;;          `(setq ,var (read-stream ,stream)))))

;; (eval-when (:compile-toplevel :load-toplevel :execute)
;;   (defvar +parser-rules+ (make-hash-table :test #'equal)) ;; Rule or not
;;   (defvar +checkpoint+ nil)) ;; used for backtracking
  
;; (eval-when (:compile-toplevel :load-toplevel :execute)  
;;   (defun compile-parser-grammar (stream-var form
;; 				 &optional (match-func 'match/stream)
;; 				 (match-type-func 'match-type/stream))
;;     (labels
;; 	((compile1 (form &optional (continue nil))
;; 	   (cond
;; 	     ((and (consp form) (keywordp (car form)))
;; 	      (case (car form)
;; 		((:and)
;; 		 `(and ,@(compiled-subexprs form t)))
;; 		((:or)
;; 		 `(or ,@(compiled-subexprs form nil)))
;; 		((:not)
;; 		 `(not ,@(compiled-subexprs form continue))) 
;; 		((:checkpoint)
;; 		 (with-unique-names (checkpoint)
;; 		   (let ((+checkpoint+ checkpoint)) 
;; 		     `(block ,checkpoint
;; 			(checkpoint-stream ,stream-var)
;; 			,(compile1 `(:and ,@(cdr form)))
;; 			(rewind-stream ,stream-var)
;; 			,continue))))
;; 		((:commit)
;; 		 `(progn
;; 		    (commit-stream ,stream-var)
;; 		    (return-from ,+checkpoint+ ,continue)))
;; 		((:rewind)
;; 		 `(progn
;; 		    (rewind-stream ,stream-var)
;; 		    (return-from ,+checkpoint+ ,continue)))
;; 		((:return)
;; 		 `(let ((retval (multiple-value-list ,(cadr form))))
;; 		    (cond
;; 		      ((= (the fixnum (current-checkpoint ,stream-var)) (the fixnum cp)) nil)
;; 		      ((< (the fixnum (current-checkpoint ,stream-var)) (the fixnum cp))
;; 		       (error "This parser rule is not functional!"))
;; 		      (t (do ((i (current-checkpoint ,stream-var)
;; 				 (current-checkpoint ,stream-var)))
;; 			     ((= (the fixnum i) (the fixnum cp)) nil)
;; 			   (commit-stream ,stream-var))))
;; 		    (return-from rule-block (apply #'values retval))))
;; 		((:rewind-return)
;; 		 `(progn (rewind-stream ,stream-var)
;; 			 ,(compile1 `(:return ,(cadr form)))))
;; 		((:zero-or-more :zom)
;; 		 `(not (do () ((not ,(compile1 `(:and ,@(cdr form)) continue))))))
;; 		((:one-or-more :oom)
;; 		 (compile1 `(:and ,@(cdr form) (:zom ,@(cdr form))) continue))
;; 		((:if)
;; 		 `(prog1 ,continue
;; 		    (if ,(cadr form) 
;; 			,(compile1 (caddr form))			 
;; 			,(if (cadddr form)
;; 			     (compile1 (cadddr form))))))
;; 		((:cond)
;; 		 `(prog1 ,continue
;; 		    (cond
;; 		      ,@(mapcar #'(lambda (atom)
;; 				    (list (car atom)
;; 					  (compile1 `(:and ,@(cdr atom)))))
;; 				(cdr form)))))
;; 		((:sequence-case-sensitive :scs :sequence :seq)
;; 		 (if (stringp (cadr form))
;; 		     (compile1
;; 		      `(:checkpoint
;; 			,@(nreverse
;; 			   (reduce #'(lambda (acc atom)
;; 				       (cons atom acc))
;; 				   (cadr form) :initial-value nil))
;; 			(:commit)))
;; 		     (compile1
;; 		      `(:checkpoint
;; 			(:do
;; 			 (reduce #'(lambda (acc atom)
;; 				     (declare (ignore acc))
;; 				     (when (not (,match-func ,stream-var atom))
;; 				       (rewind-stream ,stream-var)
;; 				       (return-from ,+checkpoint+ nil)))
;; 				 ,(cadr form) :initial-value nil))
;; 			(:commit)))))
;; 		((:sequence-case-insensitive :sci)
;; 		 (if (stringp (cadr form))
;; 		     (compile1
;; 		      `(:checkpoint
;; 			,@(nreverse
;; 			   (reduce #'(lambda (acc atom)
;; 				       (let ((upcase (char-upcase atom))
;; 					     (downcase (char-downcase atom)))
;; 					 (if (eq upcase downcase)
;; 					     (cons atom acc)
;; 					     (cons (list ':or upcase downcase)
;; 						   acc))))
;; 				   (cadr form) :initial-value nil))
;; 			(:commit)))
;; 		     (compile1
;; 		      `(:checkpoint
;; 			(:do
;; 			 (reduce #'(lambda (acc atom)
;; 				     (declare (ignore acc))
;; 				     (when (not (or (,match-func ,stream-var (char-upcase atom))
;; 						    (,match-func ,stream-var (char-downcase atom))))
;; 				       (rewind-stream ,stream-var)
;; 				       (return-from ,+checkpoint+ nil)))
;; 				 ,(cadr form) :initial-value nil))
;; 			(:commit)))))
;; 		((:empty) t)
;; 		((:type)
;; 		 (assert (null (cdddr form)))	       
;; 		 `(,match-type-func ,stream-var ,(cadr form) ,(caddr form)))
;; 		((:do)
;; 		 (assert (not (null (cdr form))))
;; 		 `(progn ,@(cdr form)
;; 			 ,continue))
;; 		((:collect)
;; 		 (assert (null (cdddr form)))
;; 		 `(or (push-atom ,(cadr form) ,(caddr form)) t))				
;; 		((:debug)
;; 		 `(or (format t "current char-code:~D~%" (let ((c (peek-stream ,stream-var)))
;; 							   (if (characterp c)
;; 							       (char-code c)
;; 							       c)))
;; 		      ,continue))
;; 		((:current)
;; 		 `(progn (describe ,stream-var) ,continue))
;; 		(t
;; 		 (if (< (length (cdr form)) 1)
;; 		     `(,(intern (symbol-name (car form))) ,stream-var)
;; 		     `(multiple-value-setq ,(cdr form) 
;; 			(,(intern (symbol-name (car form))) ,stream-var))))))
;; ;; 		 (if (gethash (car form) +parser-rules+)
;; ;; 		     (if (< (length (cdr form)) 1)
;; ;; 			 `(,(gethash (car form) +parser-rules+) ,stream-var)
;; ;; 			 `(multiple-value-setq ,(cdr form) (,(gethash (car form) +parser-rules+) ,stream-var)))
;; ;; 		     (error "No rule associated with:~A" (car form))))))
;; 	   (t
;; 	    `(,match-func ,stream-var ,form))))
;;       (compiled-subexprs (form &optional (continue t))
;; 			 (mapcar #'(lambda (f) (compile1 f continue)) (cdr form))))
;;     (compile1 form))))

;; ;;;-----------------------------------------------------------------------------
;; ;;; Rules
;; ;;;-----------------------------------------------------------------------------
;; (eval-when (:compile-toplevel :load-toplevel :execute)
;;   (defmacro defrule (name args &rest body)
;;     "Rule definition macro that provides a common lexical environment for rules."
;;     (with-unique-names (stream)
;;       (flet ((rule-args ()
;; 	       (if args
;; 		   (list* stream '&aux args)
;; 		   (list stream))))
;; 	(setf (gethash (make-keyword name) +parser-rules+) name)
;; 	`(defun ,name ,(rule-args)
;; 	   (block rule-block
;; 	     (let ((cp (current-checkpoint ,stream)))
;; 	       (declare (ignorable cp))
;; 	       ,(compile-parser-grammar stream `(:checkpoint ,@body))
;; 	       nil)))))))
;; ;;;-----------------------------------------------------------------------------
;; ;;; Rules
;; ;;;-----------------------------------------------------------------------------
;; (eval-when (:compile-toplevel :load-toplevel :execute)
;;   (defmacro defrule (name args &rest body)
;;     "Rule definition macro that provides a common lexical environment for rules."
;;     (with-unique-names (stream)
;;       (flet ((rule-args ()
;; 	       (if args
;; 		   (list* stream '&aux args)
;; 		   (list stream))))
;; 	(setf (gethash (make-keyword name) +parser-rules+) name)
;; 	`(defun ,name ,(rule-args)
;; 	   (block rule-block
;; 	     (let ((cp (current-checkpoint ,stream)))
;; 	       (declare (ignorable cp))
;; 	       ,(compile-parser-grammar stream `(:checkpoint ,@body))
;; 	       nil)))))))


;; (defmacro defvector-render (name args &body body)
;;   `(defmethod ,name ((stream core-vector-io-stream) ,@args)
;;      ,@body
;;      stream))

;; (defvector-render null! ()
;;   (string! stream "NIL"))

;; (defvector-render t! ()
;;   (string! stream "T"))

;; (defvector-render boolean! (boolean)
;;   (if boolean
;;       (t! stream)
;;       (null! stream)))

;; (defvector-render symbol! ((symbol symbol))
;;   (let ((package (symbol-package symbol))
;; 	(name (prin1-to-string symbol)))
;;     (cond ((eq package (find-package 'common-lisp)) (string! stream "CL:"))
;; 	  ((eq package (find-package 'keyword)) (string! stream #\:))
;; 	  (t (string! stream (package-name package))
;; 	     (string! stream "::")))
;;     (if (char= (char name (1- (length name))) #\|)
;; 	(string! stream (subseq name (position #\| name)))
;; 	(string! stream (subseq name (1+ (or (position #\: name :from-end t) -1)))))))

;; (defvector-render sequence! ((sequence sequence))
;;   (flet ((proper-sequence (length)
;; 	   (let ((id (set-known-object serialization-state object)))
;; 	     (string! stream "(:SEQUENCE ")
;; 	     (fixnum! stream id)
;; 	     (string! stream " :CLASS ")
;; 	     (symbol! stream (etypecase object (list 'list) (vector 'vector)))
;; 	     (string! stream " :SIZE ")
;; 	     (fixnum! stream length)
;; 	     (unless (zerop length)
;; 	       (string! stream " :ELEMENTS (")
;; 	       (map nil
;; 		    #'(lambda (element) 
;; 			(char! stream #\Space)
;; 			(funcall (type-of element) stream serialization-state))
;; 		    object))
;; 	     (string! stream " ) )")))
;; 	 (improper-list ()           
;; 	   (let ((id (set-known-object serialization-state object)))
;; 	     (string! stream "(:CONS ")
;; 	     (fixnum! stream id)
;; 	     (char! stream #\Space)        
;; 	     (serialize-sexp-internal (car object) stream serialization-state)
;; 	     (char! stream #\Space)                
;; 	     (serialize-sexp-internal (cdr object) stream serialization-state)
;; 	     (string! stream " ) "))))
;;     (let ((id (known-object-id serialization-state object)))
;;       (if id
;; 	  (progn
;; 	    (string! stream "(:REF . ")
;; 	    (fixnum! stream id)
;; 	    (string! stream ")"))
;; 	  (multiple-value-bind (seq-type length) (sequence-type-and-length object)
;; 	    (ecase seq-type
;; 	      ((:proper-sequence :proper-list) (proper-sequence length))
;; 	      ((:dotted-list :circular-list) (improper-list))))))))

;; (defvector-render hash-table! ((hash-table hash-table))
;;   (let ((id (known-object-id serialization-state object)))
;;     (if id
;; 	(progn
;; 	  (string! stream "(:REF . ")
;; 	  (fixnum! stream id)
;; 	  (string! stream ")"))
;; 	(let ((count (hash-table-count object)))
;; 	  (setf id (set-known-object serialization-state object))
;; 	  (string! stream "(:HASH-TABLE ")
;; 	  (fixnum! stream id)
;; 	  (string! stream " :TEST ")
;; 	  (symbol! stream (hash-table-test object))
;; 	  (string! stream " :SIZE ")
;; 	  (fixnum! stream (hash-table-size object))
;; 	  (string! stream " :REHASH-SIZE ")
;; 	  (fixnum! stream (hash-table-rehash-size object))
;; 	  (string! stream " :REHASH-THRESHOLD ")
;; 	  (prin1 (hash-table-rehash-threshold object) stream)
;; 	  (unless (zerop count)
;; 	    (write-string " :ENTRIES (" stream)
;; 	    (maphash #'(lambda (key value)
;; 			 (write-string " (" stream)
;; 			 (serialize-sexp-internal key stream serialization-state)
;; 			 (write-string " . " stream)
;; 			 (serialize-sexp-internal value stream serialization-state)
;; 			 (princ ")" stream))
;; 		     object))
;; 	  (write-string " ) )" stream)))))

;; (defmethod structure-object! ((stream core-vector-io-stream)
;; 			      (structure-object structure-object))
;;   (let ((id (known-object-id serialization-state object)))
;;     (if id
;; 	(progn
;; 	  (write-string "(:REF . " stream)
;; 	  (prin1 id stream)
;; 	  (write-string ")" stream))
;; 	(let ((serializable-slots (get-serializable-slots serialization-state object)))
;; 	  (setf id (set-known-object serialization-state object))
;; 	  (write-string "(:STRUCT " stream)
;; 	  (prin1 id stream)
;; 	  (write-string " :CLASS " stream)
;; 	  (print-symbol (class-name (class-of object)) stream)
;; 	  (when serializable-slots
;; 	    (write-string " :SLOTS (" stream)
;; 	    (mapc #'(lambda (slot)
;; 		      (write-string " (" stream)
;; 		      (print-symbol slot stream)
;; 		      (write-string " . " stream)
;; 		      (serialize-sexp-internal (slot-value object slot) stream serialization-state)
;; 		      (write-string ")" stream))
;; 		  serializable-slots))
;; 	  (write-string " ) )" stream)))))

;; (defmethod standard-object ((stream core-vector-io-stream)
;; 			    (standard-object standard-object))
;;   (let ((id (known-object-id serialization-state object)))
;;     (if id
;; 	(progn
;; 	  (write-string "(:REF . " stream)
;; 	  (prin1 id stream)
;; 	  (write-string ")" stream))
;; 	(let ((serializable-slots (get-serializable-slots serialization-state object)))
;; 	  (setf id (set-known-object serialization-state object))
;; 	  (write-string "(:OBJECT " stream)
;; 	  (prin1 id stream)
;; 	  (write-string " :CLASS " stream)
;; 	  (print-symbol (class-name (class-of object)) stream)
;; 	  (when serializable-slots
;; 	    (princ " :SLOTS (" stream)
;; 	    (loop :for slot :in serializable-slots
;; 	       :do (when (slot-boundp object slot)
;; 		     (write-string " (" stream)
;; 		     (print-symbol slot stream)
;; 		     (write-string " . " stream)
;; 		     (serialize-sexp-internal (slot-value object slot) stream serialization-state)
;; 		     (write-string ")" stream))))
;; 	  (write-string " ) )" stream)))))

;; (defrule abc? (header abc)
;;   (:cond
;;     ((string= "abc" header)
;;      (:zom (:type visible-char?))
;;      (:do (setq abc 1)))
;;     (t
;;      (:return 1))))
;; (defrule abc? ()
;;   #\1 #\2 #\6
;;   (:return (list 1 2)))

;;(defparameter *gee (format nil  "TEXTEE~CTEXTBB~C" #\Newline #\Newline))
;;(defparameter *gee (format nil  "~C~C~C~Ca" #\Return #\Linefeed #\Space #\Tab))
;;(defparameter *gee (format nil  "~C~C" #\Space #\Tab))
;;(defparameter *gee (format nil  "A7"))
;; (defrule text-newline (c (text (make-accumulator)) (text2 (make-accumulator)))
;;   (:and (:zom (:type alpha? c)
;; 	      (:collect c text))
;; 	(:type linefeed?))
;;   (:debug)
;;   (:and (:zom (:type alpha? c)
;; 	      (:collect c text2))
;; 	(:type linefeed?))
;;   (:return (values text text2)))

;; (defmacro match (&rest matchers)
;;   "Attempts to match the next input character with one of the supplied matchers."
;;   `(and
;;     (or ,@(loop for m in matchers
;; 	     collect `(match-atom ,m s)))
;;     ;; cheat here a little bit - eat entire char entity instead
;;     ;; of peeked char
;;     (eat)))

;; (defmacro match-seq (&rest sequence)
;;   "Tries to match the supplied matchers in sequence with characters in the input stream."
;;   `(and ,@(loop for s in sequence
;;                 collect `(match ,s))))

;; (defmacro match* (&rest sequence)
;;   "Matches any occurances of any of the supplied matchers."
;;   `(loop with data = (make-accumulator (stream-type s))
;;       for c = (match ,@sequence)
;;       while c
;;       do (push-atom c data)
;;       finally (return data)))

;; (defmacro peek (&rest matchers)
;;   "Looks ahead for an occurance of any of the supplied matchers."
;;   `(or ,@(loop for m in matchers
;; 	      collect `(match-atom ,m s))))

;; (defmacro match+ (&rest sequence)
;;   "Matches one or more occurances of any of the supplied matchers."
;;   `(and (peek ,@sequence)
;;     (match* ,@sequence)))

;; (defmacro must ((error-type &rest error-args) &rest body)
;;   "Throws a parse error if the supplied forms do not succeed."
;;   `(or (progn ,@body)
;;        (error ',error-type ,@error-args)))

