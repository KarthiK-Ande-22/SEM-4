module mux2to1 (
    input A,
    input B,
    input S,
    output Y
);
    wire notS, andA, andB;

    not (notS, S);
    and (andA, A, S);
    and (andB, B, notS);
    or (Y, andA, andB);
endmodule