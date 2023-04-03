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
    // input [6:0]         funct7  ,
    input [2:0]         funct3  ,
    input [6:0]         opcode  ,

    input               clk     ,
    input               rstn    ,

    output reg [2:0]    branch  ,
    output reg          MemRead ,
    output reg          MemWrite,
    output reg          MemtoReg,
    output reg [2:0]    ALUOP   ,
    output reg [1:0]    ALUSrc1 ,
    output reg [1:0]    ALUSrc2 ,
    output reg          PCSrc   ,//决定来自原始pc或alu计算结果
    output reg          uors    ,//有无符号数比较

    output reg          RegWrite,
    output reg          PCLoad  ,
    output reg          IRLoad  ,
    output reg          YLoad   ,
    output reg          MDLoad  ,

    output reg [2:0]    mode    ,
    output reg [2:0]    extmode1,
    output reg [2:0]    extmode2

    );

//opcode
    parameter ADDI_fml = 7'b0010011;
    parameter ADD_fml  = 7'b0110011;
    parameter LUI      = 7'b0110111;
    parameter AUIPC    = 7'b0010111;
    parameter JAL      = 7'b1101111;
    parameter JALR     = 7'b1100111;
    parameter BEQ_fml  = 7'b1100011;
    parameter LB_fml   = 7'b0000011;
    parameter SB_fml   = 7'b0100011;

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

    reg [2:0] state;
    reg [2:0] nstate;

    always @(posedge clk) begin
        if(rstn) begin
            state   <=0;

            branch  <=0;
            MemRead <=0;
            MemWrite<=0;
            MemtoReg<=0;
            ALUOP   <=0;
            ALUSrc1 <=2'b0;
            ALUSrc2 <=2'b0;
            RegWrite<=0;
            PCLoad  <=0;
            IRLoad  <=0;
            YLoad   <=0;
            MDLoad  <=0;
            mode    <=0;
        end
        else begin
            state<=nstate;
            case (nstate)
                3'b0:   begin   //取指令
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=0;
                    ALUSrc1 <=2'b0;
                    ALUSrc2 <=2'b0;
                    mode    <=0;

                    RegWrite<=1;
                    PCLoad  <=0;
                    IRLoad  <=0;
                    YLoad   <=0;
                    MDLoad  <=0;
                end
                3'b1:   begin   //译码与取操作数
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=0;
                    ALUSrc1 <=2'b0;
                    ALUSrc2 <=2'b0;

                    RegWrite<=0;
                    PCLoad  <=0;
                    IRLoad  <=1;
                    YLoad   <=0;
                    MDLoad  <=0;

                    case (opcode)
                        ADDI_fml:begin
                            case (funct3)
                                ADDI : mode<=3'b1;
                                SLLI : mode<=3'b10;
                                SLTI : mode<=3'b1;
                                SLTIU: mode<=3'b1;
                                XORI : mode<=3'b1;
                                SRLI : mode<=3'b10;
                                // SRAI : mode<=3'b10;
                                ORI  : mode<=3'b1;
                                ANDI : mode<=3'b1;
                                default: mode<=3'b0;
                            endcase
                        end
                        ADD_fml :mode<=3'b0;
                        LUI     :mode<=3'b11;
                        AUIPC   :mode<=3'b11;
                        JAL     :mode<=3'b100;
                        JALR    :mode<=3'b1;
                        BEQ_fml :mode<=3'b101;
                        LB_fml  :mode<=3'b1;
                        SB_fml  :mode<=3'b110;
                        default :mode<=3'b0;
                    endcase
                end
                3'b10:  begin   //计算
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    mode    <=0;

                    RegWrite<=0;
                    PCLoad  <=0;
                    IRLoad  <=0;
                    YLoad   <=0;
                    MDLoad  <=0;

                    case (opcode)
                        ADDI_fml:begin
                            ALUOP<=funct3;
                            ALUSrc1<=2'b1;
                            ALUSrc2<=2'b0;
                        end
                        ADD_fml :begin
                            ALUOP<=funct3;
                            ALUSrc1<=2'b0;
                            ALUSrc2<=2'b0;
                        end
                        LUI:begin
                            ALUOP<=3'b000;
                            ALUSrc1<=2'b1;
                            ALUSrc2<=2'b10;
                        end
                        AUIPC:begin
                            ALUOP<=3'b000;
                            ALUSrc1<=2'b1;
                            ALUSrc2<=2'b1;
                        end
                        JAL     :begin
                            ALUOP<=3'b000;
                            ALUSrc1<=2'b1;
                            ALUSrc2<=2'b1;
                        end
                        JALR    :begin
                            ALUOP<=3'b000;
                            ALUSrc1<=2'b1;
                            ALUSrc2<=2'b0;
                        end
                        BEQ_fml :begin
                            case (funct3)
                                BEQ :    ALUOP<=3'b010;
                                BNE :    ALUOP<=3'b010;
                                BLT :    ALUOP<=3'b010;
                                BGE :    ALUOP<=3'b010;
                                BLTU:    ALUOP<=3'b011;
                                BGEU:    ALUOP<=3'b011;
                                default: ALUOP<=3'b000;
                            endcase
                            ALUSrc1<=2'b0;
                            ALUSrc2<=2'b0;
                        end
                        LB_fml  :begin
                            ALUOP<=3'b000;
                            ALUSrc1<=2'b1;
                            ALUSrc2<=2'b0;
                        end
                        SB_fml  :begin
                            ALUOP<=3'b000;
                            ALUSrc1<=2'b1;
                            ALUSrc2<=2'b0;
                        end
                        default :begin
                            ALUOP<=3'b000;
                            ALUSrc1<=2'b0;
                            ALUSrc2<=2'b0;
                        end
                    endcase

                    case (opcode)
                        SB_fml  :begin
                            case (funct3)
                                SB: extmode2<=3'b010;
                                SH: extmode2<=3'b100;
                                default: extmode2<=3'b000;
                            endcase
                        end
                        default: extmode2<=3'b0;
                    endcase
                end
                3'b11:  begin   //访存
                    ALUOP   <=0;
                    ALUSrc1 <=2'b0;
                    ALUSrc2 <=2'b0;
                    mode    <=0;

                    RegWrite<=0;
                    PCLoad  <=0;
                    IRLoad  <=0;
                    YLoad   <=1;
                    MDLoad  <=0;

                    case (opcode)
                        //LUI     
                        //AUIPC   
                        JAL     :begin
                            branch<=3'b000;
                            PCSrc<=2'b1;
                            uors<=0;
                        end
                        JALR    :begin
                            branch<=3'b000;
                            PCSrc<=2'b10;
                            uors<=0;
                        end
                        BEQ_fml :begin
                            case (funct3)
                                BEQ :    begin
                                    branch<=3'b010;
                                    uors<=0;
                                end 
                                BNE :    begin
                                    branch<=3'b101;
                                    uors<=0;
                                end 
                                BLT :    begin
                                    branch<=3'b100;
                                    uors<=0;
                                end 
                                BGE :    begin
                                    branch<=3'b011;
                                    uors<=0;
                                end 
                                BLTU:    begin
                                    branch<=3'b100;
                                    uors<=1;
                                end 
                                BGEU:    begin
                                    branch<=3'b011;
                                    uors<=1;
                                end 
                                default: begin
                                    branch<=3'b000;
                                    uors<=0;
                                end 
                            endcase
                            PCSrc<=2'b0;
                        end
                        default: begin
                            branch<=3'b000;
                            PCSrc<=2'b0;
                            uors<=0;
                        end 
                    endcase

                    case (opcode)
                        //ADDI_fml
                        //ADD_fml 
                        //LUI     
                        //AUIPC   
                        //JAL  
                        //JALR 
                        //BEQ_fml
                        LB_fml  :begin
                            MemRead <=1;
                            MemWrite<=0;
                            MemtoReg<=1;
                        end
                        SB_fml  :begin
                            MemRead <=0;
                            MemWrite<=1;
                            MemtoReg<=0;
                        end
                        default :begin
                            MemRead <=0;
                            MemWrite<=0;
                            MemtoReg<=0;
                        end
                    endcase 

                    case (opcode)
                        LB_fml  :begin
                            case (funct3)
                                LB :        extmode1<=3'b001;
                                LH :        extmode1<=3'b011;
                                LW :        extmode1<=3'b0;
                                LBU:        extmode1<=3'b010;
                                LHU:        extmode1<=3'b100;
                                default:    extmode1<=3'b0;
                            endcase
                        end
                        default: extmode1<=3'b0;
                    endcase
                end
                3'b100:  begin  //写回
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=1;
                    ALUOP   <=0;
                    ALUSrc1 <=2'b0;
                    ALUSrc2 <=2'b0;
                    mode    <=0;

                    RegWrite<=0;
                    PCLoad  <=1;
                    IRLoad  <=0;
                    YLoad   <=0;
                    MDLoad  <=1;
                end
                default: begin
                    branch  <=0;
                    MemRead <=0;
                    MemWrite<=0;
                    MemtoReg<=0;
                    ALUOP   <=0;
                    ALUSrc1 <=2'b0;
                    ALUSrc2 <=2'b0;
                    mode    <=0;

                    RegWrite<=0;
                    PCLoad  <=0;
                    IRLoad  <=0;
                    YLoad   <=0;
                    MDLoad  <=0;
                end
            endcase
        end
    end

    always @(*) begin
        case (state)
            3'b0:   begin   //取指令
                nstate=3'b1;
            end
            3'b1:   begin   //译码与取操作数
                nstate=3'b10;
            end
            3'b10:  begin   //计算
                nstate=3'b11;
            end
            3'b11:  begin   //访存
                nstate=3'b100;
            end
            3'b100:  begin  //写回
                nstate=3'b0;
            end
            default: begin
                nstate=3'b0;
            end
        endcase
    end
endmodule
