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

(deftemplate field
	(slot iteration)
	(slot x)
	(slot y)
	(slot noise (allowed-symbols true false) (default false))
	(slot gravity (allowed-symbols true false) (default false))
)

(deffacts intitial_module_facts
	(iteration 0)
	(position (name willy))
	(field (iteration 0) (x 0) (y 0))
)

(defrule myMAIN::passToHazardsModule
	(declare (salience 100))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(focus HazardsModule)
)

(defrule myMAIN::passToMovementModule
	(declare (salience 99))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(focus MovementModule)
)

;===============================================================================

(defmodule MovementModule (import InternalFunctions deffunction ?ALL) (import myMAIN deftemplate ?ALL) (export ?ALL))


(defrule MovementModule::moveWillyNorth
	(declare (salience 1))
	(directions $? north $?)
	?it<-(iteration ?iteration)
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(retract ?it)
	(moveWilly north)
	(assert
		(position (name willy)(x ?x_w) (y (+ ?y_w 1)))
		(iteration (+ ?iteration 1))
	)
	(return)
)

(defrule MovementModule::moveWillySouth
	(declare (salience 1))
	(directions $? south $?)
	?it<-(iteration ?iteration)
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(retract ?it)
	(moveWilly south)
	(assert
		(position (name willy)(x ?x_w) (y (+ ?y_w -1)))
		(iteration (+ ?iteration 1))
	)
	(return)
)

(defrule MovementModule::moveWillyEast
	(declare (salience 1))
	?it<-(iteration ?iteration)
	(directions $? east $?)
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(retract ?it)
	(moveWilly east)
	(assert
		(position (name willy)(x (+ ?x_w 1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(return)
)

(defrule MovementModule::moveWillyWest
	(declare (salience 1))
	(directions $? west $?)
	?it<-(iteration ?iteration)
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(retract ?it)
	(moveWilly west)
	(assert
		(position (name willy)(x (+ ?x_w -1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(return)
)

;===============================================================================

(defmodule HazardsModule (import InternalFunctions deffunction ?ALL) (import myMAIN deftemplate ?ALL) (export ?ALL))

(defrule HazardsModule::blackHole
	(declare (salience 1))
	(iteration ?it)
	(percepts Pull)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(field (iteration ?it) (x ?x) (y ?y) (gravity true))
	)
)

(defrule HazardsModule::alien
	(declare (salience 1))
	(iteration ?it)
	(percepts Noise)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(field (iteration ?it) (x ?x) (y ?y) (noise true))
	)
)

(defrule HazardsModule::noHazard
	(declare (salience 1))
	(iteration ?it)
	(percepts )
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(field (iteration ?it) (x ?x) (y ?y))
	)
)
