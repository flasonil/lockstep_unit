`define LOCKSTEP_ADDRESS 32'h10204400

module lockstep_unit
  #(
   parameter ID_WIDTH       = 5
  )
  (
   input logic                 clk_i,
   input logic                 rst_ni,
   
   input logic                 req_i,
   input logic [31:0]          addr_i,
   input logic                 wen_i,
   input logic [31:0]          wdata_i,
   input logic [3:0]           be_i,
   input logic [ID_WIDTH-1:0]  id_i,
   output logic                gnt_o,
    
   output logic                r_valid_o,
   output logic                r_opc_o,
   output logic [ID_WIDTH-1:0] r_id_o,
   output logic [31:0]         r_rdata_o
   
  );
   
   logic                  s_req,s_wen;
   logic [31:0]           s_addr;
   
   logic [31:0]           lockstep_ctrl, lockstep_ctrl_reg;    
      
   enum                   logic [1:0] {TRANS_IDLE,TRANS_RUN} CS, NS;
   
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

   

   
