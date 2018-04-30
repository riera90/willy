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

(deftemplate warning
	(slot value)
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

;===========================================================================
;===========================================================================
;============================ MovementModule ===============================
;===========================================================================
;===========================================================================

(defmodule MovementModule (import InternalFunctions deffunction ?ALL) (import myMAIN deftemplate ?ALL) (export ?ALL))

;============================================================================
; backtrack
;============================================================================

(defrule MovementModule::backtrackSouth
	(declare (salience 100))
	?bt<-(warning (value backtrack))
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?past_pos<-(field (iteration ?it_field&:(= ?it_field (- ?iteration 1)))
										(x ?x_f&:(= ?x_w ?x_f))
										(y ?y_f&:(= ?y_f (+ ?y_w -1)))
							)
	=>
	(retract ?bt)
	(retract ?it)
	(retract ?willy)
	(retract ?past_pos)
	(assert
		(position (name willy) (x ?x_f) (y ?y_f))
		(iteration (+ ?iteration 1))
	)
	(moveWilly south)
	(return)
)

(defrule MovementModule::backtrackNorth
	(declare (salience 100))
	?bt<-(warning (value backtrack))
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?past_pos<-(field (iteration ?it_field&:(= ?it_field (- ?iteration 1)))
										(x ?x_f&:(= ?x_w ?x_f))
										(y ?y_f&:(= ?y_f (+ ?y_w 1)))
							)
	=>
	(retract ?bt)
	(retract ?it)
	(retract ?willy)
	(retract ?past_pos)
	(assert
		(position (name willy) (x ?x_f) (y ?y_f))
		(iteration (+ ?iteration 1))
	)
	(moveWilly north)
	(return)
)

(defrule MovementModule::backtrackEast
	(declare (salience 100))
	?bt<-(warning (value backtrack))
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?past_pos<-(field (iteration ?it_field&:(= ?it_field (- ?iteration 1)))
										(x ?x_f&:(= ?x_w (+ ?x_f -1)))
										(y ?y_f&:(= ?y_f ?y_w))
							)
	=>
	(retract ?bt)
	(retract ?it)
	(retract ?willy)
	(retract ?past_pos)
	(assert
		(position (name willy) (x ?x_f) (y ?y_f))
		(iteration (+ ?iteration 1))
	)
	(moveWilly east)
	(return)
)

(defrule MovementModule::backtrackWest
	(declare (salience 100))
	?bt<-(warning (value backtrack))
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?past_pos<-(field (iteration ?it_field&:(= ?it_field (- ?iteration 1)))
										(x ?x_f&:(= ?x_w (+ ?x_f 1)))
										(y ?y_f&:(= ?y_f ?y_w))
							)
	=>
	(retract ?bt)
	(retract ?it)
	(retract ?willy)
	(retract ?past_pos)
	(assert
		(position (name willy) (x ?x_f) (y ?y_f))
		(iteration (+ ?iteration 1))
	)
	(moveWilly west)
	(return)
)

;============================================================================
; move normal
;============================================================================

(defrule MovementModule::moveWillyNorth
	(declare (salience 0))
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	(directions $? north $?)
	(not
		(field	(x ?x_f&:(= ?x_f ?x_w))
						(y ?y_f&:(= ?y_f (+ ?y_w 1))))
	)
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
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	(directions $? south $?)
	(not
		(field	(x ?x_f&:(= ?x_f ?x_w))
						(y ?y_f&:(= ?y_f (+ ?y_w -1))))
	)
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
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	(directions $? east $?)
	(not
		(field	(x ?x_f&:(= ?x_f (+ ?x_w 1)))
						(y ?y_f&:(= ?y_f ?y_w)))
	)
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
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	(directions $? west $?)
	(not
		(field	(x ?x_f&:(= ?x_f (+ ?x_w -1)))
						(y ?y_f&:(= ?y_f ?y_w)))
	)
	=>
	(retract ?willy)
	(retract ?it)
	(moveWilly west)
	(assert
		(position (name willy) (x (+ ?x_w -1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(return)
)


;============================================================================
; move stuck
;============================================================================

(defrule MovementModule::moveWillyNorthStuck
	(declare (salience 0))
	(directions $? north $?)
	?it<-(iteration ?iteration&:(< ?iteration 999))
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


(defrule MovementModule::moveWillySouthStuck
	(declare (salience 0))
	(directions $? south $?)
	?it<-(iteration ?iteration&:(< ?iteration 999))
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

(defrule MovementModule::moveWillyEastStuck
	(declare (salience 0))
	(directions $? east $?)
	?it<-(iteration ?iteration&:(< ?iteration 999))
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

(defrule MovementModule::moveWillyWestStuck
	(declare (salience 0))
	(directions $? west $?)
	?it<-(iteration ?iteration&:(< ?iteration 999))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(retract ?willy)
	(retract ?it)
	(moveWilly west)
	(assert
		(position (name willy) (x (+ ?x_w -1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(return)
)

;============================================================================
;============================================================================
;============================= HazardsModule ================================
;============================================================================
;============================================================================

(defmodule HazardsModule (import InternalFunctions deffunction ?ALL) (import myMAIN deftemplate ?ALL) (export ?ALL))

(defrule HazardsModule::blackHole_and_alien
	(declare (salience 2))
	(iteration ?it)
	(or
		(percepts Pull Noise)
		(percepts Noise Pull)
	)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(field (iteration ?it) (x ?x) (y ?y) (gravity true))
		(warning (value backtrack))
	)
	(focus MovementModule)
)

(defrule HazardsModule::blackHole
	(declare (salience 1))
	(iteration ?it)
	(percepts Pull)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(field (iteration ?it) (x ?x) (y ?y) (gravity true))
		(warning (value backtrack))
	)
	(focus MovementModule)
)

(defrule HazardsModule::alien
	(declare (salience 1))
	(iteration ?it)
	(percepts Noise)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(field (iteration ?it) (x ?x) (y ?y) (noise true))
		(warning (value backtrack))
	)
	(focus MovementModule)
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
	(focus MovementModule)
)
