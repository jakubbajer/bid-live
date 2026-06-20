defmodule BidliveWeb.PageController do
  use BidliveWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
