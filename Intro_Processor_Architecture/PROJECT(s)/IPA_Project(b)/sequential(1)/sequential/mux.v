
module muxx (input wire a,input wire b,input wire sel,output wire y);
    wire not_sel,and_a,and_b;    
    not u1 (not_sel, sel);       
    and u2 (and_a, a, not_sel);  
    and u3 (and_b, b, sel);      
    or  u4 (y, and_a, and_b);    
endmodule


module mux64to1 (
    input wire [63:0] in0,      
    input wire [63:0] in1,      
    input wire sel,            
    output wire [63:0] out    
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_loop
            muxx mux (.a(in0[i]), .b(in1[i]), .sel(sel), .y(out[i]));
        end
    endgenerate

endmodule