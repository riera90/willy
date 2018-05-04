;*****************************************
; Autores:
; Historial de cambios:
;  - Fecha: mejoras/cambios
;*****************************************

;Regla para pasar el focus al modulo myMain
(defrule MAIN::passToMyMAIN
	=>
	(focus myMAIN))

;===============================================================================

(defmodule myMAIN (import MAIN deftemplate ?ALL) (import InternalFunctions deffunction ?ALL) (export deftemplate ?ALL))

;Plantilla para almacenar tanto la posicion de willy como la del alien
(deftemplate position
	(slot name (default ?NONE))
	(slot x (type INTEGER) (default 0)) ; Coordenada x de la posicion
	(slot y (type INTEGER) (default 0)) ; Coordenada y de la posicion
)

;Plantilla para definir un hecho warning que permite la realizacion del backtrack entre modulos
(deftemplate warning
	(slot value)
)

;Plantilla para almacenar informacion de las diferentes casillas visitadas y si existe peligro o no en la casilla
(deftemplate field
	(slot x)
	(slot y)
	(slot noise (allowed-symbols true false) (default false)) ; Indicar si en la casilla se percibe un alien
	(slot gravity (allowed-symbols true false) (default false)) ; Indicar si en la casilla se percibe un agujero negro
)

;Algunos hechos iniciales del programa
(deffacts intitial_module_facts
	(iteration 0) ; Hecho que permite llevar una cuenta del numero de movimientos que se han realizado
	(max_iteration 999) ; Hecho para definir el numero maximo de iteraciones que podemos realizar
	(position (name willy)) ; La posicion inicial de willy es la (0,0)
	(movimientos-contrarios) ; Hecho en el que se van a ir almacenando los movimientos opuestos a los que se realizaron
	(module_iteration 0)
	(repeat)
)

; Los modulo se gestionan desde el modulo myMAIN, este va enfocando modulo a modulo en serie y en el mismo orden siempre que al acabar la anterior iteracion de recorrido de módulos (HazardsModule > AfterHazardsModule > MovementModule) exista "(repeat)", estos se concatenan asertando y comprovando instancias como "(passToAfterHazardsModule)" ó "(passToMovementModule)" para asegurar, finalmente el orden lo ma

(defrule myMAIN::passToHazardsModule
	(declare (salience 300))
	?ok<-(repeat)
	?moduleit<-(module_iteration ?it)
	=>
	(retract ?ok)
	(focus HazardsModule)
	(assert
		(passToAfterHazardsModule)
	)
)

(defrule myMAIN::passToAfterHazardsModule
	(declare (salience 200))
	?ok<-(passToAfterHazardsModule)
	=>
	(retract ?ok)
	(focus AfterHazardsModule)
	(assert
		(passToMovementModule)
	)
)

(defrule myMAIN::passToMovementModule
	(declare (salience 100))
	?ok<-(passToMovementModule)
	=>
	(focus MovementModule)
	(retract ?ok)
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
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

(defrule AfterHazardsModule::locate_alien_single_point_from_bottom
	(declare (salience 3))
	?n1<-(field(x ?x1)                   (y ?y1)                   (noise true) )
	?n2<-(field(x ?x2&:(= ?x2 (+ ?x1 1)))(y ?y2&:(= ?y2 (+ ?y1 0)))(noise false))
	?n3<-(field(x ?x3&:(= ?x3 (+ ?x1 -1)))(y ?y3&:(= ?y3 (+ ?y1 0)))(noise false))
	?n4<-(field(x ?x4&:(= ?x4 (+ ?x1 0)))(y ?y4&:(= ?y4 (+ ?y1 -1)))(noise false))
	=>
	(assert
		(position (name alien)(x (+ ?x1 0))(y (+ ?y1 1)))
	)
)

(defrule AfterHazardsModule::locate_alien_single_point_from_top
	(declare (salience 3))
	?n1<-(field(x ?x1)                    (y ?y1)                   (noise true) )
	?n2<-(field(x ?x2&:(= ?x2 (+ ?x1 1)))(y ?y2&:(= ?y2 (+ ?y1 0)))(noise false))
	?n3<-(field(x ?x3&:(= ?x3 (+ ?x1 -1)))(y ?y3&:(= ?y3 (+ ?y1 0)))(noise false))
	?n4<-(field(x ?x4&:(= ?x4 (+ ?x1 0)))(y ?y4&:(= ?y4 (+ ?y1 1)))(noise false))
	=>
	(assert
		(position (name alien)(x (+ ?x1 0))(y (+ ?y1 -1)))
	)
)

(defrule AfterHazardsModule::locate_alien_single_point_from_right
	(declare (salience 3))
	?n1<-(field(x ?x1)                    (y ?y1)                   (noise true) )
	?n2<-(field(x ?x2&:(= ?x2 (+ ?x1 0)))(y ?y2&:(= ?y2 (+ ?y1 1)))(noise false))
	?n3<-(field(x ?x3&:(= ?x3 (+ ?x1 0)))(y ?y3&:(= ?y3 (+ ?y1 -1)))(noise false))
	?n4<-(field(x ?x4&:(= ?x4 (+ ?x1 1)))(y ?y4&:(= ?y4 (+ ?y1 0)))(noise false))
	=>
	(assert
		(position (name alien)(x (+ ?x1 -1))(y (+ ?y1 0)))
	)
)

; (defrule AfterHazardsModule::locate_alien_single_point_from_left
; 	(declare (salience 3))
; 	?n1<-(field(x ?x1)                    (y ?y1)                   (noise true) )
; 	?n2<-(field(x ?x2&:(= ?x2 (+ ?x1 0)))(y ?y2&:(= ?y2 (+ ?y1 1)))(noise false))
; 	?n3<-(field(x ?x3&:(= ?x3 (+ ?x1 0)))(y ?y3&:(= ?y3 (+ ?y1 -1)))(noise false))
; 	?n4<-(field(x ?x4&:(= ?x4 (+ ?x1 -1)))(y ?y4&:(= ?y4 (+ ?y1 0)))(noise false))
; 	=>
; 	(assert
; 		(position (name alien)(x (+ ?x1 1))(y (+ ?y1 0)))
; 	)
; )


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
	=>
	(retract ?a)
	(retract ?it)
	(assert
		(iteration (+ ?iteration 1))
		(killed)
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
	=>
	(retract ?a)
	(retract ?it)
	(assert
		(iteration (+ ?iteration 1))
		(killed)
	)
	(fireLaser west)
)

(defrule AfterHazardsModule::shoot_alien_up
	(declare (salience 4))
	(hasLaser)
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?x) (y ?yw))
	?a<-(position (name alien) (x ?x) (y ?ya&:(< ?yw ?ya)))
	=>
	(retract ?a)
	(retract ?it)
	(assert
		(iteration (+ ?iteration 1))
		(killed)
	)
	(fireLaser north)
)

(defrule AfterHazardsModule::shoot_alien_down
	(declare (salience 4))
	(hasLaser)
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?w<-(position (name willy) (x ?x) (y ?yw))
	?a<-(position (name alien) (x ?x) (y ?ya&:(> ?yw ?ya)))
	=>
	(retract ?a)
	(retract ?it)
	(assert
		(iteration (+ ?iteration 1))
		(killed)
	)
	(fireLaser south)
)

(defrule AfterHazardsModule::retract_warning_when_kill
	(declare (salience 4))
	?k<-(killed)
	?w<-(warning (value backtrack))
	(position (name willy) (x ?x) (y ?y))
	(field(x ?x)(y ?y)(gravity false)(noise true))
	=>
	(retract ?k)
	(retract ?w)
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

;Regla utilizadas para retroceder a la casilla anterior cuando se detecta un peligro

(defrule MovementModule::backtrackSouth
	(declare (salience 100)) ; Se le da mas prioridad que al resto de movimientos
	?w<-(warning (value backtrack)) ; Hecho que fue afirmado en el modulo de riesgos
	(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration)) ; Si se supera el limite de iteraciones posibles(en este caso 999) la regla no se activa
	?p<-(position (name willy) (x ?x) (y ?y)) ; Hay que conocer la posicion en la que esta willy para modificarla
	?m<-(movimientos-contrarios south $?valores) ;En funcion del movimiento contrario que se realizo para llegar a la casilla se activara un backtrack u otro
	;Esta regla se activara cuando se llego a la casilla actual moviendose hacia el norte
	=>
	(retract ?it) ; Eliminamos el hecho iteracion para incrementarlo
	(retract ?p) ; Eliminamos el hecho para actualizar la posicion de willy
	(retract ?w) ; Eliminamos el hecho peligro
	(retract ?m) ; Eliminamos el hecho de movimientos-contrarios para actualizarlo
	(moveWilly south)
	(assert (iteration (+ ?iteration 1))) ; Incrementamos el hecho contador
	(assert (position (name willy) (x ?x) (y (- ?y 1)))) ; Actualizacion de la posicion de willy, en este caso una posicion hacia abajo
	(assert (movimientos-contrarios $?valores)) ; Vuelvo a afirmar el hecho movimientos pero ahora sin el movimiento que acaba de realizar
	(assert (repeat))
	(return) ; Una vez realizado el movimiento lo saca de la pila el modulo movimientos
)

; Para el resto de backtracks es exactamente lo mismo lo unico que se modifica es la posicion a la que se mueve

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
		(assert (repeat))
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
		(assert (repeat))
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
		(assert (repeat))
		(return)
	)

;============================================================================
; move normal
;============================================================================

;Reglas que se activan cuando hay casillas no visitadas circunstantes a willy

(defrule MovementModule::moveWillyNorth
	(declare (salience 1))
	?mit<-(max_iteration ?max_iteration) ; Ver el numero de iteraciones maximo que podemos realizar
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration)) ; Que el numero de iteraciones sea menor que el maximo permitido
	?willy<-(position (name willy) (x ?x_w) (y ?y_w)) ; Necesitamos conocer la posicion del willy para poder despues actualizarla
	(directions $? north $?) ; Es necesario que este permitido el movimiento hacia la direccion que queremos
	(not
		(field	(x ?x_w) (y =(+ ?y_w 1))) ; Que la casilla situada en la posicion superior a willy(coordenada y + 1) no se encuentre visitada
	)
	?m<-(movimientos-contrarios $?valores) ; Necesito este hecho ya que es donde voy a ir almacenando el movimiento contrario al que realizo
																				 ;En este caso como me muevo hacia el norte almaceno sur. Esto es para luego poder retroceder
	=>
	(retract ?willy) ; Borro la posicion del willy, ya que como me muevo necesito actualizarla
	(retract ?it) ; Borro el hecho iteracion para incrementarlo
	(retract ?m) ; Borro el hecho movimientos contrarios para actualizarlo
	(moveWilly north) ; Me desplazo hacia el norte
	(assert
		(position (name willy)(x ?x_w) (y (+ ?y_w 1)))
		(iteration (+ ?iteration 1))
	) ; Afirmo los hechos posicion(con la y incrementada en una unidad) y iteracion actualizados
	(assert (movimientos-contrarios south $?valores)) ; Afirmo el hecho movimientos con la posicion sur mas el resto de movimientos que ya hubieran almacenados
	(assert (repeat))
	(return) ; Saco el modulo movimientos de la pila
)

	; Para el resto de estas reglas es exactamente lo mismo pero cambiando la direccion del movimiento

(defrule MovementModule::moveWillySouth
	(declare (salience 1))
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	(directions $? south $?)
	(not
		(field	(x ?x_w) (y =(- ?y_w 1)))
	)
	?m<-(movimientos-contrarios $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly south)
	(assert
		(position (name willy) (x ?x_w) (y (- ?y_w 1)))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios north $?valores))
	(assert (repeat))
	(return)
)

(defrule MovementModule::moveWillyEast
	(declare (salience 1))
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	(directions $? east $?)
	(not
		(field	(x =(+ ?x_w 1)) (y ?y_w))
	)
	?m<-(movimientos-contrarios $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly east)
	(assert
		(position (name willy) (x (+ ?x_w 1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios west $?valores))
	(assert (repeat))
	(return)
)

(defrule MovementModule::moveWillyWest
	(declare (salience 1))
	?mit<-(max_iteration ?max_iteration)
	?it<-(iteration ?iteration&:(< ?iteration ?max_iteration))
	?willy<-(position (name willy) (x ?x_w) (y ?y_w))
	(directions $? west $?)
	(not
		(field	(x =(- ?x_w 1)) (y ?y_w))
	)
	?m<-(movimientos-contrarios $?valores)
	=>
	(retract ?willy)
	(retract ?it)
	(retract ?m)
	(moveWilly west)
	(assert
		(position (name willy) (x (- ?x_w 1)) (y ?y_w))
		(iteration (+ ?iteration 1))
	)
	(assert (movimientos-contrarios east $?valores))
	(assert (repeat))
	(return)
)


;============================================================================
; move stuck
;============================================================================

;Estas reglas son utilizadas en el momento en que no existe ninguna casilla sin visitar circunstantes a willy
;En ese caso lo que se hace es ir realizando los movimientos apuesto a los que hicieron hasta encontrar una casilla no visitada


(defrule MovementModule::retrocederNorte
	(declare (salience 0)) ; Ha esta regla se le colocara prioridad inferior que el resto de movimientos, ya que se va a ejercutar cuando
	; no se puedan ejercutar las otras, es decir, cuando no exista ninguna casilla circunstante sin visitar
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
	(assert (repeat))
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
	(assert (repeat))
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
	(assert (repeat))
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
	(assert (repeat))
	(return)
)
