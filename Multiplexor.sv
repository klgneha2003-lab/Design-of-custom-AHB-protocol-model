module multiplexor #(parameter DATA = 15)(HRDATA_0,HRDATA_1,HRDATA_2,HRDATA_3,HRESP_0,HRESP_1,HRESP_2,HRESP_3,HREADYOUT_0,HREADYOUT_1,HREADYOUT_2,HREADYOUT_3,HSELx,HRDATA,HRESP,HREADY);
input [DATA:0] HRDATA_0,HRDATA_1,HRDATA_2,HRDATA_3;
input HRESP_0,HRESP_1,HRESP_2,HRESP_3,HREADYOUT_0,HREADYOUT_1,HREADYOUT_2,HREADYOUT_3;
input [1:0]HSELx;
//input error_0;
output reg [DATA:0] HRDATA;
output reg  HRESP;
output reg  HREADY;
always @(*)
begin
  case (HSELx)
    2'b00 :
       begin
           HRESP = HRESP_0;
           HREADY = HREADYOUT_0;
           HRDATA = HRDATA_0;
       end
     2'b01:
       begin
           HRDATA = HRDATA_1;
           HRESP = HRESP_1;
           HREADY = HREADYOUT_1;
       end
     2'b10: 
         begin
           HRDATA = HRDATA_2;
           HRESP = HRESP_2;
           HREADY = HREADYOUT_2;
         end  
     2'b11:
         begin
           HRDATA = HRDATA_3;
           HRESP = HRESP_3;
           HREADY = HREADYOUT_3;
         end  
      default :
         begin
           HRDATA = 8'b0;
           HRESP = 1'b0;
           HREADY = 1'b1;
         end
    endcase
end

endmodule
