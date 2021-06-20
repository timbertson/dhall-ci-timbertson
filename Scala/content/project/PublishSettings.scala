import sbt._
import Keys._
import xerial.sbt.Sonatype.SonatypeKeys._

object ScalaProject {
  val hiddenProjectSettings = Seq(
    publish / skip := true,
  )

  def publicProjectSettings = Seq(
    publishTo := sonatypePublishToBundle.value,
    publishMavenStyle := true,
    Test / publishArtifact := false,
  )
}

