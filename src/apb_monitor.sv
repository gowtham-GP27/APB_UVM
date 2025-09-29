class apb_active_monitor extends uvm_monitor;
  
  `uvm_component_utils(apb_active_monitor)
  
  virtual apb_intf vif;
  apb_seq_item act_req;
  uvm_analysis_port#(apb_seq_item)act_mon_port;
  uvm_analysis_port#(apb_seq_item)act_mon_cg_port;
  function  new(string name = "apb_active_monitor",uvm_component parent);
    super.new(name,parent);
    act_mon_port = new("act_mon_port",this);
    act_mon_cg_port = new("act_mon_cg_port",this);
    //act_req = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
      `uvm_error(get_type_name(), "Failed to get Interface");   
    
  endfunction
  
  task monitor_inputs();  
    act_req.READ_WRITE = vif.READ_WRITE;
    act_req.apb_write_paddr = vif.apb_write_paddr;
    act_req.apb_read_paddr = vif.apb_read_paddr;
    act_req.apb_write_data = vif.apb_write_data;
    act_req.transfer = vif.transfer;
    act_req.PRESETn = vif.PRESETn;
    act_mon_port.write(act_req);
    `uvm_info(get_type_name(), $sformatf("| SEQUENCE MONITORED | READ_WRITE = %0b | apb_write_paddr = %0d | apb_write_data = %0d | ",act_req.READ_WRITE,act_req.apb_write_paddr,act_req.apb_write_data),UVM_MEDIUM);
    act_mon_cg_port.write(act_req);
  endtask
  
  task run_phase(uvm_phase phase);
    repeat(1)@(vif.mon_cb);
    forever begin
      act_req = apb_seq_item::type_id::create("act_req");
      repeat(1)@(vif.mon_cb);
      monitor_inputs();
      repeat(2)@(vif.mon_cb);
    end
  endtask
  
endclass

class apb_passive_monitor extends uvm_monitor;
  
  `uvm_component_utils(apb_passive_monitor)
  
  virtual apb_intf vif;
  apb_seq_item pass_req;
  uvm_analysis_port#(apb_seq_item)pass_mon_port;
  uvm_analysis_port#(apb_seq_item)pass_mon_cg_port;
  
  function  new(string name = "apb_active_monitor",uvm_component parent);
    super.new(name,parent);
    pass_mon_port = new("pass_mon_port",this);
    pass_mon_cg_port = new("pass_mon_cg_port",this);
    //pass_req = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
      `uvm_error(get_type_name(), "Failed to get Interface");   
    
  endfunction
  
  task monitor_outputs();
  pass_req.apb_read_data_out = vif.apb_read_data_out;
    pass_req.PSLVERR = vif.PSLVERR;
    `uvm_info(get_type_name(), $sformatf("| SEQUENCE MONITORED | READ_WRITE = %0b | apb_read_paddr = %0d | PSLVERR = %0b | ",pass_req.READ_WRITE,pass_req.apb_read_paddr,pass_req.PSLVERR),UVM_MEDIUM);
    pass_mon_port.write(pass_req);
    pass_mon_cg_port.write(pass_req);
  endtask
  
  task run_phase(uvm_phase phase);
    repeat(1)@(vif.mon_cb);
    forever begin
      pass_req = apb_seq_item::type_id::create("pass_req");
      repeat(1)@(vif.mon_cb);
      monitor_outputs();
      repeat(2)@(vif.mon_cb);
    end
  endtask
  
endclass
