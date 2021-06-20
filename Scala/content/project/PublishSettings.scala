import sbt._
import Keys._
import xerial.sbt.Sonatype.SonatypeKeys._

object ScalaProject {
  val hiddenProjectSettings = Seq(
    publish := {},
    publishLocal := {}
  )

  def publicProjectSettings(repoName: String) = Seq(
    publishTo := sonatypePublishToBundle.value,
    publishMavenStyle := true,
    Test / publishArtifact := false,

    licenses := Seq("MIT" -> url("http://www.opensource.org/licenses/mit-license.php")),
    homepage := Some(url(s"https://github.com/timbertson/${repoName}")),

    scmInfo := Some(
      ScmInfo(
        url("https://github.com/timbertson/capsul"),
        s"scm:git@github.com:timbertson/${repoName}.git"
      )
    ),

    developers := List(
      Developer(
        id    = "gfxmonk",
        name  = "Tim Cuthbertson",
        email = "tim@gfxmonk.net",
        url   = url("http://gfxmonk.net")
      )
    ),

    sonatypeProfileName := "net.gfxmonk",

    credentials += Credentials(
      "Sonatype Nexus Repository Manager",
      "oss.sonatype.org",
      "timbertson",
      sys.env.getOrElse("SONATYPE_PASSWORD", "******"))
  )
}