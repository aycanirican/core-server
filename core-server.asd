;;;; -*- Mode: lisp; indent-tabs-mode: nil; outline-regexp: ";;;;;*"; -*-
(in-package :asdf)

;; Add distribution based features
(eval-when (:compile-toplevel :load-toplevel :execute)
  (cond
    ((probe-file "/etc/pardus-release")
     (pushnew :pardus *features*))
    ((probe-file "/etc/gentoo-release")
     (pushnew :gentoo *features*))
    ((probe-file "/etc/debian_version")
     (pushnew :debian *features*))))

(defsystem :core-server
  :description "Core Server"
  :version "0"
  :author "Evrim Ulu <evrim@core.gen.tr>"
  :licence "MIT License"
  :components ((:static-file "core-server.asd")
	       (:module :src
                        :serial t
                        :components
			((:file "packages")
                         (:file "helper")
                         (:file "sockets")
                         (:file "threads")
                         (:file "units")
                         (:file "streams")
                         (:file "parser")
                         (:file "prevalence")
                         (:file "config")
                         (:file "method")
                         (:file "classes")
                         (:file "protocol")
                         (:file "application")
                         (:file "server")
                         (:file "search")
                         (:module :applications
                                  :components
                                  ((:file "ucw")
                                   (:file "serializable-application")
                                   (:file "darcs")
                                   (:file "git")))
                         (:module :servers
                                  :components
                                  ((:file "database")
                                   (:file "dns")
                                   (:file "apache")
                                   (:file "postfix")
                                   (:file "ucw")
                                   (:file "core")
                                   (:file "ticket")
                                   (:file "socket")
                                   ;; (:module :web
;;                                             :components
;;                                             ((:module :backend
;;                                                        :components
;;                                                        ((:file "accept")
;;                                                         (:file "common")
;;                                                         (:file "httpd")
;;                                                         (:file "multithread-httpd")
;;                                                         (:file "mod-lisp")))))
                                   ))
                         (:module :rfc
                                  :serial t
                                  :components 
                                  ((:file "2109") ;;cookie
                                   (:file "2396") ;;uri
                                   (:file "822")  ;;text messages
                                   (:file "2617") ;;http auth
                                   (:file "2616") ;;http
                                   (:file "2045") ;;mime-part1
                                   (:file "2046") ;;mime-part2
                                   (:file "2388") ;;multpart/form-data
                                   )) ;;http
                         (:module :peers
                                  :components
                                  ((:file "peer")
                                   (:file "http")
                                   ))
                         (:module :services
                                  :components
                                  ((:file "whois"))))))
  :depends-on (:bordeaux-threads :iterate :cl-prevalence :ucw :sb-bsd-sockets)
  :serial t)

(defmethod perform :after ((o t) (c (eql (find-system :core-server))))
  (when (and (find-package :tr.gen.core.install)
             (not (null (sb-posix:getenv "CORESERVER_HOME"))))
    (load (concatenate 'string (sb-posix:getenv "CORESERVER_HOME")
                       "/src/install/install.lisp"))
    (load (concatenate 'string (sb-posix:getenv "CORESERVER_HOME")
                       "/src/commands/hxpath.lisp"))))

(defmethod perform :after ((o load-op) (c (eql (find-system :core-server))))
  (in-package :core-server))

(defsystem :core-server.test
  :components ((:module :t
                        :serial t
			:components ((:file "packages")
                                     (:file "postfix")
                                     (:file "parser")
                                     (:file "streams")
                                     (:file "sockets")
                                     (:module :rfc
                                              :components ((:file "2109")
                                                           (:file "2396")
                                                           (:file "2045")
                                                           (:file "2388")
							   (:file "2616"))
                                              :serial t)
                                     ;; (:file "database")
                                     ;; (:file "dns")
                                     ;; (:file "apache")
                                     ;; (:file "ucw")
                                     ;; (:file "core")
                                     )))
  :depends-on (:bordeaux-threads :core-server :rt))

;; (defmethod perform ((op asdf:test-op) (system (eql (find-system :core-server))))
;;   (asdf:oos 'asdf:load-op :core-server.test)
;;   (funcall (intern (string :run!) (string :it.bese.FiveAM)) :core-server))
