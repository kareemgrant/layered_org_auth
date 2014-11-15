class RootOrg
  attr_reader :name
  attr_accessor :access_list

  def initialize(name)
    @name = name
    @access_list = {}
  end

  def create_org(name)
    Org.new(name, self)
  end

  def assign(user, role)
    access_list[user.id] = role
  end

  def access_level(user)
    access_list[user.id] || :user
  end
end
