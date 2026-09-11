database -open -shm -into sim/test/waves_layout.shm waves -default
probe -create -database waves MLP_layout_tb -depth all
run
exit


