require 'spec_helper'

describe FederalRegisterDocumentsHelper do

  let(:document) do
    mock_model(
      FederalRegisterDocument,
      document_type: 'Notice',
      publication_date: 'Mon, 09 Jun 2014'.to_date,
      start_page: 0,
      end_page: 47,
      document_number: '2019-55555',
      contributing_agency_names: ['Internal Revenue Service',
                                  'International Trade Administration',
                                  'National Oceanic and Atmospheric Administration']
    )
  end

  describe '#federal_register_document_info' do
    subject(:federal_register_document_info) do
      helper.federal_register_document_info(document)
    end

    let(:result) do
      <<~HTML.delete!("\n")
        A <span>Notice</span> by the <span>Internal 
        Revenue Service</span>, the <span>International 
        Trade Administration</span> and the <span>National 
        Oceanic and Atmospheric Administration</span> 
        posted on <span>June 9, 2014</span>.
      HTML
    end

    it { is_expected.to eq result }
  end

  describe '#federal_register_document_page_info' do
    subject(:federal_register_document_info) do
      helper.federal_register_document_page_info(document)
    end

    let(:result) do
      <<~HTML.delete!("\n")
        Pages 0 - 47 (0 pages) [FR DOC #: 2019-55555]
      HTML
    end

    it { is_expected.to eq result }

  end

  describe '#federal_register_document_comment_period' do
    context 'when federal_register_document_info is called' do
      let(:result) do
        "A <span>Notice</span> by the <span>Internal " \
        "Revenue Service</span>, the <span>International " \
        "Trade Administration</span> and the <span>National " \
        "Oceanic and Atmospheric Administration</span> " \
        "posted on <span>June 9, 2014</span>."
      end

      specify { expect(helper.federal_register_document_info(document)).to eq result }
    end

    context 'when the document comments_close_on is before today' do
      before { allow(document).to receive(:comments_close_on).and_return Date.current.prev_week }

      specify { expect(helper.federal_register_document_comment_period(document)).to eq 'Comment Period Closed' }
    end

    context 'when the document comments_close_on is today' do
      before { allow(document).to receive(:comments_close_on).and_return Date.current }

      specify { expect(helper.federal_register_document_comment_period(document)).to eq 'Comment period ends today' }
    end
  end
end
