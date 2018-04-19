;*****************************************
; Autores:
; Historial de cambios:
;  - Fecha: mejoras/cambios
;*****************************************

(defrule MAIN::passToMyMAIN
	=>
	(focus myMAIN))


;==========================================
(defmodule myMAIN (import MAIN deftemplate ?ALL) (import InternalFunctions deffunction ?ALL) (export deftemplate ?ALL))

(deftemplate position
	(slot name (default ?NONE))
	(slot x (type INTEGER) (default 0))
	(slot y (type INTEGER) (default 0))
)

(deftemplate filed
	(slot x)
	(slot y)
	(slot noise (allowed-symbols true false))
	(slot gravity (allowed-symbols true false))
)

(deffacts intitial_module_facts
	(position (name willy))
)


(defrule moveWillyNorth

	(directions $? north $?)
	=>
	(moveWilly north)
)

(defrule moveWillySouth
	(directions $? south $?)
	=>
	(moveWilly south)
)

(defrule moveWillyEast
	(directions $? east $?)
	=>
	(moveWilly east)
)

(defrule moveWillyWest
	(directions $? west $?)
	=>
	(moveWilly west)
)

; (defrule fireWilly
; 	(hasLaser)
; 	(directions $? ?direction $?)
; 	=>
; 	(fireLaser ?direction)
; )


;=====================================
; Se pueden crear otros módulos (siempre que lo acepte el programa) con el contenido que se desee
; Se deben especificar las indicaciones de importación y exportación que deseeis, pero se sugiere importar todo de MAIN y de vuestro myMAIN
; Ejemplo:
(defmodule Modulo1 (import MAIN deftemplate ?ALL) (import myMAIN deftemplate ?ALL))

; Se puede crear cualquier constructor que deseis y que lo acepte el programa (funciones, plantillas, reglas...)





;=========================================
; Otros módulos (tantos como se deseen)
