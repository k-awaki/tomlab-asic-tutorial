database -open -shm -into sim/waves_layout.shm waves -default
probe -create -database waves counter_layout_tb -depth all
run
exit


