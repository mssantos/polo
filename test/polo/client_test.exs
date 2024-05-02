defmodule Polo.ClientTest do
  use Polo.DataCase

  alias Polo.Client
  alias Polo.Client.{Body, Header, Parameter, Request, Response}

  describe "new_request/0" do
    test "returns a new request struct" do
      request = Client.new_request()
      assert %Request{} = request
    end
  end

  describe "new_response/0" do
    test "returns a new response struct" do
      response = Client.new_response()
      assert %Response{} = response
    end
  end

  describe "change_request/2" do
    test "returns a request changeset" do
      request = Client.new_request()
      changeset = Client.change_request(request, %{method: "GET", path: "/api"})
      assert %Ecto.Changeset{} = changeset
    end
  end

  describe "create_request/2" do
    test "creates a request with given attributes" do
      request = Client.new_request()
      attrs = %{method: "get", url: "/api"}

      assert {:ok, %Request{} = new_request} = Client.create_request(request, attrs)
      assert new_request.url == "/api"
      assert new_request.method == :get
    end

    test "creates a request with embeds" do
      request = Client.new_request()

      attrs = %{
        method: "post",
        url: "/api",
        body: %{content: "{\"test\": \"my-test\"}"},
        headers: [
          %{
            name: "content-type",
            value: "application/json"
          },
          %{
            name: "Authorization",
            value: "Bearer PoloToken"
          }
        ],
        parameters: [
          %{
            name: "page",
            value: "1"
          },
          %{
            name: "sort",
            value: "asc"
          }
        ]
      }

      assert {:ok, %Request{} = new_request} = Client.create_request(request, attrs)
      assert new_request.url == "/api"
      assert new_request.method == :post
      assert match?(%Body{}, new_request.body)
      assert new_request.body.content == "{\"test\": \"my-test\"}"

      assert match?(
               [
                 %Header{name: "content-type", value: "application/json"},
                 %Header{name: "Authorization", value: "Bearer PoloToken"}
               ],
               new_request.headers
             )

      assert match?(
               [%Parameter{name: "page", value: "1"}, %Parameter{name: "sort", value: "asc"}],
               new_request.parameters
             )
    end

    test "returns error if given attributes are invalid" do
      request = Client.new_request()
      attrs = %{method: nil, url: nil}

      assert {:error, %Ecto.Changeset{valid?: false}} = Client.create_request(request, attrs)
    end

    test "returns error if given content body is an invalid JSON" do
      request = Client.new_request()
      attrs = %{method: "post", url: "/api", body: %{content: "{t: t}"}}

      assert {:error, %Ecto.Changeset{valid?: false}} = Client.create_request(request, attrs)
    end
  end

  describe "send_request/1" do
    test "sends a request and returns a response on success" do
      request = %Request{method: "get", url: "/api"}

      assert {:ok, %Response{} = response} = Client.send_request(request)
      assert response.status == 200
      assert response.body == "{\n  \"content\": {\n    \"test\": \"sandbox\"\n  }\n}"
    end

    test "returns a response with status 500 on error" do
      request = %Client.Request{method: nil, url: nil}

      assert {:ok, %Response{} = response} = Client.send_request(request)
      assert response.status == 500
      assert response.body == "Internal Server Error"
    end
  end

  describe "change_response/2" do
    test "changes response attributes" do
      response = Client.new_response()
      changeset = Client.change_response(response, %{status: 404})

      assert %Ecto.Changeset{} = changeset
    end
  end

  describe "create_response/2" do
    test "creates a response with given attributes" do
      response = Client.new_response()
      attrs = %{status: 200, body: "Success"}

      assert {:ok, %Client.Response{} = new_response} = Client.create_response(response, attrs)
      assert new_response.status == 200
      assert new_response.body == "Success"
    end

    test "returns error if given attributes are invalid" do
      response = Client.new_response()
      new_response = Client.create_response(response, %{})

      assert {:error, %Ecto.Changeset{valid?: false}} = new_response
    end
  end
end
