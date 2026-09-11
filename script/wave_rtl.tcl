database -open -shm -into sim/waves_rtl.shm waves -default
probe -create -database waves counter_rtl_tb -depth all
run
exit
