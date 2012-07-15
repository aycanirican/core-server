(in-package :manager)

(defvar *wwwroot* (make-project-path "manager" "wwwroot"))

(defvar *db-location*
  (merge-pathnames
   (make-pathname :directory '(:relative "var" "localhost" "db"))
   (tr.gen.core.server.bootstrap:home)))

;; -------------------------------------------------------------------------
;; Manager Application
;; -------------------------------------------------------------------------
(defapplication manager-application (root-http-application-mixin
				     http-application database-server
				     logger-server
				     serializable-web-application)
  ()
  (:default-initargs
      :database-directory *db-location*
    :db-auto-start t
    :fqdn "localhost"
    :admin-email "root@localhost"
    :project-name "manager"
    :project-pathname #p"/home/aycan/core-server/projects/manager/"
    :htdocs-pathname *wwwroot*
    :sources '(src/packages src/model src/tx src/interfaces src/application
	       src/security src/ui/main)
    :directories '(#p"src/" #p"src/ui/" #p"t/" #p"doc/" #p"wwwroot/"
		   #p"wwwroot/style/" #p"wwwroot/images/" #p"templates/"
		   #p"db/")
    :use '(:common-lisp :core-server :cl-prevalence :arnesi)
    :depends-on '(:arnesi+ :core-server)))

(defvar *app* (make-instance 'manager-application))

(defmethod http-application.password-of ((self manager-application)
					 (username string))
  (aif (admin.find self :username username)
       (admin.password it)))

(defmethod http-application.find-user ((self manager-application)
				       (username string))
  (admin.find self :username username))

(defmethod init-database ((self manager-application))
  (assert (null (database.get self 'initialized)))
  (setf (database.get self 'api-secret) (random-string))
  (let ((group (simple-group.add self :name "admin")))
    (admin.add self :name "Root User" :username "root" :password "core-server"
	       :owner nil :group group))
  (setf (database.get self 'initialized) t)
  self)

(defmethod start ((self manager-application))
  (if (not (database.get self 'initialized))
      (prog1 t (init-database self))
      nil))

(defun register-me (&optional (server *server*))
  (if (null (status *app*)) (start *app*))
  (register server *app*))

(defun unregister-me (&optional (server *server*))
  (unregister server *app*))

(defun hostname ()
  #+sbcl (sb-unix:unix-gethostname)
  #-sbcl "N/A")

(defun core-server-version ()
  (slot-value (asdf::find-system "core-server") 'asdf::version))

;; -------------------------------------------------------------------------
;; Index Loop
;; -------------------------------------------------------------------------

;; Uncomment below macro and M-x slime-macroexpand-1-inplace
;; You will see similar to below defhandler.
;;(defhandler/static #P"~/core-server/src/manager/wwwroot/index.html" "index.foo")


;; (defhandler/static #P"~/core-server/src/manager/wwwroot/index.html" "index.foo")

;; (DEFHANDLER "index.mtml" ((SELF HTTP-APPLICATION))
;;   (destructuring-bind (username password) (SEND/SUSPEND
;; 					    (index.foo self +context+))
;;     (let ((admin (admin.find self :username username)))
;;       (cond
;; 	((and admin (equal (admin.password admin) password))
;; 	 (continue/js
;; 	  (lambda (self k)
;; 	    (k (setf window.location "manager.foo")))))
;; 	(t nil)))))

(defhandler "index\.core" ((self manager-application))
  (destructuring-bind (username password)
      (javascript/suspend
       (lambda (stream)
	 (let ((box (<core:login))
	       (clock (<core:simple-clock)))
	   (with-js (box clock) stream
	     (let ((ctor box)
		   (cl clock))
	       (add-on-load
		(lambda ()
		  (ctor (document.get-element-by-id "login")
			(lambda (result)
			  (cl (document.get-element-by-id "clock" window.k)))))))))))
    (continue/js
     (let ((admin (admin.find self :username username)))
       (cond
	 ((and admin (equal (admin.password admin) password))
	  (prog1 (lambda (self k) (k (setf window.location "manager.html")))
	    (update-session :user admin)))
	 (t nil))))))

;; -------------------------------------------------------------------------
;; Main Manager Loop
;; -------------------------------------------------------------------------
(defhandler "manager\.core" ((self manager-application))
  (javascript/suspend
   (lambda (stream)
     (aif (query-session :user)
	  (let ((manager (or (query-session :manager)
			     (update-session :manager
					     (make-controller self it)))))
	    (with-js (manager) stream
	      (let ((ctor manager))
		(add-on-load (lambda () (ctor null window.k))))))
	  (with-js () stream
	    (setf window.location "index.html"))))))

(defhandler "auth\.core" ((self manager-application) (reply-to "reply-to")
			(action "action") (mode "mode"))
  (<:html
   (<:head
    (<:title "Core Server - http://labs.core.gen.tr/")
    (<:meta :http--equiv "Content-Type" :content "text/html; charset=utf-8")
    (<:link :rel "stylesheet" :href "/style/reset.css")
    (<:link :rel "stylesheet" :href "/style/common.css")
    (<:style :type "text/css"
	     (css "body"
		  :background "url('/style/dialog/stripe.png')"))
    (<:script :type "text/javascript" :src "library.core"))
   (<:body :class "stripe-bg"
	   (<:div :class "max-width center text-center"
		  (core-server::login-box)
		  "foo"))))


;; -------------------------------------------------------------------------
;; Applications Generated by Manager
;; -------------------------------------------------------------------------
(defclass+ dynamic-application (web-application)
  ()
  (:metaclass core-server::persistent-http-application+)
  (:default-initargs :persistent t :database-directory nil))

(defprint-object (self dynamic-application :identity t)
  (format t "~A" (web-application.fqdn self)))

(defparameter +superclasses+ '(http-application database-server))
(defmethod dynamic-application.superclasses ((self dynamic-application))
  (reduce0 (lambda (acc atom)
	     (if (member (class-name atom) +superclasses+)
		 (cons (symbol->js (class-name atom)) acc)
		 acc))
	   (reverse (class+.superclasses (class-of self)))))

(defmethod core-server::database.directory ((application dynamic-application))
  (ensure-directories-exist
   (merge-pathnames
    (make-pathname :directory (list :relative "var"
				    (web-application.fqdn application) "db"))
    (bootstrap::home))))

(defcrud dynamic-application)
(defmethod dynamic-application.find-class ((self persistent-http-server)
					   class)
  (find-class (find class +superclasses+ :key #'symbol->js :test #'equal)))

(deftransaction dynamic-application.change-class ((self persistent-http-server)
						  (instance dynamic-application)
						  new-superclasses)
  (let* ((supers (cons (find-class 'dynamic-application)
		       (mapcar (curry #'dynamic-application.find-class self)
			       new-superclasses)))
	 (args (reduce0 (lambda (acc slot)
			  (core-server::with-slotdef (initarg name) slot
			    (cons initarg
				  (cons (slot-value instance name) acc))))
			(reverse (class+.local-slots (class-of instance)))))
	 (metaclass (find-class 'core-server::persistent-http-application+)))
    (stop instance)
    (change-class instance (make-instance metaclass
					  :name 'dynamic-application
					  :direct-superclasses supers))    
    (start instance)
    (unregister self instance)
    (register self instance)))

;; ;; -------------------------------------------------------------------------
;; ;; Interface
;; ;; -------------------------------------------------------------------------
;; (deftransaction make-api-key ((self manager-application) fqdn)
;;   (let ((secret (ironclad::ascii-string-to-byte-array (database.get self 'api-secret))))
;;     (core-server::hmac secret (format nil "~A-api-key" fqdn))))

;; (deftransaction make-api-password ((self manager-application) fqdn)
;;   (let ((secret (ironclad::ascii-string-to-byte-array (database.get self 'api-secret))))
;;     (core-server::hmac secret (format nil "~A-api-password" fqdn))))

;; (deftransaction site.add ((self manager-application) &key
;; 			  (fqdn (error "Provide :fqdn"))
;; 			  (api-key (make-api-key self fqdn))
;; 			  (api-password (make-api-password self fqdn))
;; 			  (owner (admin.find self :username "root"))
;; 			  (timestamp (get-universal-time)))
;;   (assert (not (null owner)))
;;   (call-next-method self :fqdn fqdn :api-key api-key
;; 		    :api-password api-password :owner owner
;; 		    :timestamp timestamp))
