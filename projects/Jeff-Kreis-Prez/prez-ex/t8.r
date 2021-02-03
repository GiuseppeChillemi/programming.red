effects [
    crazy-button fade [
        fade-to: yellow duration: 0:0:5 fade-facet: 'text
    ] fade [
        fade-to: 200.30.0 duration: 0:0:4 fade-facet: 'body
    ]
]
size 250x80 [
    backdrop 50.90.130
    across 
    button "Click" [request/ok "bingo!"] 0:0:0 crazy-button
    button "me" [request/ok "Zip!"] 0:0:0 crazy-button
]
