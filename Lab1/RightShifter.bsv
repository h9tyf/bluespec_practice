import RightShifterTypes::*;
import Gates::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
	// Part 1: Re-implement this function using the gates found in the Gates.bsv file
	// return (sel == 0)?a:b; 
	return orGate(andGate(notGate(sel), a), andGate(sel, b));
endfunction

function Bit#(32) multiplexer32(Bit#(1) sel, Bit#(32) a, Bit#(32) b);
	// Part 2: Re-implement this function using static elaboration (for-loop and multiplexer1)
	//return (sel == 0)?a:b; 
	Bit#(32) res;
	for(Integer i = 0; i < 32; i = i+1)
	begin
		res[i] = multiplexer1(sel, a[i], b[i]);
	end
	return res;
endfunction

function Bit#(n) multiplexerN(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
	// Part 3: Re-implement this function as a polymorphic function using static elaboration
	//return (sel == 0)?a:b;
	Bit#(n) res;
	for(Integer i = 0; i < valueOf(n); i = i+1)
	begin
		res[i] = multiplexer1(sel, a[i], b[i]);
	end
	return res;
endfunction


module mkRightShifter (RightShifter);
    method Bit#(32) shift(ShiftMode mode, Bit#(32) operand, Bit#(5) shamt);
	// Parts 4 and 5: Implement this function with the multiplexers you implemented
        Bit#(32) result = operand;
	Bit#(32) flag = '0;
	if(mode == ArithmeticRightShift && result[31] == 1) begin
		flag = '1;
	end
	result = multiplexer32(shamt[0], result, {flag[0], result[31:1]});
	result = multiplexer32(shamt[1], result, {flag[1:0], result[31:2]});
	result = multiplexer32(shamt[2], result, {flag[3:0], result[31:4]});
	result = multiplexer32(shamt[3], result, {flag[7:0], result[31:8]});
	result = multiplexer32(shamt[4], result, {flag[15:0], result[31:16]});
        return result;   
    endmethod
endmodule

