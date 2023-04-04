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
    input               clk         ,
    input               rstn        ,

    input               inst_we     ,
    input               data_we     ,
    input               rf_dcp_we   ,
    input               rf_dcp_rd   ,
    input [31:0]        data_in     ,
    input [31:0]        inst_in     ,
    input [31:0]        rf_in       ,
    input [7:0]         data_addr   ,
    input [7:0]         inst_addr   ,
    input [4:0]         rf_addr     , 
    
    output [31:0]       data_out    ,
    output [31:0]       inst_out    ,
    output [31:0]       rf_out      ,

    //数据通路
    output reg [31:0]   md          ,
    output reg [31:0]   y           ,
    output [31:0]       pc          ,
    output [31:0]       npc         ,
    output reg [31:0]   imm         ,
    output reg [31:0]   ir          ,
    output reg [31:0]   a           ,
    output reg [31:0]   b           ,
    output [2:0]        branch      ,
    output              MemRead     ,
    output              MemWrite    ,
    output              MemtoReg    ,
    output [2:0]        ALUOP       ,
    output              ALUSrc1     ,
    output [1:0]        ALUSrc2     ,
    output              RegWrite    

    ,output     [2:0]   zero        ,
    output [2:0]        mode        ,
    output              uors        ,

    output              stop        ,
    output [2:0]        extmode1    ,
    output [2:0]        extmode2    ,
    output              sp_sign     
    );
    // wire [2:0]  extmode1;
    // wire [2:0]  extmode2;
    // wire        sp_sign;

    wire [31:0]         a0;
    wire [31:0]         b0;
    wire [31:0]         imm_0;
    
    reg [31:0]          b_m;
    reg [31:0]          rd;
    reg [31:0]          rd_m;
    reg [31:0]          rd_w;
    reg [31:0]          pc_d;
    reg [31:0]          pc_e;

    wire [4:0]  ra      ;
    wire [4:0]  wa      ;
    wire        rf_we   ;
    wire [31:0] rf_wd   ;
    wire [31:0] wdto_rf ;

    wire [7:0]  dm_a    ;
    wire [31:0] dm_d    ;
    wire        dm_we   ;
    wire [31:0] md_wd   ;
    
    wire [31:0] inst;
    wire [31:0] result;
    wire [31:0] md_read;


    always @(posedge clk) begin
        ir<=inst;
        y<=result;

        if(MemtoReg) md<=md_read;
        else md<=y;

        imm<=imm_0;

        b_m<=b;
        rd<=ir[11:7];
        rd_m<=rd;
        rd_w<=rd_m;
        pc_d<=pc;
        pc_e<=pc_d;
    end

PC_Controller pc_controller(
    .imm     (imm    ),
    .pc_e    (pc_e   ),
    .y       (y      ),
    .zero    (zero   ),
    .branch  (branch ),
    .clk     (clk    ),
    .rstn    (rstn   ),
    .pc      (pc     ),
    .npc     (npc    )
);

ALU alu(
    .a0     (a      ),
    .b0     (b      ),
    .imm    (imm    ),
    .pc     (pc_e   ),
    .ALUSrc1(ALUSrc1),
    .ALUSrc2(ALUSrc2),
    .uors   (uors   ),
    .sp_sign(sp_sign),
    .ALUOP  (ALUOP  ),
    .result (result ),
    .zero   (zero   )
);

Controller controller(
    .funct7     (ir[30]   ),
    .sp_sign    (sp_sign  ),

    .funct3     (ir[14:12]),
    .opcode     (ir[6:0]  ),
    .clk        (clk      ),
    .rstn       (rstn     ),
    .branch_e   (branch   ),
    .MemRead_m  (MemRead  ),
    .MemWrite_m (MemWrite ),
    .MemtoReg_m (MemtoReg ),
    .ALUOP_e    (ALUOP    ),
    .ALUSrc1_e  (ALUSrc1  ),
    .ALUSrc2_e  (ALUSrc2  ),
    .uors_e     (uors     ),
    .RegWrite_m (RegWrite ),
    .extmode1_m (extmode1 ),
    .extmode2_e (extmode2 ),

    .mode       (mode     ),

    .stop       (stop)
);

ImmGen immgen(
    .clk        (clk),
    .inst       (ir),
    .mode       (mode),
    .imm        (imm_0 )
);

inst_mem inst_mem (
  .a(inst_addr[7:0]),        // input wire [7 : 0] a
  .d(inst_in),        // input wire [31 : 0] d
  .dpra(pc[9:2]),  // input wire [7 : 0] dpra
  .clk(clk),    // input wire clk
  .we(inst_we),      // input wire we
  .spo(inst_out),    // output wire [31 : 0] spo
  .dpo(inst)    // output wire [31 : 0] dpo
);

data_mem data_mem (
  .a(dm_a),        // input wire [7 : 0] a
  .d(dm_d),        // input wire [31 : 0] d
  .dpra(data_addr[7:0]),  // input wire [7 : 0] dpra (考虑到需要接着停止的位置读取)
  .clk(clk),    // input wire clk
  .we(dm_we),      // input wire we
  .spo(md_read),    // output wire [31 : 0] spo
  .dpo(data_out)    // output wire [31 : 0] dpo
);

    assign dm_d=data_we?data_in:md_wd;
    assign dm_a=data_we?{data_addr[7:0]}:y[9:2];
    assign dm_we=data_we | MemWrite;

RegisterFile rf(
    .clk           (clk),
    .ra0           (ra),
    .ra1           (ir[24:20]),
    .rd0           (a0),
    .rd1           (b0),
    .wa            (wa),
    .wd            (wdto_rf),
    .we            (rf_we)
);

    always @(posedge clk) begin
        a<=a0;
        b<=b0;
    end
    // assign ra=rf_dcp_rd?rf_addr:ir[19:15];
    // assign rf_out=a;
    // assign wa=rf_dcp_we?rf_addr:ir[11:7];
    // assign wdto_rf=rf_dcp_we?rf_in:rf_wd;
    // assign rf_we=rf_dcp_we | RegWrite;
    assign ra=rf_dcp_rd?rf_addr:ir[19:15];
    assign rf_out=a0;
    assign wa=ir[11:7];
    assign wdto_rf=rf_wd;
    assign wdto_rf=rf_wd;
    assign rf_we=RegWrite;

EXTer exter1(
    .originword (md),
    .mode       (extmode1),
    .extword    (rf_wd)
);

EXTer exter2(
    .originword (b_m),
    .mode       (extmode2),
    .extword    (md_wd)
);
endmodule
