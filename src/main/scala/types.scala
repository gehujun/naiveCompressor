package naive

import chisel3._
import chisel3.util._
import chisel3.stage.ChiselGeneratorAnnotation


class CompressorInput extends Bundle {
    val byte = UInt(8.W)
    val last = Bool()
}

class CompressorOutput extends Bundle{
    val byte = UInt(8.W)
    val last = Bool()
}

