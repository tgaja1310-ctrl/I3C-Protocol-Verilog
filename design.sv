module i3c_controller (
    input logic clk,
    input logic rst,
    output logic scl,
    output logic sda
);

typedef enum logic [2:0] {
    IDLE,
    START,
    ADDRESS,
    DATA,
    STOP
} state_t;

state_t state;

logic [6:0] address = 7'b1010011;
logic [7:0] data    = 8'b11001100;

integer bit_count;
integer slow_clk;

// Slow down clock (VERY IMPORTANT for waveform visibility)
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        slow_clk <= 0;
        scl <= 1;
    end else begin
        slow_clk <= slow_clk + 1;
        if (slow_clk == 5) begin
            scl <= ~scl;
            slow_clk <= 0;
        end
    end
end

// FSM
always_ff @(posedge scl or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        sda <= 1;
        bit_count <= 0;
    end else begin
        case (state)

            IDLE: begin
                sda <= 1;
                state <= START;
                $display("STATE: IDLE");
            end

            START: begin
                sda <= 0; // START
                bit_count <= 6;
                state <= ADDRESS;
                $display("STATE: START");
            end

            ADDRESS: begin
                sda <= address[bit_count];
                $display("ADDRESS BIT: %b", address[bit_count]);

                if (bit_count == 0) begin
                    bit_count <= 7;
                    state <= DATA;
                end else
                    bit_count <= bit_count - 1;
            end

            DATA: begin
                sda <= data[bit_count];
                $display("DATA BIT: %b", data[bit_count]);

                if (bit_count == 0)
                    state <= STOP;
                else
                    bit_count <= bit_count - 1;
            end

            STOP: begin
                sda <= 1; // STOP
                state <= IDLE;
                $display("STATE: STOP");
            end

        endcase
    end
end

endmodule
