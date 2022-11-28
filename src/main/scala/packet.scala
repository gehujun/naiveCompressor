package naive

import chisel3._
import chisel3.util._
import chisel3.stage.ChiselGeneratorAnnotation

import naive.CompressorInput
import naive.CompressorOutput

class packetOutput extends Module {
    val io = IO(new Bundle {
        val in = Flipped(DecoupledIO(new CompressorInput()))

        val out = DecoupledIO(new CompressorOutput())
    })

    // val sPassThrought :: aAlign :: sOutLen :: Nil = Enum(3)
    // val state = RegInit(sPassThrought)

    // switch(state){
    //     is(sPassThrought){
            
    //     }
    // }
    
    io.in.ready := io.out.ready
    io.out.valid := RegNext(io.in.valid, false.B)
    io.out.bits.byte := RegNext(io.in.bits.byte, 0.U)
    io.out.bits.last := RegNext(io.in.bits.last, false.B)
}