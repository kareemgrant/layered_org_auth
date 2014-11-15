class ChildOrg < Org
  attr_reader :name, :parent
  attr_accessor :access_list
end
