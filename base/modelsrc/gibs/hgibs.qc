output ../../models/hgibs.mdl
rotate 0 90 0

// head (also gib_skull.mdl)
scale 0.075
geomset 0 0
scene rock01.smd

// heart
scale 0.1
geomset 0 1
scene rock02.smd

// colon like tube
geomset 0 2
scene rock03.smd

// lung and ribs (also gib_lung.mdl)
geomset 0 3
scene rock01.smd

// some leg with bone (also gib_legbone.mdl)
scale 0.1
geomset 0 4
scene rock02.smd

// hunk of red gibblets (also gib_b_gib.mdl)
geomset 0 5
scene rock03.smd

// spine
geomset 0 6
scene rock01.smd

// thin slice of gibs (also fleshgibs submodel 2)
scale 0.1
geomset 0 7
scene rock02.smd

// medium large, thin slice of gibs (also fleshgibs submodel 1)
geomset 0 8
scene rock03.smd

// small chunky gib  (also fleshgibs submodel 3)
geomset 0 9
scene rock01.smd

// long thin slice of gib  (also fleshgibs submodel 4)
scale 0.1
geomset 0 10
scene rock02.smd
