defmodule Couchdb.Connector.TestPrep do
  alias Couchdb.Connector.TestSupport

  alias Couchdb.Connector.TestConfig
  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.Admin
  alias Couchdb.Connector.UrlHelper

  def ensure_database do
    {:ok, _} = TestSupport.retry_on_error(fn() ->
      HTTPoison.put "#{TestConfig.database_url}", "{}", [Headers.json_header]
    end)
  end

  def delete_database do
    {:ok, _} = TestSupport.retry_on_error(fn() ->
      HTTPoison.delete("#{TestConfig.database_url}")
    end)
  end

  def ensure_document(doc, id) do
    {:ok, _} = TestSupport.retry_on_error(fn() ->
      HTTPoison.put "#{TestConfig.database_url}/#{id}", doc, [Headers.json_header]
    end)
  end

  def ensure_view(design_name, code) do
    {:ok, _} = TestSupport.retry_on_error(fn() ->
      HTTPoison.put "#{TestConfig.database_url}/_design/#{design_name}", code, [Headers.json_header]
    end)
  end

  # TODO: rev .... I will have to capture the revision from
  #            the authors work. This is because attachments 
  #            are first attached to a paarticular revision of
  #            a document then they continue to follow new revisions. So we
  #            want the latest (test) revision to attach too.
  #
  #            Note: we are using the query string form of attachments
  #            you can also use the IF-Match header (see
  #            http://docs.couchdb.org/en/2.0.0/api/document/attachments.html
  def ensure_test_attachment(doc_id, rev) do
    {:ok, _} = TestSupport.retry_on_error(fn() -> 
      image_loc = Application.get_env(:couchdb_connector, :attachment)
      att = test_att_name(image_loc)
      headers = ["Content-Type": "image/png"]
      att_url = "#{TestConfig.database_url}/#{doc_id}/#{att}?rev=#{rev}"
      HTTPoison.put(att_url, {:file, image_loc}, 
                     [{"Content-Type", "image/png"}])
    end)
  end

  def delete_test_attachment(doc_id, rev) do
    {:ok, _} = TestSupport.retry_on_error(fn() -> 
      image_loc = Application.get_env(:couchdb_connector, :attachment)
      att = test_att_name(image_loc)
      att_url = "#{TestConfig.database_url}/#{doc_id}/#{att}?rev=#{rev}"
      HTTPoison.delete(att_url, {:file, image_loc}) 
    end)
  end

  # given the location of the image on the disk, extract the image name
  # and use that as our att name.
  defp test_att_name(image_loc) do
    image_loc 
    |> String.reverse
    |> String.split("/")
    |> hd
  end

  # TODO: duplicate functions
  defp test_admin do
    %{user: "anna", password: "secret"}
  end

  defp test_user do
    %{user: "jan", password: "relax"}
  end

  def ensure_test_user do
    TestSupport.retry_on_error(fn() ->
      Admin.create_user(TestConfig.database_properties, test_admin, test_user, ["members"])
    end)
  end

  def delete_test_user do
    case Admin.user_info(TestConfig.database_properties, test_admin, "jan") do
      {:ok, body} ->
        {:ok, body_map} = Poison.decode body
        HTTPoison.delete UrlHelper.user_url(TestConfig.database_properties, test_admin, "jan")
          <> "?rev=#{body_map["_rev"]}"
      {:error, body} ->
        {:error, body}
    end
  end

  def delete_test_admin do
    case Admin.admin_info(TestConfig.database_properties, test_admin) do
      {:ok, _} ->
        HTTPoison.delete(UrlHelper.admin_url(TestConfig.database_properties, "anna", "secret"))
      {:error, body} ->
        {:error, body}
    end
  end

  def ensure_test_admin do
    TestSupport.retry_on_error(fn() ->
      Admin.create_admin(TestConfig.database_properties, test_admin)
    end)
  end

  def ensure_test_security do
    TestSupport.retry_on_error(fn() ->
      Admin.set_security(TestConfig.database_properties, test_admin, ["anna"], ["jan"])
    end)
  end

  def secure_database do
    ensure_test_admin
    ensure_test_user
    ensure_test_security
  end
end
