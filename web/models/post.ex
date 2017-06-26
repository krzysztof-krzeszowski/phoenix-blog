defmodule Pxblog.Post do
  use Pxblog.Web, :model

  schema "posts" do
    field :title, :string
    field :body, :string

    timestamps()

    belongs_to :user, Pxblog.User
    has_many :comments, Pxblog.Comment
  end


  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
    |> strip_unsafe_body(params)
  end

  defp strip_unsafe_body(model, %{"body" => nil}), do: model
  defp strip_unsafe_body(model, %{"body" => body}) do
    {:safe, clean_body} = Phoenix.HTML.html_escape(body)
    model |> put_change(:body, clean_body)
  end
  defp strip_unsafe_body(model, _), do: model
end
