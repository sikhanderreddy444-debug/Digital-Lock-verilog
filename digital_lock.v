module digital_lock (
    input  wire       clk,
    input  wire       rst,
    input  wire       enter,
    input  wire [3:0] pass_in,
    output reg        unlock,
    output reg        deny,
    output reg        locked,
    output reg [1:0]  attempt_cnt,
    output reg [2:0]  state
);

    localparam [3:0] PASSWORD = 4'b1010;

    localparam [2:0] IDLE     = 3'd0,
                     ENTRY    = 3'd1,
                     CHECK    = 3'd2,
                     UNLOCKED = 3'd3,
                     ALARM    = 3'd4;

    reg [3:0] pass_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            pass_reg    <= 4'b0000;
            unlock      <= 1'b0;
            deny        <= 1'b0;
            locked      <= 1'b0;
            attempt_cnt <= 2'd0;
        end else begin
            deny <= 1'b0;
            case (state)
                IDLE: begin
                    unlock <= 1'b0;
                    if (enter) begin
                        pass_reg <= pass_in;
                        state    <= ENTRY;
                    end
                end
                ENTRY: begin
                    state <= CHECK;
                end
                CHECK: begin
                    if (pass_reg == PASSWORD) begin
                        unlock      <= 1'b1;
                        attempt_cnt <= 2'd0;
                        state       <= UNLOCKED;
                    end else begin
                        deny <= 1'b1;
                        if (attempt_cnt == 2'd2) begin
                            attempt_cnt <= 2'd3;
                            locked      <= 1'b1;
                            state       <= ALARM;
                        end else begin
                            attempt_cnt <= attempt_cnt + 1'b1;
                            state       <= IDLE;
                        end
                    end
                end
                UNLOCKED: begin
                    unlock <= 1'b1;
                end
                ALARM: begin
                    locked <= 1'b1;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
