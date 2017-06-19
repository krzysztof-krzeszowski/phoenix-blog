defmodule Pxblog.UserControllerTest do
  use Pxblog.ConnCase

  alias Pxblog.User

  @valid_create_attrs %{email: "asd@a.pl", password: "asd", password_confirmation: "asd", username: "asd"}
  @valid_attrs %{email: "asd@a.pl", username: "asd"}
  @invalid_attrs %{}

  setup do
    user_role = insert(:role)
    user = insert(:user, role: user_role)

    admin_role = insert(:role, admin: true)
    admin_user = insert(:user, role: admin_role)

    {:ok, conn: build_conn(), user: user, admin_user: admin_user, user_role: user_role, admin_role: admin_role}
  end

  defp valid_create_attrs(role) do
    Map.put(@valid_create_attrs, :role_id, role.id)
  end

  defp login_user(conn, user) do
    post conn, session_path(conn, :create), user: %{username: user.username, password: user.password}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  @tag admin: true
  test "renders form for new resources", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = get(conn, user_path(conn, :new))
    assert html_response(conn, 200) =~ "New user"
  end

  @tag admin: true
  test "redirects from new form when not admin", %{conn: conn, user: user} do
    conn = login_user(conn, user)
    conn = get conn, user_path(conn, :new)
    assert get_flash(conn, :error) == "You are not authorized to create new users!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "creates resource and redirects when data is valid", %{conn: conn, user_role: user_role, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = post conn, user_path(conn, :create), user: valid_create_attrs(user_role)
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "redirects from creating user when not admin", %{conn: conn, user_role: user_role, user: user} do
    conn = login_user(conn, user)
    conn = post conn, user_path(conn, :create), user: valid_create_attrs(user_role)
    assert get_flash(conn, :error) == "You are not authorized to create new users!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  @tag admin: true
  test "renders form for editing chosen resource when logged in as that user", %{conn: conn, user: user} do
    conn = login_user(conn, user)
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "renders form for editing chosen resource when logged in as admin", %{conn: conn, user: user, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid when logged in as that user", %{conn: conn, user_role: user_role, user: user} do
    conn = login_user(conn, user)
    conn = put conn, user_path(conn, :update, user), user: valid_create_attrs(user_role)
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    conn = login_user(conn, user)
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource when logged in as that user", %{conn: conn, user: user} do
    conn = login_user(conn, user)
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
