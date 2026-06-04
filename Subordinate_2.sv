module SUB_2 #(parameter Addr = 9,parameter DATA = 15)(clk,rst,HSELx,ADDR,HTRANS,HBURST,HWRITE1,HDATA,HSIZE,HREADYOUT_1,HRESP_1,HRDATA_1);
input clk,rst,HWRITE1;
input [1:0]HSELx;
input [Addr:0] ADDR;
input [DATA:0] HDATA;
input [1:0]HTRANS;
input [2:0]HSIZE;
input [2:0]HBURST;
output reg HREADYOUT_1 = 1'b1;
output reg HRESP_1 = 1'b0;
output reg [DATA:0] HRDATA_1;
localparam IDLE = 3'b000;
localparam WRITE = 3'b001;
localparam READ = 3'b010;
localparam Err_1 = 3'b011;
localparam Err_2 = 3'b100;
localparam SUB_2 = 2'b01;
reg [2:0] CS;
reg [2:0] NS;
reg [7:0]mem[256:511];
reg error = 0;
reg [Addr :0]addr = 0;
wire [31:0] addr_increment;
reg [3:0]counter = 0; 
integer i= 0;
assign addr_increment =  1'b1 << HSIZE; 
always @(posedge clk)
     begin
       case(HBURST)
        3'b001 : begin
                  if(counter == 4'd15)
                    begin
                      counter <=0;
                    end
                  else
                    begin
                     counter <= counter + 1;
                    end
                 end
        3'b010 : begin
                  if(counter == 4'd3)
                    begin
                      counter <=0;
                    end
                  else
                    begin
                     counter <= counter + 1;
                    end
                 end
        3'b011 : begin
                  if(counter == 4'd3)
                    begin
                      counter <=0;
                    end
                  else
                    begin
                     counter <= counter + 1;
                    end
                 end
         3'b100 : begin
                  if(counter == 4'd7)
                    begin
                      counter <=0;
                    end
                  else
                    begin
                     counter <= counter + 1;
                    end
                 end
          3'b101 : begin
                  if(counter == 4'd7)
                    begin
                      counter <=0;
                    end
                  else
                    begin
                     counter <= counter + 1;
                    end
                 end
           3'b110 : begin
                  if(counter == 4'd15)
                    begin
                      counter <=0;
                    end
                  else
                    begin
                     counter <= counter + 1;
                    end
                 end
           3'b111 : begin
                  if(counter == 4'd15)
                    begin
                      counter <=0;
                    end
                  else
                    begin
                     counter <= counter + 1;
                    end
                 end
             endcase
          end
always @(posedge clk)
 begin
   CS <= NS;                     //current state logic
 end
always @(*)
 begin
    case (CS)                     // Next state logic
    IDLE : begin
            if( rst == 0)
               begin 
                 NS <= IDLE;
               end
             else if (HTRANS == 2'b00)
               begin
                 NS <= IDLE;
               end                         
             else if (HSELx == SUB_2)
               begin
                if(HWRITE1)
                  begin
                  if (error == 1)
                    begin
                     NS <= Err_1;
                    end   
                   NS <= WRITE;
                  end
                else 
                  begin 
                  if (error == 1)
                    begin
                     NS <= Err_1;
                    end   
                   NS <= READ;
                  end
               end
             else 
               begin
                 NS <= IDLE;
               end 
           end
     READ : begin
             if( rst == 0)
               begin 
                 NS <= IDLE;
               end
              else if (HTRANS <= 2'b00)
                begin
                  NS <= IDLE;
                end 
              else if (HSELx == SUB_2)
                begin
                  if(HWRITE1)
                    begin
                     if (error == 1)
                       begin
                        NS <= Err_1;
                       end   
                      NS <= WRITE;
                    end
                  else 
                    begin
                     if (error == 1)
                      begin
                        NS <= Err_1;
                      end   
                       NS <= READ;
                    end
                 end
                else 
                  begin
                    NS <= IDLE;
                  end
             end
       WRITE: begin
               if( rst == 0)
               begin 
                 NS <= IDLE;
               end
               else if (HTRANS <= 2'b00)
                 begin
                  NS <= IDLE;
                 end  
                else if (error == 1)
                   begin
                     NS <= Err_1;
                   end
                else if (HSELx == SUB_2 )
                   begin
                     if (HWRITE1)
                       begin
                           NS <= WRITE;
                       end
                     else 
                       begin  
                         NS <= READ;
                       end
                   end
                 else
                    begin
                      NS <= IDLE;
                    end
              end
         Err_1 :
                 begin
                     NS <= Err_2;
                 end
         Err_2 : 
                 begin
                   if (HTRANS == 2'b00)
                     begin
                       NS <= IDLE;
                     end
                 end
         endcase
 end
 wire [1023:0] safe_hdata = { {(32-DATA){1'b0}}, HDATA };
 always @(*)
 begin                                   //output logic
    case (CS) 
      IDLE : begin
               HREADYOUT_1 <= 1'b1;
               HRESP_1 <= 1'b0;
               HRDATA_1 <= 8'b0;
               error <= 1'b0; 
               i = 32'd256;
             end
      READ: begin
              if(!HWRITE1)
                begin
                   if (i == ADDR)
                      begin
                        HRDATA_1 <= mem[i];
                      end
                   end
            end
       WRITE : begin
                  if(HWRITE1)
                    begin
                       if (ADDR > 255)
                         begin
                           error = 1'b1;
                         end
                       else 
                           begin
                             if (HBURST == 3'b001|| HBURST == 3'b010 || HBURST == 3'b011 || HBURST == 3'b100 || HBURST == 3'b101 || HBURST == 3'b110 || HBURST == 3'b111)
                               begin 
                               addr = ADDR + (counter * addr_increment);
                                case(HSIZE)
                                 3'b000 : mem[addr] = safe_hdata;
                                 3'b001 : begin
                                           for ( i = 0; i < 2 ; i = i + 1)
                                              begin
                                                mem[addr + i] = safe_hdata[i*8 +: 8];
                                              end
                                           end
                                  3'b010 : begin
                                            for ( i = 0; i < 4 ; i = i + 1)
                                               begin
                                                  mem[addr + i] = safe_hdata[i*8 +: 8];
                                                end
                                             end
                                    3'b011 : begin
                                              for ( i = 0; i < 8 ; i = i + 1)
                                                begin
                                                   mem[addr + i] = safe_hdata[i*8 +: 8];
                                                end
                                              end
                                     3'b100 : begin
                                               for ( i = 0; i < 16 ; i = i + 1)
                                                  begin
                                                    mem[addr + i] = safe_hdata[i*8 +: 8];
                                                  end
                                               end
                                      3'b101 : begin
                                                for ( i = 0; i < 32 ; i = i + 1)
                                                  begin
                                                     mem[addr + i] = safe_hdata[i*8 +: 8];
                                                   end
                                                end
                                       3'b110 : begin
                                                 for ( i = 0; i < 64 ; i = i + 1)
                                                   begin
                                                      mem[addr + i] = safe_hdata[i*8 +: 8];
                                                   end
                                                 end
                                        3'b111 : begin
                                                   for ( i = 0; i < 128 ; i = i + 1)
                                                     begin
                                                       mem[addr + i] = safe_hdata[i*8 +: 8];
                                                     end
                                                  end
                                        endcase
                                     end
                                end    
                            end          
                  end
        Err_1 : begin
                     HRESP_1 <= 1'b1;
                     HREADYOUT_1 <= 1'b0;
                     error <= 1'b1; 
               end
        Err_2 : begin
                error <= 1'b1;
                HRESP_1 <= 1'b1;
                HREADYOUT_1 <= 1'b1;
                end         
      endcase
 end

endmodule
