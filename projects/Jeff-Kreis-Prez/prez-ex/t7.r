effects [ 
    slow-fade-blue fade [fade-to: blue duration: 0:0:8]
    slow-fade-blue-move-up fade [fade-to: blue duration: 0:0:8] 
        move [start: 0:0:2 xy: 0x-2 duration: 0:0:8]
]
size 300x300 [
	backdrop white
    at 50x50 title "I feel blue" 0:0:1 slow-fade-blue
    at 100x250 h1 "Up up and away!" 0:0:2 slow-fade-blue-move-up
]