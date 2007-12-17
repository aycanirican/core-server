(in-package :core-server)

(defclass custom-http-peer (http-peer)
  ())

(defmethod render-404 ((self custom-http-peer) (request http-request) (response http-response))
  (setf (http-response.status-code response) (make-status-code 404))
  (rewind-stream (http-response.stream response))
  (checkpoint-stream (http-response.stream response))
  (with-yaclml-stream (http-response.stream response)
    (<:html
     (<:body
      (<:ah "Core-serveR - URL Not Found"))))
  response)

(defmethod eval-request ((self custom-http-peer) (request http-request))
  (let ((response (call-next-method))
	(path (caar (uri.paths (http-request.uri request)))))
    (if (any #'(lambda (app)
		 (when (string= path (web-application.fqdn app))
		   (with-yaclml-stream (http-response.stream response)
		     (dispatch app request response))))
	     (server.applications (peer.server self)))
	response
	(render-404 self request response))))

(defclass http-server (socket-server)
  ((applications :accessor server.applications :initform '()))
  (:default-initargs :port 3001 :peer-class '(custom-http-peer)))

(defmethod register ((self http-server) (app http-application))
  (setf (server.applications self)
	(sort (cons app
		    (remove (web-application.fqdn app)
			    (server.applications self)
			    :test #'equal :key #'web-application.fqdn)) #'>
	      :key (lambda (app) (length (web-application.fqdn app)))))
  (setf (application.server app) self))

(defmethod unregister ((self http-server) (app http-application))
  (setf (server.applications self)
	(remove (web-application.fqdn app)
		(server.applications self) :test #'equal :key #'web-application.fqdn)))

(defmethod find-application ((self http-server) fqdn)
  (find fqdn (server.applications self) :key #'web-application.fqdn :test #'equal))
