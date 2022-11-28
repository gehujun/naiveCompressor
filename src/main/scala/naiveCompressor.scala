package naive

import chisel3._
import chisel3.util._
import chisel3.stage.ChiselGeneratorAnnotation

import naive.CompressorInput
import naive.CompressorOutput

class naiveCompressor extends RawModule{
  val compressor_clk = IO(Input(Clock()))
  val compressor_rst = IO(Input(Bool()))

  val compressor_in = IO(Flipped(DecoupledIO(new CompressorInput() )))
  val compressor_out = IO(DecoupledIO(new CompressorOutput() ))

  withClockAndReset(compressor_clk, compressor_rst){
    val byte = RegNext(compressor_in.bits.byte, 0.U) 

    when(byte >= 65.U && byte <= 90.U){
        compressor_out.bits.byte := byte + 32.U
    } .elsewhen(byte >= 97.U && byte <= 122.U){
        compressor_out.bits.byte := byte - 32.U
    } .otherwise{
        compressor_out.bits.byte := byte
    }

    compressor_out.bits.last := RegNext(compressor_in.bits.last,false.B)

    compressor_out.valid := RegNext(compressor_in.valid, false.B)
    compressor_in.ready := RegNext(compressor_out.ready, true.B)
    // compressor_in.ready := true.B

    // compressor_out.bits.last := compressor_in.bits.last
  }
}

class naiveCompressorWrapped extends RawModule{
  val S_AXIS_ACLK = IO(Input(Clock()))
  val S_AXIS_ARESTN = IO(Input(Bool()))
  
  val M_AXIS_ACLK = IO(Input(Clock()))
  val M_AXIS_ARESTN = IO(Input(Bool()))

  val S_AXIS = IO(new Bundle {
    val TDATA = Input(UInt(8.W))
    val TKEEP = Input(UInt(1.W))
    val TLAST = Input(Bool())
    val TREADY = Output(Bool())
    val TVALID = Input(Bool())
  })

  val M_AXIS = IO(new Bundle {
    val TDATA = Output(UInt(8.W))
    val TKEEP = Output(UInt(2.W))
    val TLAST = Output(Bool())
    val TREADY = Input(Bool())
    val TVALID = Output(Bool())
  })
  
  var packetout : packetOutput = null
  withClockAndReset(M_AXIS_ACLK, ~M_AXIS_ARESTN){
   packetout = Module(new packetOutput) 
  }


  var compressor = Module(new naiveCompressor)
  
  compressor.compressor_clk := M_AXIS_ACLK
  compressor.compressor_rst := ~M_AXIS_ARESTN

  compressor.compressor_in.bits.byte := S_AXIS.TDATA
  compressor.compressor_in.bits.last := S_AXIS.TLAST
  compressor.compressor_in.valid := S_AXIS.TVALID 
  S_AXIS.TREADY := compressor.compressor_in.ready

  packetout.io.in <> compressor.compressor_out

  M_AXIS.TDATA := packetout.io.out.bits.byte
  M_AXIS.TLAST := packetout.io.out.bits.last
  M_AXIS.TKEEP := "b11".U
  M_AXIS.TVALID := packetout.io.out.valid
  packetout.io.out.ready := M_AXIS.TREADY

  // M_AXIS.TDATA := compressor.compressor_out.bits.byte
  // M_AXIS.TLAST := compressor.compressor_out.bits.last
  // M_AXIS.TKEEP := "b11".U
  // M_AXIS.TVALID := compressor.compressor_out.valid
  // compressor.compressor_out.ready := M_AXIS.TREADY
}

import chisel3.stage.ChiselStage
object GetCompressorVerilog extends App{
  (new ChiselStage).execute(
  Array(
    "-X", "verilog", 
    "--target-dir", "genrtl"), 
  Seq(ChiselGeneratorAnnotation(() => new naiveCompressorWrapped())))
}