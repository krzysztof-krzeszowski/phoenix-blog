# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pxblog.Repo.insert!(%Pxblog.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Pxblog.Repo
alias Pxblog.Role
alias Pxblog.User

role = %Role{}
  |> Role.changeset(%{name: "Admin", admin: true})
  |> Repo.insert!

admin = %User{}
  |> User.changeset(%{username: "admin", email: "asd@qwe.pl", password: "asdqwe123", password_confirmation: "asdqwe123", role_id: role.id})
  |> Repo.insert!
