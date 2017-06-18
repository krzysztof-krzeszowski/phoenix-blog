defmodule Pxblog.SessionControllerTest do
  use Pxblog.ConnCase

  alias Pxblog.User
  alias Pxblog.TestHelper

  setup do
    {:ok, role} = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, _user} = TestHelper.create_user(role, %{email: "a@a.pl", username: "test", password: "test", password_confirmation: "test"})
    {:ok, conn: build_conn()}
  end

  test "shows the login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "creates a new user session for a valid user", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "test", password: "test"}
    assert get_session(conn, :current_user)
    assert get_flash(conn, :info) == "Sign in successful!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create a session with a bad login", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "a", password: "a"}
    assert get_flash(conn, :error) == "Invalid username/password combination!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "deletes the user session", %{conn: conn} do
    user = Repo.get_by(User, %{username: "test"})
    conn = delete conn, session_path(conn, :delete, user)
    refute get_session(conn, :current_user)
    assert get_flash(conn, :info) == "Signed out successfully!"
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
