proc prop {obj pin iostandard} {
    # set package pin
    set_property PACKAGE_PIN $pin $obj
    
    # set io standard
    set_property IOSTANDARD $iostandard $obj
}

proc setup {port pin iostandard} {
    set obj [get_ports $port]
    
    # set property 
    prop $obj $pin $iostandard
}


# -- clock

set clk [get_ports sysclk]

create_clock -add -name sys_clk_pin -period 10.0 -waveform {0 5} $clk

prop $clk W5 LVCMOS33


# -- input

setup reset T18 LVCMOS33


# -- output

# 7 segments

foreach {i pin} {7 V7 6 W7 5 W6 4 U8 3 V8 2 U5 1 V5 0 U7} {
  setup seg\[$i\] $pin LVCMOS33
}

foreach {i pin} {3 W4 2 V4 1 U4 0 U2} {
    setup anode\[$i\] $pin LVCMOS33
}
