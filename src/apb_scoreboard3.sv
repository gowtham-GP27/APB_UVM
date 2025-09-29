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

  function void store_prev_val(input apb_seq_item passive_seq);

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

  task run_phase(uvm_phase phase);  

  //super.run_phase(phase); 

    apb_seq_item act;

  apb_seq_item pass;

  forever begin

    wait((pass_mon_queue.size() > 0) && (act_mon_queue.size() > 0));

    act = act_mon_queue.pop_front();

    pass = pass_mon_queue.pop_front();

    count++;

    store_prev_val(pass);

    // start of reset

    if((act.PRESETn == 0 && act.transfer == 1) ||  (act.PRESETn == 0 && act.transfer == 0)) begin

        $display("\n\n------------------------------------------------------------------------------");

        $display("                PRESETn is applied it should go to idle state and hence latch                            ");

        $display("------------------------------------------------------------------------------");

        $display("transfer = %b | reset = %b | read_write = %b | write_addr = %d | read_addr = %d | wdata = %d | rdata = %d | pslverr = %d", act.transfer, act.PRESETn, act.READ_WRITE, act.apb_write_paddr, act.apb_read_paddr, act.apb_write_data, pass.apb_read_data_out, pass.PSLVERR);

        if((pass.apb_read_data_out == prev_val[0]) && (pass.PSLVERR == prev_err[0])) begin 

            $display("@ %0t : PRESETn = %b | Transfer = %b | apb_read_data_out = %d | PSLVERR = %b", $time, act.PRESETn ,act.transfer ,pass.apb_read_data_out ,pass.PSLVERR);

            match++;

            $display("                TEST PASSED @ %0t                             ", $time);

        end

        else begin

            $display("@ %0t : PRESETn = %b | Transfer = %b | apb_read_data_out = %d | PSLVERR = %b", $time, act.PRESETn ,act.transfer ,pass.apb_read_data_out ,pass.PSLVERR);

            mismatch++;

            $display("                TEST FAILED @ %0t                                ",$time);

        end

        $display("------------------------------------------------------------------------------\n\n");

    end // end of reset

        // start latch state

    else if(act.PRESETn == 1 && act.transfer == 0) begin

        $display("\n\n------------------------------------------------------------------------------");

          $display("                PRESETn = 1 and transfer = 0 is applied for latched state (state == IDLE)  ");

            $display("------------------------------------------------------------------------------");

                  $display("transfer = %b | reset = %b | read_write = %b | write_addr = %d | read_addr = %d | wdata = %d | rdata = %d | pslverr = %d", act.transfer, act.PRESETn, act.READ_WRITE, act.apb_write_paddr, act.apb_read_paddr, act.apb_write_data, pass.apb_read_data_out, pass.PSLVERR);

            if((pass.apb_read_data_out === prev_val[0])&& (pass.PSLVERR == prev_err[0])) begin 

              $display("@ %0t : PRESETn = %b | Transfer = %b | apb_read_data_out = %d | PSLVERR = %b", $time, act.PRESETn ,act.transfer ,pass.apb_read_data_out ,pass.PSLVERR);

              match++;

              $display("                TEST PASSED @ %0t                             ", $time);    

            end

            else begin

              $display("@ %0t : PRESETn = %b | Transfer = %b | apb_read_data_out = %d | PSLVERR = %b", $time, act.PRESETn ,act.transfer ,pass.apb_read_data_out ,pass.PSLVERR);

              mismatch++;

              $display("                TEST FAILED @ %0t                                ",$time);

            end

         $display("------------------------------------------------------------------------------\n\n");

    end // end of latch

        // when transfer happens

    else begin

          if(act.READ_WRITE == 0) begin  // Write

            mem[act.apb_write_paddr] = act.apb_write_data;

            $display("\n\n------------------------------------------------------------------------------");

            $display("                Write conition write operation                         ");

            $display("------------------------------------------------------------------------------");

            $display("@ %0t : Address written to = %d | data written to address = %d", $time ,act.apb_write_paddr ,act.apb_write_data);

          end

          else begin

                  if((act.apb_read_paddr[7:0] > 63) && pass.PSLVERR==1) begin

                      $display("------------------------------------------------------------------------------");

                      $display("                Read Condition is accessing outside memory and error is raised             ", $time);

                      $display("------------------------------------------------------------------------------");

                      $display("transfer = %b | reset = %b | read_write = %b | write_addr = %d | read_addr = %d | wdata = %d | rdata = %d | pslverr = %d", act.transfer, act.PRESETn, act.READ_WRITE, act.apb_write_paddr, act.apb_read_paddr, act.apb_write_data, pass.apb_read_data_out, pass.PSLVERR);

                      $display("@ %0t : Address read from = %d | data read from address = %d", $time ,act.apb_read_paddr ,pass.apb_read_data_out);

                      match++;

                      $display("                TEST PASSED @ %0t                                ",$time);

                  end

                  else if((act.apb_read_paddr[7:0] > 63) && pass.PSLVERR==0) begin

                      $display("------------------------------------------------------------------------------");

                      $display("                Read Condition is accessing outside memory and error is not raised             ", $time);

                      $display("------------------------------------------------------------------------------");

                      $display("transfer = %b | reset = %b | read_write = %b | write_addr = %d | read_addr = %d | wdata = %d | rdata = %d | pslverr = %d", act.transfer, act.PRESETn, act.READ_WRITE, act.apb_write_paddr, act.apb_read_paddr, act.apb_write_data, pass.apb_read_data_out, pass.PSLVERR);

                      $display("@ %0t : Address read from = %d | data read from address = %d", $time ,act.apb_read_paddr ,pass.apb_read_data_out);

                      mismatch++;

                      $display("                TEST FAILED @ %0t                                ",$time);

                  end

                  else if(pass.apb_read_data_out === mem[act.apb_read_paddr] && !pass.PSLVERR) begin

                      $display("------------------------------------------------------------------------------");

                      $display("                Read Condition read operation                             ", $time);

                      $display("------------------------------------------------------------------------------");

                      $display("transfer = %b | reset = %b | read_write = %b | write_addr = %d | read_addr = %d | wdata = %d | rdata = %d | pslverr = %d", act.transfer, act.PRESETn, act.READ_WRITE, act.apb_write_paddr, act.apb_read_paddr, act.apb_write_data, pass.apb_read_data_out, pass.PSLVERR);

                      $display("@ %0t : Address read from = %d | data read from address = %d", $time ,act.apb_read_paddr ,pass.apb_read_data_out);

                      match++;

                      $display("                TEST PASSED @ %0t                                ",$time);

                  end

                  else begin

                      $display("\n\n------------------------------------------------------------------------------");

                      $display("                Read Condition data output not matching with the written data                             ", $time);

                      $display("------------------------------------------------------------------------------");

                      $display("@ %0t : Address read from = %d | data read from address(dut) = %d | data in address(ref) = %d", $time ,act.apb_read_paddr ,pass.apb_read_data_out, mem[act.apb_read_paddr]);

                      mismatch++;

                      $display("                TEST FAILED @ %0t                                ",$time);

                  end

        end

        $display("------------------------------------------------------------------------------\n\n");

      end // end of transfer

      $display("Total number of transactions = %0d\nMatches = %0d\nMismatches = %0d",(match+mismatch),match,mismatch);

    end

  endtask
 
endclass

 
