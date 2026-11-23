`timescale 1ns / 1ps

module digital_lock_tb;

    reg        clk;
    reg        rst;
    reg        enter;
    reg [3:0]  pass_in;
    wire       unlock;
    wire       deny;
    wire       locked;
    wire [1:0] attempt_cnt;
    wire [2:0] state;

    reg        deny_seen;
    integer    errors;

    digital_lock dut (
        .clk(clk),
        .rst(rst),
        .enter(enter),
        .pass_in(pass_in),
        .unlock(unlock),
        .deny(deny),
        .locked(locked),
        .attempt_cnt(attempt_cnt),
        .state(state)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (rst)
            deny_seen <= 1'b0;
        else if (deny)
            deny_seen <= 1'b1;
    end

    task try_password;
        input [3:0] p;
        begin
            deny_seen = 1'b0;
            pass_in   = p;
            enter     = 1'b1;
            #10;
            enter     = 1'b0;
            #50;
        end
    endtask

    task check;
        input cond;
        input [1023:0] name;
        begin
            if (cond)
                $display("PASS: %0s", name);
            else begin
                $display("FAIL: %0s", name);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors    = 0;
        deny_seen = 1'b0;
        clk       = 1'b0;
        rst       = 1'b1;
        enter     = 1'b0;
        pass_in   = 4'b0000;
        #20;
        rst = 1'b0;
        #10;

        try_password(4'b1010);
        check(unlock == 1'b1, "correct password 1010 unlocks");
        check(state == 3'd3, "state is UNLOCKED after correct password");
        check(attempt_cnt == 2'd0, "attempt counter is 0 after correct password");

        rst = 1'b1;
        #20;
        rst = 1'b0;
        #10;
        check(unlock == 1'b0 && locked == 1'b0 && attempt_cnt == 2'd0 && state == 3'd0, "reset clears unlock, locked, counter and state");

        try_password(4'b0000);
        check(deny_seen == 1'b1, "wrong password 0000 raises deny pulse");
        check(attempt_cnt == 2'd1 && state == 3'd0, "counter is 1 after first wrong password");

        try_password(4'b1111);
        check(deny_seen == 1'b1, "wrong password 1111 raises deny pulse");
        check(attempt_cnt == 2'd2 && state == 3'd0, "counter is 2 after second wrong password");

        try_password(4'b0011);
        check(deny_seen == 1'b1, "wrong password 0011 raises deny pulse");
        check(locked == 1'b1 && attempt_cnt == 2'd3 && state == 3'd4, "third wrong password locks the system");

        try_password(4'b1010);
        check(unlock == 1'b0 && locked == 1'b1, "correct password does not unlock while locked");

        rst = 1'b1;
        #20;
        rst = 1'b0;
        #10;
        check(locked == 1'b0 && attempt_cnt == 2'd0, "reset clears lockout");

        try_password(4'b0000);
        check(attempt_cnt == 2'd1, "counter is 1 after wrong password post-reset");

        try_password(4'b1010);
        check(unlock == 1'b1 && attempt_cnt == 2'd0, "correct password unlocks and clears counter");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", errors);
        $finish;
    end

endmodule
