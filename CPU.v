`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 21:39:28
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(
    input clk,
    input rstn,

    input inst_we,
    input data_we,
    input rf_dcp_we,
    input rf_dcp_rd,
    input [31:0] data_in,
    input [31:0] inst_in,
    input [31:0] rf_in,
    input [7:0]  data_addr,
    input [7:0]  inst_addr,
    input [4:0]  rf_addr, 
    output [31:0]data_out,
    output [31:0]inst_out,
    output [31:0]rf_out,

    //数据通路
    output reg [31:0] md,
    output reg [31:0] y,
    output [31:0] pc,
    output [31:0] npc,
    output [31:0] imm,
    output reg [31:0] ir,
    output [31:0] a,
    output [31:0] b,
    output [2:0]  branch  ,
    output        MemRead ,
    output        MemWrite,
    output        MemtoReg,
    output [2:0]  ALUOP   ,
    output [1:0]  ALUSrc1 ,
    output [1:0]  ALUSrc2 ,
    output        RegWrite 
    );

    //自加数据通路
    wire [2:0]  zero    ;
    wire        pc_load ;
    wire        ir_load ;
    wire        y_load  ;
    wire        md_load ;
    wire [2:0]  mode    ;
    wire [2:0]  extmode ;
    wire [1:0]  PCSrc   ;
    wire        uors    ;

    wire [4:0]  ra      ;
    wire [4:0]  wa      ;
    wire [31:0] wd      ;
    wire        rf_we   ;
    wire [31:0] rf_wd   ;

    wire [7:0]  dm_a    ;
    wire [31:0] dm_d    ;
    wire        dm_we   ;
    wire [31:0] md_wd   ;
    
    wire [31:0] inst;
    wire [31:0] result;
    wire [31:0] md_read;


    always @(posedge clk) begin
        if(ir_load) begin
            ir<=inst;
        end
        if(y_load) begin
            y<=result;
        end
        if(md_load) begin
            md<=(MemtoReg?md_read:y);
        end
    end

PC_Controller pc_controller(
    .imm     (imm    ),
    .y       (y      ),
    .zero    (zero   ),
    .branch  (branch ),
    .PCSrc   (PCSrc  ),
    .pc_load (pc_load),
    .clk     (clk    ),
    .rstn    (rstn   ),
    .pc      (pc     ),
    .npc     (npc    )
);

ALU alu(
    .a0     (a      ),
    .b0     (b      ),
    .imm    (imm    ),
    .pc     (pc     ),
    .ALUSrc1(ALUSrc1),
    .ALUSrc2(ALUSrc2),
    .uors   (uors   ),
    .sp_sign(ir[30] ),
    .ALUOP  (ALUOP  ),
    .result (result ),
    .zero   (zero   )
);

Controller controller(
    // .funct7     (ir[31:25]),
    .funct3     (ir[14:12]),
    .opcode     (ir[6:0]  ),
    .clk        (clk      ),
    .rstn       (rstn     ),
    .branch     (branch   ),
    .MemRead    (MemRead  ),
    .MemWrite   (MemWrite ),
    .MemtoReg   (MemtoReg ),
    .ALUOP      (ALUOP    ),
    .ALUSrc1    (ALUSrc1  ),
    .ALUSrc2    (ALUSrc2  ),
    .PCSrc      (PCSrc    ),
    .uors       (uors     ),
    .extmode1   (extmode1 ),
    .extmode2   (extmode2 ),

    .RegWrite   (RegWrite ),
    .PCLoad     (pc_load  ),
    .IRLoad     (ir_load  ),
    .YLoad      (y_load   ),
    .MDLoad     (md_load  )
);

ImmGen immgen(
    .clk        (clk),
    .inst       (ir),
    .mode       (mode),
    .imm        (imm )
);

inst_mem inst_mem (
  .a(inst_addr),        // input wire [7 : 0] a
  .d(inst_in),        // input wire [31 : 0] d
  .dpra(pc[7:0]),  // input wire [7 : 0] dpra
  .clk(clk),    // input wire clk
  .we(inst_we),      // input wire we
  .spo(inst_out),    // output wire [31 : 0] spo
  .dpo(inst)    // output wire [31 : 0] dpo
);

data_mem data_mem (
  .a(dm_a),        // input wire [7 : 0] a
  .d(dm_d),        // input wire [31 : 0] d
  .dpra(data_addr),  // input wire [7 : 0] dpra (考虑到需要接着停止的位置读取)
  .clk(clk),    // input wire clk
  .we(dm_we),      // input wire we
  .spo(md_read),    // output wire [31 : 0] spo
  .dpo(data_out)    // output wire [31 : 0] dpo
);

    assign dm_d=data_we?data_in:md_wd;
    assign dm_a=data_we?data_addr:y[7:0];
    assign dm_we=data_we & MemWrite;

RegisterFile rf(
    .clk           (clk),
    .ra0           (ra),
    .ra1           (ir[24:20]),
    .rd0           (a),
    .rd1           (b),
    .wa            (wa),
    .wd            (wd),
    .we            (rf_we)
);

    assign ra=rf_dcp_rd?rf_addr:ir[19:15];
    assign rf_out=a;
    assign wa=rf_dcp_we?rf_addr:ir[11:7];
    assign wd=rf_dcp_we?rf_in:rf_wd;
    assign rf_we=rf_dcp_we & RegWrite;

EXTer exter1(
    .originword (wd),
    .mode       (extmode1),
    .extword    (rf_wd)
);

EXTer exter2(
    .originword (b),
    .mode       (extmode2),
    .extword    (md_wd)
);
endmodule
