// Scala script for processing data

import scala.io.Source
import scala.math._

case class DataPoint(id: Int, value: Double)

def processData(points: List[DataPoint]): Double = {
  points.map(_.value).sum / points.length
}

val data = List(
  DataPoint(1, 100.5),
  DataPoint(2, 200.3),
  DataPoint(3, 150.7)
)

println(s"Average: ${processData(data)}")
