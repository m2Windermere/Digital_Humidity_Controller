module humidity_ctrl (
    input  wire       clk,        // 时钟
    input  wire       rst_n,      // 复位
    input  wire [7:0] humidity_in,// 传感器输入的湿度数据 (0-100)
    output reg        fan_on,     // 风扇开�?
    output reg        alarm       // 报警�?
);

    // 定义湿度阈�?
    parameter HIGH_THRESHOLD = 8'd80;
    parameter LOW_THRESHOLD  = 8'd40;

    // 状态定�?
    parameter IDLE  = 2'b00;
    parameter WORK  = 2'b01;
    parameter ALERT = 2'b10;

    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= IDLE;
            fan_on <= 1'b0;
            alarm  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (humidity_in > HIGH_THRESHOLD) begin
                        state  <= WORK;
                        fan_on <= 1'b1;
                    end
                end
                WORK: begin
                    if (humidity_in > 8'd95) begin // 湿度爆表
                        state <= ALERT;
                        alarm <= 1'b1;
                    end else if (humidity_in < LOW_THRESHOLD) begin
                        state  <= IDLE;
                        fan_on <= 1'b0;
                    end
                end
                ALERT: begin
                    if (humidity_in < HIGH_THRESHOLD) begin
                        state <= WORK;
                        alarm <= 1'b0;
                    end
                end
            endcase
        end
    end
endmodule
