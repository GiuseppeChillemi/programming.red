REBOL [
	Title: "Presentation Dialect with example"
	Author: "Jeff Kreis"
	Date:   15-Jan-2001
]

;print "Presentation"
random/seed now/time
vids: copy []
foreach [w f] system/view/vid/vid-styles [
	append vids w
]
vids: make hash! vids

count-faces: func [code [block!] count /local i][
	foreach w code [
		if find vids w [count: count + 1]
	] count
]

effect-obj: make object! [
	start:      0:0:0 
	base:       'none
	fade-to:    none
	xy:         none
	effects:    none
	duration:  0:0:0
	fade-facet: none
]
fade-obj: fade-up-obj: make effect-obj [
	fade-to: 0.0.0
]
grow-obj: move-obj: go-obj: make effect-obj [
	xy: 100x100
]
add-effects-obj: make effect-obj [
	duration: 0:0:1
]
	
make-effect-obj: func [
	base [word!] changes [block!]
	/local base-obj new
][
	base-obj: get to-word join base "-obj"
	new: make base-obj changes
	new/base: base
	new
]

present: func [prez /new /local count][
	prez-data: make block! 300
	user-effects: copy []	
	user-effect-words: copy []
	gprez: prez
	prez-face: make face [
		para: none 
		pane: copy []
	]
	inactive-layouts: copy []
	user-effect-rules: [
		some [
			m1:
			set deriv word! some [
				m1: set base ['move | 'grow | 'go | 'fade-up | 'fade] set changes block! (
					new: make-effect-obj base changes
					either spot: select user-effects deriv [
						append spot new
					][
						repend user-effects [deriv reduce [new]]
					]
					if not find user-effect-words deriv: to-lit-word deriv [
						repend user-effect-words [to-lit-word deriv '|]
					]
				)
			]	
		] (if not empty? user-effect-words [remove back tail user-effect-words])
	]
	if not parse prez [
		m1: 
		opt ['effects into user-effect-rules]
		'size set size pair! (prez-face/size: size the-prez: copy []) 
		some [ ;-- prez level
			into [  ;-- Scene level
				( this-scene:   copy [] this-layout:  copy [] count: 0)
				some [
					copy prez-part to time! (
						effect-chunk: copy []
					) 
					set appear-time time! 
					opt [
						m0: set ue user-effect-words (
;							print ["USER EFFECT:" ue]
							if ue [
								ue: select user-effects ue
								new: copy []
								foreach effect ue [
									append new replace/all copy next second effect none []
								]
								change/only m0 new
							]
						) :m0                                                           
					]
					m1:
					into [ ;-- Effect level
						m1:
						some [
							set effect-time time! ( prez-info: copy [] )
							m: set prez-act ['fade | 'fade-up | 'grow | 'move | 'go | 'add-effects] :m [
								['fade | 'fade-up]  set tup opt [tuple! | word!] 
								set num [integer! | time!] set fac opt word! (
									if word? tup [if not tuple? tup: get tup [tup: none]]
									repend prez-info [tup num fac]
								)                                                        |
								['grow | 'move | 'go] set pair pair! set num [integer! | time!] (
									repend prez-info [pair num]
								)                                                        |
								'add-effects set the-effects block! set num time! (
									repend prez-info [the-effects num]
								)
							] (
								repend effect-chunk [prez-act prez-info effect-time]
							)
						]
					] (
						;-- add effects for an element
						count: count-faces prez-part count
						append this-layout prez-part
						repend this-scene [count effect-chunk appear-time]
					)
				] | copy prez-part to end (append this-layout prez-part)
			] (
				;-- add layout for this scene
				new-parts: get in layout this-layout 'pane
				foreach face new-parts [
					if in face 'font [
						set in face 'font make face/font []
					]
				]
				repend/only inactive-layouts new-parts
				;-- add corresponding scene to prezentation 
				append/only the-prez this-scene
			)
		]
	][print ["Failed to parse near:" mold m1] halt]
	display-prez
]

init-scene: func [
	scene [block!]
	/local begin
][
	begin: now/time/precise 
	;-- calculate all the times
	;   build the layout portions
	active-layout: copy []
	this-lay: first inactive-layouts
	inactive-layouts: next inactive-layouts
	lst-lay: 0 
	if empty? scene [append/only active-layouts this-lay]
	forskip scene 3 [
		set [lay eff t1] scene 
		;-- add in the amount up to the animinated element
		append active-layout copy/part skip this-lay lst-lay at this-lay lay
		lst-lay: lay
		;-- change the index to the affected face
		change scene pick this-lay lay
		;-- set the absolute time for this to appear
		change at scene 3 begin + t1
		;-- set the absolute times for the effects to happen
		forskip eff 3 [
			set [act info t2] eff 
			change at eff 3 begin + t1 + t2
		]
	]
	append/only active-layouts active-layout
]

display-prez: func [
	/local
	lay eff t1 t2 act info lst-lay
][
	active-layouts: copy []
	set-scene
	view/new prez-face
	update-visible
]

set-scene: func [ /local scene ] [
	if tail? the-prez [
		show prez-face
		return false
	]
	this-scene: first the-prez
;	print ["initializing scene:" now/time]
	init-scene this-scene

	scene: first active-layouts	

	if not empty? scene [
		bg: first scene 
		if any [bg/style = 'backdrop bg/style = 'backtile][
			bg/size: prez-face/size
		]
	]
	clear prez-face/pane 
	append prez-face/pane scene

	active-layouts: next active-layouts
	the-prez: next the-prez
]

next-prez-part: does [
	if tail? prez-data: skip prez-data 4 [
		halt
	]
]

fast-forward: 0

update-visible: func [ 
	/local t1 
	face effects appear-time i 
][
	forever [
		i: 0
		wait 0:0.02
		t1: now/time/precise + fast-forward
		if empty? this-scene [if not set-scene [exit]]
		;print [(length? this-scene) / 3 "faces to do in this scene"]
		foreach [face effects appear-time] copy this-scene  [
			; print [appear-time "(" t1 "}"] ; "effects:" mold effects 
			if appear-time <= t1 [
				either face/user-data [
					either not empty? effects [
						do-effects face effects t1
					][
						;					print ["Removing from scene:" face/style face/text]
						remove/part at this-scene i 3
						i: i - 3
					]
				][
					;				print ["Initially Visible:" face/style face/text]
					face/user-data: on
					if any [face/style = 'backdrop face/style = 'backtile][
						face/size: prez-face/size
					]
					append prez-face/pane face
					do-effects face effects t1
					show prez-face
					;				print ["Length prez-face/pane:" length? prez-face/pane]
				]
			]
			i: i + 3
		] 
	]
]



do-effects: func [face [object!] effects [block!] t1 [time!] /local][
	i: 1
	foreach [effect data time] copy effects [
		if time <= t1 [
			if 'init <> last data [                     ;- total time , end time
				if time? data/2 [change/only at data 2 reduce [data/2 t1 + data/2]]
				
;				print ["initializing" effect face/style face/text mold data]
				do reduce [to-word join 'init- effect face data]
				append data 'init
			] 
			if not do reduce [effect face data][
;				print ["Completed" effect face/style face/text]
				remove/part at effects i 3
				i: i - 3
			]
		]
		i: i + 3
	]
]

dist: func [a b c][to-integer ((a - b) / c)]
dist-d: func [a b c][(((to-decimal a) - (to-decimal b)) / to-decimal c)]

move: func [
	face [object!] 
	data [block!]
][
	do-space face data 'offset
]

init-move: func [
	face [object!]
	data [block!]
	/local pair ticks
][
	set [pair ticks] data
	if any [not pair? pair all [not integer? ticks not block? ticks]][
		make error! reform ["Bad data to init-move" mold data]
	]
	change data reduce [ticks pair]
]

go: func [
	face data [block!]
	/local offset ticks
][
	do-space/percent face data 'offset
]

init-go: func [face [object!] data [block!]][
	init-space face data 'offset
]

do-space: func [
	face [object!] data [block!] facet [word!]
	/percent
	/local which t1 d x y
][
;	print "Do space"
	which: get in face facet
;	?? which
	either block? data/1 [
		t1: now/time/precise + fast-forward
		x: data/2/x y: data/2/y
		d: 1.0 - dist-d data/1/2 t1 data/1/1 
		if t1 >= data/1/2 [
			if percent [set in face facet face/user-data + to-pair reduce [x y] show face]
			return false
		]
		either percent [
;			prin face/style
;			probe face/user-data probe reduce [x y] probe d
			set in face facet ((face/user-data + (to-pair reduce [to-integer x * d to-integer y * d])))
;			print [face/style "target:" face/user-data]
		][set in face facet which + data/2]
		show face
;		print ["Showd:" face/style face/text face/size face/offset]
		true
	][
		set in face facet which + data/2
		show face
		change data data/1 - 1
		data/1 >= 0
	]
]

init-space: func [
	face [object!] data [block!] facet [word!]
	/local pair ticks which delta t1 x y
][
	which: get in face facet
	set [pair ticks] data
	if any [not pair? pair all [not integer? ticks not block? ticks]][
		make error! reform ["Bad data to init-space:" mold data]
	]
	either not block? ticks [
		ticks: abs ticks
		delta: to-pair reduce [
			dist pair/x  which/x ticks
			dist pair/y  which/y ticks
		]
	][
		x: pair/x y: pair/y
		delta: to-pair reduce [
			x - which/x
			y - which/y
		]
		face/user-data: which
	]
	change data reduce [ticks delta pair]
]

grow: func [
	face [object!] data [block!]
	/local size
][
	do-space/percent face data 'size
]

init-grow: func [
	face [object!] data [block!]
	/local size
][
	init-space face data 'size

;	?? data

	either block? face/effect [
		append face/effect 'fit
	][face/effect: [fit]]
;	face/user-data: data/3	
;	print ["Grow data:" mold data]
]

delt-tuple: func [a b /local result][
	result: copy []
	repeat i length? a [
		append result max 0 min 255 (pick a i) + pick b i 
	]
	to-tuple result
]

time-scale: func [
	coords [block!]
	d [decimal!]
	/local result
][
	result: copy []
	repeat i length? coords [
		append result to-integer (((pick coords i) * (1 - d)))
	]
]

fade: func [
	face [object!] data [block!]
	/local ticks afc aft afe fade-img fade-img-spot c facet
	fc ffc fec
][

;	print ["fade" mold data]

	set [ticks afc aft afe fade-img fade-img-spot facet] data

	all [ffc: face/font ffc: ffc/color]
	fc: face/color
	all [fec: face/edge fec: fec/color]

	if block? ticks [
		t1: now/time/precise
		d: dist-d ticks/2 t1 ticks/1
		if d <= 0.0 [
			if fade-img [
				change fade-img-spot either negative? fade-img [
					-255
				][0]
				show face
			]
			return false
		]

		all [afc fc: afc/1  afc: time-scale afc/2 d]
		all [aft ffc: aft/1 aft: time-scale aft/2 d]
		all [afe fec: afe/1 afe: time-scale afe/2 d]
	]

	if fade-img [
		change fade-img-spot either block? ticks [
			either not negative? fade-img [
				-255 + to-integer (255 * (1 - dist-d ticks/2 t1 ticks/1))
			][
				0 - (to-integer (255 * (1 - dist-d ticks/2 t1 ticks/1)))
			]
		][
			fade-img-spot/1 + fade-img
		]
	]

	either facet [
		switch/default facet reduce [
			'text [
				all [face/font face/font/color: delt-tuple aft ffc 
					block? face/colors 2 <= length? face/colors 
					change face/colors face/font/color
				]
			]
			'body default: [
				all [
					face/color face/color: delt-tuple afc fc
					block? face/colors 2 <= length? face/colors
					change face/colors face/color
				]
			]
			'edge [
				all [face/edge face/edge/color: delt-tuple afe fec]
			]
			'full [
				all [face/edge face/edge/color: delt-tuple afe fec]
				all [face/font face/font/color: delt-tuple aft ffc]
				all [
					face/color face/color: delt-tuple afc fc
					block? face/colors 2 <= length? face/colors
					change face/colors face/color
				]
			]
		] default
	][
		;-- otherwise, decide based on what's there
		if face/color [
			face/color: delt-tuple afc fc
		]
		if face/font/color [
			face/font/color: delt-tuple aft ffc
		]
	]
	show face

	either block? ticks [true][
		;-- amount of ticks of this
		change data ticks - 1
		data/1 >= 0
	]
]

init-add-effects: func [
	face [object!] data [block!]
	/local the-effects ticks calc-effects t1 t2
][
	set [the-effects ticks] data
	calc-effects: copy []
	t1: now/time/precise

	if not face/effect [
		face/effect: copy []
	]
	if not block? face/effect [
		face/effect: compose [(face/effect)]
	]

	;-caclucate the transition times
	t2: t1
	forall the-effects [
		either time? the-effects/1 [
			repend calc-effects [t1 + the-effects/1 the-effects/2]
			t2: t2 + the-effects/1
			the-effects: next the-effects
		][
			if block? the-effects/1 [repend calc-effects [t2: t2 + ticks/1 the-effects/1]]
		]
	]
	sort/skip calc-effects 2
	;?? calc-effects
	change clear data calc-effects
]

add-effects: func [
	face [object!] data [block!]
	/local t1
][
	if 1 = length? data [return false]
	t1: now/time/precise 
;	?? data
	while [all [time? data/1 data/1 <= t1]][
		append face/effect copy/deep data/2 
		remove/part head data 2
		show face
;		?? data
	]
	return yes
]


init-fade-up: func [
	face [object!] data [block!]
][
	init-fade/up face data
]
fade-up: func [
	face [object!] data [block!]
][
	fade face data
]

init-fade: func [
	face [object!] data [block!] /up
	/local eff t1 t2 afc aft afe fade-img fade-img-spot ticks facet blk-ticks
][

	set [t1 ticks facet] data
	if not t1 [t1: 0.0.0]
	if not ticks [ticks: 10]
	set [fade-img fade-img-spot] none

	if face/image [
		eff: reduce ['brighten either up [-255][0]]
		either not block? face/effect [
			face/effect: eff
		][
			append face/effect eff
		]
		either block? ticks [
			fade-img: either up [255][-255]
		][
			fade-img: to-integer (255 / ticks)
		]
		fade-img-spot: back tail face/effect
	]	

	either not block? ticks [ticks: abs ticks][
		blk-ticks: ticks ticks: 1
	]

	if afc: face/color	[
		afc: reduce [
			dist t1/1 afc/1 ticks
			dist t1/2 afc/2 ticks
			dist t1/3 afc/3 ticks
		]
		if blk-ticks [
			afc: reduce [face/color afc]
		]
	] 
	
	if all [aft: face/font aft: aft/color] [
		aft: reduce [
			dist t1/1 aft/1 ticks
			dist t1/2 aft/2 ticks
			dist t1/3 aft/3 ticks
		]
		if blk-ticks [
			aft: reduce [face/font/color aft]
		]
	]
	if all [afe: face/edge afe: afe/color] [
		afe: reduce [
			dist t1/1 afe/1 ticks
			dist t1/2 afe/2 ticks
			dist t1/3 afe/3 ticks
		]
		if blk-ticks [
			afe: reduce [face/edge/color afe]
		]		
	]
	if blk-ticks [ticks: blk-ticks]

	change data reduce [ticks afc aft afe fade-img fade-img-spot facet]
]




