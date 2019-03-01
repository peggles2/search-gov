class ElasticNewsItem
  extend Indexable
  DUBLIN_CORE_AGG_NAMES = [:contributor, :subject, :publisher]

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => {
      dynamic: :strict,
      _analyzer: { path: 'language' },
      properties: {
        language: { type: 'keyword', index: true },
        rss_feed_url_id: { type: 'integer' },
        title: { type: 'text',
                 term_vector: 'with_positions_offsets',
                 copy_to: 'bigram' },
        description: { type: 'text',
                       term_vector: 'with_positions_offsets',
                       copy_to: 'bigram' },
        body: { type: 'text',
                term_vector: 'with_positions_offsets',
                copy_to: 'bigram' },
        published_at: { type: 'date' },
        popularity: { type: 'integer' },
        link: ElasticSettings::KEYWORD,
        contributor: { type: 'text', analyzer: 'keyword' },
        subject: { type: 'text', analyzer: 'keyword' },
        publisher: { type: 'text', analyzer: 'keyword' },
        bigram: { type: 'text', analyzer: 'bigram_analyzer' },
        tags: { type: 'text', analyzer: 'keyword' },
        id: { type: 'integer', index: :not_analyzed } }
    }
  }

end
