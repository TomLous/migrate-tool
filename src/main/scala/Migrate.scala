import github4s.Github
import github4s.Github._
import github4s.jvm.Implicits._
import cats.implicits._
import cats._
import scalaj.http.HttpResponse
import com.typesafe.config.{Config, ConfigFactory}

object Migrate  extends App{

  import github4s.jvm.Implicits._



  val conf = ConfigFactory.load()
  val githubConf = conf.getConfig("github")

  val githubUser = githubConf.getString("username")
  val githubToken = Option(githubConf.getString("token"))

  val user1 = Github(githubToken).users.get(githubUser)

  user1.exec[Id, HttpResponse[String]]() match {
    case Left(e) => println(s"Something went wrong: ${e.getMessage}")
    case Right(r) => println(r.result)
  }


}
