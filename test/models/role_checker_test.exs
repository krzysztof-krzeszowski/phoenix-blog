defmodule Pxblog.RoleCheckerTest do
  use Pxblog.ModelCase
  alias Pxblog.TestHelper
  alias Pxblog.RoleChecker

  test "is_admin? is true when user has an admin role" do
    {:ok, role} = TestHelper.create_role(%{name: "Admin", admin: true})
    {:ok, user} = TestHelper.create_user(role, %{username: "a", password: "a", password_confirmation: "a", email: "a@a.pl"})
    assert RoleChecker.is_admin?(user)
  end

  test "is_admin? is false when user has no admin role" do
    {:ok, role} = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, user} = TestHelper.create_user(role, %{username: "a", password: "a", password_confirmation: "a", email: "a@a.pl"})
    refute RoleChecker.is_admin?(user)
  end
end
