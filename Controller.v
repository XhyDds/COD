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
    input               funct7  ,
    output reg          sp_sign ,

    input [2:0]         funct3  ,
    input [6:0]         opcode  ,

    input               clk     ,
    input               rstn    ,

    output reg [2:0]    branch_e    ,
    output reg          MemRead_m   ,
    output reg          MemWrite_m  ,
    output reg          MemtoReg_m  ,
    output reg [2:0]    ALUOP_e     ,
    output reg          ALUSrc1_e   ,       // ?????
    output reg [1:0]    ALUSrc2_e   ,       // ?????
    output reg          uors_e      ,//有无符号数比较

    // output reg          RegWrite_w  ,
    output reg          RegWrite_m  ,

    output reg [2:0]    extmode1_m  ,
    output reg [2:0]    extmode2_e  ,
    
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

    reg [2:0]       branch      ;
    reg             MemRead     ;
    reg             MemWrite    ;
    reg             MemtoReg    ;
    reg [2:0]       ALUOP       ;
    reg             ALUSrc1     ;       // ?????
    reg [1:0]       ALUSrc2     ;       // ?????
    reg             uors        ;//有无符号数比较
    reg             RegWrite    ;
    reg [2:0]       extmode1    ;
    reg [2:0]       extmode2    ;


    // reg [2 :0]      branch_e    ;
    reg             MemRead_e   ;
    // reg             MemRead_m   ;
    reg             MemWrite_e  ;
    // reg             MemWrite_m  ;
    reg             MemtoReg_e  ;
    // reg             MemtoReg_m  ;
    // reg [2 :0]      ALUOP_e     ;
    // reg             ALUSrc1_e   ;
    // reg [1 :0]      ALUSrc2_e   ;
    // reg             uors_e      ;
    reg             RegWrite_e  ;
    // reg             RegWrite_m  ;
    // reg             RegWrite_w  ;
    reg [2 :0]      extmode1_e  ;
    // reg [2 :0]      extmode1_m  ;
    // reg [2 :0]      extmode2_e  ;
    reg             sp_sign_e   ; 

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

            stop    <=0;
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
            
                    stop    <=0;
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
            
                    stop    <=0;
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
            
                    stop    <=0;
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
            
                    stop    <=0;
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
            
                    stop    <=0;
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
            
                    stop    <=0;
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
            
                    stop    <=0;
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

                    stop    <=1;
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

                    stop    <=0;
                end
            endcase
        end
    end

    //ctl数据流水
    always @(posedge clk) begin
        branch_e    <= branch       ;
        MemRead_e   <= MemRead      ;
        MemRead_m   <= MemRead_e    ;
        MemWrite_e  <= MemWrite     ;
        MemWrite_m  <= MemWrite_e   ;
        MemtoReg_e  <= MemtoReg     ;
        MemtoReg_m  <= MemtoReg_e   ;
        ALUOP_e     <= ALUOP        ;
        ALUSrc1_e   <= ALUSrc1      ;
        ALUSrc2_e   <= ALUSrc2      ;
        uors_e      <= uors         ;
        RegWrite_e  <= RegWrite     ;
        RegWrite_m  <= RegWrite_e   ;
        // RegWrite_w  <= RegWrite_m   ;
        extmode1_e  <= extmode1     ;
        extmode1_m  <= extmode1_e   ;
        extmode2_e  <= extmode2     ;
        sp_sign     <= funct7       ;
    end
endmodule
