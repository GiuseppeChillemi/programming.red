REBOL [
	Title: "Make Presentation"
]

do %presentation.r

view/offset layout [
	styles link-styles backdrop
	title "Presentation:" center
	across
	lbl black "File:" 30 
	tp: txt "test-prez.r" black 240.240.240 170
	edge [size: 2x1 effect: 'bevel] [
		tp/text: form any [request-file tp/text]
		show tp
	] return
	button "Start" [
		all [value? 'prez-face unview/only prez-face]
		present/new this-prez: load to-file tp/text 
	]
	button "Quit" [q]
	return
	ot: field "untitled.r" 100 button "save" [
		save to-file ot/text compose/deep [
			REBOL [File: (to-file ot/text)]
			do %presentation.r
			present [(this-prez)]
		]
	]
]  300x50