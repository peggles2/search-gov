require 'spec_helper'

describe FeaturedCollectionLink do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to belong_to :featured_collection }

  it 'squishes title and url' do
    fc = FeaturedCollection.new(title: 'Search USA Blog',
                                status: 'active',
                                publish_start_on: '07/01/2011',
                                affiliate: @affiliate)
    fc.featured_collection_links.build(title: ' Blog Post    1 ',
                                       url: '   https://search.gov/blog-1   ',
                                       position: 0)
    fc.save!
    link = fc.featured_collection_links(true).first

    expect(link.title).to eq('Blog Post 1')
    expect(link.url).to eq('https://search.gov/blog-1')
  end

  describe "URL should have http(s):// prefix" do
    context "when the URL does not start with http(s):// prefix" do
      url = 'usasearch.howto.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each_with_index do |prefix, index|
        specify do
          featured_collection = FeaturedCollection.new(:title => 'Search USA Blog',
                                                       :status => 'active',
                                                       :publish_start_on => '07/01/2011',
                                                       :affiliate => @affiliate)
          featured_collection.featured_collection_links.build(:title => 'Did You Mean Roes or Rose?',
                                                              :url => "#{prefix}#{url}",
                                                              :position => index)
          featured_collection.save!
          expect(featured_collection.featured_collection_links.first.url).to eq("http://#{prefix}#{url}")
        end
      end
    end
  end
end
