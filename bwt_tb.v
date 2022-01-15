`timescale 1ns / 1ps


module bwt_datapath_TB ;

reg clk,start;
reg [8191:0]string;
wire done;
integer fd,fout;

bwt_dpath b(reset,clk,string,length_done,bwt_done,ibwt_done);
control_path c(start,done,clk,reset,length_done,bwt_done,ibwt_done);

       initial 
         begin
          clk=1'b0;
          #2  start=1'b1;
          $dumpfile("data_path.vcd");
           $dumpvars(0,bwt_datapath_TB);
           #1000000000 $finish ;
           end
          initial 
          begin
               string=0;
               fd=$fopen("G:/BITS Hyderabad ME Microelectronics/Labs/RC Project/Final_BWT/testcase.txt","r");
               while (! $feof(fd))  begin
               $fgets(string,fd);
              end
              $fclose(fd);
  
          end


always 
begin
#5 clk=~clk;
end

always @(posedge clk  )
begin
if(done)
begin
$display($time, "%s  %s", b.bwt, b.ibwt);
end
end

endmodule