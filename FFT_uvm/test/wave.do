onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/clk
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/rst_n
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/valid_in
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/in_r
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/in_i
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/out_r
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/out_i
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/valid_out
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/frame_done
add wave -noupdate -expand -group fft_4096_dif /FFT_top/DUT_interface/out_index

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {0 ps}
