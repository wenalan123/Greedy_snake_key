/************************************************************************
 * Author        : Wen Chunyang
 * Email         : 1494640955@qq.com
 * Create time   : 2018-04-10 19:41
 * Last modified : 2018-04-10 19:41
 * Filename      : game_ctrl.v
 * Description   : 
 * *********************************************************************/
module  game_ctrl(
        input                   clk                     ,
        input                   rst_n                   ,
        //key
        input                   key_left                ,
        input                   key_right               ,
        input                   key_up                  ,
        input                   key_down                ,
        //
        input                   hit_wall                ,
        input                   hit_body                ,
        //play
        input         [ 7: 0]   play_vga_r              ,
        input         [ 7: 0]   play_vga_g              ,
        input         [ 7: 0]   play_vga_b              ,
        input                   play_hs                 ,
        input                   play_vs                 ,
        //
        output  wire  [ 2: 0]   game_status             ,
        //vga
        output  reg   [ 7: 0]   vga_r                   ,
        output  reg   [ 7: 0]   vga_g                   ,
        output  reg   [ 7: 0]   vga_b                   ,
        output  reg             vga_hs                  ,
        output  reg             vga_vs                
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
localparam  START   =           3'b001                          ;
localparam  PLAY    =           3'b010                          ;
localparam  END     =           3'b100                          ;
reg     [ 2: 0]                 status_c                        ;
reg     [ 2: 0]                 status_n                        ; 

wire    [ 7: 0]                 start_vga_r                     ; 
wire    [ 7: 0]                 start_vga_g                     ;
wire    [ 7: 0]                 start_vga_b                     ;
wire                            start_hs                        ;
wire                            start_vs                        ;

wire    [ 7: 0]                 end_vga_r                       ;
wire    [ 7: 0]                 end_vga_g                       ;
wire    [ 7: 0]                 end_vga_b                       ;
wire                            end_hs                          ;
wire                            end_vs                          ;

wire    [ 7: 0]                 start_data                      ;
wire                            start_rd_en                     ;
wire    [ 7: 0]                 end_data                        ;
wire                            end_rd_en                       ; 
//======================================================================
// ***************      Main    Code    ****************
//======================================================================
assign	game_status		=		status_c;
//status_c
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        status_c <= START;
    end
    else begin
        status_c <= status_n;
    end
end


//status_n
always@(*)begin
    case(status_c)
        START:begin
            if(key_right||key_up||key_down)begin
                status_n = PLAY;
            end
            else begin
                status_n = status_c;
            end
        end
        PLAY:begin
            if(hit_body||hit_wall)begin
                status_n = END;
            end
            else begin
                status_n = status_c;
            end
        end
        END:begin
            if(key_left||key_right||key_up||key_down)begin
                status_n = START;
            end
            else begin
                status_n = status_c;
            end
        end
        default:begin
            status_n = START;
        end
    endcase
end

always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        vga_r        <=     start_vga_r; 
        vga_g        <=     start_vga_g; 
        vga_b        <=     start_vga_b; 
        vga_hs       <=     start_hs; 
        vga_vs       <=     start_vs; 
    end
    else 
        case(status_c)
            START:begin
                vga_r        <=     start_vga_r; 
                vga_g        <=     start_vga_g; 
                vga_b        <=     start_vga_b; 
                vga_hs       <=     start_hs; 
                vga_vs       <=     start_vs; 
            end
            PLAY:begin
                vga_r        <=     play_vga_r; 
                vga_g        <=     play_vga_g; 
                vga_b        <=     play_vga_b; 
                vga_hs       <=     play_hs; 
                vga_vs       <=     play_vs; 
            end
            END:begin
                vga_r        <=     end_vga_r; 
                vga_g        <=     end_vga_g; 
                vga_b        <=     end_vga_b; 
                vga_hs       <=     end_hs; 
                vga_vs       <=     end_vs; 
            end
            default:begin
                vga_r        <=     start_vga_r; 
                vga_g        <=     start_vga_g; 
                vga_b        <=     start_vga_b; 
                vga_hs       <=     start_hs; 
                vga_vs       <=     start_vs; 
            end
        endcase
end

//start
start_end   start_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //vga
        .vga_r                  (start_vga_r            ),
        .vga_g                  (start_vga_g            ),
        .vga_b                  (start_vga_b            ),
        .vga_hs                 (start_hs               ),
        .vga_vs                 (start_vs               ),
        //rom
        .rom_data               (start_data             ),
        .rom_rd_en              (start_rd_en            )
);
rom_start_ctrl  rom_start_ctrl_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //rom
        .start_rd_en            (start_rd_en            ),
        .start_data             (start_data             )
);

//end
start_end   end_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //vga
        .vga_r                  (end_vga_r              ),
        .vga_g                  (end_vga_g              ),
        .vga_b                  (end_vga_b              ),
        .vga_hs                 (end_hs                 ),
        .vga_vs                 (end_vs                 ),
        //rom
        .rom_data               (end_data               ),
        .rom_rd_en              (end_rd_en              )
);
rom_end_ctrl    rom_end_ctrl_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //rom
        .end_rd_en              (end_rd_en              ),
        .end_data               (end_data               )
);

endmodule
