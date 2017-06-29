defmodule Pxblog.CommentHelperTest do
  use Pxblog.ModelCase

  alias Pxblog.{Comment, CommentHelper}

  import Pxblog.Factory

  setup do
    user = insert(:user)
    post = insert(:post)
    comment = insert(:comment)
    fake_socket = %{assigns: %{user: user.id}}
    {:ok, user: user, post: post, comment: comment, socket: fake_socket}
  end

  test "creates a comment for a post", %{post: post} do
    {:ok, comment} = CommentHelper.create(%{
      "postId" => post.id,
      "author" => "author",
      "body" => "body"
    }, %{})
    assert comment
    assert Repo.get!(Comment, comment.id)
  end

  test "does not approve a comment when not an authorized user", %{post: post, comment: comment} do
    {:error, message} = CommentHelper.approve(%{"postId" => post.id, "commentId" => comment.id}, %{})
    assert message = "User is not authorized"
  end
end
