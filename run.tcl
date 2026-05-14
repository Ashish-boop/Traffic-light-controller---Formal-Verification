clear -all

check_cov -init -type all -model {statement branch expression toggle functional}

#analyze
analyze -sv12 TLC_rtl.sv TLC_assertions.sv

#elaborate
elaborate -top traffic_light_ctrl_4way -create_related_covers {precondition witness} -no_type_properties -mode verilog


#elaborate -top traffic_light_ctrl
#clock clk

#reset rst_n

clock clk
reset !rst_n

# Prove all properties
prove -all -with_ppd -save_ppd -orchestration on

# Measure coverage
check_cov -measure
