defmodule Pxblog.PostView do
  use Pxblog.Web, :view

  def markdown(body) do
    {_, body, _} =
      body
      |> Earmark.as_html
    body |> raw
  end
end
