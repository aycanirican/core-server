(in-package :core-server)

;;+----------------------------------------------------------------------------
;;| Class+ Framework for [Core-serveR]
;;+----------------------------------------------------------------------------
;;
;; Class+ framework is used to save several class definition parameters
;; so that they can be reached during compile/execution time. MOP can
;; also provide us some of the information but since there are numerous
;; incompatible Common-lisp implementations, we prefered a new framework.
;;
;; Generally, those parameters are accessed during compile time. Several
;; frameworks inside [Core-serveR] uses Class+:
;; i)  Command Framework - Used to execute unix shell commands
;; ii) Component Framework - Used to generate remote proxies for web widgets
;; 
;; defclass+ is the main macro for class+ framework. Interface functions are
;; as follows:
;;
;; - local-slots-of-class
;; - remote-slots-of-class
;; - default-initargs-of-class
;; - client-type-of-slot
;; - local-methods-of-class
;; - remote-methods-of-class
;;
;; TODO: Explain what is local/remote slot/method, client-type
;; FIXmE: Bug me on the list if you wish to learn -evrim.

(eval-when (:execute :compile-toplevel :load-toplevel)
  (defvar +class-registry+ (make-hash-table :test #'equal)
    "Registry of the Class+ Framework")

  (defun class-successor (class)
    "Returns successor of 'class' in the registry"
    (mapcar (lambda (class) (gethash class +class-registry+))
	    (getf class :supers)))

  (defun class-search (name type &optional (key #'list-or-atom-key))
    "Class tree search function for class 'name'. 'type' can be:
i)  :local-slots - Returns local slots of the class
ii) :remote-slots - Returns remote slots of the class 
iii):default-initargs - Returns default-initargs of the class
iv) :client-types - Returns client-types of the class
v)  :local-methods - Returns local-methods of the class
vi) :remote-methods - Return remote-methods of the class"
    (let (lst)
      (core-search (cons (gethash name +class-registry+) nil)
		   (lambda (atom)
		     (aif (getf atom type)
			  (mapcar (lambda (slot) (pushnew slot lst :key key))
				  (ensure-list it)))
		     nil)
		   #'class-successor #'append)
      lst))

  (defun list-or-atom-key (a)
    (if (listp a) (car a) a))

  (defun local-slots-of-class (name)
    "Returns local slots of the class 'name'"
    (class-search name :local-slots))

  (defun remote-slots-of-class (name)
    "Returns remote slots of the class 'name'"
    (class-search name :remote-slots))

  (defun default-initargs-of-class (name)
    "Returns default-initargs of the class 'name'"
    (class-search name :default-initargs))

  (defun client-type-of-slot (name slot)
    "Returns client-type of the slot 'slot' of the class 'name'. Default
client-type is :primitive"
    (core-search (cons (gethash name +class-registry+) nil)
		 (lambda (atom)
		   (aif (cdr (assoc slot (getf atom :client-types)))
			(return-from client-type-of-slot it)))
		 #'class-successor
		 #'append)
    nil)

  (defun local-methods-of-class (name)
    "Returns local-methods of the class 'name'"
    (class-search name :local-methods))

  (defun remote-methods-of-class (name)
    "Returns remote-methods of the class 'name'"
    (class-search name :remote-methods #'identity))

  (defun register-local-method-for-class (name method-name)
    (setf (getf (gethash name +class-registry+) :local-methods)
	  (cons method-name
		(remove method-name
			(getf (gethash name +class-registry+) :local-methods)))))

  (defun register-remote-method-for-class (name method-name)
    (setf (getf (gethash name +class-registry+) :remote-methods)
	  (cons method-name
		(remove method-name
			(getf (gethash name +class-registry+) :remote-methods)))))

  (defun ctor-arguments (name)
    (reduce #'(lambda (acc slot-def)
		(cons (make-keyword (car (ensure-list slot-def)))
		      (cons (car (ensure-list slot-def)) acc)))
	    (append (remote-slots-of-class name)
		    (local-slots-of-class name)) :initial-value nil))
  
  (defun register-class (name supers slots rest)
    (flet ((filter-slot (slot-definition)
	     (when (or (eq 'local (getf (cdr slot-definition) :host))
		       (eq 'both  (getf (cdr slot-definition) :host)))
	       (unless (getf (cdr slot-definition) :initarg)
		 (setf (getf (cdr slot-definition) :initarg) (make-keyword (car slot-definition)))))
	     (unless (getf (cdr slot-definition) :accessor)
	       (setf (getf (cdr slot-definition) :accessor) (car slot-definition)))
	     (remf (cdr slot-definition) :host)
	     (remf (cdr slot-definition) :client-type)
	     slot-definition)
	   (filter-rest (acc atom)
	     (if (member (car atom) '(:default-initargs :documetation :metaclass))
		 (cons atom acc)
		 acc))
	   (client-type (slot)
	     (cons (car slot) (or (getf (cdr slot) :client-type) 'primitive)))
	   (local-slots (slots)
	     (nreverse
	      (reduce #'(lambda (acc slot)
			  (if (or (eq 'local (getf (cdr slot) :host))
				  (eq 'both (getf (cdr slot) :host)))
			      (aif (getf (cdr slot) :initform)
				   (cons (list (car slot) it) acc)
				   (cons (car slot) acc))
			      acc))
		      slots :initial-value nil)))
	   (remote-slots (slots)
	     (nreverse
	      (reduce #'(lambda (acc slot)
			  (if (or (eq 'remote (getf (cdr slot) :host))
				  (eq 'both (getf (cdr slot) :host)))
			      (cons (car slot) acc)
			      acc))
		      slots :initial-value nil))))
      (setf (getf (gethash name +class-registry+) :supers) supers
	    (getf (gethash name +class-registry+) :default-initargs) (plist-to-alist (cdr (assoc :default-initargs rest)))
	    (getf (gethash name +class-registry+) :local-slots) (local-slots slots)
	    (getf (gethash name +class-registry+) :remote-slots) (remote-slots slots)
	    (getf (gethash name +class-registry+) :client-types) (mapcar #'client-type slots))
      (values (mapcar #'filter-slot slots) (reduce #'filter-rest rest :initial-value nil)))))

(defmacro defclass+ (name supers slots &rest rest)
  "Defines a class using Class+ Framework"
  (multiple-value-bind (slots new-rest) (register-class name supers slots rest)    
    `(prog1 (defclass ,name (,@supers component)
	      ,slots
	      (:default-initargs ,@(alist-to-plist (default-initargs-of-class name)))
	      ,@(remove :default-initargs new-rest :key #'car))
       ,(aif (cdr (assoc :ctor rest))
	     `(defun ,name ,@it
		(apply #'make-instance ',name (list ,@(extract-argument-names (car it)))))
	     `(defun ,name (&key ,@(local-slots-of-class name) ,@(remote-slots-of-class name))
		(apply #'make-instance ',name (list ,@(ctor-arguments name))))))))

(deftrace class+
    '(register-class register-remote-method-for-class register-local-method-for-class
      class-search local-slots-of-class remote-slots-of-class
      default-initargs-of-class client-type-of-slot local-methods-of-class
      remote-methods-of-class))
