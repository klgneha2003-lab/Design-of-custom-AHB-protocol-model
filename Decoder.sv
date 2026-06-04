module decoder #(parameter Addr = 9)(ADDR,burst,HREADY,HSELx);
input [Addr:0]ADDR;
input burst;
input HREADY;
output reg [1:0]HSELx;
always @(ADDR,HREADY)
begin
   if(HREADY)
      begin
        if(burst == 1'b0)
           begin
             HSELx[1] = ADDR[9];
             HSELx[0] = ADDR[8];
           end
         else if (burst) 
           begin
              HSELx[1] = HSELx[1];
              HSELx[0] = HSELx[0];
           end
         else 
           begin
              HSELx[1] =  1'b0;
              HSELx[0] = 1'b0;
           end
       end
end
endmodule
