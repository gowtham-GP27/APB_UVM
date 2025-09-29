class apb_driver extends uvm_driver#(apb_seq_item);
  
  `uvm_component_utils(apb_driver)
  virtual apb_intf vif;
  apb_seq_item req;
  function new(string name = "apb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
      `uvm_error(get_type_name(), "Failed to get Interface");
    
  endfunction
  
  task drive_inputs();
    if(req.transfer) begin : if_main
      if(req.READ_WRITE == 0) begin :if1
      	vif.apb_write_paddr <= req.apb_write_paddr;
        vif.apb_write_data <= req.apb_write_data;
        vif.READ_WRITE <= req.READ_WRITE;
        vif.transfer <= req.transfer;
        vif.PRESETn <= req.PRESETn;
        `uvm_info(get_type_name(), $sformatf("| SEQUENCE DRIVEN | READ_WRITE = %0b | apb_write_paddr = %0d | apb_write_data = %0d | ",req.READ_WRITE,req.apb_write_paddr,req.apb_write_data),UVM_MEDIUM);
      end : if1
      else begin : e1
        vif.apb_read_paddr <= req.apb_read_paddr;
        //vif.apb_write_data <= req.apb_write_data;        
        vif.READ_WRITE <= req.READ_WRITE;
        `uvm_info(get_type_name(), $sformatf("| SEQUENCE DRIVEN | READ_WRITE = %0b | apb_read_paddr = %0d |",req.READ_WRITE,req.apb_read_paddr),UVM_MEDIUM);
      end : e1      
    end : if_main
    
    else begin : else_main
      vif.apb_write_paddr <= 0;
      vif.apb_write_data <= 0;      
      vif.READ_WRITE <= 0;
      vif.apb_read_paddr <= 0;
      vif.transfer <= 0;
    end : else_main
  endtask
      
  task run_phase(uvm_phase phase);
    forever begin : f1
      seq_item_port.get_next_item(req);
      drive_inputs();
      seq_item_port.item_done();
      repeat(3)@(vif.drv_cb);
    end : f1
  endtask  
endclass

