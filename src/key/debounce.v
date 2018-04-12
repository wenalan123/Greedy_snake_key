/************************************************************************
 * Author        : Wen Chunyang
 * Email         : 1494640955@qq.com
 * Create time   : 2018-04-11 14:13
 * Last modified : 2018-04-11 14:13
 * Filename      : debounce.v
 * Description   : 
 * *********************************************************************/
module  debounce(
        input                   clk                     ,
        input                   rst_n                   ,
        //key
        input                   key_in                  ,
        output  wire            key_out 
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
parameter   TIME_20MS   =       500_000                         ; 
reg     [ 1: 0]                 key_r                           ;
reg     [18: 0]                 cnt                             ;
wire                            add_cnt                         ;
wire                            end_cnt                         ;
wire                            flag_20ms                       ;
reg                             flag_20ms_r                     ; 
//======================================================================
// ***************      Main    Code    ****************
//======================================================================
//key_r
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_r   <=      'd0;
    end
    else begin
        key_r   <=      {key_r[0],key_in};
    end
end

//cnt
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt <= 0;
    end
    else if(add_cnt)begin
        if(end_cnt)
            cnt <= cnt;//保持不变
        else
            cnt <= cnt + 1'b1;
    end
    else
        cnt <= 0;
end

assign add_cnt      =       key_r[1] == 0;       
assign end_cnt      =       add_cnt && cnt== TIME_20MS-1;   
assign flag_20ms    =       end_cnt;

//flag_20ms_r
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_20ms_r     <=      0;
    end
    else begin
        flag_20ms_r     <=      flag_20ms;
    end
end

//检测上升沿，确保只有一拍
assign key_out  =   flag_20ms & (!flag_20ms_r);




endmodule
