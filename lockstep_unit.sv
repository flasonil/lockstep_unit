`define LOCKSTEP_ADDRESS 32'h10204400

module lockstep_unit
  #(
   parameter ID_WIDTH       = 5
  )
  (
   input logic                 clk_i,
   input logic                 rst_ni,
   
   XBAR_PERIPH_BUS.Slave speriph_slave
  );

   logic                       req_i;
   logic [31:0]                addr_i;
   logic                       wen_i;
   logic [31:0]                wdata_i;
   logic [3:0]                 be_i;
   logic                       gnt_o;
   logic                       r_valid_o;
   logic                       r_opc_o;
   logic [ID_width-1:0]        id_i_o;
   logic [31:0]                r_rdata_o;
   
   logic                  s_req,s_wen;
   logic [31:0]           s_addr;
   
   logic [31:0]           lockstep_ctrl, lockstep_ctrl_reg;    
      
   enum                   logic [1:0] {TRANS_IDLE,TRANS_RUN} CS, NS;

   assign speriph_slave.gnt = gnt_o;
   assign req_i = speriph_slave.req;
   assign addr_i = speriph_slave.addr;
   assign wen_i = speriph_slave.wen;
   assign wdata_i = speriph_slave.wdata;
   assign be_i = speriph_slave.be;
   assign id_i = speriph_slave.id;
   assign speriph_slave.r_valid = r_valid_o;
   assign speriph_slave.r_opc = r_opc_o;
   assign speriph_slave.r_id = r_id_o;
   assign speriph_slave.r_rdata = r_rdata_o;
   
   always_ff @(posedge clk_i, negedge  rst_ni)
     begin
        if(rst_ni == 1'b0)
          CS <= TRANS_IDLE;
        else
          CS <= NS;
     end
   
   always_comb
     begin
	
	gnt_o = 1'b1;
	r_valid_o = 1'b0;
	
	case(CS)
	  
	  TRANS_IDLE:
	    begin
	       if (req_i == 1'b1)
		 NS = TRANS_RUN;
	       else
		 NS = TRANS_IDLE;
	    end
	  
	  TRANS_RUN:
	    begin
	       r_valid_o = 1'b1;
	       if (req_i == 1'b1)
		 NS = TRANS_RUN;
	       else
		 NS = TRANS_IDLE;
	    end
	  
	  default:
	    NS = TRANS_IDLE;
	  
	endcase
     end
always_ff @(posedge clk_i,negedge rst_ni) begin
	if(!rst_ni)begin
		s_req <= 1'b0;
		s_wen <= 1'b0;
		s_addr <= 32'h00000000;
		r_id_o <= 5'b00000;
	end else begin
		s_req <= req_i;
		s_wen <= wen_i;
		s_addr <= addr_i;
		r_id_o <= id_i;
	end
end
always_ff @(posedge clk_i,negedge rst_ni) begin
	if(~rst_ni)
		lockstep_ctrl_reg <= 32'h00000000;
	else
		lockstep_ctrl_reg <= lockstep_ctrl;
end

always_comb begin
	if(req_i && ~wen_i) begin
		if(addr_i == `LOCKSTEP_ADDRESS)
			lockstep_ctrl = wdata_i;
	end
	if(s_req && s_wen)begin
		if(s_addr == `LOCKSTEP_ADDRESS)
			r_rdata_o = lockstep_ctrl_reg;
	end
end

endmodule // lockstep_unit

   

   
