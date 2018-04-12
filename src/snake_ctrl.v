/************************************************************************
 * Author        : Wen Chunyang
 * Email         : 1494640955@qq.com
 * Create time   : 2018-04-11 18:32
 * Last modified : 2018-04-11 18:32
 * Filename      : snake_ctrl.v
 * Description   : 
 * *********************************************************************/
module  snake_ctrl(
        input                   clk                     ,
        input                   rst_n                   ,
        //key
        input                   key_left                ,
        input                   key_right               ,
        input                   key_up                  ,
        input                   key_down                ,
        //pixel
        input         [ 9: 0]   pixel_x                 ,
        input         [ 9: 0]   pixel_y                 ,
        input         [ 2: 0]   game_status             ,
        input                   body_add_sig            ,
        //head
        output  wire  [ 5: 0]   head_x                  ,
        output  wire  [ 4: 0]   head_y                  ,
        //hit
        output  reg             hit_body                ,
        output  reg             hit_wall                ,
        output  reg   [ 1: 0]   object 
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
parameter   TIME_250MS  =       6_250_000                       ;
localparam  PLAY    =           3'b010                          ;

parameter   IDLE        =       3'd0                            ; 
parameter   LETF        =       3'd1                            ;
parameter   RIGHT       =       3'd2                            ;
parameter   UP          =       3'd3                            ;
parameter   DOWN        =       3'd4                            ;
reg     [ 2: 0]                 status_c                        ;
reg     [ 2: 0]                 status_n                        ;

parameter   NONE        =       2'b00                           ;
parameter   HEAD        =       2'b01                           ;
parameter   BODY        =       2'b10                           ; 
wire    [ 5: 0]                 block_x                         ;
wire    [ 5: 0]                 block_y                         ;
//cnt0
reg     [22: 0]                 cnt0                            ;
wire                            add_cnt0                        ;
wire                            end_cnt0                        ;

//body
reg     [ 5: 0]                 body_x[15: 0]                   ;
reg     [ 4: 0]                 body_y[15: 0]                   ;
reg     [15: 0]                 snake_light                     ;
reg     [ 3: 0]                 body_num                        ; 
//======================================================================
// ***************      Main    Code    ****************
//======================================================================
assign  head_x      =       body_x[0];
assign  head_y      =       body_y[0];

//每秒移动4次
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt0 <= 0;
    end
    else if(add_cnt0)begin
        if(end_cnt0)
            cnt0 <= 0;
        else
            cnt0 <= cnt0 + 1'b1;
    end
end

assign add_cnt0     =       1'b1;       
assign end_cnt0     =       add_cnt0 && cnt0 == TIME_250MS;


parameter   D_RIGHT     =       3'd0                           ;
parameter   D_LEFT      =       3'd1                           ;
parameter   D_UP        =       3'd2                           ;
parameter   D_DOWN      =       3'd3                           ;
parameter   D_NONE      =       3'd4                           ;
reg     [ 2: 0]                 direct                          ; 

//direct
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        direct  <=  D_NONE;
    end
    else if(key_left)begin
        direct  <=  D_LEFT;
    end
    else if(key_right)begin
        direct  <=  D_RIGHT;
    end
    else if(key_up)begin
        direct  <=  D_UP;
    end
    else if(key_down)begin
        direct  <=  D_DOWN;
    end
    else 
        direct  <=  D_NONE;
end





//status_c
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        status_c <= IDLE;
    end
    else begin
        status_c <= status_n;
    end
end


//status_n
always@(*)begin
    if(game_status == PLAY)
        case(status_c)
            IDLE:begin//蛇头默认在右边，所以左键不能作为启动键，不然会出立刻结束的(撞到自己的身体)
                if(direct == D_UP)begin
                    status_n = UP;
                end
                else if(direct == D_DOWN)begin
                    status_n = DOWN;
                end
                else if(direct == D_RIGHT)begin
                    status_n = RIGHT;
                end
                else begin
                    status_n = status_c;
                end
            end
            RIGHT:begin
                if(direct == D_UP)begin
                    status_n = UP;
                end
                else if(direct == D_DOWN)begin
                    status_n = DOWN;
                end
                else begin
                    status_n = status_c;
                end
            end
            LETF:begin
                if(direct == D_UP)begin
                    status_n = UP;
                end
                else if(direct == D_DOWN)begin
                    status_n = DOWN;
                end
                else begin
                    status_n = status_c;
                end
            end
            UP:begin
                if(direct == D_RIGHT)begin
                    status_n = RIGHT;
                end
                else if(direct == D_LEFT)begin
                    status_n = LETF;
                end
                else begin
                    status_n = status_c;
                end
            end
            DOWN:begin
                if(direct == D_RIGHT)begin
                    status_n = RIGHT;
                end
                else if(direct == D_LEFT)begin
                    status_n = LETF;
                end
                else begin
                    status_n = status_c;
                end
            end
            default:begin
                status_n = IDLE;
            end
        endcase
    else
        status_n    <=      IDLE;
end


//hit_wall
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        hit_wall    <=      1'b0;
    end
    else if(game_status == PLAY)begin
        case(status_c)
            UP:if(body_y[0] == 5'd0)
                    hit_wall    <=      1'b1;
                else
                    hit_wall    <=      1'b0;
            DOWN:if(body_y[0] == 5'd29)
                    hit_wall    <=      1'b1;
                else
                    hit_wall    <=      1'b0;
            RIGHT:if(body_x[0] == 6'd39)
                    hit_wall    <=      1'b1;
                else
                    hit_wall    <=      1'b0;
            LETF:if(body_x[0] == 6'd0)
                    hit_wall    <=      1'b1;
                else
                    hit_wall    <=      1'b0;
            default:
                hit_wall    <=      1'b0;
        endcase
    end
    else
        hit_wall    <=      1'b0;
end

//hit_body
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        hit_body    <=      1'b0; 
    end
    else if((body_x[0] == body_x[ 1] && body_y[0] == body_y[ 1] && snake_light[ 1] == 1'b1)|
            (body_x[0] == body_x[ 2] && body_y[0] == body_y[ 2] && snake_light[ 2] == 1'b1)|
            (body_x[0] == body_x[ 3] && body_y[0] == body_y[ 3] && snake_light[ 3] == 1'b1)|
            (body_x[0] == body_x[ 4] && body_y[0] == body_y[ 4] && snake_light[ 4] == 1'b1)|
            (body_x[0] == body_x[ 5] && body_y[0] == body_y[ 5] && snake_light[ 5] == 1'b1)|
            (body_x[0] == body_x[ 6] && body_y[0] == body_y[ 6] && snake_light[ 6] == 1'b1)|
            (body_x[0] == body_x[ 7] && body_y[0] == body_y[ 7] && snake_light[ 7] == 1'b1)|
            (body_x[0] == body_x[ 8] && body_y[0] == body_y[ 8] && snake_light[ 8] == 1'b1)|
            (body_x[0] == body_x[ 9] && body_y[0] == body_y[ 9] && snake_light[ 9] == 1'b1)|
            (body_x[0] == body_x[10] && body_y[0] == body_y[10] && snake_light[10] == 1'b1)|
            (body_x[0] == body_x[11] && body_y[0] == body_y[11] && snake_light[11] == 1'b1)|
            (body_x[0] == body_x[12] && body_y[0] == body_y[12] && snake_light[12] == 1'b1)|
            (body_x[0] == body_x[13] && body_y[0] == body_y[13] && snake_light[13] == 1'b1)|
            (body_x[0] == body_x[14] && body_y[0] == body_y[14] && snake_light[14] == 1'b1)|
            (body_x[0] == body_x[15] && body_y[0] == body_y[15] && snake_light[15] == 1'b1)
            )begin
        hit_body    <=      1'b1;
    end
    else
        hit_body    <=      1'b0;
end

//snake head
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        body_x[0]    <=      'd10;
        body_y[0]    <=      'd5;
    end
    else if(game_status == PLAY)begin
        case(status_c)
            UP:     if(end_cnt0)    
                        body_y[0]   <=  body_y[0] - 1'b1;
            DOWN:   if(end_cnt0)   
                        body_y[0]   <=  body_y[0] + 1'b1;
            RIGHT:  if(end_cnt0)
                        body_x[0]   <=  body_x[0] + 1'b1;
            LETF:   if(end_cnt0)
                        body_x[0]   <=  body_x[0] - 1'b1;            
            default:begin
                body_x[0]    <=      'd10;
                body_y[0]    <=      'd5;
            end
        endcase
    end
    else begin
        body_x[0]    <=      'd10;
        body_y[0]    <=      'd5;
    end
end

//snake body
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        body_x[ 1]   <=      6'd9;
        body_y[ 1]   <=      5'd5;
        body_x[ 2]   <=      6'd8;
        body_y[ 2]   <=      5'd5;
        //后面的身体暂时还没有，所以没有所谓的坐标，都为0，最多是16节身体
        body_x[ 3]   <=      6'd0;
        body_y[ 3]   <=      5'd0;
        body_x[ 4]   <=      6'd0;
        body_y[ 4]   <=      5'd0;
        body_x[ 5]   <=      6'd0;
        body_y[ 5]   <=      5'd0;
        body_x[ 6]   <=      6'd0;
        body_y[ 6]   <=      5'd0;
        body_x[ 7]   <=      6'd0;
        body_y[ 7]   <=      5'd0;
        body_x[ 8]   <=      6'd0;
        body_y[ 8]   <=      5'd0;
        body_x[ 9]   <=      6'd0;
        body_y[ 9]   <=      5'd0;
        body_x[10]   <=      6'd0;
        body_y[10]   <=      5'd0;
        body_x[11]   <=      6'd0;
        body_y[11]   <=      5'd0;
        body_x[12]   <=      6'd0;
        body_y[12]   <=      5'd0;
        body_x[13]   <=      6'd0;
        body_y[13]   <=      5'd0;
        body_x[14]   <=      6'd0;
        body_y[14]   <=      5'd0;
        body_x[15]   <=      6'd0;
        body_y[15]   <=      5'd0;
    end
    //如果key没有打一拍的话，这里一定要status_c != status_c，否则会一下子结束游戏的，打了的话就无所谓了
    else if(status_c != IDLE && end_cnt0 && game_status == PLAY)begin
        body_x[ 1]   <=      body_x[ 0];   
        body_y[ 1]   <=      body_y[ 0];
        body_x[ 2]   <=      body_x[ 1];
        body_y[ 2]   <=      body_y[ 1];
        body_x[ 3]   <=      body_x[ 2];
        body_y[ 3]   <=      body_y[ 2];
        body_x[ 4]   <=      body_x[ 3];
        body_y[ 4]   <=      body_y[ 3];
        body_x[ 5]   <=      body_x[ 4];
        body_y[ 5]   <=      body_y[ 4];
        body_x[ 6]   <=      body_x[ 5];
        body_y[ 6]   <=      body_y[ 5];
        body_x[ 7]   <=      body_x[ 6];
        body_y[ 7]   <=      body_y[ 6];
        body_x[ 8]   <=      body_x[ 7];
        body_y[ 8]   <=      body_y[ 7];
        body_x[ 9]   <=      body_x[ 8];
        body_y[ 9]   <=      body_y[ 8];
        body_x[10]   <=      body_x[ 9];
        body_y[10]   <=      body_y[ 9];
        body_x[11]   <=      body_x[10];
        body_y[11]   <=      body_y[10];
        body_x[12]   <=      body_x[11];
        body_y[12]   <=      body_y[11];
        body_x[13]   <=      body_x[12];
        body_y[13]   <=      body_y[12];
        body_x[14]   <=      body_x[13];
        body_y[14]   <=      body_y[13];
        body_x[15]   <=      body_x[14];
        body_y[15]   <=      body_y[14];
    end
    else if(game_status != PLAY)begin
        body_x[ 1]   <=      6'd9;
        body_y[ 1]   <=      5'd5;
        body_x[ 2]   <=      6'd8;
        body_y[ 2]   <=      5'd5;
        //后面的身体暂时还没有，所以没有所谓的坐标，都为0，最多是16节身体
        body_x[ 3]   <=      6'd0;
        body_y[ 3]   <=      5'd0;
        body_x[ 4]   <=      6'd0;
        body_y[ 4]   <=      5'd0;
        body_x[ 5]   <=      6'd0;
        body_y[ 5]   <=      5'd0;
        body_x[ 6]   <=      6'd0;
        body_y[ 6]   <=      5'd0;
        body_x[ 7]   <=      6'd0;
        body_y[ 7]   <=      5'd0;
        body_x[ 8]   <=      6'd0;
        body_y[ 8]   <=      5'd0;
        body_x[ 9]   <=      6'd0;
        body_y[ 9]   <=      5'd0;
        body_x[10]   <=      6'd0;
        body_y[10]   <=      5'd0;
        body_x[11]   <=      6'd0;
        body_y[11]   <=      5'd0;
        body_x[12]   <=      6'd0;
        body_y[12]   <=      5'd0;
        body_x[13]   <=      6'd0;
        body_y[13]   <=      5'd0;
        body_x[14]   <=      6'd0;
        body_y[14]   <=      5'd0;
        body_x[15]   <=      6'd0;
        body_y[15]   <=      5'd0;
    end
end

//snake_light  这个控制蛇的长度
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        snake_light             <=  16'h0007;
    end
    else if(body_add_sig && game_status == PLAY)begin
        snake_light[body_num]   <=  1'b1;
    end
    else if(game_status != PLAY)begin
        snake_light <=  16'h0007;
    end
end

//body_num
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        body_num    <=      'd3;
    end
    else if(body_add_sig && game_status == PLAY)begin
        body_num    <=      body_num + 1'b1;
    end
    else if(game_status != PLAY)begin
        body_num    <=      'd3;
    end
end

assign  block_x    =       pixel_x[9:4];
assign  block_y    =       pixel_y[9:4];

//object
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        object  <=  NONE;
    end
    else if(block_x == body_x[0] && block_y == body_y[0] && snake_light[0] == 1'b1)begin
        object  <=  HEAD;
    end
    else if((block_x == body_x[ 1] && block_y == body_y[ 1] && snake_light[ 1] == 1'b1)|
            (block_x == body_x[ 2] && block_y == body_y[ 2] && snake_light[ 2] == 1'b1)|
            (block_x == body_x[ 3] && block_y == body_y[ 3] && snake_light[ 3] == 1'b1)|
            (block_x == body_x[ 4] && block_y == body_y[ 4] && snake_light[ 4] == 1'b1)|
            (block_x == body_x[ 5] && block_y == body_y[ 5] && snake_light[ 5] == 1'b1)|
            (block_x == body_x[ 6] && block_y == body_y[ 6] && snake_light[ 6] == 1'b1)|
            (block_x == body_x[ 7] && block_y == body_y[ 7] && snake_light[ 7] == 1'b1)|
            (block_x == body_x[ 8] && block_y == body_y[ 8] && snake_light[ 8] == 1'b1)|
            (block_x == body_x[ 9] && block_y == body_y[ 9] && snake_light[ 9] == 1'b1)|
            (block_x == body_x[10] && block_y == body_y[10] && snake_light[10] == 1'b1)|
            (block_x == body_x[11] && block_y == body_y[11] && snake_light[11] == 1'b1)|
            (block_x == body_x[12] && block_y == body_y[12] && snake_light[12] == 1'b1)|
            (block_x == body_x[13] && block_y == body_y[13] && snake_light[13] == 1'b1)|
            (block_x == body_x[14] && block_y == body_y[14] && snake_light[14] == 1'b1)|
            (block_x == body_x[15] && block_y == body_y[15] && snake_light[15] == 1'b1)
            )begin
        object  <=  BODY;
    end
    else begin
        object  <=  NONE;
    end
end








endmodule
