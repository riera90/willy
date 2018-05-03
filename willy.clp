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
	(max_iteration 999)
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?past_pos<-(field (iteration ?it_field&:(= ?it_field (- ?iteration 1)))
										(x ?x_f&:(= ?x_w ?x_f))
										(y ?y_f&:(= ?y_f (+ ?y_w -1)))
							)
	=>
	(retract ?bt)
	(retract ?it)
	(retract ?willy)
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?past_pos<-(field (iteration ?it_field&:(= ?it_field (- ?iteration 1)))
										(x ?x_f&:(= ?x_w ?x_f))
										(y ?y_f&:(= ?y_f (+ ?y_w 1)))
							)
	=>
	(retract ?bt)
	(retract ?it)
	(retract ?willy)
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?past_pos<-(field (iteration ?it_field&:(= ?it_field (- ?iteration 1)))
										(x ?x_f&:(= ?x_w (+ ?x_f -1)))
										(y ?y_f&:(= ?y_f ?y_w))
							)
	=>
	(retract ?bt)
	(retract ?it)
	(retract ?willy)
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?past_pos<-(field (iteration ?it_field&:(= ?it_field (- ?iteration 1)))
										(x ?x_f&:(= ?x_w (+ ?x_f 1)))
										(y ?y_f&:(= ?y_f ?y_w))
							)
	=>
	(retract ?bt)
	(retract ?it)
	(retract ?willy)
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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

(defrule HazardsModule::noHazardmax
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

(defrule HazardsModule::locate_alien_middle_horizontal
	(declare (salience 3))
	?n1<-(field (x ?x1)                   (y ?y)(noise true))
	?n2<-(field (x ?x2&:(= ?x1 (+ ?x2 -2)))(y ?y)(noise true))
	=>
	(assert
		(position (name alien)(x (+ ?x1 1))(y ?y))
	)
)

(defrule HazardsModule::locate_alien_middle_vertical
	(declare (salience 3))
	?n1<-(field (x ?x)(y ?y1)                   (noise true))
	?n2<-(field (x ?x)(y ?y2&:(= ?y1 (+ ?y2 -2)))(noise true))
	=>
	(assert
		(position (name alien)(x ?x)(y (+ ?y1 1)))
	)
)

(defrule HazardsModule::shoot_alien_right
	(declare (salience 4))
	(hasLaser)
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?xw)              (y ?y))
	?a<-(position (name alien) (x ?xa&:(< ?xw ?xa)) (y ?y))
	=>
	(retract ?a)
	(retract ?mit)
	(assert
		(max_iteration (+ ?max_iteration -1))
	)
	(fireLaser east)
)

(defrule HazardsModule::shoot_alien_left
	(declare (salience 4))
	(hasLaser)
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?xw)              (y ?y))
	?a<-(position (name alien) (x ?xa&:(> ?xw ?xa)) (y ?y))
	=>
	(retract ?a)
	(retract ?mit)
	(assert
		(max_iteration (+ ?max_iteration -1))
	)
	(fireLaser west)
)

(defrule HazardsModule::shoot_alien_up
	(declare (salience 4))
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?x) (y ?yw))
	?a<-(position (name alien) (x ?x) (y ?ya&:(< ?yw ?ya)))
	=>
	(retract ?a)
	(retract ?mit)
	(assert
		(max_iteration (+ ?max_iteration -1))
	)
	(fireLaser north)
)

(defrule HazardsModule::shoot_alien_down
	(declare (salience 4))
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?x) (y ?yw))
	?a<-(position (name alien) (x ?x) (y ?ya&:(> ?yw ?ya)))
	=>
	(retract ?a)
	(retract ?mit)
	(assert
		(max_iteration (+ ?max_iteration -1))
	)
	(fireLaser south)
)
