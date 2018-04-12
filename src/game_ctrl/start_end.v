/************************************************************************
 * Author        : Wen Chunyang
 * Email         : 1494640955@qq.com
 * Create time   : 2018-04-08 16:57
 * Last modified : 2018-04-08 16:57
 * Filename      : vga.v
 * Description   : 
 * *********************************************************************/
module  start_end(
        input                   clk                     ,
        input                   rst_n                   ,
        //vga
        output  reg   [ 7: 0]   vga_r                   ,
        output  reg   [ 7: 0]   vga_g                   ,
        output  reg   [ 7: 0]   vga_b                   ,
        output  wire            vga_hs                  ,
        output  wire            vga_vs                  ,
        //rom
        input         [ 7: 0]   rom_data                ,
        output  reg             rom_rd_en 
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
//ADV7123 t输出延迟=t6+t8=7.5+15=22.5ns
// 640*480@60Hz fclk=25MHz,Tclk=40ns,20ns>7.5ns,所以数据不需要提前一个时钟输出,按正常时序即可
parameter   LinePeriod      =       800                         ;
parameter   H_SyncPulse     =       96                          ;
parameter   H_BackPorch     =       48                          ;
parameter   H_ActivePix     =       640                         ;
parameter   H_FrontPorch    =       16                          ;
parameter   Hde_start       =       H_SyncPulse + H_BackPorch   ; 
parameter   Hde_end         =       Hde_start + H_ActivePix     ; 

parameter   FramePeriod     =       525                         ;
parameter   V_SyncPulse     =       2                           ;
parameter   V_BackPorch     =       33                          ;
parameter   V_ActivePix     =       480                         ;
parameter   V_FrontPorch    =       10                          ;
parameter   Vde_start       =       V_SyncPulse + V_BackPorch   ; 
parameter   Vde_end         =       Vde_start + V_ActivePix     ; 

parameter   Red_Wide        =       20                          ;
parameter   Red_Length      =       30                          ; 


reg                             hsync                           ;
reg                             vsync                           ;

reg     [ 9: 0]                 h_cnt                           ;
wire                            add_h_cnt                       ;
wire                            end_h_cnt                       ;

reg     [ 9: 0]                 v_cnt                           ;
wire                            add_v_cnt                       ; 
wire                            end_v_cnt                       ;

wire							start_area	                    ;
//======================================================================
// ***************      Main    Code    ****************
//======================================================================
assign  vga_hs      =       hsync;
assign  vga_vs      =       vsync;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        h_cnt <= 0;
    end
    else if(add_h_cnt)begin
        if(end_h_cnt)
            h_cnt <= 0;
        else
            h_cnt <= h_cnt + 1'b1;
    end
end

assign add_h_cnt     =       1'b1;
assign end_h_cnt     =       add_h_cnt && h_cnt== LinePeriod-1;

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        v_cnt <= 0;
    end
    else if(add_v_cnt)begin
        if(end_v_cnt)
            v_cnt <= 0;
        else
            v_cnt <= v_cnt + 1'b1;
    end
end

assign add_v_cnt     =       end_h_cnt;
assign end_v_cnt     =       add_v_cnt && v_cnt== FramePeriod-1;

//hsync
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        hsync   <=      1'b0;
    end
    else if(add_h_cnt && h_cnt == H_SyncPulse-1)begin
        hsync   <=      1'b1;
    end
    else if(end_h_cnt)begin
        hsync   <=      1'b0;
    end
end

//vsync
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        vsync   <=      1'b0;
    end
    else if(add_v_cnt && v_cnt == V_SyncPulse-1)begin
        vsync   <=      1'b1;
    end
    else if(end_v_cnt)begin
        vsync   <=      1'b0;
    end
end



assign  start_area        =   (h_cnt >= Hde_start - 2 + 220 && h_cnt < Hde_start - 2 + 420 && v_cnt >= Vde_start + 140 && v_cnt < Vde_start + 340);//v_cnt是多周期的，所以不用提前  




always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        vga_r   <=      8'h0;
        vga_g   <=      8'h0;
        vga_b   <=      8'h0;
    end
    else if(rom_rd_en)begin
        vga_r   <=      {rom_data[7:5],5'h0};
        vga_g   <=      {rom_data[4:2],5'h0};
        vga_b   <=      {rom_data[1:0],6'h0};
    end
    else begin
        vga_r   <=      8'h0;
        vga_g   <=      8'h0;
        vga_b   <=      8'h0;
    end
end


//rom_rd_en
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rom_rd_en   <=      1'b0;
    end
    else if(start_area)begin
        rom_rd_en   <=      1'b1;
    end
    else begin
        rom_rd_en   <=      1'b0;
    end
end



endmodule
