module traffic_light_ctrl_4way_sva();

`define clk traffic_light_ctrl_4way.clk
`define rst_n traffic_light_ctrl_4way.rst_n
`define north_red traffic_light_ctrl_4way.north_red
`define north_yellow traffic_light_ctrl_4way.north_yellow
`define north_green traffic_light_ctrl_4way.north_green
`define south_red traffic_light_ctrl_4way.south_red
`define south_yellow traffic_light_ctrl_4way.south_yellow
`define south_green traffic_light_ctrl_4way.south_green
`define east_red traffic_light_ctrl_4way.east_red
`define east_yellow traffic_light_ctrl_4way.east_yellow
`define east_green traffic_light_ctrl_4way.east_green
`define west_red traffic_light_ctrl_4way.west_red
`define west_yellow traffic_light_ctrl_4way.west_yellow
`define west_green traffic_light_ctrl_4way.west_green
`define local_emergency traffic_light_ctrl_4way.local_emergency
`define global_emergency traffic_light_ctrl_4way.global_emergency
`define state traffic_light_ctrl_4way.state
`define next_state traffic_light_ctrl_4way.next_state
`define timer traffic_light_ctrl_4way.timer

       // NO CONFLICTING GREENS (NS vs EW) -
       property no_conflict(a, b);
        @(posedge `clk) disable iff (!`rst_n)
            !(a && b);// Two signals must mot be high at the same time
       endproperty


     // For example: // South and West must not be green together call no_conflict property for south and west green
      a_conflict1 : assert property(no_conflict(`south_green, `west_green));

     // North and East must not be green together
      a_conflict2 : assert property(no_conflict(`north_green, `east_green));

     // North and West must not be green together
      a_conflict3 : assert property(no_conflict(`north_green, `west_green));

     // South and East must not be green together
      a_conflict4 : assert property(no_conflict(`south_green, `east_green));


       // MUTUAL EXCLUSIVITY PER DIRECTION
      property direction_exclusive(r, y, g);
        @(posedge `clk) disable iff (!`rst_n)
            !( (r && y) || (r && g) || (y && g) );//No two of (red, yellow, green) can be ON at the same time
      endproperty


    // North: Red --> Yellow --> Green ( (No two of red, yellow, green can be ON at the same time in North)
        a_north_excl : assert property(direction_exclusive(`north_red, `north_yellow, `north_green));

    //South: Red --> Yellow --> Green (No two of red, yellow, green can be ON at the same time in South)
        a_south_excl  : assert property (direction_exclusive(`south_red, `south_yellow, `south_green));

    //East: Red --> Yellow --> Green  (No two of red, yellow, green can be ON at the same time in East)
        a_east_excl  : assert property (direction_exclusive(`east_red, `east_yellow, `east_green));

    //West: Red --> Yellow --> Green  (No two of red, yellow, green can be ON at the same time in West)
        a_west_excl  : assert property (direction_exclusive(`west_red, `west_yellow, `west_green));


     // YELLOW → RED transition - after yellow turns OFF, the system eventually transitions to red, enforcing correct sequencing in the traffic light controller
      property yellow_to_red(y, r);
      @(posedge `clk) disable iff (!`rst_n)
        $fell(y) |-> ##[1:$] r;//
      endproperty

     // North Direction  - After Yellow  turns OFF, transition to Red
     a_y2r_north : assert property(yellow_to_red(`north_yellow, `north_red));

     // South Direction - After Yellow  turns OFF, transition to Red
     a_y2r_south : assert property(yellow_to_red(`south_yellow, `south_red));


     // East Direction - After Yellow  turns OFF, transition to Red
     a_y2r_east  : assert property(yellow_to_red(`east_yellow, `east_red));


     // west Direction - After Yellow  turns OFF, transition to Red
     a_y2r_west  : assert property(yellow_to_red(`west_yellow, `west_red));


     // GLOBAL EMERGENCY → ALL RED : Ambulance / fire truck detected- all signals go red
        property emergency_all_red;
        @(posedge `clk) disable iff (!`rst_n)
           //if global_emergency signal is detected then all the direction should go to red.
                $rose(`global_emergency) |=> (`east_red && `south_red && `north_red && `west_red);
        endproperty

        a_emg_all_red : assert property(emergency_all_red);

      // LOCAL EMERGENCY → NS GREEN, EW RED - A local emergency is a direction-specific or partial-system critical condition (like ambulance, accident, or road blockage) that force       s only part of the traffic system to change state, while the rest continues operating normally.

       property local_emergency_ns_green;
        @(posedge `clk) disable iff (!`rst_n)
                $rose(`local_emergency) && (!`global_emergency) |-> ##1 (`north_green && !`north_red && `south_green && !`south_red && `east_red && `west_red);

     // Hint : Local emergency with No global emergency, east and west should be red, north and south should be green

       endproperty

       a_local_emg_ns : assert property(local_emergency_ns_green);

        // timer
        property timer_check;
                @(posedge `clk) disable iff(!`rst_n)
                        ($past(`state) != `state) |-> (`timer == 0);
        endproperty

        a_timer : assert property(timer_check);

        cover property (@(posedge `clk) disable iff(!`rst_n)
                        `next_state == '0);

endmodule

// Bind the SVA to RTL
bind traffic_light_ctrl_4way traffic_light_ctrl_4way_sva sva_inst(.*);


