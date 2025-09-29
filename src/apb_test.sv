class apb_test extends uvm_test;
  
  `uvm_component_utils(apb_test)
  
  apb_sequence seq;
  apb_env env;
  
  function new(string name = "apb_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env",this);
    //seq = apb_sequence::type_id::create("seq",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq = apb_sequence::type_id::create("seq");
    seq.start(env.act_agt.seqr);
    #30;
    phase.drop_objection(this);    
  endtask
  
endclass

class write_read_test extends apb_test;
  
  `uvm_component_utils(write_read_test)  
  
  function new(string name = "write_read_test",uvm_component parent);
    super.new(name,parent);
  endfunction 
  
  task run_phase(uvm_phase phase);
    write_read_seq seq_wr;
    phase.raise_objection(this);
    seq_wr = write_read_seq::type_id::create("seq_wr");
    seq_wr.start(env.act_agt.seqr);
    #30;
    phase.drop_objection(this);    
  endtask
  
endclass

class transfer_off_test extends apb_test;

  `uvm_component_utils(transfer_off_test)

  function new(string name = "transfer_off_test",uvm_component parent);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    transfer_off seq_to;
    phase.raise_objection(this);
    seq_to = transfer_off::type_id::create("seq_to");
    seq_to.start(env.act_agt.seqr);
    #30;
    phase.drop_objection(this);
  endtask

endclass


class error_write_test extends apb_test;
  `uvm_component_utils(error_write_test)
  error_write seq;

  function new(string name = "error_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq = error_write::type_id::create("seq", this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
  endtask

endclass : error_write_test

//class regression_test


class regression_test extends apb_test;
  `uvm_component_utils(regression_test)
  regression_seq seq_reg;

  function new(string name = "regression_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq_reg = regression_seq::type_id::create("seq", this);
    seq_reg.start(env.act_agt.seqr);
    phase.drop_objection(this);
  endtask

endclass 

