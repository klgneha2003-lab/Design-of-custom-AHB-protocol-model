module manager #(parameter Addr = 9,parameter DATA = 15)(clk,rst,HREADY,HWRITE,HADDR,HWDATA,HRESP,HBURST,HWRITE1,ADDR,HSIZE,HTRANS,HDATA,E_flag,burst);
input clk,rst,HWRITE,HREADY,HRESP;
input [2:0] HBURST;
input [Addr:0]HADDR;
input [DATA:0] HWDATA;
output reg HWRITE1;
output reg [1:0] HTRANS = 2'b00;
output reg [Addr:0]ADDR;
output reg [2:0] HSIZE = 3'b000;
output reg [DATA:0]HDATA;
output reg E_flag = 0;
output reg burst = 0;
localparam IDLE = 3'b000;
localparam BUSY = 3'b001;
localparam NONSEQ = 3'b010;
localparam SEQ = 3'b011;
localparam READ = 3'b100;
localparam WAIT = 3'b101;
reg [2:0]CS = IDLE;
reg [2:0]NS;
reg [3:0]counter = 4'b000; 
always @(HWRITE)            //declaring size of data 
begin
   if(DATA == 7)
     begin 
       HSIZE <= 3'b000; 
     end
   else if(DATA == 15)
     begin
       HSIZE <= 3'b001;
     end
   else if(DATA == 31)
     begin
       HSIZE <= 3'b010;
     end
    else if(DATA == 63)
      begin
       HSIZE <= 3'b011;
      end
    else if(DATA == 127)
     begin
       HSIZE <= 3'b100;
     end
    else if(DATA == 255)
     begin
       HSIZE <= 3'b101;
     end
    else if(DATA == 511)
     begin
       HSIZE <= 3'b110;
     end
    else if(DATA == 1023)
     begin
       HSIZE <= 3'b111;
     end
end   
assign addr_increment =  1'b1 << HSIZE;                
always @(posedge clk)
begin
 CS <= NS;                   //present stage logic
end 
always @(*)
begin                         //next state logic
   case(CS)
      IDLE :
        begin
           if(rst == 0)
              begin 
                 NS <= IDLE;
              end
             else if (HREADY & HRESP)
               begin
                  NS <= IDLE;
               end
            else if(HREADY & HWRITE)
               begin
                 NS <= NONSEQ;
               end
             else if (HREADY & (HWRITE))
                begin
                  NS <= READ;
                end
             else 
               begin
                 NS <= IDLE;
               end
         end
      BUSY: 
         begin
          if (rst == 0)
            begin
              NS <= IDLE; 
            end
          else if (!HREADY & HRESP)
               begin
                  NS <= BUSY;
               end
             else if(!HREADY & !HRESP)
               begin 
                 NS <= WAIT;
               end
             else if (HREADY & HRESP)
               begin
                  NS <= IDLE;
               end
          else if(HREADY & HWRITE)
            begin
              if (HBURST == 3'b000)
                begin
                  NS <= NONSEQ;
                end
             end
            else if (HREADY & (!HWRITE))
                begin
                   NS <= READ;
                end
          else
            begin
                NS <= BUSY;
           end
          end
      NONSEQ :
              begin
            if (rst == 0)
            begin
              NS <= IDLE; 
            end 
            else if (!HREADY & HRESP)
               begin
                  NS <= NONSEQ;
               end
             else if(!HREADY & !HRESP)
               begin 
                 NS <= WAIT;
               end
             else if (HREADY & HRESP)
               begin
                  NS <= IDLE;
               end
            else if(HREADY & HWRITE & !HRESP)  
                begin
                  if(HBURST == 3'b000)
                      begin
                       NS <= NONSEQ;
                     end
                  else 
                   begin
                    NS <= SEQ;
                   end
                end
              else if (HREADY & (!HWRITE) & !HRESP)
                  begin
                    NS <= READ;
                  end
            else
               begin
                NS <= IDLE;
               end
           end
      SEQ :
         begin
           if (rst == 0)
            begin
              NS <= IDLE; 
            end
            else if (!HREADY & HRESP)
               begin
                  NS <= SEQ;
               end
             else if(!HREADY & !HRESP)
               begin 
                 NS <= WAIT;
               end
             else if (HREADY & HRESP)
               begin
                  NS <= IDLE;
               end
            else if(HREADY & !HRESP) 
              begin
                 if (HBURST != 3'b000)
                 begin
                    NS <= SEQ;
                 end
                else if (HTRANS == 2'b10)
                   begin
                    NS <= NONSEQ;
                   end  
              end
            else if(HREADY & (!HWRITE) & !HRESP)
                 begin
                   NS <= READ;
                 end
            else
             begin 
               NS <= IDLE;
             end
         end
       READ : 
          begin
             if (rst == 0)
               begin
                 NS <= IDLE;
               end
              else if (!HREADY & HRESP)
               begin
                  NS <= READ;
               end
             else if(!HREADY & !HRESP)
               begin 
                 NS <= WAIT;
               end
             else if (HREADY & HRESP)
               begin
                  NS <= IDLE;
               end
              if(HREADY & (!HWRITE) & !HRESP)
                begin 
                 NS <= READ;
                end
              else 
                begin
                  NS <= NONSEQ;
                end                 
          end
       WAIT : begin
                if (rst == 0)
                  begin
                    NS <= IDLE;
                  end
                else if (!HREADY & HRESP)
               begin
                  NS <= WAIT;
               end
             else if(!HREADY & !HRESP)
               begin 
                 NS <= WAIT;
               end
             else if (HREADY & HRESP)
               begin
                  NS <= IDLE;
               end
               else if (HREADY & HWRITE)
                  begin
                    NS <= NONSEQ;
                  end
                else if (HREADY & !HWRITE)
                  begin
                    NS <= READ;
                  end
                else
                  begin
                    NS <= IDLE;
                  end
              end
      endcase
end
always @(posedge clk)
begin                       //output logic
   case(CS)
   IDLE : 
        begin 
          HWRITE1 <= 1'b0;
          HTRANS <= 2'b00;        
          ADDR <= 10'b0;
          HDATA <= 8'b0;
          E_flag <= 0;
          counter <= 4'd0;
          burst <= 0;
          if (HREADY & HRESP)
            begin
               E_flag <= 1;
            end
        end
   BUSY :
         begin 
         HWRITE1 <= 1'b0;
         HTRANS <= 2'b01;        
         ADDR <= HADDR;
         HDATA <= HWDATA;
         counter <= 0;
         burst <= 0;
          if (HREADY & HRESP)
            begin
               E_flag <= 1;
            end
         end 
   NONSEQ:
         begin
          HWRITE1 <= 1'b1;
           if (HREADY & HRESP || !HREADY & HRESP)
            begin
               E_flag <= 1;
            end
           else if(HBURST == 3'b000)
             begin   
               HTRANS <= 2'b10;
               ADDR <= HADDR;
               HDATA <= HWDATA;
               counter <= 0;
               burst <= 0;
             end
         end
   SEQ :
        begin
          HTRANS <= 2'b11;
            if (HREADY & HRESP || !HREADY & HRESP)
            begin
               E_flag <= 1;
            end
            else if (HBURST == 3'b001)
               begin 
               HDATA <= HWDATA;
               ADDR <= HADDR;
               counter = counter +1;
               if (counter != 4'd15)
                  begin
                     if(counter == 1)
                       begin
                         burst <= 1'b1;
                       end
                     counter <= counter +1;
                  end
                else 
                  begin
                     counter <= 0;
                     HTRANS <= 2'b01;
                  end
               end
             else if (HBURST == 3'b010)
                  begin 
                     HDATA <= HWDATA;
                     ADDR <= HADDR;
                    counter <= counter + 1;
                     if(counter == 1)
                       begin
                         burst <= 1'b1;
                       end
                      else if (counter == 4'd4)         // 4- beat wrapping burst
                        begin
                         counter <=0;                     
                         HTRANS <= 2'b10;
                        end
                   end
                else if (HBURST == 3'b011)
                    begin                          // 4- beat incrementing burst
                      HDATA <= HWDATA;
                      ADDR <= HADDR;
                      counter <= counter + 1;
                       if(counter == 1)
                       begin
                         burst <= 1'b1;
                       end
                       else if (counter == 4'd4)
                          begin 
                           counter <= 0;
                           HTRANS <= 2'b10;
                          end
                     end
               else if (HBURST == 3'b100)
                    begin
                      HDATA <= HWDATA;
                      ADDR <= HADDR;
                     counter <= counter + 1;          // 8-beat wrapping burst
                      if(counter == 1)
                       begin
                         burst <= 1'b1;
                       end
                       else if (counter == 4'd8)
                         begin
                           HDATA <= 8'b0;
                           counter <= 0;
                           HTRANS <= 2'b10;
                         end 
                     end
                else if (HBURST == 3'b101)
                     begin                            //8-beat incrementing burst
                       HDATA <= HWDATA;
                        ADDR <= HADDR;
                       counter <= counter + 1;
                        if(counter == 1)
                       begin
                         burst <= 1'b1;
                       end
                        else if(counter == 4'd8)
                            begin
                             counter <= 0;
                             HTRANS <= 2'b10;     
                            end
                      end
                else if (HBURST == 3'b110)
                      begin                           //16 - beat wrapping burst
                        HDATA <= HWDATA;
                        ADDR <= HADDR;
                        counter <= counter + 1;
                         if(counter == 1)
                           begin
                            burst <= 1'b1;
                           end
                         else if (counter == 4'd15)
                            begin
                              counter <= 0;
                              HTRANS <= 2'b10;
                            end
                       end
                else if (HBURST == 3'b111)
                      begin                 //16-beat incrementing burst
                        HDATA <= HWDATA;
                        ADDR <= HADDR;
                        counter <= counter + 1;
                        if(counter == 1)
                          begin
                            burst <= 1'b1;
                          end
                        else if (counter == 4'd15)
                            begin
                              ADDR <= ADDR;
                               counter <= 0;
                               HTRANS <= 2'b10;
                            end
                       end
                 HWRITE1 <= 1'b1;
                
          end
        READ: 
              begin
               if (HREADY & HRESP || !HREADY & HRESP)
                 begin
                   E_flag <= 1;
                 end
               else if((!HWRITE) & HREADY) 
                  begin
                   HWRITE1 <= 1'b0;
                   ADDR <= HADDR;
                  end
               end   
        WAIT : 
              begin
               if (HREADY & HRESP || !HREADY & HRESP)
            begin
               E_flag <= 1;
            end
            else 
               begin
                ADDR <= ADDR;
                HDATA <= HDATA;
                HWRITE1 <= HWRITE1;
                HTRANS <= HTRANS;
                HSIZE <= HSIZE;
              end   
            end    
     endcase
end
endmodule
