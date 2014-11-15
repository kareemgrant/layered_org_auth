class Org
  attr_reader :name, :parent
  attr_accessor :access_list

  def initialize(name, parent)
    @name = name
    @access_list = {}
    @parent = parent
  end

  def create_child_org(name)
    ChildOrg.new(name, self)
  end

  def assign(user, role)
    access_list[user.id] = role
  end

  def access_level(user)
    permissions = []

    permissions << parent.access_level(user)
    permissions << access_list[user.id]
    permissions = permissions.compact

    permissions.last || :user
  end
end
