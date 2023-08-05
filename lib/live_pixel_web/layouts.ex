defmodule LivePixelWeb.Layouts do
  use LivePixelWeb, :html

  def render("root.html", assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="csrf-token" content={get_csrf_token()} />
        <.live_title suffix=" · LivePixelWeb">
          <%= assigns[:page_title] || "Demo" %>
        </.live_title>

        <link rel="stylesheet" href={~p"/assets/app.css"} />
        <script defer type="text/javascript" src={~p"/assets/app.js"}>
        </script>
      </head>
      <body class="bg-neutral-200">
        <%= @inner_content %>
      </body>
    </html>
    """
  end

  def render("live.html", assigns) do
    ~H"""
    <%= @inner_content %>
    """
  end
end
