import scala.concurrent.{ExecutionContext, Future}
import scala.collection.concurrent.TrieMap

case class User(id: Int, name: String, email: String)

trait UserRepository:
  def findById(id: Int)(using ExecutionContext): Future[Option[User]]
  def findAll()(using ExecutionContext): Future[List[User]]

class InMemoryUserRepository extends UserRepository:
  private val store = TrieMap(
    1 -> User(1, "Alice", "alice@example.com"),
    2 -> User(2, "Bob",   "bob@example.com"),
  )

  def findById(id: Int)(using ExecutionContext): Future[Option[User]] =
    Future.successful(store.get(id))

  def findAll()(using ExecutionContext): Future[List[User]] =
    Future.successful(store.values.toList.sortBy(_.id))

@main def run(): Unit =
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Await
  import scala.concurrent.duration.*

  val repo = InMemoryUserRepository()
  val user = Await.result(repo.findById(1), 1.second)
  println(user.map(u => s"Hello, ${u.name}!").getOrElse("Not found."))
