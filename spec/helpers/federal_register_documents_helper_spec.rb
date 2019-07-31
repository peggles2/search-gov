require 'spec_helper'

describe FederalRegisterDocumentsHelper do
  describe '#federal_register_document_info' do
    subject(:federal_register_document_info) do
      helper.federal_register_document_info(document)
    end

    let(:document) do
      mock_model(
        FederalRegisterDocument,
        document_type: 'Notice',
        publication_date: 'Mon, 09 Jun 2014'.to_date,
        contributing_agency_names: ['Internal Revenue Service',
                                    'International Trade Administration',
                                    'National Oceanic and Atmospheric Administration']
      )
    end
    let(:result) do
      <<~HTML
        A <span>Notice</span> by the <span>Internal
        Revenue Service</span>, the <span>International
        Trade Administration</span> and the <span>National
        Oceanic and Atmospheric Administration</span>
        posted on <span>June 9, 2014</span>.
      HTML
    end

    it { is_expected.to eq result }
  end

  describe '#federal_register_document_comment_period' do
    let(:document) { mock_model(FederalRegisterDocument) }

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
