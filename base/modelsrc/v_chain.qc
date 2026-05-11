output ../models/v_chain.vvm
materialprefix "models/"
scene v_chain.smd

scene chain-anim.smd unpack start 1 end 1 pack loop
scene chain-anim.smd fps 10.0

event 0 5000 ""
scene chain-anim.smd fps 60.0 loop
