;*****************************************
; Autores:
; Historial de cambios:
;  - Fecha: mejoras/cambios
;*****************************************

(defrule MAIN::passToMyMAIN
	=>
	(focus myMAIN))

;===============================================================================

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

(defrule myMAIN::passToHazardsModule
	(declare (salience 100))
	(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(focus HazardsModule)
)

(defrule myMAIN::passToMovementModule
	(declare (salience 99))
	(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(focus MovementModule)
)

;===============================================================================

(defmodule MovementModule (import InternalFunctions deffunction ?ALL) (import myMAIN deftemplate ?ALL) (export ?ALL))


(defrule MovementModule::moveWillyNorth
	(declare (salience 1))
	(directions $? north $?)
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(moveWilly north)
	(assert
		(position (name willy)(x ?x_w) (y (+ ?y_w 1)))
	)
	(return)
)

(defrule MovementModule::moveWillySouth
	(declare (salience 1))
	(directions $? south $?)
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(moveWilly south)
	(assert
		(position (name willy)(x ?x_w) (y (+ ?y_w -1)))
	)
	(return)
)

(defrule MovementModule::moveWillyEast
	(declare (salience 1))
	(directions $? east $?)
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(moveWilly east)
	(assert
		(position (name willy)(x (+ ?x_w 1)) (y ?y_w))
	)
	(return)
)

(defrule MovementModule::moveWillyWest
	(declare (salience 1))
	(directions $? west $?)
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(moveWilly west)
	(assert
		(position (name willy)(x (+ ?x_w -1)) (y ?y_w))
	)
	(return)
)

;===============================================================================

(defmodule HazardsModule (import InternalFunctions deffunction ?ALL) (import myMAIN deftemplate ?ALL) (export ?ALL))

(defrule HazardsModule::blackHole
	(declare (salience 1))
	(percepts Pull)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(filed (x ?x) (y ?y) (gravity true))
	)
)

(defrule HazardsModule::alien
	(declare (salience 1))
	(percepts Noise)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(filed (x ?x) (y ?y) (noise true))
	)
)
