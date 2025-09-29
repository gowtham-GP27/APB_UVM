`uvm_analysis_imp_decl(_active_mon_cg) // declaring analysis imp with write method _active_mon_cg

`uvm_analysis_imp_decl(_passive_mon_cg) // declaring analysis imp with write method _passive_mon_cg

class apb_coverage extends uvm_component;
  
  `uvm_component_utils(apb_coverage) // factory registeration
  uvm_analysis_imp_active_mon_cg#(apb_seq_item, apb_coverage) a_mon_cov_imp;
  uvm_analysis_imp_passive_mon_cg#(apb_seq_item, apb_coverage)p_mon_cov_imp;
  
  apb_seq_item mon_inputs; // seq_items for the active monitor transactions
  apb_seq_item mon_outputs; // seq_items for the passive monitor transactions
  
  //covergroup for active monitor
  
  covergroup act_mon_cgrp;
    //TRANSFER_CP : coverpoint transfer;
    
    //PRESETn_CP : coverpoint PRESETn;
    
    READ_WRITE_CP : coverpoint mon_inputs.READ_WRITE{
      bins write_bins = {1};
      bins read_bins = {0};
    }
    W_PADDR_CP :coverpoint mon_inputs.apb_write_paddr [7:0] iff(mon_inputs.READ_WRITE == 0){
      bins write_address_bin = {[0:255]};
    }
    
    R_PADDR_CP : coverpoint mon_inputs.apb_read_paddr [7:0] iff(mon_inputs.READ_WRITE == 1) {
      bins read_address_bin = {[0:255]};
    }
    
    WRITE_DATA_CP : coverpoint mon_inputs.apb_write_data iff(mon_inputs.READ_WRITE == 0) {
      bins data = {[0:255]};    
    }
    
    W_SLAVE_CP : coverpoint mon_inputs.apb_write_paddr[8] iff(mon_inputs.READ_WRITE == 0) {
      bins slave1 = {0};
      bins slave2 = {1};
    }
    
    R_SLAVE_CP : coverpoint mon_inputs.apb_read_paddr[8] iff(mon_inputs.READ_WRITE == 1) {
      bins slave1 = {0};
      bins slave2 = {1};
    }   
  endgroup
  
  //passive monitor covergroup
  covergroup passive_mon_cgrp;
    READ_DATA_OUT_CP : coverpoint mon_outputs.apb_read_data_out {
      bins read_data = {[0:255]};
    }
    PSLVERR_CP : coverpoint mon_outputs.PSLVERR {
      bins err = {1};
      bins err_n = {0};
    }
  endgroup
  
  //new constructor
  function new(string name = "apb_coverage", uvm_component parent);
    super.new(name,parent);
    a_mon_cov_imp = new("a_mon_cov_imp",this);
    p_mon_cov_imp = new("p_mon_cov_imp",this);
    act_mon_cgrp = new();
    passive_mon_cgrp = new();    
  endfunction
  
  function void write_active_mon_cg(apb_seq_item req);
    mon_inputs = req;
    act_mon_cgrp.sample();
  endfunction
  
  function void write_passive_mon_cg(apb_seq_item req);
    mon_outputs = req;
    passive_mon_cgrp.sample();
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("------------------------- INPUT-COVERAGE ------------------------------");
    $display("");
    $display(" !!!! INPUT COVERAGE = %0.2f %% !!!!",act_mon_cgrp.get_coverage());
    $display("");
    $display("------------------------- INPUT-COVERAGE ------------------------------");
    $display("");
    $display("------------------------- OUPTUT-COVERAGE ------------------------------");
    $display("");
    $display(" !!!! OUTPUT COVERAGE = %0.2f %% !!!!",passive_mon_cgrp.get_coverage());
    $display("");
    $display("------------------------- OUTPUT-COVERAGE ------------------------------");
  endfunction
  
  
  
endclass
