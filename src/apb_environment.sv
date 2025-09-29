class apb_env extends uvm_env;
  
  `uvm_component_utils(apb_env)
  
  apb_active_agent act_agt;
  apb_passive_agent pass_agt;
  apb_scoreboard scb;  
  apb_coverage cg_comp;
  function new(string name = "apb_env", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    act_agt = apb_active_agent::type_id::create("act_agt",this);
    pass_agt = apb_passive_agent::type_id::create("pass_agt",this);
    scb = apb_scoreboard::type_id::create("scb",this);
    cg_comp = apb_coverage::type_id::create("cg_comp",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    act_agt.act_mon.act_mon_port.connect(scb.act_mon_imp);
    pass_agt.pass_mon.pass_mon_port.connect(scb.pass_mon_imp);
    act_agt.act_mon.act_mon_cg_port.connect(cg_comp.a_mon_cov_imp);
    pass_agt.pass_mon.pass_mon_cg_port.connect(cg_comp.p_mon_cov_imp);
  endfunction 
  
endclass
