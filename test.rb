require 'minitest/autorun'

require_relative 'root_org'
require_relative 'org'
require_relative 'child_org'
require_relative 'user'

class LayeredOrgAuthTest < MiniTest::Unit::TestCase

  def setup
    @root = RootOrg.new('root')
    @user = User.new('kareem')
  end

  def test_default_role_when_none_is_assigned
    role = @root.access_level(@user)

    assert_equal(role, :user)
  end

  def test_assign_user_as_admin
    @root.assign(@user, :admin)
    role = @root.access_level(@user)

    assert_equal(role, :admin)
  end

  def test_assign_user_as_user
    @root.assign(@user, :user)
    role = @root.access_level(@user)

    assert_equal(role, :user)
  end

  def test_root_org_ability_to_create_org
    org = @root.create_org('org')

    assert_equal(@root, org.parent)
  end

  def test_user_assigned_as_admin_at_root_level_is_also_admin_at_org_level
    @root.assign(@user, :admin)
    org = @root.create_org('org')

    assert_equal(org.access_level(@user), :admin)
  end

  def test_user_assigned_as_admin_at_root_level_but_denied_at_org_level
    @root.assign(@user, :admin)
    org = @root.create_org('org')
    org.assign(@user, :denied)

    assert_equal(org.access_level(@user), :denied)
  end

  def test_user_assigned_as_admin_at_root_level_and_denied_at_one_org_level_while_admin_at_other_org_level
    @root.assign(@user, :admin)
    org_1 = @root.create_org('org_1')
    org_2 = @root.create_org('org_2')
    org_1.assign(@user, :denied)

    assert_equal(org_1.access_level(@user), :denied)
    assert_equal(org_2.access_level(@user), :admin)
  end

  def test_org_ability_to_create_child_org
    @root.assign(@user, :admin)
    org = @root.create_org('org')
    child_org = org.create_child_org('child_org')

    assert_equal(org, child_org.parent)
  end

  def test_admin_at_root_level_is_also_admin_at_child_org_level
    @root.assign(@user, :admin)
    org = @root.create_org('org')
    child_org = org.create_child_org('child_org')

    assert_equal(child_org.access_level(@user), :admin)
  end

  def test_denied_at_org_level_is_also_denied_at_child_org_level
    @root.assign(@user, :admin)
    org = @root.create_org('org')
    org.assign(@user, :denied)
    child_org = org.create_child_org('child_org')

    assert_equal(child_org.access_level(@user), :denied)
  end

  def test_admin_at_org_level_denied_at_one_child_level_but_not_other_child_level
    @root.assign(@user, :user)
    org = @root.create_org('org')
    org.assign(@user, :admin)

    child_org_1 = org.create_child_org('child_org_1')
    child_org_2 = org.create_child_org('child_org_2')

    child_org_1.assign(@user, :denied)

    assert_equal(child_org_1.access_level(@user), :denied)
    assert_equal(child_org_2.access_level(@user), :admin)
  end

  def test_no_user_can_have_more_than_one_role_on_any_specific_org_at_any_level
    @root.assign(@user, :user)
    @root.assign(@user, :admin)

    org = @root.create_org('org')
    org.assign(@user, :user)
    org.assign(@user, :denied)

    child_org = org.create_child_org('child_org')
    child_org.assign(@user, :admin)
    child_org.assign(@user, :user)

    assert_equal(@root.access_level(@user), :admin)
    assert_equal(org.access_level(@user), :denied)
    assert_equal(child_org.access_level(@user), :user)
  end
end
