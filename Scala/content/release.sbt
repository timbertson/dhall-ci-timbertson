import scala.util.Try

ThisBuild / publishTo := sonatypePublishToBundle.value
ThisBuild / version := Try(IO.read(new File("VERSION")).trim()).getOrElse("0.0.0-SNAPSHOT")
ThisBuild / versionScheme := Some("early-semver")

sonatypeProfileName := "net.gfxmonk"

credentials += Credentials(
  "Sonatype Nexus Repository Manager",
  "oss.sonatype.org",
  "timbertson",
  sys.env.getOrElse("SONATYPE_PASSWORD", "******"))

ThisBuild / licenses := Seq("MIT" -> url("http://www.opensource.org/licenses/mit-license.php"))

ThisBuild / developers := List(
  Developer(
    id    = "gfxmonk",
    name  = "Tim Cuthbertson",
    email = "tim@gfxmonk.net",
    url   = url("http://gfxmonk.net")
  )
)
