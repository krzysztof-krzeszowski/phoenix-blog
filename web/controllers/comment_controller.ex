defmodule Pxblog.CommentController do
  use Pxblog.Web, :controller

  alias Pxblog.Comment
  alias Pxblog.Post

  plug :scrub_params, "comment" when action in [:create, :update]

  def create(conn, %{"comment" => comment_params, "post_id" => post_id}) do
    post = Repo.get!(Post, post_id) |> Repo.preload([:user, :comments])
    changeset = post
      |> build_assoc(:comments)
      |> Comment.changeset(comment_params)

    case Repo.insert(changeset) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment created successfully!")
        |> redirect(to: user_post_path(conn, :show, post.user, post))
      {:error, changeset} ->
        render(conn, Pxblog.PostView, "show.html", post: post, user: post.user, comment_changeset: changeset)
    end
  end

  def delete(conn, _), do: conn

  def update(conn, _), do: conn
end
