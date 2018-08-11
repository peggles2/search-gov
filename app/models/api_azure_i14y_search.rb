class ApiAzureI14ySearch < ApiI14ySearch
  protected

  def as_json_result_hash(result)
    {
      title: result.title,
      url: result.link,
      display_url: result.link,
      snippet: as_json_build_snippet(result.description),
    }
  end
end
