module parity_calc(
    input [7:0] data_in,
    input PAR_TYP,
    input data_valid,
    output reg parity_bit
);

always @(*) begin
    if(PAR_TYP == 0) begin//even parity
            parity_bit = ^data_in; // Calculate parity bit
    end
    else begin//odd parity
            parity_bit = ~^data_in; // Calculate parity bit
    end
end

endmodule