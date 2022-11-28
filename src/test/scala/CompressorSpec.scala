package naive

import org.scalatest._
import org.scalatest.flatspec.AnyFlatSpec

import chisel3._
import chisel3.util._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._
import chisel3.stage.ChiselGeneratorAnnotation

import chiseltest._
import chiseltest.formal.Formal
import chiseltest.formal.BoundedCheck
import naive.verifydata.ByteStream

class CompressorTest extends Module {
    val io = IO(new Bundle{
        val in = Flipped(DecoupledIO(new CompressorInput))
        val out = DecoupledIO(new CompressorOutput)
    }) 

    val compressor = Module(new naiveCompressor)
    compressor.compressor_clk := clock
    compressor.compressor_rst := reset

    io.in <> compressor.compressor_in
    compressor.compressor_out <> io.out
}

class CompressorSpec extends AnyFlatSpec with ChiselScalatestTester{
    behavior of "compressor"

    it should "simple converte data" in {
        test(new CompressorTest).withAnnotations(Seq(VerilatorBackendAnnotation,WriteVcdAnnotation)) { dut =>
            dut.io.in.initSource()
            dut.io.in.setSourceClock(dut.clock)
            dut.io.out.initSink()
            dut.io.out.setSinkClock(dut.clock)

            dut.clock.setTimeout(1000 + (1 << 12))

            // read byte from file and compress
            // val is = new ByteStream("/home/hustsss/dataset/calgary/paper1")
            val is = new ByteStream("/home/hustsss/naiveCompressor/tmp/test.txt")
            val oss = new ByteStream("/home/hustsss/naiveCompressor/tmp/out.txt")
            fork {
                val bd = new CompressorInput()
                var flag = true
                while(flag){
                    val (byte, last) = is.getByte()
                    dut.io.in.enqueue(bd.Lit(_.byte -> (byte & 0xFF).U, _.last ->last.B))
                    flag = !last
                }
            }.fork {
                var last = false
                var idx = 0
                dut.io.out.ready.poke(true.B)
                while(!last) {
                    var valid = dut.io.out.valid.peek().litToBoolean
                    while(!valid){
                        dut.clock.step()
                        valid = dut.io.out.valid.peek().litToBoolean
                    }
                    var (byte,streamEnd) = oss.getByte()
                    
                    last = dut.io.out.bits.last.peek().litToBoolean
                    dut.io.out.bits.byte.expect((byte & 0xFF).U)
                    dut.clock.step()
                    // dut.io.out.bits.byte.expect(0.U)
                }
            }.join()
        }
    }
}