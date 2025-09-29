class apb_seq_item extends uvm_sequence_item;
  
  rand logic transfer;
  rand logic PRESETn;
  rand logic [8:0] apb_write_paddr;
  rand logic [8:0] apb_read_paddr;
  rand logic READ_WRITE; 
  rand logic [7:0] apb_write_data;
  logic [7:0] apb_read_data_out;
  logic PSLVERR;
  
  // field automation macros and factory registeration	  
  `uvm_object_utils_begin(apb_seq_item)
  `uvm_field_int(transfer,UVM_ALL_ON)
  `uvm_field_int(PRESETn,UVM_ALL_ON)
  `uvm_field_int(apb_write_paddr, UVM_ALL_ON)
  `uvm_field_int(apb_read_paddr, UVM_ALL_ON)
  `uvm_field_int(READ_WRITE, UVM_ALL_ON)
  `uvm_field_int(apb_write_data, UVM_ALL_ON)
  `uvm_field_int(apb_read_data_out, UVM_ALL_ON)
  `uvm_field_int(PSLVERR,UVM_ALL_ON)
  `uvm_object_utils_end
  
  // new constructor 
  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction
  
endclass
