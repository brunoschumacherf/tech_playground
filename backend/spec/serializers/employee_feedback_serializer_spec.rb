require 'rails_helper'

RSpec.describe EmployeeFeedbackSerializer, type: :serializer do
  let(:import_file) { create(:import_file) }
  let(:feedback) do
    create(:employee_feedback,
      import_file: import_file,
      nome: 'João Silva',
      email: 'joao@example.com',
      cargo: 'Analista',
      area: 'TI',
      funcao: 'Profissional',
      genero: 'Masculino',
      geracao: 'Millennial',
      tempo_de_empresa: 'Entre 2 e 5 anos',
      enps: 10,
      feedback: 5,
      enps_aberta: 'Excelente ambiente de trabalho',
      comentarios_feedback: 'Feedback muito positivo',
      data_da_resposta: Time.parse('2022-01-20')
    )
  end
  let(:serializer) { EmployeeFeedbackSerializer.new(feedback) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:json) { JSON.parse(serialization.to_json) }

  describe 'attributes' do
    it 'includes all required attributes' do
      expect(json).to include(
        'id',
        'nome',
        'email',
        'cargo',
        'area',
        'funcao',
        'genero',
        'geracao',
        'tempo_de_empresa',
        'enps',
        'feedback',
        'enps_aberta',
        'comentarios_feedback',
        'data_da_resposta'
      )
    end

    it 'returns correct id' do
      expect(json['id']).to eq(feedback.id)
    end

    it 'returns correct nome' do
      expect(json['nome']).to eq('João Silva')
    end

    it 'returns correct email' do
      expect(json['email']).to eq('joao@example.com')
    end

    it 'returns correct enps' do
      expect(json['enps']).to eq(10)
    end

    it 'returns correct feedback' do
      expect(json['feedback']).to eq(5)
    end

    it 'returns correct enps_aberta' do
      expect(json['enps_aberta']).to eq('Excelente ambiente de trabalho')
    end

    it 'returns correct comentarios_feedback' do
      expect(json['comentarios_feedback']).to eq('Feedback muito positivo')
    end
  end

  describe '#data_da_resposta' do
    it 'formats date as DD/MM/YYYY' do
      expect(json['data_da_resposta']).to eq('20/01/2022')
    end

    it 'returns nil when data_da_resposta is nil' do
      feedback.update(data_da_resposta: nil)
      serializer = EmployeeFeedbackSerializer.new(feedback.reload)
      serialization = ActiveModelSerializers::Adapter.create(serializer)
      json = JSON.parse(serialization.to_json)

      expect(json['data_da_resposta']).to be_nil
    end
  end

  describe 'enum translations' do
    it 'translates area using I18n' do
      expect(json['area']).to be_present
    end

    it 'translates cargo using I18n' do
      expect(json['cargo']).to be_present
    end

    it 'translates funcao using I18n' do
      expect(json['funcao']).to be_present
    end

    it 'translates tempo_de_empresa using I18n' do
      expect(json['tempo_de_empresa']).to be_present
    end

    context 'when enum value is blank' do
      it 'returns nil for blank area' do
        feedback.update(area: nil)
        serializer = EmployeeFeedbackSerializer.new(feedback.reload)
        serialization = ActiveModelSerializers::Adapter.create(serializer)
        json = JSON.parse(serialization.to_json)

        expect(json['area']).to be_nil
      end

      it 'returns nil for blank cargo' do
        feedback.update(cargo: '')
        serializer = EmployeeFeedbackSerializer.new(feedback.reload)
        serialization = ActiveModelSerializers::Adapter.create(serializer)
        json = JSON.parse(serialization.to_json)

        expect(json['cargo']).to be_nil
      end
    end

    context 'when enum value uses default translation' do
      it 'uses humanize as fallback when translation is missing' do
        feedback.update(area: 'unknown_area')
        serializer = EmployeeFeedbackSerializer.new(feedback.reload)
        serialization = ActiveModelSerializers::Adapter.create(serializer)
        json = JSON.parse(serialization.to_json)

        expect(json['area']).to eq('Unknown area')
      end
    end
  end
end
