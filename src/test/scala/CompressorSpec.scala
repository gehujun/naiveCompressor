package naive

import org.scalatest._
import org.scalatest.flatspec.AnyFlatSpec

import chisel3._
import chisel3.util._

import chiseltest._
import chiseltest.formal.Formal
import chiseltest.formal.BoundedCheck

import verifydata._

class CompressorTest extends Module{
    val io = IO(new Bundle {
        val in = Flipped(DecoupledIO(new CompressorInput()))
        val out = DecoupledIO(new CompressorOutput())
    })

    val compressor = Module(new naiveCompressor())
    compressor.compressor_clk := clock
    compressor.compressor_rst := reset


}

class AdderSpec extends AnyFlatSpec with ChiselScalatestTester{
  behavior of "AdderSpec"

  it should "Adder a + b = c" in { //one scalatest test
    test(new CompressorTest) {  dut => 
      // withAnnotations(Seq(WriteVcdAnnotation will save wave.vcd in the test_run_dir dir 
      //handle to our design
      
    }
  }
}

private object LocalHelpers {
implicit class CompressorTestDUT(c: CompressorTest) {
  def init() = {
    c.io.in.initSource()
    c.io.in.setSourceClock(c.clock)

    c.io.out.initSink()
    c.io.out.setSinkClock(c.clock)
  }

  def test(input_file : String, output_file : String, randomThrottle: Boolean = false) = {
    val is = new ByteStream(input_file)
    val oss = (0 until 8).map(i => new ByteStream(output_file + s".$i"))

    fork {
      val bd = new ByteBundle()
      var flag = true
      while(flag) {
        val (byte, last) = is.getByte()
        c.io.in.enqueue(bd.Lit(_.byte -> (byte & 0xFF).U, _.last -> last.B))
        
        flag = !last
      }
    }.fork {
      var last = false
      c.io.out.ready.poke(true.B)
      while(!last) {
        var valid = c.io.out.valid.peek().litToBoolean
        while(!valid) {
          c.clock.step()
          valid = c.io.out.valid.peek().litToBoolean
        }

        val idx = c.io.out.bits.idx.peek().litValue.toInt
        val (byte, streamEnd) = oss(idx).getByte()

        last = c.io.out.bits.last.peek().litToBoolean
        c.io.out.bits.byte.expect((byte & 0xFF).U)

        c.clock.step()
        if(randomThrottle) {
          c.io.out.ready.poke(false.B)
          c.clock.step(128)
          c.io.out.ready.poke(true.B)
        }
      }
    }.join()

    for(i <- 0 until 8)
      assert(oss(i).end())
  }
}
}
