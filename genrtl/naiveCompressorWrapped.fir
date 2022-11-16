circuit naiveCompressorWrapped :
  module naiveCompressor :
    input compressor_clk : Clock
    input compressor_rst : UInt<1>
    input compressor_in : { flip ready : UInt<1>, valid : UInt<1>, bits : { byte : UInt<8>, last : UInt<1>}}
    output compressor_out : { flip ready : UInt<1>, valid : UInt<1>, bits : { byte : UInt<8>, last : UInt<1>}}

    node _T = geq(compressor_in.bits.byte, UInt<7>("h41")) @[naiveCompressor.scala 26:13]
    node _T_1 = leq(compressor_in.bits.byte, UInt<7>("h5a")) @[naiveCompressor.scala 26:29]
    node _T_2 = and(_T, _T_1) @[naiveCompressor.scala 26:21]
    when _T_2 : @[naiveCompressor.scala 26:37]
      node _compressor_out_bits_byte_T = add(compressor_in.bits.byte, UInt<6>("h20")) @[naiveCompressor.scala 27:38]
      node _compressor_out_bits_byte_T_1 = tail(_compressor_out_bits_byte_T, 1) @[naiveCompressor.scala 27:38]
      compressor_out.bits.byte <= _compressor_out_bits_byte_T_1 @[naiveCompressor.scala 27:30]
    else :
      node _T_3 = geq(compressor_in.bits.byte, UInt<7>("h61")) @[naiveCompressor.scala 28:20]
      node _T_4 = leq(compressor_in.bits.byte, UInt<7>("h7a")) @[naiveCompressor.scala 28:36]
      node _T_5 = and(_T_3, _T_4) @[naiveCompressor.scala 28:28]
      when _T_5 : @[naiveCompressor.scala 28:45]
        node _compressor_out_bits_byte_T_2 = sub(compressor_in.bits.byte, UInt<6>("h20")) @[naiveCompressor.scala 29:38]
        node _compressor_out_bits_byte_T_3 = tail(_compressor_out_bits_byte_T_2, 1) @[naiveCompressor.scala 29:38]
        compressor_out.bits.byte <= _compressor_out_bits_byte_T_3 @[naiveCompressor.scala 29:30]
      else :
        compressor_out.bits.byte <= compressor_in.bits.byte @[naiveCompressor.scala 31:30]
    compressor_out.bits.last <= compressor_in.bits.last @[naiveCompressor.scala 33:28]
    compressor_out.valid <= compressor_in.valid @[naiveCompressor.scala 35:24]
    compressor_in.ready <= compressor_out.ready @[naiveCompressor.scala 36:23]

  module naiveCompressorWrapped :
    input S_AXIS_ACLK : Clock
    input S_AXIS_ARESTN : UInt<1>
    input M_AXIS_ACLK : Clock
    input M_AXIS_ARESTN : UInt<1>
    output S_AXIS : { flip TDATA : UInt<8>, flip TKEEP : UInt<1>, flip TLAST : UInt<1>, TREADY : UInt<1>, flip TVALID : UInt<1>}
    output M_AXIS : { TDATA : UInt<16>, TKEEP : UInt<2>, TLAST : UInt<1>, flip TREADY : UInt<1>, TVALID : UInt<1>}

    inst compressor of naiveCompressor @[naiveCompressor.scala 64:26]
    compressor.compressor_clk <= M_AXIS_ACLK @[naiveCompressor.scala 66:29]
    compressor.compressor_rst <= M_AXIS_ARESTN @[naiveCompressor.scala 67:29]
    compressor.compressor_in.bits.byte <= S_AXIS.TDATA @[naiveCompressor.scala 71:38]
    compressor.compressor_in.bits.last <= S_AXIS.TLAST @[naiveCompressor.scala 72:38]
    compressor.compressor_in.valid <= S_AXIS.TVALID @[naiveCompressor.scala 73:34]
    S_AXIS.TREADY <= compressor.compressor_in.ready @[naiveCompressor.scala 74:17]
    M_AXIS.TDATA <= compressor.compressor_out.bits.byte @[naiveCompressor.scala 76:16]
    M_AXIS.TLAST <= compressor.compressor_out.bits.last @[naiveCompressor.scala 77:16]
    M_AXIS.TKEEP <= UInt<2>("h3") @[naiveCompressor.scala 78:16]
    M_AXIS.TVALID <= compressor.compressor_out.valid @[naiveCompressor.scala 79:17]
    compressor.compressor_out.ready <= M_AXIS.TREADY @[naiveCompressor.scala 80:35]

