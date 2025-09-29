`uvm_analysis_imp_decl(_act_mon)
`uvm_analysis_imp_decl(_pass_mon)

class apb_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(apb_scoreboard)
  
  uvm_analysis_imp_act_mon#(apb_seq_item,apb_scoreboard)act_mon_imp;
  uvm_analysis_imp_pass_mon#(apb_seq_item,apb_scoreboard)pass_mon_imp;
  
  int match, mismatch, count;
  
  bit [7:0] mem [511:0];
  
  apb_seq_item act_mon_queue[$];
  apb_seq_item pass_mon_queue[$];
  
  virtual apb_intf vif;
  
  function new(string name = "apb_scoreboard", uvm_component parent);
    super.new(name,parent);
    pass_mon_imp = new("pass_mon_imp",this);
    act_mon_imp = new("act_mon_imp",this);
  endfunction
                      
  
  /*function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
      `uvm_error(get_type_name(), "Failed to get Interface");    
  endfunction*/
  
  function void write_act_mon(apb_seq_item req);
    act_mon_queue.push_back(req);
    $display("inputs received here @ %0t",$time);
  endfunction
  
  function void write_pass_mon(apb_seq_item req);
    pass_mon_queue.push_back(req);
    $display("outputs received here @ %0t",$time);
  endfunction
  
           
   task run_phase(uvm_phase phase);
    apb_seq_item active_seq;
    apb_seq_item passive_seq;

    forever begin
      fork

        begin : p1
          wait(act_mon_queue.size() > 0);
          active_seq = act_mon_queue.pop_front();

        end : p1

        begin : p2
          wait(pass_mon_queue.size() > 0);
          passive_seq = pass_mon_queue.pop_front();
        end : p2

      join


      if(active_seq.READ_WRITE == 0) begin
        mem[active_seq.apb_write_paddr] = active_seq.apb_write_data;
        count++;
        $display("DATA = %0d, WRITTEN IN MEMORY ADDRESS = %0d ", active_seq.apb_write_data, active_seq.apb_write_paddr );
        //count++;
      end
      else begin
        if(passive_seq.apb_read_data_out == mem[active_seq.apb_read_paddr]) begin
          match ++;
          count ++;
          `uvm_info(get_type_name(), $sformatf(" TEST_PASSED | READ_DATA = %0d | DATA READ FROM = %0d | PSLVERR = %0b", passive_seq.apb_read_data_out, active_seq.apb_read_paddr,passive_seq.PSLVERR), UVM_MEDIUM)
          
          //count++;
        end
        else if(passive_seq.PSLVERR == 1) begin
          `uvm_info(get_type_name(), $sformatf(" ERROR_DETECTED | READ_DATA = %0d | DATA READ FROM = %0d | PSLVERR = %0b ", passive_seq.apb_read_data_out, active_seq.apb_read_paddr, passive_seq.PSLVERR), UVM_MEDIUM)
        end
        else begin
          mismatch++;
          count ++;
          `uvm_info(get_type_name(), $sformatf(" TEST_FAILED  | READ_DATA = %0d | DATA READ FROM = %0d | PSLVERR = %0b ", passive_seq.apb_read_data_out, active_seq.apb_read_paddr, passive_seq.PSLVERR), UVM_MEDIUM)
          //count ++;          
        end
      end

      $display("TOTAL TRANSACTIONS : %0d | MATCHES = %0d | MISMATCHES = %0d |", count, match, mismatch);
      $display("--------------------------------- SCOREBOARD ------------------------------------------");
      $display("");
    end

  endtask  
endclass
