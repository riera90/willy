
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
	(slot x)
	(slot y)
	(slot noise (allowed-symbols true false) (default false))
	(slot gravity (allowed-symbols true false) (default false))
)

(deffacts intitial_module_facts
	(iteration 0)
	(max_iteration 999)
	(position (name willy))
	(movimientos-contrarios)
	(shoot)
)

(defrule myMAIN::passTo
	(declare (salience 100))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(focus HazardsModule)
	(focus AfterHazardsModule)
	(focus MovementModule)
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
		(field (x ?x) (y ?y) (gravity true)(noise true))
		(warning (value backtrack))
	)
	(return)
)

(defrule HazardsModule::blackHole
	(declare (salience 1))
	(iteration ?it)
	(percepts Pull)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(field (x ?x) (y ?y) (gravity true))
		(warning (value backtrack))
	)
	(return)
)

(defrule HazardsModule::alien
	(declare (salience 1))
	(iteration ?it)
	(percepts Noise)
	(position (name willy) (x ?x) (y ?y))
	=>
	(assert
		(field (x ?x) (y ?y) (noise true))
		(warning (value backtrack))
	)
	(return)
)

(defrule HazardsModule::noHazardmax
	(declare (salience 1))
	(iteration ?it)
	(percepts )
	(position (name willy) (x ?x) (y ?y))
	(not (field (x ?x) (y ?y)))
	=>
	(assert
		(field (x ?x) (y ?y))
	)
	(return)
)


;============================================================================
;============================================================================
;=========================== AfterHazardsModule =============================
;============================================================================
;============================================================================

(defmodule AfterHazardsModule (import InternalFunctions deffunction ?ALL) (import myMAIN deftemplate ?ALL) (export ?ALL))

(defrule AfterHazardsModule::nothing_to_do
	(declare (salience 0))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	=>
	(return)
)

;============================================================================
; alien locate
;============================================================================

(defrule AfterHazardsModule::locate_alien_middle_horizontal
	(declare (salience 3))
	?n1<-(field (x ?x1)                    (y ?y)(noise true))
	?n2<-(field (x ?x2&:(= ?x1 (+ ?x2 -2)))(y ?y)(noise true))
	=>
	(assert
		(position (name alien)(x (+ ?x1 1))(y ?y))
	)
)

(defrule AfterHazardsModule::locate_alien_middle_vertical
	(declare (salience 3))
	?n1<-(field (x ?x)(y ?y1)                    (noise true))
	?n2<-(field (x ?x)(y ?y2&:(= ?y1 (+ ?y2 -2)))(noise true))
	=>
	(assert
		(position (name alien)(x ?x)(y (+ ?y1 1)))
	)
)

(defrule AfterHazardsModule::locate_alien_oblique_negative_alien_up
	(declare (salience 3))
	?n1<-(field(x ?x1)                   (y ?y1)                    (noise true) )
	?n2<-(field(x ?x2&:(= ?x2 (+ ?x1 1)))(y ?y2&:(= ?y2 (+ ?y1 -1)))(noise true) )
	?n3<-(field(x ?x3&:(= ?x3 (+ ?x1 0)))(y ?y3&:(= ?y3 (+ ?y1 -1)))(noise false))
	=>
	(assert
		(position (name alien)(x (+ ?x1 1))(y (+ ?y1 0)))
	)
)

(defrule AfterHazardsModule::locate_alien_oblique_negative_alien_down
	(declare (salience 3))
	?n1<-(field(x ?x1)                   (y ?y1)                    (noise true) )
	?n2<-(field(x ?x2&:(= ?x2 (+ ?x1 1)))(y ?y2&:(= ?y2 (+ ?y1 -1)))(noise true) )
	?n3<-(field(x ?x3&:(= ?x3 (+ ?x1 1)))(y ?y3&:(= ?y3 (+ ?y1  0)))(noise false))
	=>
	(assert
		(position (name alien)(x (+ ?x1 0))(y (+ ?y1 -1)))
	)
)

(defrule AfterHazardsModule::locate_alien_oblique_positive_alien_up
	(declare (salience 3))
	?n1<-(field(x ?x1)                   (y ?y1)                   (noise true) )
	?n2<-(field(x ?x2&:(= ?x2 (+ ?x1 1)))(y ?y2&:(= ?y2 (+ ?y1 1)))(noise true) )
	?n3<-(field(x ?x3&:(= ?x3 (+ ?x1 1)))(y ?y3&:(= ?y3 (+ ?y1 0)))(noise false))
	=>
	(assert
		(position (name alien)(x (+ ?x1 0))(y (+ ?y1 1)))
	)
)

(defrule AfterHazardsModule::locate_alien_oblique_positive_alien_down
	(declare (salience 3))
	?n1<-(field(x ?x1)                   (y ?y1)                   (noise true) )
	?n2<-(field(x ?x2&:(= ?x2 (+ ?x1 1)))(y ?y2&:(= ?y2 (+ ?y1 1)))(noise true) )
	?n3<-(field(x ?x3&:(= ?x3 (+ ?x1 0)))(y ?y3&:(= ?y3 (+ ?y1 1)))(noise false))
	=>
	(assert
		(position (name alien)(x (+ ?x1 1))(y (+ ?y1 0)))
	)
)

;============================================================================
; alien elimination
;============================================================================

(defrule AfterHazardsModule::shoot_alien_right
	(declare (salience 4))
	(hasLaser)
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?xw)              (y ?y))
	?a<-(position (name alien) (x ?xa&:(< ?xw ?xa)) (y ?y))
	?s<-(shoot)
	=>
	(retract ?s)
	(retract ?a)
	(retract ?it)
	(assert
		(iteration (+ ?iteration 1))
	)
	(fireLaser east)
)

(defrule AfterHazardsModule::shoot_alien_left
	(declare (salience 4))
	(hasLaser)
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?xw)              (y ?y))
	?a<-(position (name alien) (x ?xa&:(> ?xw ?xa)) (y ?y))
	?s<-(shoot)
	=>
	(retract ?s)
	(retract ?a)
	(retract ?it)
	(assert
		(iteration (+ ?iteration 1))
	)
	(fireLaser west)
)

(defrule AfterHazardsModule::shoot_alien_up
	(declare (salience 4))
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?x) (y ?yw))
	?a<-(position (name alien) (x ?x) (y ?ya&:(< ?yw ?ya)))
	?s<-(shoot)
	=>
	(retract ?s)
	(retract ?a)
	(retract ?it)
	(assert
		(iteration (+ ?iteration 1))
	)
	(fireLaser north)
)

(defrule AfterHazardsModule::shoot_alien_down
	(declare (salience 4))
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?x) (y ?yw))
	?a<-(position (name alien) (x ?x) (y ?ya&:(> ?yw ?ya)))
	?s<-(shoot)
	=>
	(retract ?s)
	(retract ?a)
	(retract ?it)
	(assert
		(iteration (+ ?iteration 1))
	)
	(fireLaser south)
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
		?w<-(warning (value backtrack))
		(max_iteration ?max_iteration)
		?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
		?p<-(position (name willy) (x ?x) (y ?y))
		?m<-(movimientos-contrarios south $?valores)
		=>
		(retract ?it)
		(retract ?p)
		(retract ?w)
		(retract ?m)
		(moveWilly south)
		(assert (iteration (+ ?iteration 1)))
		(assert (position (name willy) (x ?x) (y (- ?y 1))))
		(assert (movimientos-contrarios $?valores))
		(return)
	)

	(defrule MovementModule::backtrackNorth
		(declare (salience 100))
		?w<-(warning (value backtrack))
		(max_iteration ?max_iteration)
		?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
		?p<-(position (name willy) (x ?x) (y ?y))
		?m<-(movimientos-contrarios north $?valores)
		=>
		(retract ?it)
		(retract ?p)
		(retract ?w)
		(retract ?m)
		(moveWilly north)
		(assert (iteration (+ ?iteration 1)))
		(assert (position (name willy) (x ?x) (y (+ ?y 1))))
		(assert (movimientos-contrarios $?valores))
		(return)
	)

	(defrule MovementModule::backtrackEast
		(declare (salience 100))
		?w<-(warning (value backtrack))
		(max_iteration ?max_iteration)
		?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
		?p<-(position (name willy) (x ?x) (y ?y))
		?m<-(movimientos-contrarios east $?valores)
		=>
		(retract ?it)
		(retract ?p)
		(retract ?w)
		(retract ?m)
		(moveWilly east)
		(assert (iteration (+ ?iteration 1)))
		(assert (position (name willy) (x (+ ?x 1)) (y ?y)))
		(assert (movimientos-contrarios $?valores))
		(return)
	)

	(defrule MovementModule::backtrackWest
		(declare (salience 100))
		?w<-(warning (value backtrack))
		(max_iteration ?max_iteration)
		?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
		?p<-(position (name willy) (x ?x) (y ?y))
		?m<-(movimientos-contrarios west $?valores)
		=>
		(retract ?it)
		(retract ?p)
		(retract ?w)
		(retract ?m)
		(moveWilly west)
		(assert (iteration (+ ?iteration 1)))
		(assert (position (name willy) (x (- ?x 1)) (y ?y)))
		(assert (movimientos-contrarios $?valores))
		(return)
	)

;============================================================================
; move normal
;============================================================================

(defrule MovementModule::moveWillyNorth
	(declare (salience 1))
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	(directions $? north $?)
	(not
		(field	(x ?x_f&:(= ?x_f ?x_w))
						(y ?y_f&:(= ?y_f (+ ?y_w 1))))
	)
	?m<-(movimientos-contrarios $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly north)
	(assert
		(position (name willy)(x ?x_w) (y (+ ?y_w 1)))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios south $?valores))
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
	?m<-(movimientos-contrarios $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly south)
	(assert
		(position (name willy)(x ?x_w) (y (+ ?y_w -1)))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios north $?valores))
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
	?m<-(movimientos-contrarios $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly east)
	(assert
		(position (name willy)(x (+ ?x_w 1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios west $?valores))
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
	?m<-(movimientos-contrarios $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly west)
	(assert
		(position (name willy) (x (+ ?x_w -1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios east $?valores))
	(return)
)


;============================================================================
; move stuck
;============================================================================

(defrule MovementModule::retrocederNorte
	(declare (salience 0))
	(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?m<-(movimientos-contrarios north $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly north)
	(assert
		(position (name willy) (x ?x_w) (y (+ ?y_w 1)))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios $?valores))
	(return)
)

(defrule MovementModule::retrocederSur
	(declare (salience 0))
	(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?m<-(movimientos-contrarios south $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly south)
	(assert
		(position (name willy) (x ?x_w) (y (- ?y_w 1)))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios $?valores))
	(return)
)


(defrule MovementModule::retrocederEste
	(declare (salience 0))
	(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?m<-(movimientos-contrarios east $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly east)
	(assert
		(position (name willy) (x (+ ?x_w 1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios $?valores))
	(return)
)


(defrule MovementModule::retrocederOeste
	(declare (salience 0))
	(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	?m<-(movimientos-contrarios west $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly west)
	(assert
		(position (name willy) (x (- ?x_w 1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios $?valores))
	(return)
)
