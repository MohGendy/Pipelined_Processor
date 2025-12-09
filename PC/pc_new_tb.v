module pc_new_tb;
    reg pc_src;
    reg [1:0] pc_in_sel;
    reg [7:0] pc_plus_1;
    reg [7:0] stack_addr;
    reg [7:0] branch_addr;
    reg [7:0] reset_addr;
    reg [7:0] interrupt_addr;
    wire [7:0] pc_new;

    pc_new dut (
        .pc_src(pc_src),
        .pc_in_sel(pc_in_sel),
        .pc_plus_1(pc_plus_1),
        .stack_addr(stack_addr),
        .branch_addr(branch_addr),
        .reset_addr(reset_addr),
        .interrupt_addr(interrupt_addr),
        .pc_new(pc_new)
    );

    initial begin
        // Test case 1
        pc_src = 0; pc_in_sel = 2'b00; pc_plus_1 = 8'h10;
        #10;
        $display("Test 1 - pc_new: %h (Expected: 10)", pc_new);

        // Test case 2
        pc_src = 1; pc_in_sel = 2'b00; interrupt_addr = 8'hFF; 
        #10;
        $display("Test 2 - pc_new: %h (Expected: FF)", pc_new);

        // Test case 3
        pc_src = 1; pc_in_sel = 2'b01; stack_addr = 8'h20; 
        #10;
        $display("Test 3 - pc_new: %h (Expected: 20)", pc_new);

        // Test case 4
        pc_src = 1; pc_in_sel = 2'b10; branch_addr = 8'h30; 
        #10;
        $display("Test 4 - pc_new: %h (Expected: 30)", pc_new);

        // Test case 5
        pc_src = 1; pc_in_sel = 2'b11; reset_addr = 8'h40; 
        #10;
        $display("Test 5 - pc_new: %h (Expected: 40)", pc_new);

        $stop;
    end
endmodule

