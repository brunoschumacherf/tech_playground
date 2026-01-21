require 'rails_helper'

RSpec.describe ImportFileSerializer, type: :serializer do
  let(:import_file) { create(:import_file, name: 'test_import.csv', status: :completed) }
  
  def serialize
    serializer = ImportFileSerializer.new(import_file.reload)
    serialization = ActiveModelSerializers::Adapter.create(serializer)
    JSON.parse(serialization.to_json)
  end

  describe 'attributes' do
    it 'includes all required attributes' do
      json = serialize
      expect(json).to include(
        'info',
        'summary',
        'by_area',
        'sentiment_analysis',
        'eda',
        'ai_insights',
        'sentiment_details'
      )
    end
  end

  describe '#info' do
    it 'returns correct info hash' do
      json = serialize
      expect(json['info']).to include(
        'id' => import_file.id,
        'name' => 'test_import.csv',
        'status' => 'completed'
      )
      expect(json['info']).to have_key('created_at')
    end

    it 'formats created_at correctly' do
      json = serialize
      expect(json['info']['created_at']).to be_present
    end
  end

  describe '#summary' do
    context 'when there are feedbacks' do
      before do
        create_list(:employee_feedback, 3,
          import_file: import_file,
          enps: 10,
          feedback: 5
        )
        create(:employee_feedback,
          import_file: import_file,
          enps: 0,
          feedback: 2
        )
      end

      it 'returns correct total_responses' do
        json = serialize
        expect(json['summary']['total_responses']).to eq(4)
      end

      it 'calculates enps_score correctly' do
        json = serialize
        expect(json['summary']['enps_score']).to be_a(Numeric)
      end

      it 'calculates favorability correctly' do
        json = serialize
        expect(json['summary']['favorability']).to be_a(Numeric)
      end
    end

    context 'when there are no feedbacks' do
      it 'returns empty hash' do
        json = serialize
        expect(json['summary']).to eq({})
      end
    end
  end

  describe '#by_area' do
    context 'when there are feedbacks with different areas' do
      before do
        create(:employee_feedback, import_file: import_file, area: 'TI', feedback: 5)
        create(:employee_feedback, import_file: import_file, area: 'TI', feedback: 4)
        create(:employee_feedback, import_file: import_file, area: 'RH', feedback: 3)
      end

      it 'groups feedbacks by area' do
        json = serialize
        expect(json['by_area']).to be_a(Hash)
      end

      it 'calculates average feedback per area' do
        json = serialize
        expect(json['by_area'].values.first.to_f).to be_a(Numeric)
      end
    end

    context 'when there are no feedbacks' do
      it 'returns empty hash' do
        json = serialize
        expect(json['by_area']).to eq({})
      end
    end
  end

  describe '#sentiment_analysis' do
    context 'when there are comments' do
      before do
        create(:employee_feedback,
          import_file: import_file,
          enps_aberta: 'Excelente ambiente de trabalho'
        )
        create(:employee_feedback,
          import_file: import_file,
          enps_aberta: 'Preciso de mais treinamento'
        )
        create(:employee_feedback,
          import_file: import_file,
          enps_aberta: '-'
        )
      end

      it 'returns sentiment counts' do
        json = serialize
        expect(json['sentiment_analysis']).to include(
          'positive',
          'neutral',
          'negative'
        )
      end

      it 'ignores dash comments' do
        json = serialize
        sentiment_counts = json['sentiment_analysis']
        total_counted = sentiment_counts.values.sum
        expect(total_counted).to eq(2)
      end
    end

    context 'when there are no comments' do
      before do
        create(:employee_feedback, import_file: import_file, enps_aberta: nil)
      end

      it 'returns zero counts' do
        json = serialize
        expect(json['sentiment_analysis']).to eq({
          'positive' => 0,
          'neutral' => 0,
          'negative' => 0
        })
      end
    end
  end

  describe '#eda' do
    context 'when there are feedback scores' do
      before do
        create_list(:employee_feedback, 5, import_file: import_file, feedback: 5)
        create_list(:employee_feedback, 3, import_file: import_file, feedback: 3)
        create_list(:employee_feedback, 2, import_file: import_file, feedback: 4)
      end

      it 'calculates mean' do
        json = serialize
        expect(json['eda']['mean']).to be_a(Numeric)
      end

      it 'calculates median' do
        json = serialize
        expect(json['eda']['median']).to be_a(Numeric)
      end

      it 'calculates mode' do
        json = serialize
        expect(json['eda']['mode']).to eq(5)
      end
    end

    context 'when there are no feedback scores' do
      it 'returns empty hash' do
        json = serialize
        expect(json['eda']).to eq({})
      end
    end
  end

  describe '#ai_insights' do
    context 'when there are feedbacks' do
      before do
        create(:employee_feedback, import_file: import_file, area: 'TI', feedback: 2.5)
        create(:employee_feedback, import_file: import_file, area: 'RH', feedback: 4.5)
      end

      it 'identifies critical area' do
        json = serialize
        expect(json['ai_insights']).to include('critical_area', 'score', 'recommendation')
      end

      it 'provides recommendation' do
        json = serialize
        expect(json['ai_insights']['recommendation']).to be_a(String)
      end
    end

    context 'when there are no feedbacks' do
      it 'returns nil' do
        json = serialize
        expect(json['ai_insights']).to be_nil
      end
    end

    context 'when critical area has low score' do
      before do
        create(:employee_feedback,
          import_file: import_file,
          area: 'TI',
          feedback: 2.0,
          enps_aberta: 'Não estou satisfeito com as condições'
        )
        create(:employee_feedback,
          import_file: import_file,
          area: 'RH',
          feedback: 4.5,
          enps_aberta: 'Estou muito satisfeito'
        )
      end

      it 'provides critical recommendation' do
        json = serialize
        expect(json['ai_insights']['recommendation']).to include('Crítico')
      end
    end
  end

  describe '#sentiment_details' do
    context 'when there are negative comments' do
      before do
        create(:employee_feedback,
          import_file: import_file,
          enps_aberta: 'Não estou satisfeito com o ambiente de trabalho'
        )
        create(:employee_feedback,
          import_file: import_file,
          enps_aberta: 'Preciso de mais suporte e treinamento'
        )
      end

      it 'extracts top negative terms' do
        json = serialize
        expect(json['sentiment_details']).to include('top_negative_terms', 'critical_quotes')
      end

      it 'returns critical quotes' do
        json = serialize
        expect(json['sentiment_details']['critical_quotes']).to be_an(Array)
      end
    end

    context 'when there are no negative comments' do
      before do
        create(:employee_feedback,
          import_file: import_file,
          enps_aberta: 'Excelente ambiente de trabalho'
        )
      end

      it 'returns empty negative terms' do
        json = serialize
        expect(json['sentiment_details']['top_negative_terms']).to eq({})
      end
    end

    context 'when comments are blank or dash' do
      before do
        create(:employee_feedback, import_file: import_file, enps_aberta: nil)
        create(:employee_feedback, import_file: import_file, enps_aberta: '-')
        create(:employee_feedback, import_file: import_file, enps_aberta: '')
      end

      it 'ignores blank comments' do
        json = serialize
        expect(json['sentiment_details']['top_negative_terms']).to eq({})
      end
    end
  end
end
