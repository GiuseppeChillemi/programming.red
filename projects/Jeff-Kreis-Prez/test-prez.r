effects [
	slow-fade-red fade [start: 0:0:0 fade-to: red duration: 0:0:10]
	go-c-slow go [xy: 250x250 duration: :0:5]
	go-c-fast go [xy: 250x250 duration: :0:1]
	go-c-med-fade go [xy: 250x250 duration: :0:3] fade [start: :0:1 fade-to: green duration: :0:3]
	slow-grow-fade grow [start: :0:1 xy: 150x150 duration: :0:10] fade [start: :0:1 fade-to: 10.20.200 duration: :0:10]
	slow-shrink grow [start :0:1 xy: 5x5 duration: :0:10]
]
size 500x500 [
	backdrop 200.150.130
	h1 "Testing presentation engine"
	across
	button "8" :0:0 slow-grow-fade
	tab
	button "9" :0:0 slow-shrink
	below
	txt "1" :0:0 go-c-slow
	txt "2" :0:1 go-c-fast
	h1 "3" :0:2 go-c-med-fade
	at 480x400 guide
	h1 "4" :0:0 go-c-fast
	h2 "5" :0:1 go-c-slow
	h3 "6" :0:2 go-c-med-fade		

;	tb "5" :0:4 go-center-slow
]
