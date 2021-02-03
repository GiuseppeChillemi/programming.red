
size 300x300 [
   origin 0x0
   image %space.jpg 300x300 0:0:0 [
       0:0:1 add-effects [
           0:0:0.5   [blur]
	   0:0:1     [reflect -1x1]
	   0:0:2     [colorize 200.120.10]
	   0:0:4     [tint -120]
           0:0:2.5   [gradcol 1x1 255.255.255 0.0.0]
	   0:0:4     [contrast 15]
	   0:0:2     [draw [pen white text 20x45 "Groovy"]]
	   0:0:1     [draw [pen white line 20x60 80x60]]
	   0:0:2     [draw [pen red circle 150x150 90]]
       ] 0:0:1
	   0:0:6 fade 0:0:1
   ]
]
