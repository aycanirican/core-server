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

;;+----------------------------------------------------------------------------
;;| Standard Global Variables
;;+----------------------------------------------------------------------------
;; 
;; This file contains system specific global variables.


(defun load-end.lisp (&rest args)
  (declare (ignore args))
  (load (merge-pathnames "etc/end.lisp"
			 (bootstrap:home))))

#+sbcl
(progn
  (require :sb-posix)
  (sb-unix::enable-interrupt sb-posix:sigterm #'core-server::load-end.lisp)
  (with-open-file (s (merge-pathnames #P"var/core-server.pid"
				      (bootstrap:home))
		     :direction :output :if-exists :supersede
		     :if-does-not-exist :create)
    (format s "~D" (sb-posix:getpid))))

;;-----------------------------------------------------------------------------
;; Unix Commands
;;-----------------------------------------------------------------------------
;;
;; You must add your use to your /etc/sudoers file with visudo like:
;; evrim:   ALL= NOPASSWD: ALL
;;
(defvar +sudo+ (whereis "sudo") "Sudo Pathname")
(defvar +cp+ (whereis "cp") "cp Pathname")
(defvar +chown+ (whereis "chown") "chown Pathname")
(defvar +chmod+ (whereis "chmod") "chmod Pathname")
(defvar +find+ (whereis "find") "find Pathname")
(defvar +rm+ (whereis "rm") "rm Pathname")
(defvar +mkdir+ (whereis "mkdir") "mkdir Pathname")
(defvar +sed+ (whereis "sed") "sed Pathname")

;;-----------------------------------------------------------------------------
;; Apache Specific Variables
;;-----------------------------------------------------------------------------
(defvar *apache-default-config-extenstion* "conf"
  "Apache Configuration File Extension")
(defvar +apache-user+ #-debian "apache" #+debian "www-data"
	"The user that Apache runs as")
(defvar +apache-group+ #-debian "apache" #+debian "www-data"
	"The group that Apache runs as")

;;-----------------------------------------------------------------------------
;; Postfix Specific Variables
;;-----------------------------------------------------------------------------
(defvar +postmap+ #P"/usr/sbin/postmap") ;;can't be found on all.

;;-----------------------------------------------------------------------------
;; DNS Specific Variables
;;-----------------------------------------------------------------------------
(defvar +ns1+ "139.179.139.251"
  "IP address of the first nameserver")

(defvar +ns2+ "212.175.40.11"
  "IP address of the second nameserver")

(defvar +mx+ "212.175.40.55"
  "IP address of the mail exchanger")

;;-----------------------------------------------------------------------------
;; SCm Specific Variables
;;-----------------------------------------------------------------------------
(defvar +darcs+ (whereis "darcs") "darcs Pathname")
(defvar +git+ #P"/usr/bin/git" "git Pathname") ;; can't be found on all

(defvar +remote-user+ "evrim.ulu"
  "Default ssh username for application sharing, see darcs-application.share")

;;-----------------------------------------------------------------------------
;; Web Specific Variables
;;-----------------------------------------------------------------------------
(defvar +default-extension+ ".core" "Web application default extension")
(defvar +dojo-path+ "/dojo/" "Dojo Pathname")
(defvar +fckeditor-path+ "/fckeditor/" "Fckeditor Pathname")

;;-----------------------------------------------------------------------------
;; Mail Service Variables
;;-----------------------------------------------------------------------------
(defvar +x-mailer+ "Core Server (http://labs.core.gen.tr)")
