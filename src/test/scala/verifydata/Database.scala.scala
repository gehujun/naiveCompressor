package naive.verifydata

import java.io._
import scala.io.Source

import com.github.tototoshi.csv._

class VerifyData(file : String) {
  val source = Source.fromFile(file)
  val data = source.getLines().map(_.split(",")).toArray
  source.close
}

class VerifyDataset(file: String) {
  val reader = CSVReader.open(new File(file))

  def forEachBatch(batchSize: Int)(f: (IndexedSeq[Seq[Int]], Boolean) => Unit) = {
    val it = reader.iterator
    var data = it.take(batchSize).map{ _.map(_.toInt)}.toIndexedSeq
    var last = false
    do {
      val dataNxt = it.take(batchSize).map{ _.map(_.toInt)}.toIndexedSeq
      last = dataNxt.isEmpty

      f(data, last)

      data = dataNxt
    } while(!last)
  }

  def forAll(f: IndexedSeq[Seq[Int]] => Unit) = {
    val data = reader.all().map{ _.map(_.toInt)}.toIndexedSeq

    f(data)
  }
}

class ByteStream(pathname : String) {
  private val is = new FileInputStream(pathname)
  private val buf = new Array[Byte](1024)

  private var n = 0
  private var idx = 0

  private var last = false
  def getByte() : (Byte, Boolean) = {
    val bufEnd = idx == n
    val streamEnd = is.available() == 0
    
    if(bufEnd && !streamEnd) {
      n = is.read(buf)
      idx = 0
    }

    if(!last) {
      idx = idx + 1
      last = streamEnd && idx == n
    }
    
    (buf(idx - 1), last)
  }

  def end() = idx == n && is.available() == 0
}
