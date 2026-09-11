set _MODEL      ZeroSkipOPU
set FREQ_MHz    100
set DESIGN      top${_MODEL}
set MMMC        mmmc/${_MODEL}/enc_default_freq${FREQ_MHz}.view
set INNOVUS_OUTPUT innovus/${_MODEL}/freq${FREQ_MHz}/outputs
set TEMPUS_REPORT tempus/${_MODEL}/freq${FREQ_MHz}/reports