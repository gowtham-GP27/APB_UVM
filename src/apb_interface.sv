interface apb_intf(input logic PCLK);
  
  logic transfer;
  logic PRESETn; 
  logic READ_WRITE; // to check the mode of transfer
  logic [8:0] apb_write_paddr; // address where data has to be written
  logic [8:0] apb_read_paddr; // address from where data has to be read
  logic [7:0] apb_write_data; // data that has to be written
  logic [7:0] apb_read_data_out; // data that has to be read
  logic  PSLVERR; // error bit
  // driver clocking block
  clocking drv_cb@(posedge PCLK);
    default input #0 output #0;
    output READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data,transfer,PRESETn;
    
  endclocking
  
  // monitor clocking block
  clocking mon_cb@(posedge PCLK);
    default input #0 output #0;    
    input READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data, apb_read_data_out, PSLVERR, transfer, PRESETn;    
  endclocking
  
  // modport for driver  
  modport DRV(clocking drv_cb, input PCLK, transfer, PRESETn);
  
  // modport for monitor
    
  modport MON(clocking mon_cb, input PCLK, transfer, PRESETn);
  
 // clock toggle  
  property p1;
    @(posedge PCLK) PCLK != $past(1, PCLK);
  endproperty
  assert property(p1)begin
    $info("PCLK is toggling");
  end
  else begin
    $error("PCLK is not toggling");
  end
  
  //valid inputs
  property p2;
    @(posedge PCLK) disable iff(!PRESETn )transfer |-> not($isunknown({READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data}));
  endproperty
  assert property(p2)begin
    $info("VALID INPUTS");
  end
  else begin
    $error("INVALID INPUTS");
  end
    
  //RESET CHECK
    
  property p3;
    @(posedge PCLK) !PRESETn |-> ({PSLVERR, apb_read_data_out} == 'b0);
  endproperty
  assert property(p3)
    $info("RESET passed");
  else begin
    $error("RESET failed");
  end 
    
endinterface
