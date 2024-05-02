defmodule PoloWeb.ClientLiveTest do
  use PoloWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "ClientLive" do
    test "connected mount", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "data-component=\"client\""
    end
  end

  # TODO
end
