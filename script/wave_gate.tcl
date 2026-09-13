database -open -shm -into ./sim/waves_gate.shm waves -default
probe -create -database waves counter_gate_tb -depth all
run
exit
