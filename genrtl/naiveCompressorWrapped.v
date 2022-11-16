module naiveCompressor(
  output       compressor_in_ready,
  input        compressor_in_valid,
  input  [7:0] compressor_in_bits_byte,
  input        compressor_in_bits_last,
  input        compressor_out_ready,
  output       compressor_out_valid,
  output [7:0] compressor_out_bits_byte,
  output       compressor_out_bits_last
);
  wire [7:0] _compressor_out_bits_byte_T_1 = compressor_in_bits_byte + 8'h20; // @[naiveCompressor.scala 27:38]
  wire [7:0] _compressor_out_bits_byte_T_3 = compressor_in_bits_byte - 8'h20; // @[naiveCompressor.scala 29:38]
  wire [7:0] _GEN_0 = compressor_in_bits_byte >= 8'h61 & compressor_in_bits_byte <= 8'h7a ?
    _compressor_out_bits_byte_T_3 : compressor_in_bits_byte; // @[naiveCompressor.scala 28:45 29:30 31:30]
  assign compressor_in_ready = compressor_out_ready; // @[naiveCompressor.scala 36:23]
  assign compressor_out_valid = compressor_in_valid; // @[naiveCompressor.scala 35:24]
  assign compressor_out_bits_byte = compressor_in_bits_byte >= 8'h41 & compressor_in_bits_byte <= 8'h5a ?
    _compressor_out_bits_byte_T_1 : _GEN_0; // @[naiveCompressor.scala 26:37 27:30]
  assign compressor_out_bits_last = compressor_in_bits_last; // @[naiveCompressor.scala 33:28]
endmodule
module naiveCompressorWrapped(
  input         S_AXIS_ACLK,
  input         S_AXIS_ARESTN,
  input         M_AXIS_ACLK,
  input         M_AXIS_ARESTN,
  input  [7:0]  S_AXIS_TDATA,
  input         S_AXIS_TKEEP,
  input         S_AXIS_TLAST,
  output        S_AXIS_TREADY,
  input         S_AXIS_TVALID,
  output [15:0] M_AXIS_TDATA,
  output [1:0]  M_AXIS_TKEEP,
  output        M_AXIS_TLAST,
  input         M_AXIS_TREADY,
  output        M_AXIS_TVALID
);
  wire  compressor_compressor_in_ready; // @[naiveCompressor.scala 64:26]
  wire  compressor_compressor_in_valid; // @[naiveCompressor.scala 64:26]
  wire [7:0] compressor_compressor_in_bits_byte; // @[naiveCompressor.scala 64:26]
  wire  compressor_compressor_in_bits_last; // @[naiveCompressor.scala 64:26]
  wire  compressor_compressor_out_ready; // @[naiveCompressor.scala 64:26]
  wire  compressor_compressor_out_valid; // @[naiveCompressor.scala 64:26]
  wire [7:0] compressor_compressor_out_bits_byte; // @[naiveCompressor.scala 64:26]
  wire  compressor_compressor_out_bits_last; // @[naiveCompressor.scala 64:26]
  naiveCompressor compressor ( // @[naiveCompressor.scala 64:26]
    .compressor_in_ready(compressor_compressor_in_ready),
    .compressor_in_valid(compressor_compressor_in_valid),
    .compressor_in_bits_byte(compressor_compressor_in_bits_byte),
    .compressor_in_bits_last(compressor_compressor_in_bits_last),
    .compressor_out_ready(compressor_compressor_out_ready),
    .compressor_out_valid(compressor_compressor_out_valid),
    .compressor_out_bits_byte(compressor_compressor_out_bits_byte),
    .compressor_out_bits_last(compressor_compressor_out_bits_last)
  );
  assign S_AXIS_TREADY = compressor_compressor_in_ready; // @[naiveCompressor.scala 74:17]
  assign M_AXIS_TDATA = {{8'd0}, compressor_compressor_out_bits_byte}; // @[naiveCompressor.scala 76:16]
  assign M_AXIS_TKEEP = 2'h3; // @[naiveCompressor.scala 78:16]
  assign M_AXIS_TLAST = compressor_compressor_out_bits_last; // @[naiveCompressor.scala 77:16]
  assign M_AXIS_TVALID = compressor_compressor_out_valid; // @[naiveCompressor.scala 79:17]
  assign compressor_compressor_in_valid = S_AXIS_TVALID; // @[naiveCompressor.scala 73:34]
  assign compressor_compressor_in_bits_byte = S_AXIS_TDATA; // @[naiveCompressor.scala 71:38]
  assign compressor_compressor_in_bits_last = S_AXIS_TLAST; // @[naiveCompressor.scala 72:38]
  assign compressor_compressor_out_ready = M_AXIS_TREADY; // @[naiveCompressor.scala 80:35]
endmodule
