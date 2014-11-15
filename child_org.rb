class ChildOrg
  attr_reader :name, :parent
  attr_accessor :access_list

  def initialize(name, parent)
    @name = name
    @parent = parent
    @access_list = {}
  end

  def assign(user, role)
    raise UnknownRoleError unless [:admin, :user, :denied].include?(role)
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
