`timescale 1ns / 1ps
module control_flow(start,done,clk,reset,len_done,bwt_done,ibwt_done);
input clk,len_done,bwt_done,ibwt_done,start;

output reg reset,done;
reg [2:0] st;
 
parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100;
always @(posedge clk )
begin
    case(st)
    s0: if(start) st <=s1;
    s1: if(!len_done) st <=s1;
         else if(len_done) st <=s2;
    s2: if(! bwt_done)st <=s2;
         else if(bwt_done) st <=s3;
    s3:  if(! ibwt_done)st <=s3;
         else if(ibwt_done) st <=s4;
  
    s4: st <= s4; 
    default: st <= s0  ; 
    endcase
end

always @(st)

begin
      case(st)
      
      s0:  begin #1 reset=1; end
      s1:  begin #1  reset=0;    end
      s2:  begin #1   reset=0;   end
      s3:  begin #1    reset=0; end          
      s4:  begin #1    reset=0;done=1;  end
   
      default: begin #1  reset=1; done=0; end
      
      endcase


end


endmodule
module bwt_dpath(reset,clk,str,len_done,bwt_done,ibwt_done);
input reset,clk;
input [8191:0]str ;
output wire len_done,bwt_done,ibwt_done;
wire [9:0]len;
wire [8191:0] bwt,ibwt;
len L(clk,reset,str,len_done,len);

final_bwt b(len,str,clk,reset,len_done,bwt_done,bwt);

sort s(bwt_done,clk,reset,bwt,len,ibwt,ibwt_done);

endmodule



module sort(bwt_done,clk,reset,input_str,len,ibwt_final,ibwt_done);

input clk,reset,bwt_done;
input [9:0]len;
input [8191:0] input_str ;
output reg [8183:0]ibwt_final;
integer i,j,l,i1,j1,k1,L,p;
output reg ibwt_done;
reg [7:0] sort_mem[1:1024];
reg [9:0] mem1[1:1024];
reg [7:0] ibwt_mem[1:1023];

always @ (posedge clk) 
   begin
     if(reset)
     begin
     j=1; 
     i=1;
    ibwt_done=0;
     l=0;
     j1=1;
     i1=1;
     k1=0;
     L=0;p=0;
     ibwt_final=0;
     end
     
     if(bwt_done)
     begin
       if(l < len)
       begin
       sort_mem[len-l] = input_str[l*8+:8];
       mem1[l+1] = l+1;
       l=l+1;
       
       end
       else if(i <len)
           begin
                          if(j<len)
                          begin
                               if(sort_mem[j] > sort_mem[j+1])
                               begin
                               sort_mem[j] <= sort_mem[j+1];
                               sort_mem[j+1] <= sort_mem[j];
                               mem1[j] <= mem1[j+1];
                               mem1[j+1] <= mem1[j];
                               end
                               j=j+1;
                           end
                           else if(j==len)  
                           begin
                                 j=j-len+1;
                                 i=i+1;
                            end

            end
         
           else if(i==len)
           begin
                    if(!(mem1[1]==j1))
                    begin
                          if(mem1[i1]==j1)
                           begin
                          
                            ibwt_mem[len-1-k1]=sort_mem[i1];
                            j1=i1;
                            i1=j1-i1;
                            k1=k1+1;
                            end
                    i1=i1+1;
                    end
                     else if(mem1[1]==j1)
                      begin
                        if(p < len-1)
                          begin
                          ibwt_final[p*8+:8] = ibwt_mem[len-1-p];
                                if(p==len-2)
                                begin
                                ibwt_done=1;  
                                end
                          p=p+1;
                          end
                      
                         
           
                      end    
          end
          end
end
endmodule


module len(clk,reset,str,done,size);

input clk,reset;
input [1024*8-1:0] str;
output reg done;
output reg [14:0] size;
integer fd;
integer i,l;

always @ (posedge clk)
begin 

       if(reset)
       begin
       i=0;
       l=0;
       done=0;
       size=0;
       end
 
       else if(str[l*8+:8]!=8'b0)
       begin
       i=i+1;
       l=l+1;
       
       end
    
      else if (str[l*8+:8]==8'b0)
      begin
        done=1;  
        size=i;
      end
   end  


endmodule
module final_bwt(len,input_str,clk,reset,len_done,bwt_done,final_bwt);
input [9:0] len;
input [8191:0] input_str ;
input clk,reset,len_done;
output reg [8191:0] final_bwt;
output reg bwt_done;
reg [7:0] sort[1:1024];
reg [7:0] main[1:1024];
reg [9:0] index [1:1024];
reg [7:0] new_sort[1:1024];
reg [7:0] memory1[1:1024];
reg [7:0] memory1_even[1:1024];
reg [1:1024] bin=1024'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
integer a,z,i,p,q,n,v,e,c,d,count,temp,m,dec,aux;

always@(posedge clk)
begin 
if (reset)
begin
a=0;
bwt_done=0;
z=2;
i=1;
count=1;
temp=0;
p=1;
q=1;
n=2;
v=1;
m=1;
e=0;
c=1;
d=1;aux=1;
end


if(len_done)
begin
      if(a < len)
       begin
       sort[len-a] = input_str[a*8+:8];
       main[len-a] = input_str[a*8+:8];
       index[a+1] = a+1;
       a=a+1;
       end
      
      else if(c <len)
      begin
                          if (d<len)
                          begin
                              if(sort[d] > sort[d+1])
                               begin
                               sort[d] <= sort[d+1];
                               sort[d+1] <= sort[d];
                               index[d] <= index[d+1];
                               index[d+1] <= index[d];
                               end
                               d=d+1;
                           end
                           else if(d==len)  
                           begin
                                d=d-len+1;
                                 c=c+1;
                           end

      end
     
     else if(z<len+1)
     begin
                       if(z!=len)
                       begin
                                if((sort[z]!=sort[z-1])& (sort[z]!=sort[z+1]))
                                begin
                                z=z+1;
                                end
                                else
                                begin
                                bin[z]=0;
                                z=z+1;
                                end
                        end
                        
                        else if(z==len)
                        begin 
                 
                                                             if(sort[z]!=sort[z-1])
                                                             begin
                                                             bin[z]=1;
                                                             z=z+1;
                                                             end
                                     
                                                             else 
                                                             begin
                                                             bin[z]=0;
                                                             z=z+1;
                                                             end
                                                         
                                                     
                        end
                                                          
     end
     else if(aux<len+1)
     begin
     memory1[aux]=sort[aux];
     memory1_even[aux]=sort[aux];
     aux=aux+1;
     
     end
     
     else if(~&bin)
     begin
                        if(i<len+1)
                        begin
                                
                                if(bin[i])
                                begin
                                new_sort[i]="*";
                                
                                       if(i==len)
                                       begin
                                       count=count+1;
                                       end
                                i=i+1;       
                                end
                               
                               else if(!bin[i])
                               begin
                                  
                                       if(index[i]!=len-count)
                                       begin
                                       temp=(index[i]+count)%len;
                                       new_sort[i]=main[temp];
                                                
                                                 if(i==len)
                                               begin
                                               count=count+1;
                                               end
                                       i=i+1;       
                                       end
                                       
                                       else if(index[i]==len-count)
                                       begin
                                       new_sort[i]=main[len];
                                       
                                                  if(i==len)
                                                   begin
                                                   count=count+1;
                                                   end
                                                
                                       i=i+1; 
                                       end
                                  
                               end
                         end
                         
                         else if(p<len+1)
                         begin
                             
                                    if(bin[q]==0)
                                    begin
                                 
                                              
                                                            if(q==len)
                                                            begin
                                                            q=q-len+1;
                                                            p=p+1;
                                                            end
                                                     else if(memory1[q]==memory1[q+1]) 
                                                     begin       
                                                            if(memory1_even[q]==memory1_even[q+1]) 
                                                            begin    
                                                                        if (sort[q]==sort[q+1])
                                                                          begin
                                                                            
                                                                                    if(new_sort[q]>new_sort[q+1])
                                                                                    begin
                                                                                    new_sort[q]<=new_sort[q+1];
                                                                                    new_sort[q+1]<=new_sort[q];
                                                                                    index[q]<= index[q+1];
                                                                                    index[q+1]<= index[q]; 
                                                                                    end
                                                                                    
                                                                
                                                                            q=q+1;
                                                                            end
                                                                           
                                                                            else if (sort[q]!=sort[q+1])
                                                                            begin
                                                                                    q=q+1;
                                                                            end 
                                                            end 
                                                            
                                                            else if(memory1_even[q]!=memory1_even[q+1])
                                                            begin
                                                            q=q+1;
                                                            end                
                                                      end               
                                                    else if(memory1[q]!=memory1[q+1])
                                                    begin
                                                    q=q+1;
                                                    end
                                                              
                               
                                    end
                               
                                
                                    else if(bin[q]==1)
                                    begin
                                                             
                                                             if (q==len)
                                                             begin
                                                             q=q-len+1;
                                                             p=p+1;
                                                             end
                                                             
                                                             else 
                                                             begin
                                                             q=q+1;
                                                             end
                                 
                                 
                                    end
                               
                               
                               
                               
                         end
                         
                         else if(n<len+1)
                         begin
                        
                                   if(!bin[n])
                                     begin
                                                         if(n!=len)
                                                         begin
                                                             if((new_sort[n]!=new_sort[n-1])&(new_sort[n]!=new_sort[n+1]))
                                                             begin
                                                             bin[n]=1;
                                                             n=n+1;
                                                             end
                                     
                                                             else 
                                                             begin
                                                             bin[n]=0;
                                                             n=n+1;
                                                             end
                                                         end    
                                                         
                                                         else if(n==len)
                                                         begin
                                                             if(new_sort[n]!=new_sort[n-1])
                                                             begin
                                                             bin[n]=1;
                                                             n=n+1;
                                                             end
                                     
                                                             else 
                                                             begin
                                                             bin[n]=0;
                                                             n=n+1;
                                                             end
                                                         
                                                         end
                                     end
                                
                                  else if(bin[n])
                                  begin 
                                  n=n+1;
                                  end
                         end
                         
                        else if(v<len+1)
                        begin
                        
                        sort[v]= new_sort[v];
                        
                            if(count%2)
                            begin
                            memory1[v] = new_sort[v];
                            end
                            
                            if(!(count%2))
                            begin
                            memory1_even[v] = new_sort[v];
                            end
                            if(v==len)
                            begin
                            n=2;
                            p=1;
                            i=1;
                            v=1;
                            end
                       
                           else if(v!=len)
                           begin
                           v=v+1;
                           end
                        end 
                         
                     
      end
     
      else if(m<len+1)
      begin
                       if(index[m]!=1)
                       begin 
                       dec=index[m]-1;
                       sort[m]=main[dec];
                       m=m+1;
                       end
                       
                       else 
                       begin
                      sort[m]="$";
                       m=m+1;
                       end                            
      end  
                        
     else if(e<len)
     begin
     
     final_bwt[8*e+:8]=sort[len-e];
                        if (e==len-1)
                        begin
                        bwt_done=1; 
                        end  
     e=e+1;                    
     end

     
end
end
endmodule