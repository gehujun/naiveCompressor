module naiveCompressor(
  input        clock,
  input        reset,
  output       compressor_in_ready,
  input        compressor_in_valid,
  input  [7:0] compressor_in_bits_byte,
  input        compressor_in_bits_last,
  input        compressor_out_ready,
  output       compressor_out_valid,
  output [7:0] compressor_out_bits_byte,
  output       compressor_out_bits_last
);
  wire [7:0] _compressor_out_bits_byte_T_1 = compressor_in_bits_byte + 8'h20; // @[naiveCompressor.scala 22:38]
  wire [7:0] _compressor_out_bits_byte_T_3 = compressor_in_bits_byte - 8'h20; // @[naiveCompressor.scala 24:38]
  wire [7:0] _GEN_0 = compressor_in_bits_byte >= 8'h61 & compressor_in_bits_byte <= 8'h7a ?
    _compressor_out_bits_byte_T_3 : compressor_in_bits_byte; // @[naiveCompressor.scala 23:45 24:30 26:30]
  assign compressor_in_ready = compressor_out_ready; // @[naiveCompressor.scala 31:23]
  assign compressor_out_valid = compressor_in_valid; // @[naiveCompressor.scala 30:24]
  assign compressor_out_bits_byte = compressor_in_bits_byte >= 8'h41 & compressor_in_bits_byte <= 8'h5a ?
    _compressor_out_bits_byte_T_1 : _GEN_0; // @[naiveCompressor.scala 21:37 22:30]
  assign compressor_out_bits_last = compressor_in_bits_last; // @[naiveCompressor.scala 28:28]
endmodule
