ThisBuild / version := IO.read(new File("VERSION")).trim()

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
