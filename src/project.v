module spi_slave (
    input clk,
    input rst_n,
    input sck,
    input mosi,
    input cs_n,
    output reg miso,
    output reg [7:0] data_out,
    output reg data_ready
);
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    reg sck_q, sck_qq;
    reg cs_n_q, cs_n_qq;
    
    wire sck_rise = sck_q & ~sck_qq;
    wire sck_fall = ~sck_q & sck_qq;
    wire cs_n_active = ~cs_n_q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sck_q <= 0; sck_qq <= 0;
            cs_n_q <= 1; cs_n_qq <= 1;
        end else begin
            sck_q <= sck; sck_qq <= sck_q;
            cs_n_q <= cs_n; cs_n_qq <= cs_n_q;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 0;
            shift_reg <= 0;
            data_out <= 0;
            data_ready <= 0;
        end else if (cs_n_active) begin
            if (sck_rise) begin
                shift_reg <= {shift_reg[6:0], mosi};
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt == 7) begin
                    data_out <= {shift_reg[6:0], mosi};
                    data_ready <= 1;
                end else begin
                    data_ready <= 0;
                end
            end else begin
                data_ready <= 0;
            end
        end else begin
            bit_cnt <= 0;
            data_ready <= 0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            miso <= 0;
        end else if (cs_n_active) begin
            if (sck_fall) begin
                miso <= shift_reg[7];
            end
        end else begin
            miso <= 1'b0;
        end
    end
endmodule
