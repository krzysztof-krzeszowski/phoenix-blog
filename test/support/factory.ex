defmodule Pxblog.Factory do
  use ExMachina.Ecto, repo: Pxblog.Repo

  alias Pxblog.Role
  alias Pxblog.User
  alias Pxblog.Post
  alias Pxblog.Comment

  def comment_factory do
    %Comment{
      author: "user",
      body: "some body",
      approved: false,
      post: build(:post)
    }
  end

  def post_factory do
    %Post{
      title: "Some title",
      body: "Some body",
      user: build(:user)
    }
  end

  def role_factory do
    %Role{
      name: sequence(:name, &"Test Role #{&1}"),
      admin: false
    }
  end

  def user_factory do
    %User{
      username: sequence(:username, &"User #{&1}"),
      email: "a@a.pl",
      password: "a",
      password_confirmation: "a",
      password_digest: Comeonin.Bcrypt.hashpwsalt("a"),
      role: build(:role)
    }
  end
end
