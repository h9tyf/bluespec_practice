import RightShifterTypes::*;
import Gates::*;
import FIFO::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) b, Bit#(1) a);
    return orGate(andGate(a, sel),andGate(b, notGate(sel))); 
endfunction

function Bit#(32) multiplexer32(Bit#(1) sel, Bit#(32) a, Bit#(32) b);
	Bit#(32) res_vec = 0;
	for (Integer i = 0; i < 32; i = i+1)
	    begin
		res_vec[i] = multiplexer1(sel, a[i], b[i]);
	    end
	return res_vec; 
endfunction

function Bit#(n) multiplexerN(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
	Bit#(n) res_vec = 0;
	for (Integer i = 0; i < valueof(n); i = i+1)
	    begin
		res_vec[i] = multiplexer1(sel, a[i], b[i]);
	    end
	return res_vec; 
endfunction

module mkRightShifterPipelined (RightShifterPipelined);

		FIFO#(Bit#(32)) flag1 <- mkFIFO();
		FIFO#(Bit#(32)) data1 <- mkFIFO();
		FIFO#(Bit#(5)) shamt1 <- mkFIFO();
		FIFO#(Bit#(32)) flag2 <- mkFIFO();
		FIFO#(Bit#(32)) data2 <- mkFIFO();
		FIFO#(Bit#(5)) shamt2 <- mkFIFO();
		FIFO#(Bit#(32)) flag4 <- mkFIFO();
		FIFO#(Bit#(32)) data4 <- mkFIFO();
		FIFO#(Bit#(5)) shamt4 <- mkFIFO();
		FIFO#(Bit#(32)) flag8 <- mkFIFO();
		FIFO#(Bit#(32)) data8 <- mkFIFO();
		FIFO#(Bit#(5)) shamt8 <- mkFIFO();
		FIFO#(Bit#(32)) flag16 <- mkFIFO();
		FIFO#(Bit#(32)) data16 <- mkFIFO();
		FIFO#(Bit#(5)) shamt16 <- mkFIFO();
		FIFO#(Bit#(32)) res <- mkFIFO();
		rule shift1;
			Bit#(32) f = flag1.first();
			Bit#(32) d = data1.first();
			Bit#(5) s = shamt1.first();
			flag2.enq(f);
			data2.enq(multiplexer32(s[0], d, {f[0], d[31:1]}));
			shamt2.enq(s);
			
			flag1.deq();
			data1.deq();
			shamt1.deq();
		endrule

		
		rule shift2;
			Bit#(32) f = flag2.first();
			Bit#(32) d = data2.first();
			Bit#(5) s = shamt2.first();
			flag4.enq(f);
			data4.enq(multiplexer32(s[1], d, {f[1:0], d[31:2]}));
			shamt4.enq(s);
			
			flag2.deq();
			data2.deq();
			shamt2.deq();
		endrule

		
		rule shift4;
			Bit#(32) f = flag4.first();
			Bit#(32) d = data4.first();
			Bit#(5) s = shamt4.first();
			flag8.enq(f);
			data8.enq(multiplexer32(s[2], d, {f[3:0], d[31:4]}));
			shamt8.enq(s);
			
			flag4.deq();
			data4.deq();
			shamt4.deq();
		endrule

		
		rule shift8;
			Bit#(32) f = flag8.first();
			Bit#(32) d = data8.first();
			Bit#(5) s = shamt8.first();
			flag16.enq(f);
			data16.enq(multiplexer32(s[3], d, {f[7:0], d[31:8]}));
			shamt16.enq(s);
			
			flag8.deq();
			data8.deq();
			shamt8.deq();
		endrule

		
		rule shift16;
			Bit#(32) f = flag16.first();
			Bit#(32) d = data16.first();
			Bit#(5) s = shamt16.first();
			res.enq(multiplexer32(s[4], d, {f[15:0], d[31:16]}));
			
			flag16.deq();
			data16.deq();
			shamt16.deq();
		endrule

		

		method Action push(ShiftMode mode, Bit#(32) operand, Bit#(5) shamt);
			/* Write your code here */
			Bit#(32) result = operand;
			Bit#(32) flag = '0;
			Bit#(5) sh = shamt;
			if(mode == ArithmeticRightShift && result[31] == 1) begin
				flag = '1;
			end

			flag1.enq(flag);
			data1.enq(result);
			shamt1.enq(sh);
    	endmethod
	
		method ActionValue#(Bit#(32)) pull();
			/* Write your code here */
			Bit#(32) result = res.first();
			res.deq();
			return result;
		endmethod
endmodule

