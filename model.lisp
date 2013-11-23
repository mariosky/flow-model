(ql:quickload "sqlite")
(ql:quickload "ironclad")
(defpackage :model (:use :cl)
	    (:export connect-db
		     disconnect-db
		     get-user/password
		     get-exercises
		     post-user
		     hash-password
		     ))
(in-package :model)

(defvar *salt* "W6Y$~U5viQiuHar_75?Kfz?29,;#+JK+&wY,ZL9^Z0I$Lob,Az8NZCcOyKcTP]O(")

(defun hash-password (password)
  (ironclad:byte-array-to-hex-string 
   (ironclad:digest-sequence 
    :sha256 
    (ironclad:ascii-string-to-byte-array (concatenate 'string password *salt*)))))

(defun get-user/password (username)
  (sqlite:execute-single *db* "SELECT password FROM users WHERE username = ?" username))

(defun post-user (username password)
  (sqlite:execute-non-query *db* "INSERT INTO users (username, password) VALUES (?, ?)"
			    username (hash-password password)))

(defun post-exercise (title exercise &optional (coding nil))
  (sqlite:execute-non-query *db* "INSERT INTO exercises (title, content, coding) VALUES (?, ?, ?)"
			    title exercise (if coding "true" "false")))

;;(post-user "amherag" "password")
;;(post-exercise "prueba1" "hola hola hola" t)
;;(post-exercise "prueba2" "adios adios adios" nil)

(defun get-exercises ()
  "It gets ALL the exercises for now."
  (sqlite:execute-to-list *db* "SELECT * FROM exercises ORDER BY rowid"))

;;(get-exercises)

(let ((connected? nil))
  "Very basic singleton."
  (defun disconnect-db ()
    (when connected?
      (sqlite:disconnect *db*)
      (setf connected? nil)))

  (defun connect-db (&optional (path "db.sqlite"))
    (when (not connected?)
      (defparameter *db* (sqlite:connect path))
      (setf connected? t))))

;;(connect-db)
;;(disconnect-db)

(defun init-db ()
  (sqlite:execute-non-query *db* "CREATE TABLE users(username text, password text)")
  (sqlite:execute-non-query *db* "CREATE TABLE exercises(title text, content text, coding bool)"))

;;(init-db)
