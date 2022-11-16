circuit naiveCompressor :
  module naiveCompressor :
    input clock : Clock
    input reset : UInt<1>
    input compressor_in : { flip ready : UInt<1>, valid : UInt<1>, bits : { byte : UInt<8>, last : UInt<1>}}
    output compressor_out : { flip ready : UInt<1>, valid : UInt<1>, bits : { byte : UInt<8>, last : UInt<1>}}

    node _T = geq(compressor_in.bits.byte, UInt<7>("h41")) @[naiveCompressor.scala 21:13]
    node _T_1 = leq(compressor_in.bits.byte, UInt<7>("h5a")) @[naiveCompressor.scala 21:29]
    node _T_2 = and(_T, _T_1) @[naiveCompressor.scala 21:21]
    when _T_2 : @[naiveCompressor.scala 21:37]
      node _compressor_out_bits_byte_T = add(compressor_in.bits.byte, UInt<6>("h20")) @[naiveCompressor.scala 22:38]
      node _compressor_out_bits_byte_T_1 = tail(_compressor_out_bits_byte_T, 1) @[naiveCompressor.scala 22:38]
      compressor_out.bits.byte <= _compressor_out_bits_byte_T_1 @[naiveCompressor.scala 22:30]
    else :
      node _T_3 = geq(compressor_in.bits.byte, UInt<7>("h61")) @[naiveCompressor.scala 23:20]
      node _T_4 = leq(compressor_in.bits.byte, UInt<7>("h7a")) @[naiveCompressor.scala 23:36]
      node _T_5 = and(_T_3, _T_4) @[naiveCompressor.scala 23:28]
      when _T_5 : @[naiveCompressor.scala 23:45]
        node _compressor_out_bits_byte_T_2 = sub(compressor_in.bits.byte, UInt<6>("h20")) @[naiveCompressor.scala 24:38]
        node _compressor_out_bits_byte_T_3 = tail(_compressor_out_bits_byte_T_2, 1) @[naiveCompressor.scala 24:38]
        compressor_out.bits.byte <= _compressor_out_bits_byte_T_3 @[naiveCompressor.scala 24:30]
      else :
        compressor_out.bits.byte <= compressor_in.bits.byte @[naiveCompressor.scala 26:30]
    compressor_out.bits.last <= compressor_in.bits.last @[naiveCompressor.scala 28:28]
    compressor_out.valid <= compressor_in.valid @[naiveCompressor.scala 30:24]
    compressor_in.ready <= compressor_out.ready @[naiveCompressor.scala 31:23]

