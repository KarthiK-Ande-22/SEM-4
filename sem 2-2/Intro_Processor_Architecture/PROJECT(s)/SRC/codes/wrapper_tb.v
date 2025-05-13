`include "wrapper.v"
// `timescale 1ns / 1ps

module tb_wrapper;

    // Inputs
    reg [63:0] a;
    reg [63:0] b;
    reg [3:0] op;

    // Output
    wire [63:0] result;

    // Signed versions of inputs and outputs
    wire signed [63:0] signed_a;
    wire signed [63:0] signed_b;
    wire signed [63:0] signed_result;

    // Assign signed versions
    assign signed_a = a;
    assign signed_b = b;
    assign signed_result = result;

    // Instantiate the wrapper module
    wrapper uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    // Monitor changes and display results
    initial begin
        $monitor("Time = %t | op = %d | signed_a = %d | signed_b = %d | signed_result = %d", 
                 $time, op, signed_a, signed_b, signed_result);
    end

    // Dump signals for GTKWave
    initial begin
        $dumpfile("wrapper_tb.vcd"); // VCD file for GTKWave
        $dumpvars(0, tb_wrapper);   // Dump all signals in the scope of tb_wrapper
    end

    // Apply test cases
    initial begin
        // Test ADD (op = 0000)
        op = 4'b0000;
        a = 10; b = 20; #1;  // Normal addition
        // a = 0; b = 0; #1;    // Zero addition
        a = 64'h7FFFFFFFFFFFFFFF; b = 1; #1;  // Overflow case
        a = -10; b = 15; #1; // Mixed sign addition
        // a = -64; b = 64'h7FFFFFFFFFFFFFFF; #1; // Max positive and negative
        // a = 64'hFFFFFFFFFFFFFFFF; b = 1; #1; // Carry test
        // a = -1; b = -1; #1;  // Negative overlap

        // Test SUB (op = 0001)
        op = 4'b0001;
        a = 30; b = 20; #1;  // Normal subtraction
        a = 10; b = 20; #1;  // Negative result
        a = 64'h7FFFFFFFFFFFFFFF; b = -1; #1; // Large pos - small neg
        // a = 0; b = 0; #1;    // Zero subtraction
        a = 64'h8000000000000000; b = 1; #1; // Minimum signed value
        a = -15; b = 5; #1;  // Negative - positive
        // a = 12345; b = 12345; #1; // Same values

        // Test AND (op = 0010)
        op = 4'b0010;
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000000; #1; // All 1s and 0s
        a = 64'hAAAAAAAAAAAAAAAA; b = 64'h5555555555555555; #1; // Alternating bits
        // a = 64'h0F0F0F0F0F0F0F0F; b = 64'hF0F0F0F0F0F0F0F0; #1; // Overlapping patterns
        // a = 0; b = 64'hFFFFFFFFFFFFFFFF; #1; // Zero and all 1s
        // a = 1; b = 1; #1; // Single bit AND
        // a = -1; b = -1; #1; // Negative numbers
        // a = 64'h1234567890ABCDEF; b = 64'hFEDCBA0987654321; #1; // Random values

        // Test OR (op = 0011)
        op = 4'b0011;
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000000; #1; // All 1s and 0s
        a = 64'hAAAAAAAAAAAAAAAA; b = 64'h5555555555555555; #1; // Alternating bits
        // a = 64'h0F0F0F0F0F0F0F0F; b = 64'hF0F0F0F0F0F0F0F0; #1; // Overlapping patterns
        // a = 0; b = 64'hFFFFFFFFFFFFFFFF; #1; // Zero and all 1s
        // a = 1; b = 1; #1; // Single bit OR
        // a = -1; b = -1; #1; // Negative numbers
        // a = 64'h1234567890ABCDEF; b = 64'hFEDCBA0987654321; #1; // Random values

        // Test XOR (op = 0100)
        op = 4'b0100;
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000000; #1; // All 1s and 0s
        // a = 64'hAAAAAAAAAAAAAAAA; b = 64'h5555555555555555; #1; // Alternating bits
        // a = 64'h0F0F0F0F0F0F0F0F; b = 64'hF0F0F0F0F0F0F0F0; #1; // Overlapping patterns
        // a = 0; b = 64'hFFFFFFFFFFFFFFFF; #1; // Zero and all 1s
        // a = 1; b = 1; #1; // Single bit XOR
        // a = -1; b = -1; #1; // Negative numbers
        // a = 64'h1234567890ABCDEF; b = 64'hFEDCBA0987654321; #1; // Random values

        // Test SLR (op = 0101)
        op = 4'b0101;
        a = 64'h8000000000000000; b = 1; #1; // Shift 1 bit
        a = 64'hFFFFFFFFFFFFFFFF; b = 4; #1; // Shift multiple bits
        a = 64'h1234567890ABCDEF; b = 8; #1; // Random value
        // a = 0; b = 16; #1; // Shift zero
        // a = 64'h8000000000000000; b = 63; #1; // Shift all bits
        // a = 64'h7FFFFFFFFFFFFFFF; b = 1; #1; // Shift positive number
        // a = -1; b = 5; #1; // Shift negative number

        // Test SLL (op = 0110)
        op = 4'b0110;
        a = 64'h1; b = 1; #1; // Shift left by 1
        a = 64'hFFFFFFFFFFFFFFFF; b = 4; #1; // Shift all 1s
        // a = 64'h1234567890ABCDEF; b = 8; #1; // Random value
        // a = 0; b = 16; #1; // Shift zero
        // a = 64'h1; b = 63; #1; // Shift maximum bits
        // a = 64'h7FFFFFFFFFFFFFFF; b = 1; #1; // Positive number
        // a = -1; b = 5; #1; // Shift negative number

        // Test SRA (op = 0111)
        op = 4'b0111;
        a = 64'h8000000000000000; b = 1; #1; // Shift 1 bit
        a = 64'hFFFFFFFFFFFFFFFF; b = 4; #1; // All 1s
        // a = 64'h1234567890ABCDEF; b = 8; #1; // Random value
        // a = 0; b = 16; #1; // Shift zero
        // a = 64'h8000000000000000; b = 63; #1; // Shift all bits
        // a = 64'h7FFFFFFFFFFFFFFF; b = 1; #1; // Positive number
        // a = -1; b = 5; #1; // Shift negative number

        // Test SLT (op = 1000)
        op = 4'b1000;
        a = 10; b = 20; #1; // a < b
        a = 20; b = 10; #1; // a > b
        // a = -10; b = -20; #1; // Negative numbers
        // a = -10; b = 10; #1; // Mixed signs
        // a = 10; b = 10; #1; // Equal numbers
        // a = 0; b = -10; #1; // Zero and negative
        // a = 0; b = 10; #1; // Zero and positive

        // Test SLTU (op = 1001)
        op = 4'b1001;
        a = 10; b = 20; #1; // a < b
        a = 20; b = 10; #1; // a > b
        a = 0; b = -1; #1; // Equal numbers
        // a = 64'hFFFFFFFFFFFFFFFF; b = 0; #1; // Maximum unsigned
        // a = 64'h7FFFFFFFFFFFFFFF; b = 64'h8000000000000000; #1; // Edge case
        // a = 64'h1234567890ABCDEF; b = 64'hFEDCBA0987654321; #1; // Random values
        // a = 64'h1; b = 64'hFFFFFFFFFFFFFFFF; #1; // Small vs large unsigned

        // Finish the simulation
        $finish;
    end

endmodule



// `include "wrapper.v"
// `timescale 1ns / 1ps

// module tb_wrapper;

//     // Inputs
//     reg [63:0] a;
//     reg [63:0] b;
//     reg [3:0] op;

//     // Output
//     wire [63:0] result;

//     // Instantiate the wrapper module
//     wrapper uut (
//         .a(a),
//         .b(b),
//         .op(op),
//         .result(result)
//     );

//     // Monitor changes and display results
//     initial begin
//         $monitor("Time = %t, op = %b, a = %d, b = %d, result = %d", $time, op, a, b, result);
//     end
// //     initial begin
// //     $monitor("Time = %t, op = %b, a = %0d, b = %0d, result = %0d", 
// //              $time, op, $signed(a), $signed(b), $signed(result));
// // end
// // initial begin
// //     // Display the output at each simulation step
// //     $display("Time = %0t | op = %b | a = %0d | b = %0d | result = %0d", 
// //              $time, op, $signed(a), $signed(b), $signed(result));
// // end


//     // Apply test cases
//     initial begin
//         // Test ADD (op = 0000)
//         op = 4'b0000;
//         a = 10; b = 20; #1;  // Normal addition
//         a = 0; b = 0; #1;    // Zero addition
//         a = 64'h7FFFFFFFFFFFFFFF; b = 1; #1;  // Overflow case
//         a = -10; b = 15; #1;  // Mixed sign addition
//         a = -64; b = 64'h7FFFFFFFFFFFFFFF; #1;
//         a = 64'hFFFFFFFFFFFFFFFF; b = 1; #1;  // Carry test
//         a = -1; b = -1; #1;  // Negative overlap

//         // Test SUB (op = 0001)
//         op = 4'b0001;
//         a = 30; b = 20; #1;  // Normal subtraction
//         a = 10; b = 20; #1;  // Negative result
//         a = 64'h7FFFFFFFFFFFFFFF; b = -1; #1; // Large pos - small neg
//         a = 0; b = 0; #1;    // Zero subtraction
//         a = 64'h8000000000000000; b = 1; #1;  // Minimum signed value
//         a = -15; b = 5; #1;   // Negative - positive
//         a = 12345; b = 12345; #1;  // Same values

//         // Test AND (op = 0010)
//         op = 4'b0010;
//         a = 64'hFFFFFFFFFFFFFFFF; b = 64'hFFFFFFFFFFFFFFFF; #1;  // All bits set
//         a = 0; b = 0; #1;    // All zeros
//         a = 64'hAAAAAAAAAAAAAAAA; b = 64'h5555555555555555; #1;  // Alternating bits
//         a = 64'hF0F0F0F0F0F0F0F0; b = 64'h0F0F0F0F0F0F0F0F; #1;  // Mixed patterns
//         a = 64'hFFFFFFFFFFFFFFFF; b = 0; #1;  // One operand zero
//         a = 64'h8000000000000000; b = 64'h8000000000000000; #1;  // Single bit match
//         a = 64'h1111111111111111; b = 64'h2222222222222222; #1;  // Partial bits set

//         // Test OR (op = 0011)
//         op = 4'b0011;
//         a = 64'hFFFFFFFFFFFFFFFF; b = 64'hFFFFFFFFFFFFFFFF; #1;  // All bits set
//         a = 0; b = 0; #1;    // All zeros
//         a = 64'hAAAAAAAAAAAAAAAA; b = 64'h5555555555555555; #1;  // Complementary patterns
//         a = 64'hF0F0F0F0F0F0F0F0; b = 64'h0F0F0F0F0F0F0F0F; #1;  // Mixed patterns
//         a = 64'hFFFFFFFFFFFFFFFF; b = 0; #1;  // One operand zero
//         a = 0; b = 64'h8000000000000000; #1;  // Single bit set
//         a = 123456789; b = 987654321; #1;  // Different numbers

//         // Test XOR (op = 0100)
//         op = 4'b0100;
//         a = 64'hFFFFFFFFFFFFFFFF; b = 64'hFFFFFFFFFFFFFFFF; #1;  // All bits set
//         a = 0; b = 0; #1;    // All zeros
//         a = 64'hAAAAAAAAAAAAAAAA; b = 64'h5555555555555555; #1;  // Complementary patterns
//         a = 64'hF0F0F0F0F0F0F0F0; b = 64'h0F0F0F0F0F0F0F0F; #1;  // Mixed patterns
//         a = 64'hFFFFFFFFFFFFFFFF; b = 0; #1;  // One operand zero
//         a = 64'h8000000000000000; b = 64'h4000000000000000; #1;  // Single bit set
//         a = 5; b = 10; #1;   // Two small numbers

//         // Test SLR (op = 0101)
//         op = 4'b0101;
//         a = 0; b = 4; #1;    // Shift zero
//         a = 64'h8000000000000000; b = 63; #1;  // Large number shift
//         a = 64'h1; b = 1; #1;  // Single bit shift
//         a = 64'h1234567890ABCDEF; b = 0; #1;  // No shift
//         a = 64'hFFFFFFFFFFFFFFFF; b = 63; #1;  // Maximum shift
//         a = 64'hFFFFFFFFFFFFFFFF; b = -1; #1;  // Negative shift (invalid)
//         a = 64'h8000000000000000; b = 32; #1;  // Shift by midpoint

//         // Test SLL (op = 0110)
//         op = 4'b0110;
//         a = 0; b = 4; #1;    // Shift zero
//         a = 64'h1; b = 63; #1;  // Large number shift
//         a = 64'h1; b = 1; #1;  // Single bit shift
//         a = 64'h1234567890ABCDEF; b = 0; #1;  // No shift
//         a = 64'h1; b = 63; #1;  // Maximum shift
//         a = 64'hFFFFFFFFFFFFFFFF; b = 63; #1;  // Overflow scenario
//         a = 64'h1234; b = 16; #1;  // Mid shift

//         // Test SRA (op = 0111)
//         op = 4'b0111;
//         a = 0; b = 4; #1;    // Shift zero
//         a = 64'h8000000000000000; b = 63; #1;  // Large negative number
//         a = -1; b = 1; #1;   // Single bit shift
//         a = 64'h1234567890ABCDEF; b = 0; #1;  // No shift
//         a = 64'h8000000000000000; b = 63; #1;  // Maximum shift
//         a = -64; b = 2; #1;  // Sign extension test
//         a = 64; b = 3; #1;   // Positive number shift

//         // Test SLT (op = 1000)
//         op = 4'b1000;
//         a = 5; b = 5; #1;    // Equal numbers
//         a = 5; b = 10; #1;   // Positive less than positive
//         a = -10; b = 5; #1;  // Negative less than positive
//         a = 10; b = -10; #1;  // Positive greater than negative
//         a = 64'h7FFFFFFFFFFFFFFF; b = 64'h8000000000000000; #1;  // Large positive less
//         a = -10; b = -5; #1;  // Negative values
//         a = 64'h8000000000000000; b = 64'h7FFFFFFFFFFFFFFF; #1;  // Min and Max

//         // Test SLTU (op = 1001)
//         op = 4'b1001;
//         a = 5; b = 5; #1;    // Equal numbers
//         a = 5; b = 10; #1;   // Small unsigned less than large unsigned
//         a = 0; b = 1; #1;    // Zero less than non-zero
//         a = 64'hFFFFFFFFFFFFFFFF; b = 0; #1;  // Unsigned overflow comparison
//         a = 64'hFFFFFFFFFFFFFFFF; b = 64'h7FFFFFFFFFFFFFFF; #1;  // Large unsigned greater
//         a = 64'h7FFFFFFFFFFFFFFF; b = 64'h8000000000000000; #1;  // Boundary case
//         a = 0; b = 0; #1;    // Zero comparison

//         // Finish the simulation
//         $finish;
//     end

// endmodule


// `include "wrapper.v"
// `timescale 1ns / 1ps

// module tb_wrapper;

//     // Inputs
//     reg [63:0] a;
//     reg [63:0] b;
//     reg [3:0] op;

//     // Output
//     wire [63:0] result;

//     wrapper uut (
//         .a(a),
//         .b(b),
//         .op(op),
//         .result(result)
//     );

//     initial begin

//         $display("Time\t\tA\t\t\tB\t\t\tOP\t\tResult");
//         $monitor("%0t\t%d\t%d\t%d\t%d", $time, a, b, op, result);
//     end

//     initial begin

//         a = 64'd0;
//         b = 64'd0;
//         op = 4'b0000;

//         #5;

//         // Test case 1: ADD operation (op = 0000)
//         a = 64'h7FFFFFFFFFFFFFFF;  // Large positive number
//         b = 64'h1;                  // Small positive number
//         op = 4'b0000;               // ADD operation
//         #1;

//         // Test case 2: SUB operation (op = 0001)
//         a = 64'h8000000000000000;  // Minimum 64-bit signed value (negative)
//         b = 64'h1;                  // Small positive number
//         op = 4'b0001;               // SUB operation
//         #1;

//         // Test case 3: AND operation (op = 0010)
//         a = 64'hFFFFFFFFFFFFFFFF;  // All 1s
//         b = 64'h0000000000000000;  // All 0s
//         op = 4'b0010;               // AND operation
//         #1;

//         // Test case 4: OR operation (op = 0011)
//         a = 64'h5555555555555555;  // Pattern 0101
//         b = 64'hAAAAAAAAAAAAAAAA;  // Pattern 1010
//         op = 4'b0011;               // OR operation
//         #1;

//         // Test case 5: XOR operation (op = 0100)
//         a = 64'hFFFFFFFFFFFFFFFF;  // All 1s
//         b = 64'hFFFFFFFFFFFFFFFF;  // All 1s
//         op = 4'b0100;               // XOR operation
//         #1;

//         // Test case 6: SLR operation (op = 0101)
//         a = 64'h8000000000000000;  // Large number, most significant bit set
//         b = 64'h06;                 // Shift by 6 bits
//         op = 4'b0101;               // SLR operation
//         #1;

//         // Test case 7: SLL operation (op = 0110)
//         a = 64'h0000000000000001;  // Small number (1)
//         b = 64'h3F;                 // Shift by 63 bits (maximum shift)
//         op = 4'b0110;               // SLL operation
//         #1;

//         // Test case 8: SRA operation (op = 0111)
//         a = 64'h8000000000000000;  // Large negative number (most significant bit set)
//         b = 64'h06;                 // Shift by 6 bits
//         op = 4'b0111;               // SRA operation
//         #1;

//         // Test case 9: SLT operation (op = 1000)
//         a = 64'h7FFFFFFFFFFFFFFF;  // Maximum positive value
//         b = 64'h8000000000000000;  // Minimum negative value
//         op = 4'b1000;               // SLT operation
//         #1;

//         // Test case 10: SLTU operation (op = 1001)
//         a = 64'h7FFFFFFFFFFFFFFF;  // Maximum unsigned value
//         b = 64'hFFFFFFFFFFFFFFFF;  // Just below maximum unsigned value
//         op = 4'b1001;               // SLTU operation
//         #1;

//         // Test case 11: SLT operation (op = 1000) with equal numbers
//         a = 64'h1234567890ABCDEF;
//         b = 64'h1234567890ABCDEF;  // Equal numbers
//         op = 4'b1000;               // SLT operation
//         #1;

//         // Test case 12: SLTU operation (op = 1001) with equal numbers
//         a = 64'h1234567890ABCDEF;
//         b = 64'h1234567890ABCDEF;  // Equal numbers
//         op = 4'b1001;               // SLTU operation
//         #1;

//         // Finish the simulation
//         $finish;
//     end

// endmodule
