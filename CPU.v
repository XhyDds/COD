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
    wire  eflush;
    wire  dstall;
    wire  fstall;
    wire  flush;

    wire [31:0]         a0;
    wire [31:0]         b0;
    wire [31:0]         imm_0;
    
    reg [31:0]          b_m;
    reg [31:0]           b_m_0;
    reg [31:0] md_n;

    reg [4:0]          rs1;
    reg [4:0]          rs2;
    reg [4:0]          rd;
    reg [4:0]          rd_m;
    reg [4:0]          rd_w;
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

    wire  RegWrite_m;
    wire [1:0] afwd;
    wire [1:0] bfwd;


    always @(posedge clk) begin
        if(!rstn) begin
            ir<=0;
            y<=0;
            md<=0;
            imm<=0;
            b_m<=0;
            rs1<=0;
            rs2<=0;
            rd <=0;
            rd_m<=0;
            rd_w<=0;
            pc_d<=0;
            pc_e<=0;
            md_n<=0;
        end
        else if(flush) begin    //清除f,d,e段，保留m
            ir<=0;
            y<=0;
            if(MemtoReg) md<=md_read;
            else md<=y;
            md_n<=md;
            imm<=0;
            b_m<=0; //e段结果
            rs1<=0;
            rs2<=0;
            rd <=0;
            rd_m<=0;
            rd_w<=rd_m;
            pc_d<=0;
            pc_e<=0;   
        end
        else if(eflush) begin   //停止f段，清除d段，保留后三段
            ir<=ir;
            y<=result;
            if(MemtoReg) md<=md_read;
            else md<=y;
            md_n<=md;
            imm<=0;
            b_m<=b_m_0;
            rs1<=0;
            rs2<=0;
            rd <=0;
            rd_m<=rd;
            rd_w<=rd_m;
            pc_d<=pc_d;
            pc_e<=0;   //d段
        end
        else begin
            ir<=inst;
            y<=result;

            if(MemtoReg) md<=md_read;
            else md<=y;
            md_n<=md;

            imm<=imm_0;

            rs1<=ir[19:15];
            rs2<=ir[24:20];
            rd<=ir[11:7];

            b_m<=b_m_0;
            rd_m<=rd;
            rd_w<=rd_m;
            pc_d<=pc;
            pc_e<=pc_d;     
        end
    end

    always @(*) begin
        case (bfwd)
            2'b00: b_m_0=b;
            // 2'b00: b_m=b_m_0;
            2'b01: b_m_0=y;
            2'b10: b_m_0=md;
            2'b11: b_m_0=md_n;
        endcase        
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
    .npc     (npc    ),

    .fstall  (fstall ),
    .flush   (flush  ),
    .stop    (stop   )
);

ALU alu(
    .a0     (a      ),
    .b0     (b      ),
    .imm    (imm    ),
    .pc     (pc_e   ),
    .ALUSrc1(ALUSrc1),
    .ALUSrc2(ALUSrc2),
    .afwd   (afwd    ), 
    .bfwd   (bfwd    ), 
    .y      (y       ), 
    .md     (md      ), 
    .uors   (uors   ),
    .sp_sign(sp_sign),
    .ALUOP  (ALUOP  ),
    .result (result ),
    .zero   (zero   ),

    .clk    (clk)
);

Controller controller(
    .eflush     (eflush   ),
    .flush      (flush    ),

    .funct7     (ir[30]   ),
    .sp_sign    (sp_sign  ),

    .funct3     (ir[14:12]),
    .opcode     (ir[6:0]  ),
    .clk        (clk      ),
    .rstn       (rstn     ),
    .branch   (branch   ),
    .MemRead    (MemRead  ),
    .MemWrite_m (MemWrite ),
    .MemtoReg_m (MemtoReg ),
    .ALUOP    (ALUOP    ),
    .ALUSrc1  (ALUSrc1  ),
    .ALUSrc2  (ALUSrc2  ),
    .uors     (uors     ),
    .RegWrite_w (RegWrite ),
    .RegWrite_m (RegWrite_m),
    .extmode1_m (extmode1 ),
    .extmode2 (extmode2 ),

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
        if(!rstn) begin
            a<=0;
            b<=0;
        end
        else if(eflush || flush) begin
            a<=0;
            b<=0;
        end
        else begin
            a<=a0;
            b<=b0;
        end
    end
    // assign ra=rf_dcp_rd?rf_addr:ir[19:15];
    // assign rf_out=a;
    // assign wa=rf_dcp_we?rf_addr:ir[11:7];
    // assign wdto_rf=rf_dcp_we?rf_in:rf_wd;
    // assign rf_we=rf_dcp_we | RegWrite;
    assign ra=rf_dcp_rd?rf_addr:ir[19:15];
    assign rf_out=a0;
    assign wa=rd_w;
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

ForwardingUnit forwardunit(
    .rs1         (rs1         ),
    .rs2         (rs2         ),
    .rd_m        (rd_m        ),
    .rd_w        (rd_w        ),
    .RegWrite_m  (RegWrite_m  ),
    .RegWrite_w  (RegWrite    ),
    .afwd        (afwd        ),
    .bfwd        (bfwd        ),
    .eflush      (eflush      ),

    .clk    (clk)
);

HarzardUnit harzardunit(
    .rs1     (ir[19:15]),
    .rs2     (ir[24:20]),
    .rd      (rd      ),
    .MemRead (MemRead ),
    .eflush  (eflush  ),
    .dstall  (dstall  ),
    .fstall  (fstall  )
);
endmodule
