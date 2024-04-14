require "pg"

class DatabasePersistence

  def initialize(logger)
    @logger = logger
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "todos")
          end
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    tuple = result.first

    todo_sql = "SELECT id, name, completed FROM todos WHERE list_id = $1"
    todo_result = query(todo_sql, id)
    todos_array = format_todos(todo_result)

    {id: tuple["id"], name: tuple["name"], todos: todos_array}
  end



  def all_lists
    sql = "SELECT * FROM lists"
    result = query(sql)

    result.map do |tuple|

      list_id = tuple["id"].to_i
      todo_sql = "SELECT id, name, completed FROM todos WHERE list_id = $1"
      todo_result = query(todo_sql, list_id)
      todos_array = format_todos(todo_result)

      {id: list_id.to_i, name: tuple["name"], todos: todos_array}
    end

  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, list_name)
  end

  def delete_list(id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, id)
  end

  def update_list(id, list_name)
    sql = "UPDATE lists SET name = $2 WHERE id = $1"
    query(sql, id, list_name)
  end

  def add_todo(list_id, text)
    sql = "INSERT INTO todos (name, list_id) VALUES ($1, $2)"
    query(sql, text, list_id)
  end

  def delete_todo(list_id, todo_id)
    sql = "DELETE FROM todos WHERE id = $1 AND list_id = $2"
    query(sql, todo_id, list_id)
  end

  def update_todo(list_id, todo_id, is_completed)
    sql = "UPDATE todos SET completed = $3 WHERE list_id = $1 AND id = $2"
    query(sql, list_id, todo_id, is_completed)
  end

  def complete_all_todos(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
  end

  private

  def completed?(str)
    str == 't'
  end

  def format_todos(todo_result)
    todo_result.map do |todo_tuple|
      { id: todo_tuple["id"].to_i,
        name: todo_tuple["name"],
        completed: completed?(todo_tuple["completed"]) }
    end
  end
end