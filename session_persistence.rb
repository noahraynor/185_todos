class SessionPersistence

  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  def find_list(id)
    @session[:lists].find{ |list| list[:id] == id }
  end

  def all_lists
    @session[:lists]
  end

  def create_new_list(list_name)
    id = next_element_id(@session[:lists])
    @session[:lists] << { id: id, name: list_name, todos: [] }
  end

  def next_element_id(elements)
    max = elements.map { |todo| todo[:id] }.max || 0
    max + 1
  end

  def delete_list(id)
    @session[:lists].reject! { |list| list[:id] == id }
  end

  def update_list(id, list_name)
    list = find_list(id)
    list[:name] = list_name
  end

  def add_todo(list_id, text)
    list = find_list(list_id)
    todo_id = next_element_id(list[:todos])
    list[:todos] << { id: todo_id, name: text, completed: false }
  end

  def delete_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo(list_id, todo_id, is_completed)
    list = find_list(list_id)
    todo = list[:todos].find { |todo| todo[:id] == todo_id }
    todo[:completed] = is_completed
  end

  def complete_all_todos(list_id)
    list = find_list(list_id)
    list[:todos].each do |todo|
      todo[:completed] = true
    end
  end
end