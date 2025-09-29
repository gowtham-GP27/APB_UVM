`include "defines.svh"

class apb_sequence extends uvm_sequence#(apb_seq_item);
  
  // declaring a seq_item that has to be sent to the driver
  apb_seq_item req;
  
  // factory registeration
  `uvm_object_utils(apb_sequence)
  
  //new constructor
  function new(string name = "apb_sequence");
    super.new("apb_sequence");
  endfunction
  
  virtual task body();
    
    req = apb_seq_item::type_id::create("req");//creating seq_item
    repeat(`num_of_txns) begin
      start_item(req);
      assert(req.randomize());
      `uvm_info(get_type_name(), $sformatf("| SEQUENCE GENERATED | READ_WRITE = %0b | apb_write_paddr = %9b | apb_read_paddr = %9b | apb_write_data = %8d | ",req.READ_WRITE,req.apb_write_paddr,req.apb_read_paddr, req.apb_write_data),UVM_MEDIUM);
      finish_item(req);
    end
  endtask
endclass

class  write_read_seq extends uvm_sequence#(apb_seq_item);
  
  `uvm_object_utils(write_read_seq)
  
  bit [8:0] temp_read_paddr;
  
  function new(string name = "write_read_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(`num_of_txns) begin
      `uvm_do_with(req,{req.transfer == 1; req.PRESETn == 1;req.READ_WRITE == 0; })
      temp_read_paddr = req.apb_write_paddr;
      `uvm_do_with(req, {req.transfer == 1;req.PRESETn == 1;req.READ_WRITE == 1; req.apb_read_paddr == temp_read_paddr;})      
    end    
  endtask  
endclass

class transfer_off extends uvm_sequence#(apb_seq_item);
  `uvm_object_utils(transfer_off)
  function new(string name = "transfer_off");
    super.new(name);
  endfunction
  bit [8:0]temp_read_paddr;
  task body();
    repeat(2)begin
      `uvm_do_with(req,{req.READ_WRITE ==0;req.apb_write_paddr inside {[0:511]};req.PRESETn == 1;})
      temp_read_paddr=req.apb_write_paddr;
      `uvm_do_with(req,{req.transfer == 0;})
      `uvm_do_with(req,{req.READ_WRITE ==1;req.apb_read_paddr == temp_read_paddr;})
    end
  endtask
endclass

class error_write extends apb_sequence;
 `uvm_object_utils(error_write)

  function new(string name ="error_write");
    super.new(name);
  endfunction: new

 virtual task body();
  repeat(3) begin
    req = apb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize()with{req.READ_WRITE == 0; req.transfer == 1;req.PRESETn == 1;};
    req.apb_write_paddr = 9'bxxxxxxxx;
    finish_item(req);
  end
   repeat(3) begin
    req = apb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize()with{req.READ_WRITE == 0; req.transfer == 1;req.PRESETn == 1;};
    req.apb_write_data = 8'bxxxxxxxx;
    finish_item(req);
  end
   repeat(3) begin
    req = apb_seq_item::type_id::create("req");
    start_item(req);
    req.randomize()with{req.READ_WRITE == 1; req.transfer == 1;req.PRESETn == 1;};
    req.apb_read_paddr = 9'bxxxxxxxxx;
    finish_item(req);
   end
  
 endtask: body
endclass: error_write

class write_override extends uvm_sequence#(apb_seq_item);
  `uvm_object_utils(write_override)
  bit [8:0] read_addr;

  function new(string name ="write_override");
    super.new(name);
  endfunction: new

  task body();
  // write to same address twice and then read from it
  `uvm_do_with(req,{req.READ_WRITE == 0; req.transfer == 1;})
    read_addr = req.apb_write_paddr;
  `uvm_do_with(req,{req.READ_WRITE == 0; req.apb_read_paddr == read_addr;req.transfer == 1;})

  // READ from the same address
  `uvm_do_with(req,{req.READ_WRITE == 1; req.apb_read_paddr == read_addr;req.transfer == 1;})
  endtask: body
endclass: write_override

class wr_rd_ov extends uvm_sequence#(apb_seq_item);
 `uvm_object_utils(wr_rd_ov)

  bit [8:0]read_addr;
 function new(string name = "wr_rd_ov");
  super.new(name);
 endfunction

 virtual task body();
  repeat(3) begin
    `uvm_do_with(req,{req.READ_WRITE==0; req.transfer==1; req.apb_write_paddr == 40;})
     read_addr = req.apb_write_paddr;
  end
 repeat(4) begin
 `uvm_do_with(req,{req.READ_WRITE==1; req.transfer==1; req.apb_read_paddr == read_addr;})
 end
 endtask

endclass : wr_rd_ov

class random_write extends uvm_sequence#(apb_seq_item);
 `uvm_object_utils(random_write)

  function new(string name ="random_write");
    super.new(name);
  endfunction: new

 task body();
  repeat(3) begin
  //Selecting the random slave, random address, random wdata
  `uvm_do_with(req,{req.READ_WRITE == 0; req.transfer == 1;})
  //Selecting a slave and randomising the addr and write data
  // slave 1 is selected
  `uvm_do_with(req,{req.READ_WRITE == 0; req.transfer == 1; req.apb_write_paddr[8] == 1;})
  `uvm_do_with(req,{req.READ_WRITE == 0; req.transfer == 1; req.apb_write_paddr[8] == 1;})
  end
 endtask: body
endclass: random_write

class direct_seq extends uvm_sequence#(apb_seq_item);

  `uvm_object_utils(direct_seq)

  function new(string name = "direct_seq");
    super.new(name);
  endfunction

  task body();
    repeat(5) begin
      start_item(req);
      req.randomize() with {req.PRESETn == 1; req.transfer == 0; req.READ_WRITE == 0;};
      req.apb_write_paddr = 8'bxxxxxxxx;
      finish_item(req);
    end
  endtask

endclass


class regression_seq extends uvm_sequence#(apb_seq_item);
 `uvm_object_utils(regression_seq)

  error_write seq2;
  write_read_seq seq1;
  transfer_off seq3;
  write_override seq4;
  wr_rd_ov seq5;
  random_write seq6;
  direct_seq seq7;
  function new(string name ="reqression_seq");
    super.new(name);
  endfunction: new

 virtual task body();
  begin
    `uvm_do(seq2)
    `uvm_do(seq1)
    `uvm_do(seq3)
    `uvm_do(seq4)
    `uvm_do(seq5)
    `uvm_do(seq6)
    `uvm_do(seq7)
  end
 endtask: body
endclass

