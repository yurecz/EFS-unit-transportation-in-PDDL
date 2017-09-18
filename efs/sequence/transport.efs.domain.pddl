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
        seq     ;sequence
    )

    (:constants

    )
    
    ;Large letter - invariant
    ;small letter - variant
    (:predicates

        (Next ?from - seq ?to - seq)       ;next sequence
        (Prev ?from - seq ?to - seq)       ;prev sequence
        
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
        (in ?u - unit ?t - unit)           ;unit inside transport slot
        (inOrbit ?u - unit ?o - orbit)     ;orbit the planet
        (freeSpace ?u - unit ?s - seq)     ;free space for cargo
        
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
        :parameters (?t - unit ?to - loc ?p - seq ?n - seq ?u - unit ?from - loc )
        :precondition (and (at ?u ?from)
                           (at ?t ?to)
                           (freeSpace ?t ?p)
                           (Transportable ?u)
                           (Transport ?t)
                           (freeSpace ?t ?p )             
                           (Prev ?p ?n)
                           (Adj ?from ?to)
                      )
        :effect (and (not (at ?u ?from))
                     (not (freeSpace ?t ?p ))
                     (freeSpace ?t ?n )
                     (in ?u ?t)
                )
    )
    
    ; load at the same location
    (:action load 
        :parameters (?t - unit ?loc - loc ?p - seq ?n - seq ?u - unit )
        :precondition (and (at ?u ?loc)
                           (at ?t ?loc)
                           (freeSpace ?t ?p)
                           (Transportable ?u)
                           (Transport ?t)
                           (freeSpace ?t ?p )             
                           (Prev ?p ?n)                           
                      )
        :effect (and (not (at ?u ?loc))
                     (not (freeSpace ?t ?p))
                     (freeSpace ?t ?n)
                     (in ?u ?t)
                )
    )    
    
    ; unload to Land adjacent location
    (:action offshoreLanding 
        :parameters (?t - unit ?from - loc ?p - seq ?n - seq ?u - unit ?to - loc )
        :precondition (and (at ?t ?from)
                           (in ?u ?t)
                           (freeSpace ?t ?p)
                           (Adj ?from ?to)
                           (Ocean ?from)
                           (Land ?to)
                           (Move ?u)
                           (Next ?p ?n)
                      )
        :effect (and (at ?u ?to)
                     (not (in ?u ?t))
                     (not (freeSpace ?t ?p))
                     (freeSpace ?t ?n)                     
                )
    )  
    
    ; unload to Land (anyone can)
    (:action unload 
        :parameters (?t - unit ?loc - loc ?p - seq ?n - seq ?u - unit )
        :precondition (and (at ?t ?loc)
                           (in ?u ?t)
                           (freeSpace ?t ?p)
                           (Land ?loc)
                           (Next ?p ?n)
                      )
        :effect (and (at ?u ?loc)
                     (not (freeSpace ?t ?p))
                     (freeSpace ?t ?n)
                     (not (in ?u ?t))
                )
    )  
    
    ; unload to ocean location(only naval can)
    (:action unloadInOcean 
        :parameters (?t - unit ?loc - loc ?p - seq ?n - seq ?u - unit )
        :precondition (and (at ?t ?loc)
                           (in ?u ?t)
                           (freeSpace ?t ?p)
                           (Ocean ?loc)
                           (Naval ?u)
                           (Next ?p ?n)
                      )
        :effect (and (at ?u ?loc)
                     (not (freeSpace ?t ?p))
                     (freeSpace ?t ?n)
                     (not (in ?u ?t))
                )
    ) 
    ; undock from space ship
    (:action spaceUndock 
        :parameters (?t - unit ?o - orbit ?p - seq ?n - seq ?u - unit )
        :precondition (and (inOrbit ?t ?o)
                           (in ?u ?t)
                           (freeSpace ?t ?p)
                           (Space ?u)
                           (Next ?p ?n)
                      )
        :effect (and (inOrbit ?u ?o)
                     (not (freeSpace ?t ?p))
                     (freeSpace ?t ?n)
                     (not (in ?u ?t))
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
    
    ; Planet Cargo Transfer
    (:action transShipment
        :parameters (?loc - loc ?from - unit ?pFrom - seq ?nFrom - seq ?to - unit ?pTo - seq ?nTo - seq ?u - unit)
        :precondition (and (at ?from ?loc)
                           (at ?to ?loc)
                           (in ?u ?from)
                           (Prev ?nTo ?nTo) ;dummy
                           (freeSpace ?from ?pFrom)
                           (Next ?pFrom ?nFrom)
                           (freeSpace ?to ?pTo)
                           (Prev ?pTo ?nTo)
                      )
        :effect (and (not (in ?u ?from))
                     (in ?u ?to)
                     (not (freeSpace ?from ?pFrom))
                     (freeSpace ?from ?nFrom)
                     (not (freeSpace ?to ?pTo))
                     (freeSpace ?to ?nTo)
                )
    )  
    
    ; Orbit Cargo Transfer
    (:action OrbitTransShipment
        :parameters (?o - orbit ?from - unit ?pFrom - seq ?nFrom - seq ?to - unit ?pTo - seq ?nTo - seq ?u - unit)
        :precondition (and (inOrbit ?from ?o)
                           (inOrbit ?to ?o)
                           (in ?u ?from)
                           (freeSpace ?from ?pFrom)
                           (Next ?pFrom ?nFrom)
                           (freeSpace ?to ?pTo)
                           (Prev ?pTo ?nTo)
                      )
        :effect (and (not (in ?u ?from))
                     (in ?u ?to)
                     (not (freeSpace ?from ?pFrom))
                     (freeSpace ?from ?nFrom)
                     (not (freeSpace ?to ?pTo))
                     (freeSpace ?to ?nTo)
                )
    )    
)