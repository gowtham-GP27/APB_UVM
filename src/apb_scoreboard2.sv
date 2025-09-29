`uvm_analysis_imp_decl(_act_mon)
`uvm_analysis_imp_decl(_pass_mon)

class apb_scoreboard extends uvm_scoreboard;
  apb_seq_item act_mon_queue[$];
  apb_seq_item pass_mon_queue[$];
  
  virtual apb_intf vif;

  int mismatch,match,count,prev_count;
	logic [7:0] prev_val [1:0];
	logic [1:0] prev_err;
  logic [7:0] mem [511:0];

  `uvm_component_utils(apb_scoreboard)
 
  uvm_analysis_imp_act_mon#(apb_seq_item, apb_scoreboard) act_mon_imp;
  uvm_analysis_imp_pass_mon#(apb_seq_item, apb_scoreboard) pass_mon_imp;

  function new(string name = "apb_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    act_mon_imp = new("act_mon_imp", this);
    pass_mon_imp = new("pass_mon_imp",this);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
      `uvm_error(get_type_name(), "Failed to get Interface");
    
  endfunction

  function void write_act_mon(apb_seq_item req);
    act_mon_queue.push_back(req);
  endfunction

  function void write_pass_mon(apb_seq_item req);
    pass_mon_queue.push_back(req);
  endfunction

  task run_phase(uvm_phase phase);
    apb_seq_item active_seq;
    apb_seq_item passive_seq;
    forever begin
			count++;
      wait(pass_mon_queue.size() > 0 && act_mon_queue.size()>0); 
      active_seq = pass_mon_queue.pop_front();
      passive_seq = act_mon_queue.pop_front();
			store_prev_val(passive_seq);
      wait(check_for_pass_fail(active_seq,passive_seq) == 1);
      $display("-----------------------------------------------------------\n Total Transactions = %d\nMatches = %d\n Mismatches = %d",(match+mismatch),match,mismatch);
    end
  endtask
	
	function store_prev_val(input apb_seq_item passive_seq);
		  if(count == 0) begin
							prev_val = {passive_seq.apb_read_data_out,8'bxxxxxxxx};
							prev_err = {passive_seq.PSLVERR,1'bx};
							prev_count = count;
			end
			else if((count-1) == prev_count) begin
							prev_val[0] = prev_val[1];
							prev_val[1] = passive_seq.apb_read_data_out;
							prev_err[0] = prev_err[1];
							prev_err[1] = passive_seq.PSLVERR;
							prev_count = count;
			end
	endfunction

	function display_val(input apb_seq_item active_seq, input apb_seq_item passive_seq);
      $display("RESET = %b | Transfer = %b\n\t\tPSLVERR = %b",vif.PRESETn,vif.transfer,passive_seq.PSLVERR);
		if(active_seq.READ_WRITE)
			$display("Write condition : addr written to : %d | data = %d",active_seq.apb_write_paddr,active_seq.apb_write_data);
		else
			$display("Read condition : addr to read from : %d | data recived(dut) = %d",active_seq.apb_read_paddr,passive_seq.apb_read_data_out);
	endfunction

  function bit check_for_pass_fail(input apb_seq_item active_seq, input apb_seq_item passive_seq);
    if((!vif.PRESETn && vif.transfer) ||  (!vif.PRESETn && !vif.transfer))begin
		if(passive_seq.PSLVERR == 0 && passive_seq.apb_read_data_out == 8'b0) begin
			match++;
			$display(" Reset is active low \n PSLVERR and apb_read_data_out are set to zero");
		  display_val(active_seq,passive_seq);
			$display("------------------------------ Passed -------------------------------");
			return 1;
	    end
	    else begin 
			mismatch++;
			$display(" Reset condition failed \n PSLVERR and apb_read_data_out are not to zero");
			display_val(active_seq,passive_seq);
		  $display("------------------------------ Failed -------------------------------");
			return 1;
		end
	end
    else if(vif.PRESETn && !vif.transfer) begin
		if(passive_seq.PSLVERR === prev_err[0] && passive_seq.apb_read_data_out === prev_val[0]) begin
		  	match++;
				$display("When transfer = 0 PRDATA and PSLVERR are latching to the previous value");
				display_val(active_seq,passive_seq);
			  $display("------------------------------ Passed -------------------------------");
				return 1;
		end
		else begin
				mismatch++;
				$display("When transfer = 0 PRDATA and PSLVERR are not latched to the previous value");
			  display_val(active_seq,passive_seq);
			  $display("------------------------------ Failed -------------------------------");
				return 1;
		end
	end
	else begin
		if(active_seq.READ_WRITE) begin 
			mem[active_seq.apb_write_paddr] = active_seq.apb_write_data;	
			display_val(active_seq,passive_seq);
			return 1;
		end
		else begin
			if((mem[active_seq.apb_read_paddr] === 8'bx || mem[active_seq.apb_read_paddr] === 8'bz) && !passive_seq.PSLVERR) begin
				$display("Bridge is Accessing memory which is not written into");
				mismatch++;
				display_val(active_seq,passive_seq);
			  $display("------------------------------ Failed -------------------------------");
				return 1;
			end
			else begin 
				if(mem[active_seq.apb_read_paddr] === passive_seq.apb_read_data_out) begin
					match++;
					$display(" Read data matching with the written data");
					display_val(active_seq,passive_seq);
					$display("------------------------------ Passed -------------------------------");
					return 1;
				end
				else begin
          mismatch++;
          $display(" Read data not matching with the written data: PRDATA = %d | while data in PRADDR (%d) = %d",passive_seq.apb_read_data_out,active_seq.apb_read_paddr,mem[active_seq.apb_read_paddr]);
					display_val(active_seq,passive_seq);
				  $display("------------------------------ Failed -------------------------------");
					return 1;
        end
			end
		end
	end
  endfunction 
endclass
