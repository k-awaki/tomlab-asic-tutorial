database -open -shm -into ./sim/test/waves_gate.shm waves -default
probe -create -database waves MLP_core_fastinit_gate_tb -depth all
run
exit
