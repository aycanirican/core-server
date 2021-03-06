(in-package :core-server)

;; -------------------------------------------------------------------------
;; Abstract Security Classes
;; -------------------------------------------------------------------------

;; -------------------------------------------------------------------------
;; Abstract Group
;; -------------------------------------------------------------------------
(defclass+ abstract-group ()
  ((name :accessor group.name :initform (error "Provide :name")
	 :initarg :name :host local :index t :export t :print t)
   (users :host local :export nil :accessor group.users :relation groups
	  :type abstract-user*))
  (:ctor %make-abstract-group))

;; -------------------------------------------------------------------------
;; Abstract User
;; -------------------------------------------------------------------------
(defclass+ abstract-user ()
  ((name :accessor user.name :initform nil :initarg :name :host both
	 :index t :print t)
   (group :accessor user.group :initform nil :initarg :group :host both
	  :print t)
   (groups :accessor user.groups :host local :type abstract-group*
	   :relation users :export nil))
  (:ctor %make-abtract-user))

(defmethod user.has-group ((user abstract-user) (group abstract-group))
  (find group (cons (user.group user) (user.groups user))))

(defmethod user.has-group ((user abstract-user) (group string))
  (find group (cons (user.group user) (user.groups user)) :key #'group.name
	:test #'equal))

;; -------------------------------------------------------------------------
;; Anonymous Group
;; -------------------------------------------------------------------------
(defclass+ anonymous-group (abstract-group)
  ()
  (:ctor make-anonymous-group)
  (:default-initargs :name "Anonymous Group"))

;; -------------------------------------------------------------------------
;; Anonymous User
;; -------------------------------------------------------------------------
(defclass+ anonymous-user (abstract-user)
  ()
  (:ctor make-anonymous-user)
  (:default-initargs :name "Anonymous User" :group (make-anonymous-group)))

