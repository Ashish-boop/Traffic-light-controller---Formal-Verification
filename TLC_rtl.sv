
module traffic_light_ctrl_4way (
    input  logic clk,
    input  logic rst_n,
    input  logic local_emergency,  // Local emergency → NS green
    input  logic global_emergency, // Global emergency → all red

    output logic north_red,
    output logic north_yellow,
    output logic north_green,

    output logic south_red,
    output logic south_yellow,
    output logic south_green,

    output logic east_red,
    output logic east_yellow,
    output logic east_green,

    output logic west_red,
    output logic west_yellow,
    output logic west_green
);

    parameter int GREEN_TIME  = 5;
    parameter int YELLOW_TIME = 2;

    typedef enum logic [1:0] {
        NS_GREEN  = 2'b00,
        NS_YELLOW = 2'b01,
        EW_GREEN  = 2'b10,
        EW_YELLOW = 2'b11
    } state_e;

    state_e state, next_state;
    int timer;

    // Registered outputs
    logic r_north_red, r_north_yellow, r_north_green;
    logic r_south_red, r_south_yellow, r_south_green;
    logic r_east_red,  r_east_yellow, r_east_green;
    logic r_west_red,  r_west_yellow, r_west_green;

    // FSM: state and timer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= NS_GREEN;
            timer <= 0;
        end
        else if (global_emergency) begin
            state <= NS_GREEN;
            timer <= 0;
        end
        else begin
            state <= next_state;
            if (state != next_state)
                timer <= 0;
            else
                timer <= timer + 1;
        end
    end

    // Next state logic
    always_comb begin
        next_state = state;
        if (local_emergency)
            next_state = NS_GREEN;
        else begin
            case (state)

  NS_GREEN: begin
    if (timer >= GREEN_TIME)
      next_state = NS_YELLOW;
    else
      next_state = NS_GREEN;
  end

  NS_YELLOW: begin
    if (timer >= YELLOW_TIME)
      next_state = EW_GREEN;
    else
      next_state = NS_YELLOW;
  end

  EW_GREEN: begin
    if (timer >= GREEN_TIME)
      next_state = EW_YELLOW;
    else
      next_state = EW_GREEN;
  end

  EW_YELLOW: begin
    if (timer >= YELLOW_TIME)
      next_state = NS_GREEN;
    else
      next_state = EW_YELLOW;
  end

endcase
end
    end

    // Output logic: registered
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // All red at reset
            r_north_red <= 1; r_north_yellow <= 0; r_north_green <= 0;
            r_south_red <= 1; r_south_yellow <= 0; r_south_green <= 0;
            r_east_red  <= 1; r_east_yellow  <= 0; r_east_green  <= 0;
            r_west_red  <= 1; r_west_yellow  <= 0; r_west_green  <= 0;
        end
        else if (global_emergency) begin
            // All red
            r_north_red <= 1; r_north_yellow <= 0; r_north_green <= 0;
            r_south_red <= 1; r_south_yellow <= 0; r_south_green <= 0;
            r_east_red  <= 1; r_east_yellow  <= 0; r_east_green  <= 0;
            r_west_red  <= 1; r_west_yellow  <= 0; r_west_green  <= 0;
        end
        else if (local_emergency) begin
            // NS green, EW red
            r_north_green <= 1; r_north_red <= 0; r_north_yellow <= 0;
            r_south_green <= 1; r_south_red <= 0; r_south_yellow <= 0;
            r_east_red  <= 1; r_east_green <= 0; r_east_yellow <= 0;
            r_west_red  <= 1; r_west_green <= 0; r_west_yellow <= 0;
        end
        else begin
            // Normal FSM
            case (state)
                NS_GREEN: begin
                    r_north_green <= 1; r_north_red <= 0; r_north_yellow <= 0;
                    r_south_green <= 1; r_south_red <= 0; r_south_yellow <= 0;
                    r_east_red  <= 1; r_east_green <= 0; r_east_yellow <= 0;
                    r_west_red  <= 1; r_west_green <= 0; r_west_yellow <= 0;
                end
                NS_YELLOW: begin
                    r_north_yellow <= 1; r_north_red <= 0; r_north_green <= 0;
                    r_south_yellow <= 1; r_south_red <= 0; r_south_green <= 0;
                    r_east_red  <= 1; r_east_green <= 0; r_east_yellow <= 0;
                    r_west_red  <= 1; r_west_green <= 0; r_west_yellow <= 0;
                end
                EW_GREEN: begin
                    r_east_green <= 1; r_east_red <= 0; r_east_yellow <= 0;
                    r_west_green <= 1; r_west_red <= 0; r_west_yellow <= 0;
                    r_north_red <= 1; r_north_green <= 0; r_north_yellow <= 0;
                    r_south_red <= 1; r_south_green <= 0; r_south_yellow <= 0;
                end
                EW_YELLOW: begin
                    r_east_yellow <= 1; r_east_red <= 0; r_east_green <= 0;
                    r_west_yellow <= 1; r_west_red <= 0; r_west_green <= 0;
                    r_north_red <= 1; r_north_green <= 0; r_north_yellow <= 0;
                    r_south_red <= 1; r_south_green <= 0; r_south_yellow <= 0;
                end
            endcase
        end
    end

    // Assign registered outputs to ports
    assign north_red    = r_north_red;
    assign north_yellow = r_north_yellow;
    assign north_green  = r_north_green;
    assign south_red    = r_south_red;
    assign south_yellow = r_south_yellow;
    assign south_green  = r_south_green;
    assign east_red     = r_east_red;
    assign east_yellow  = r_east_yellow;
    assign east_green   = r_east_green;
    assign west_red     = r_west_red;
    assign west_yellow  = r_west_yellow;
    assign west_green   = r_west_green;

endmodule
~
~
