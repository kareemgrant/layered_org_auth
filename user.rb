class User
  attr :id, :name

  def initialize(name)
    @id = rand.to_s[2..9]
    @name = name
  end
end
