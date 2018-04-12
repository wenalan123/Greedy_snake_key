module  rom_start_ctrl(
        input                   clk                     ,
        input                   rst_n                   ,
        //rom
        input                   start_rd_en             ,
        output  wire  [ 7: 0]   start_data 
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
localparam  ADDR_END    =       40000                           ;
reg     [15: 0]                 rom_addr                        ; 
wire                            add_rom_addr                    ;
wire                            end_rom_addr                    ; 

//======================================================================
// ***************      Main    Code    ****************
//======================================================================
//rom_addr
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rom_addr <= 0;
    end
    else if(add_rom_addr)begin
        if(end_rom_addr)
            rom_addr <= 0;
        else
            rom_addr <= rom_addr + 1'b1;
    end
end

assign add_rom_addr      =       start_rd_en;       
assign end_rom_addr      =       add_rom_addr && rom_addr== ADDR_END-1;   



rom_start	rom_start_inst (
        .address                (rom_addr                ),
        .clock                  (clk                     ),
        .q                      (start_data              )
);

endmodule
