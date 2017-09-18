;Multi-unit transportation domain for the game "Emperor of the fading suns"(EoFS)
(define (domain transportefs)

    (:requirements
        ;:durative-actions
        ;:equality
        ;:negative-preconditions
        ;:numeric-fluents
        ;:object-fluents
        :typing
    )

    (:types
        unit    ;unit
        loc     ;location
        orbit   ;planet orbit
        slot    ;transport slot
    )

    (:constants

    )
    
    ;Large letter - invariant
    ;small letter - variant
    (:predicates
        
        ;Univers - invariants
        (Adj ?loc1 - loc ?loc2 - loc)      ;grid conenctions
        (Land  ?loc - loc)                 ;Land 
        (Ocean ?loc - loc)                 ;Ocean
        (Planet ?orbit - orbit ?loc - loc)  ;connected orbit of the planet
        (Stargate ?from - orbit ?to - orbit) ;Stargate connections

        ;Unit transportability
        (Transport ?unit - unit)           ;unit can transport
        (Transportable ?unit - unit )      ;unit can be transported
        
        ;Unit movement types
        (Move   ?u - unit)                 ;   
        (Naval  ?u - unit)                 ; 
        (Space  ?u - unit)                 ; 
        (Jump   ?u - unit)                 ; 

        ;variants
        (at ?u - unit ?loc - loc)          ;unit at location
        (in ?u - unit ?t - unit ?s - slot) ;unit inside transport slot
        (hasSlot ?t - unit ?s - slot)      ;has free transport slot
        (inOrbit ?u - unit ?o - orbit)     ;orbit the planet
        
    )

;    (:functions

;    )
    
    ; move with foot, wheels, tread, crawler
    (:action move 
        :parameters (?u - unit ?from - loc ?to - loc)
        :precondition (and (Adj ?from ?to)
                           (at ?u ?from)
                           (Move ?u)
                           (Land ?to)
                      )
        :effect (and (not (at ?u ?from)) 
                     (at ?u ?to)
                )
    )
    
    ; naval move
    (:action sail 
        :parameters (?u - unit ?from - loc ?to - loc)
        :precondition (and (Adj ?from ?to)
                           (at ?u ?from)
                           (Naval ?u)
                           (Ocean ?to)
                           (Ocean ?from)
                      )
        :effect (and (not (at ?u ?from)) 
                     (at ?u ?to)
                )
    )    
    
    ; load to adjacent location
    (:action loadAdj 
        :parameters (?t - unit ?to - loc ?s - slot ?u - unit ?from - loc )
        :precondition (and (at ?u ?from)
                           (at ?t ?to)
                           (Transportable ?u)
                           (Transport ?t)
                           (hasSlot ?t ?s )                           
                           (Adj ?from ?to)
                      )
        :effect (and (not (at ?u ?from))
                     (not (hasSlot ?t ?s ))
                     (in ?u ?t ?s)
                )
    )
    
    ; load at the same location
    (:action load 
        :parameters (?t - unit ?loc - loc ?s - slot ?u - unit )
        :precondition (and (at ?u ?loc)
                           (at ?t ?loc)
                           (Transportable ?u)
                           (Transport ?t)
                           (hasSlot ?t ?s )                           
                      )
        :effect (and (not (at ?u ?loc))
                     (not (hasSlot ?t ?s ))
                     (in ?u ?t ?s)
                )
    )    
    
    ; unload to Land adjacent location
    (:action offshoreLanding 
        :parameters (?t - unit ?from - loc ?s - slot ?u - unit ?to - loc )
        :precondition (and (at ?t ?from)
                           (in ?u ?t ?s)
                           (Adj ?from ?to)
                           (Ocean ?from)
                           (Land ?to)
                           (Move ?u)
                      )
        :effect (and (at ?u ?to)
                     (hasSlot ?t ?s )
                     (not (in ?u ?t ?s))
                )
    )  
    
    ; unload to Land (anyone can)
    (:action unload 
        :parameters (?t - unit ?loc - loc ?s - slot ?u - unit )
        :precondition (and (at ?t ?loc)
                           (in ?u ?t ?s)
                           (Land ?loc)
                      )
        :effect (and (at ?u ?loc)
                     (hasSlot ?t ?s )
                     (not (in ?u ?t ?s))
                )
    )  
    
    ; unload to ocean location(only naval can)
    (:action unloadInOcean 
        :parameters (?t - unit ?loc - loc ?s - slot ?u - unit )
        :precondition (and (at ?t ?loc)
                           (in ?u ?t ?s)
                           (Ocean ?loc)
                           (Naval ?u)
                      )
        :effect (and (at ?u ?loc)
                     (hasSlot ?t ?s )
                     (not (in ?u ?t ?s))
                )
    ) 
    ; undock from space ship
    (:action spaceUndock 
        :parameters (?t - unit ?o - orbit ?s - slot ?u - unit )
        :precondition (and (inOrbit ?t ?o)
                           (in ?u ?t ?s)
                           (Space ?u)
                      )
        :effect (and (inOrbit ?u ?o)
                     (hasSlot ?t ?s )
                     (not (in ?u ?t ?s))
                )
    )   
    
    ; launch to orbit
    (:action launch 
        :parameters (?u - unit ?loc - loc ?o - orbit )
        :precondition (and (at ?u ?loc)
                           (Planet ?o ?loc)
                           (Space ?u)
                      )
        :effect (and (inOrbit ?u ?o)
                     (not (at ?u ?loc))
                )
    )  
    
    ; descent from orbit to Land(any orbit ship can)
    (:action descentToLand 
        :parameters (?u - unit ?o - orbit ?loc - loc)
        :precondition (and (inOrbit ?u ?o)
                           (Planet ?o ?loc)
                           (Land ?loc)
                      )
        :effect (and (not (inOrbit ?u ?o))
                     (at ?u ?loc)
                )
    )   
    
    ; descent from orbit to Water
    (:action descentToWater 
        :parameters (?u - unit ?o - orbit ?loc - loc)
        :precondition (and (inOrbit ?u ?o)
                           (Planet ?o ?loc)
                           (Ocean ?loc)
                           (Naval ?u)
                      )
        :effect (and (not (inOrbit ?u ?o))
                     (at ?u ?loc)
                )
    )   
    
    ; Jump
    (:action jump 
        :parameters (?u - unit ?from - orbit ?to - orbit)
        :precondition (and (inOrbit ?u ?from)
                           (Stargate ?from ?to)
                           (Jump ?u)
                      )
        :effect (and (not (inOrbit ?u ?from))
                     (inOrbit ?u ?to)
                )
    )  
    
    ; PlanetCargo Transfer
    (:action transShipment
        :parameters (?loc - loc ?from - unit ?sFrom - slot ?to - unit ?sTo - slot ?u - unit)
        :precondition (and (at ?from ?loc)
                           (at ?to ?loc)
                           (in ?u ?from ?sFrom)
                           (hasSlot ?to ?sTo)
                      )
        :effect (and (not (in ?u ?from ?sFrom))
                     (in ?u ?to ?sTo)
                     (not (hasSlot ?to ?sTo))
                     (hasSlot ?from ?sFrom)
                )
    )  
    
    ; Orbit Cargo Transfer
    (:action OrbitTransShipment
        :parameters (?o - orbit ?from - unit ?sFrom - slot ?to - unit ?sTo - slot ?u - unit)
        :precondition (and (inOrbit ?from ?o)
                           (inOrbit ?to ?o)
                           (in ?u ?from ?sFrom)
                           (hasSlot ?to ?sTo)
                      )
        :effect (and (not (in ?u ?from ?sFrom))
                     (in ?u ?to ?sTo)
                     (not (hasSlot ?to ?sTo))
                     (hasSlot ?from ?sFrom)
                )
    )    
)