/************************************************************************
 * Author        : Wen Chunyang
 * Email         : 1494640955@qq.com
 * Create time   : 2018-04-11 14:34
 * Last modified : 2018-04-11 14:34
 * Filename      : key.v
 * Description   : 
 * *********************************************************************/
module  key(
        input                   clk                     ,
        input                   rst_n                   ,
        //key
        input                   key3                    ,
        input                   key2                    ,
        input                   key1                    ,
        input                   key0                    ,
        //key out
        output  wire            key_left                ,
        output  wire            key_right               ,
        output  wire            key_up                  ,
        output  wire            key_down 
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/


//======================================================================
// ***************      Main    Code    ****************
//======================================================================




debounce    debounce_left_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //key
        .key_in                 (key3                   ),
        .key_out                (key_left               )
);
debounce    debounce_right_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //key
        .key_in                 (key2                   ),
        .key_out                (key_right              )
);
debounce    debounce_up_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //key
        .key_in                 (key1                   ),
        .key_out                (key_up                 )
);
debounce    debounce_down_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //key
        .key_in                 (key0                   ),
        .key_out                (key_down               )
);

endmodule
