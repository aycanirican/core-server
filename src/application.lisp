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

(in-package :core-server)

;;-----------------------------------------------------------------------------
;; Application Classes
;;-----------------------------------------------------------------------------
(defclass application ()
  ((server :accessor application.server :initform nil
	   :documentation "On which server this application is running, setf'ed after (register)")
   (debug :accessor application.debug :initarg :debug :initform t
	  :documentation "Debugging flag for this application"))
  (:documentation "Base Application Class"))
