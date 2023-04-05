`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 18:05:25
// Design Name: 
// Module Name: Controller
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


module Controller(
    input               eflush  ,
    input               flush   ,

    input               funct7  ,
    output reg          sp_sign ,

    input [2:0]         funct3  ,
    input [6:0]         opcode  ,

    input               clk     ,
    input               rstn    ,

    output reg [2:0]    branch    ,
    output reg          MemRead   ,
    output reg          MemWrite_m  ,
    output reg          MemtoReg_m  ,
    output reg [2:0]    ALUOP     ,
    output reg          ALUSrc1   ,       // ?????
    output reg [1:0]    ALUSrc2   ,       // ?????
    output reg          uors      ,//有无符号数比较

    output reg          RegWrite_w  ,
    output reg          RegWrite_m  ,

    output reg [2:0]    extmode1_m  ,
    output reg [2:0]    extmode2  ,
    
    output reg [2:0]    mode        ,

    output reg          stop        

    );

//opcode
    parameter ADDI_fml = 7'b0010011;
    parameter ADD_fml  = 7'b0110011;
    parameter LUI      = 7'b0110111;
    parameter AUIPC    = 7'b0010111;
    // parameter JAL      = 7'b1101111;
    // parameter JALR     = 7'b1100111;
    parameter BEQ_fml  = 7'b1100011;
    parameter LB_fml   = 7'b0000011;
    parameter SB_fml   = 7'b0100011;

    parameter ECALL = 7'b1110011;

//funct3
    parameter ADDI     = 3'b000;
    parameter SLLI     = 3'b001;
    parameter SLTI     = 3'b010;
    parameter SLTIU    = 3'b011;
    parameter XORI     = 3'b100;
    parameter SRLI     = 3'b101;
    parameter SRAI     = 3'b101;
    parameter ORI      = 3'b110;
    parameter ANDI     = 3'b111;
    
    parameter ADD      = 3'b000;
    parameter SUB      = 3'b000;
    parameter SLL      = 3'b001;
    parameter SLT      = 3'b010;
    parameter SLTU     = 3'b011;
    parameter XOR      = 3'b100;
    parameter SRL      = 3'b101;
    parameter SRA      = 3'b101;
    parameter OR       = 3'b110;
    parameter AND      = 3'b111;

    parameter BEQ      = 3'b000;
    parameter BNE      = 3'b001;
    parameter BLT      = 3'b100;
    parameter BGE      = 3'b101;
    parameter BLTU     = 3'b110;
    parameter BGEU     = 3'b111;

    parameter LB       = 3'b000;
    parameter LH       = 3'b001;
    parameter LW       = 3'b010;
    parameter LBU      = 3'b100;
    parameter LHU      = 3'b101;

    parameter SB       = 3'b000;
    parameter SH       = 3'b001;
    parameter SW       = 3'b010;
//   

    // reg [2:0]       branch      ;
    // reg             MemRead     ;
    reg             MemWrite    ;
    reg             MemtoReg    ;
    // reg [2:0]       ALUOP       ;
    // reg             ALUSrc1     ;       // ?????
    // reg [1:0]       ALUSrc2     ;       // ?????
    // reg             uors        ;//有无符号数比较
    reg             RegWrite    ;
    reg [2:0]       extmode1    ;
    // reg [2:0]       extmode2    ;


    // reg [2 :0]      branch    ;
    // reg             MemRead   ;
    // reg             MemRead_m   ;
    // reg             MemWrite  ;
    // reg             MemWrite_m  ;
    // reg             MemtoReg  ;
    // reg             MemtoReg_m  ;
    // reg [2 :0]      ALUOP     ;
    // reg             ALUSrc1   ;
    // reg [1 :0]      ALUSrc2   ;
    // reg             uors      ;
    // reg             RegWrite  ;
    // reg             RegWrite_m  ;
    // reg             RegWrite_w  ;
    // reg [2 :0]      extmode1  ;
    // reg [2 :0]      extmode1_m  ;
    // reg [2 :0]      extmode2  ;
    // reg             sp_sign   ; 

    //stop
    reg             stop_n;    
    reg stop_state;
    reg nstop_state; 

    always @(posedge clk) begin
        if(!rstn) begin
            stop_state<=0;
        end
        else begin
            stop_state<=nstop_state;
        end
        case (stop_state)
            1'b0: stop<=0;
            1'b1: stop<=1;
        endcase
    end
    always @(*) begin
        case (stop_state)
            1'b0: begin
                if(stop_n) nstop_state=1;
                else nstop_state=0;
            end
            1'b1: nstop_state=1;
        endcase
    end

    //译码
    always @(*) begin
        case (opcode)
            ADDI_fml:begin
               case (funct3)
                   ADDI : mode=3'b1;
                   SLLI : mode=3'b10;
                   SLTI : mode=3'b1;
                   SLTIU: mode=3'b1;
                   XORI : mode=3'b1;
                   SRLI : mode=3'b10;
                   // SRAI : mode=3'b10;
                   ORI  : mode=3'b1;
                   ANDI : mode=3'b1;
                   default: mode=3'b0;
               endcase
            end
            ADD_fml :mode=3'b0;
            LUI     :mode=3'b11;
            AUIPC   :mode=3'b11;
            // JAL     :mode=3'b100;
            // JALR    :mode=3'b1;
            BEQ_fml :mode=3'b101;
            LB_fml  :mode=3'b1;
            SB_fml  :mode=3'b110;
            default :mode=3'b0;
        endcase
    end

    always @(posedge clk) begin
        if(!rstn) begin
            branch  <=0;
            MemRead <=0;
            MemWrite<=0;
            MemtoReg<=0;
            ALUOP   <=0;
            ALUSrc1 <=0;
            ALUSrc2 <=0;
            uors    <=0;
            RegWrite<=0;
            extmode1<=0;
            extmode2<=0;

            stop_n    <=0;
        end
        else if(eflush||flush) begin
            branch  <=0;
            MemRead <=0;
            MemWrite<=0;
            MemtoReg<=0;
            ALUOP   <=0;
            ALUSrc1 <=0;
            ALUSrc2 <=0;
            uors    <=0;
            RegWrite<=0;
            extmode1<=0;
            extmode2<=0;

            stop_n    <=0;
        end
        else begin
            //译码
            case (opcode)
                ADDI_fml: begin
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=funct3;
                    ALUSrc1 <=1'b1;
                    ALUSrc2 <=2'b0;
                    uors    <=0;
                    RegWrite<=1;
                    extmode1<=0;
                    extmode2<=0;
            
                    stop_n    <=0;
                end 
                ADD_fml: begin
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=funct3;
                    ALUSrc1 <=1'b0;
                    ALUSrc2 <=2'b0;
                    uors    <=0;
                    RegWrite<=1;
                    extmode1<=0;
                    extmode2<=0;
            
                    stop_n    <=0;
                end
                LUI: begin
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=3'b0;
                    ALUSrc1 <=1'b1;
                    ALUSrc2 <=2'b10;
                    uors    <=0;
                    RegWrite<=1;
                    extmode1<=0;
                    extmode2<=0;
            
                    stop_n    <=0;
                end
                AUIPC: begin
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=3'b0;
                    ALUSrc1 <=1'b1;
                    ALUSrc2 <=2'b1;
                    uors    <=0;
                    RegWrite<=1;
                    extmode1<=0;
                    extmode2<=0;
            
                    stop_n    <=0;
                end
                BEQ_fml: begin
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    case (funct3)
                        BEQ :    begin
                            ALUOP<=3'b010;
                            branch<=3'b010;
                            uors<=0;
                        end 
                        BNE :    begin
                            ALUOP<=3'b010;
                            branch<=3'b101;
                            uors<=0;
                        end 
                        BLT :    begin
                            ALUOP<=3'b010;
                            branch<=3'b100;
                            uors<=0;
                        end 
                        BGE :    begin
                            ALUOP<=3'b010;
                            branch<=3'b011;
                            uors<=0;
                        end 
                        BLTU:    begin
                            ALUOP<=3'b011;
                            branch<=3'b100;
                            uors<=1;
                        end 
                        BGEU:    begin
                            ALUOP<=3'b011;
                            branch<=3'b011;
                            uors<=1;
                        end 
                        default: begin
                            ALUOP<=3'b000;
                            branch<=3'b000;
                            uors<=0;
                        end 
                    endcase
                    ALUSrc1 <=1'b0;
                    ALUSrc2 <=2'b0;
                    RegWrite<=0;
                    extmode1<=0;
                    extmode2<=0;
            
                    stop_n    <=0;
                end
                LB_fml: begin
                    branch  <=0;
                    MemRead <=1;
                    MemWrite<=0;
                    MemtoReg<=1;
                    ALUOP   <=3'b000;
                    ALUSrc1 <=1'b1;
                    ALUSrc2 <=2'b0;
                    uors    <=0;
                    RegWrite<=1;
                    extmode2<=0;
                    case (funct3)
                        LB :        extmode1<=3'b001;
                        LH :        extmode1<=3'b011;
                        LW :        extmode1<=3'b0;
                        LBU:        extmode1<=3'b010;
                        LHU:        extmode1<=3'b100;
                        default:    extmode1<=3'b0;
                    endcase
            
                    stop_n    <=0;
                end
                SB_fml: begin
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=1;
                    MemtoReg<=0;
                    ALUOP   <=3'b000;
                    ALUSrc1 <=1'b1;
                    ALUSrc2 <=2'b0;
                    uors    <=0;
                    RegWrite<=0;
                    extmode1<=0;
                    case (funct3)
                        SB: extmode2<=3'b010;
                        SH: extmode2<=3'b100;
                        default: extmode2<=3'b000;
                    endcase
            
                    stop_n    <=0;
                end
                ECALL: begin
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=0;
                    ALUSrc1 <=0;
                    ALUSrc2 <=0;
                    uors    <=0;
                    RegWrite<=0;
                    extmode1<=0;
                    extmode2<=0;

                    stop_n    <=1;
                end
                default: begin          //包含空指令
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=0;
                    ALUSrc1 <=0;
                    ALUSrc2 <=0;
                    uors    <=0;
                    RegWrite<=0;
                    extmode1<=0;
                    extmode2<=0;

                    stop_n    <=0;
                end
            endcase
        end
    end

    //ctl数据流水
    always @(posedge clk) begin
        if(!rstn) begin
            MemWrite_m  <= 0   ;
            MemtoReg_m  <= 0   ;
            RegWrite_m  <= 0   ;
            RegWrite_w  <= 0   ;
            extmode1_m  <= 0   ;
            sp_sign     <= 0   ;    
        end
        else if(flush) begin    //清除f,d,e段，保留m
            MemWrite_m  <= 0   ;
            MemtoReg_m  <= 0   ;
            RegWrite_m  <= 0   ;
            RegWrite_w  <= RegWrite_m   ;
            extmode1_m  <= 0   ;
            sp_sign     <= 0   ;    
        end
        else begin
            // MemRead_m   <= MemRead    ;
            MemWrite_m  <= MemWrite   ;
            MemtoReg_m  <= MemtoReg   ;
            RegWrite_m  <= RegWrite   ;
            RegWrite_w  <= RegWrite_m   ;
            extmode1_m  <= extmode1   ;
            sp_sign     <= funct7       ;            
        end
    end
endmodule
