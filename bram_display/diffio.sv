/// in to differential output
module diffio(
	input in,
	output logic op,
	output logic on
);

assign op = in;
assign on = ~in;

endmodule
