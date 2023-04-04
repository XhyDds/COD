`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/03 19:00:21
// Design Name: 
// Module Name: TOP
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


module TOP(
    input clk,
    input rstn,
    input rxd,
    output txd,
    
    output [15:0] DebugData,
        output    stop
    );

    wire clk_cpu;
    wire  we_im;
    wire  we_dm;
    wire [31:0] pc ;
    wire [31:0] npc;
    wire [31:0] ir ;
    wire [31:0] imm;
    wire [31:0] a  ;
    wire [31:0] b  ;
    wire [31:0] y  ;
    wire [31:0] md ;

    wire [31:0] dout_rf;
    wire [31:0] dout_dm;
    wire [31:0] dout_im;

    wire [31:0] pc_chk;

    wire [31:0] addr;
    wire [31:0] din;

    wire [2:0]        branch      ;
    wire              MemRead     ;
    wire              MemWrite    ;
    wire              MemtoReg    ;
    wire [2:0]        ALUOP       ;
    wire              ALUSrc1     ;
    wire [1:0]        ALUSrc2     ;
    wire              RegWrite    ;

    wire [2:0]  zero    ;
    wire [2:0]  mode    ;
    wire        uors    ;

    wire rf_dcp_rd;

    wire [15:0] CTL;

    assign CTL={2'b0,branch  ,MemRead ,MemWrite,MemtoReg,ALUOP   ,ALUSrc1 ,ALUSrc2 ,RegWrite};
    
    assign DebugData={mode,zero,branch,extmode1,extmode2,sp_sign};  //?位

    SDU SDU(
        .clk     (clk     ),
        .rstn    (rstn    ),
        .rxd     (rxd     ),

        .txd     (txd     ),
        .clk_cpu (clk_cpu ),

        .pc_chk  (pc_chk  ),
        .npc     (npc     ),
        .pc      (pc      ),
        .IR      (ir      ),
        .IMM     (imm     ),
        .CTL     (CTL     ),//
        .A       (a       ),
        .B       (b       ),
        .Y       (y       ),
        .MDR     (md      ),

        .addr    (addr    ),

        .dout_rf (dout_rf ),
        .dout_dm (dout_dm ),
        .dout_im (dout_im ),
        // .sw      (sw      ),//

        .din     (din     ),
        .we_dm   (we_dm   ),
        .we_im   (we_im   ),
        // .clk_ld  (clk_ld  ),//
        // .cs      (cs      ),//
        // .sel     (sel     ),//
        .rf_dcp_rd   (rf_dcp_rd   )
    );

    CPU CPU(
        .clk         (clk_cpu     ),
        .rstn        (rstn        ),
        .inst_we     (we_im       ),
        .data_we     (we_dm       ),
        .rf_dcp_we   (1'b0        ),
        .rf_dcp_rd   (rf_dcp_rd       ),
        .data_in     (din         ),
        .inst_in     (din         ),
        .rf_in       (din         ),
        .data_addr   (addr        ),
        .inst_addr   (addr        ),
        .rf_addr     (addr        ),
        .data_out    (dout_dm     ),
        .inst_out    (dout_im     ),
        .rf_out      (dout_rf     ),
        .md          (md          ),
        .y           (y           ),
        .pc          (pc          ),
        .npc         (npc         ),
        .imm         (imm         ),
        .ir          (ir          ),
        .a           (a           ),
        .b           (b           ),
        .branch      (branch      ),//
        .MemRead     (MemRead     ),//
        .MemWrite    (MemWrite    ),//
        .MemtoReg    (MemtoReg    ),//
        .ALUOP       (ALUOP       ),//
        .ALUSrc1     (ALUSrc1     ),//
        .ALUSrc2     (ALUSrc2     ),//
        .RegWrite    (RegWrite    ),//

        .mode        (mode        ),
        .zero        (zero        ),
        .uors        (uors        ),
        .extmode1    (extmode1    ),
        .extmode2    (extmode2    ),
        .sp_sign     (sp_sign     ),

        .stop       (stop)
    );
endmodule
