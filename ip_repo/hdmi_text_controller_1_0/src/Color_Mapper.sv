//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Zuofu Cheng   08-19-2023                               --
//                                                                       --
//    Fall 2023 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input  logic [9:0]  drawX, drawY,
                       input logic [7:0] data,
                       input logic [31:0] reg_val, control_1,
                       output logic [9:0] regnum,
                       output logic [6:0] code,
                       output logic [3:0] pix_row, // pixel row within a register
                       output logic [3:0]  Red, Green, Blue);
    logic [9:0] drawY, drawX;
    
    logic [2:0] pix_col; // pixel column within a register
    
    logic [1:0] char_sel; // which char within a single register
    logic [7:0] curr_char;
    logic [4:0] reg_val; // the index of the reg out ot the 604 registers
    logic [4:0] xpos;  // which register the char is at (80  / 4 char/reg)
    logic [4:0] ypos; // which line the char is at
    logic point; // one bit that represent whether it is white or black
    logic inverted; // whether the pixel is inverted or not
    
    assign xpos = drawX[9:5]; // xpos = drawX / 32
    assign char_sel = drawX[4:3]; // char_sel 
    assign pix_col = drawX[2:0]; // which pixel within a char
    
    assign ypos = drawY[8:4]; // ypos = drawY / 16
    assign pix_row = drawY[3:0];
    
    assign regnum = 20 * ypos + xpos;
    
    always_comb begin
        case (char_sel)
            2'b00: begin
                code = reg_val[6:0];
                inverted = reg_val[7];
            end
            2'b01: begin
                code = reg_val[14:8];
                inverted = reg_val[15];
            end
            2'b10: begin
                code = reg_val[22:16];
                inverted = reg_val[23];
            end
            2'b11: begin
                code = reg_val[30:24];                
                inverted = reg_val[31];
            end
        endcase
    end 
    
    assign point = data[7-pix_col];
    
    always_comb begin
        case ((point && ~inverted) || (~point && inverted))
            1'b1: begin
                Red = control_1[27:24];
                Green = control_1[23:20];
                Blue = control_1[19:16];
            end
            1'b0: begin
                Red = control_1[11:8];
                Green = control_1[7:4];
                Blue = control_1[3:0];
           end
        endcase
    end
    
    
endmodule
