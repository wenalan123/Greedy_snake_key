/************************************************************************
 * Author        : Wen Chunyang
 * Email         : 1494640955@qq.com
 * Create time   : 2018-04-11 09:33
 * Last modified : 2018-04-11 09:33
 * Filename      : vga_play.v
 * Description   : 
 * *********************************************************************/
module  vga_play(
        input                   clk                     ,
        input                   rst_n                   ,
        //
        input         [ 1: 0]   object                  ,
        input         [ 5: 0]   apple_x                 ,
        input         [ 4: 0]   apple_y                 ,
        output  reg   [ 9: 0]   pixel_x                 ,
        output  reg   [ 9: 0]   pixel_y                 ,
        
        //vga
        output  reg   [ 7: 0]   play_vga_r              ,
        output  reg   [ 7: 0]   play_vga_g              ,
        output  reg   [ 7: 0]   play_vga_b              ,
        output  wire            play_hs                 ,
        output  wire            play_vs 
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

parameter   Red_Wide        =       16                          ;

parameter   NONE            =       2'b00                       ;
parameter   HEAD            =       2'b01                       ;
parameter   BODY            =       2'b10                       ;


reg                             hsync                           ;
reg                             vsync                           ;

reg     [ 9: 0]                 h_cnt                           ;
wire                            add_h_cnt                       ;
wire                            end_h_cnt                       ;

reg     [ 9: 0]                 v_cnt                           ;
wire                            add_v_cnt                       ; 
wire                            end_v_cnt                       ;

wire                            valid_area                      ; 

reg     [ 3: 0]                 snake_x                         ;
reg     [ 3: 0]                 snake_y                         ; 

wire                            wall_area                       ; 
//======================================================================
// ***************      Main    Code    ****************
//======================================================================
assign  play_hs      =       hsync;
assign  play_vs      =       vsync;

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

//pixel_x,pixel_y
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pixel_x <= 0;
        pixel_y <= 0;
    end
    else if(valid_area)begin
            pixel_x <= h_cnt - Hde_start + 2;//这里提前了两个时钟，因为前后判断各耽搁一个时钟,具体自己画一下时序图
            pixel_y <= v_cnt - Vde_start;//因为v_cnt数据是多个时钟保持的，持续时间长，所以不会耽搁，故不能加2
    end
    else begin
        pixel_x <= 0;
        pixel_y <= 0;
    end
end



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


assign  valid_area        =   (h_cnt >= Hde_start - 1 && h_cnt < Hde_end - 1 && v_cnt >= Vde_start && v_cnt < Vde_end);//v_cnt是多周期的，所以不用提前  
assign  wall_area    =   (h_cnt >= Hde_start -1 && h_cnt < Hde_start - 1 + Red_Wide) || (h_cnt >= Hde_end - 1 - Red_Wide && h_cnt < Hde_end - 1) || (v_cnt >= Vde_start && v_cnt < Vde_start + Red_Wide) || (v_cnt >= Vde_end - Red_Wide && v_cnt < Vde_end);

//wall 100  , snake head 010,snake body 011,apple 110
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        play_vga_r   <=      8'h0;
        play_vga_g   <=      8'h0;
        play_vga_b   <=      8'h0;
    end
    else if(valid_area)begin
        if(wall_area)begin
            play_vga_r   <=      8'hff;
            play_vga_g   <=      8'h00;
            play_vga_b   <=      8'h00;
        end
        else if(pixel_x[9:4] == apple_x && pixel_y[9:4] == apple_y)begin//扫描到了苹果的位置
            play_vga_r   <=      8'hff;
            play_vga_g   <=      8'hff;
            play_vga_b   <=      8'h00;
        end
        else if(object == NONE)begin
                play_vga_r   <=      8'h00;
                play_vga_g   <=      8'h00;
                play_vga_b   <=      8'h00;
            end
        else if(object == HEAD || object == BODY)begin
            case({snake_x,snake_y})
                8'b0000_0000,8'b0000_1111,8'b1111_0000,8'b1111_11111:begin
                    play_vga_r   <=      8'h00;
                    play_vga_g   <=      8'h00;
                    play_vga_b   <=      8'h00;
                end    
                default:begin
                    if(object == HEAD)begin
                        play_vga_r   <=      8'h00;
                        play_vga_g   <=      8'hff;
                        play_vga_b   <=      8'h00;
                    end
                    else begin
                        play_vga_r   <=      8'h00;
                        play_vga_g   <=      8'hff;
                        play_vga_b   <=      8'hff;
                    end
                end
            endcase
        end
    end
    else begin
        play_vga_r   <=      8'h0;
        play_vga_g   <=      8'h0;
        play_vga_b   <=      8'h0;
    end
end

//snake_x,snake_y
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        snake_x     <=      'd0;
        snake_y     <=      'd0;
    end
    else if(valid_area)begin
        snake_x     <=      pixel_x[3:0];
        snake_y     <=      pixel_y[3:0];
    end
end








endmodule
