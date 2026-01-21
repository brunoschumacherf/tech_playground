require 'csv'

class ImportCsvService
  def self.call(file_path, import_file_record)
    ActiveRecord::Base.transaction do
      CSV.foreach(file_path, headers: true, col_sep: ';', encoding: 'UTF-8') do |row|
        EmployeeFeedback.create!(
          import_file: import_file_record,
          nome: row['nome'],
          email: row['email'],
          email_corporativo: row['email_corporativo'],
          celular: row['celular'],
          area: row['area'],
          cargo: row['cargo'],
          funcao: row['funcao'],
          localidade: row['localidade'],
          tempo_de_empresa: row['tempo_de_empresa'],
          genero: row['genero'],
          geracao: row['geracao'],
          n0_empresa: row['n0_empresa'],
          n1_diretoria: row['n1_diretoria'],
          n2_gerencia: row['n2_gerencia'],
          n3_coordenacao: row['n3_coordenacao'],
          n4_area: row['n4_area'],
          data_da_resposta: row['Data da Resposta'],
          interesse_no_cargo: row['Interesse no Cargo'].to_i,
          comentarios_interesse: row['Comentários - Interesse no Cargo'],
          contribuicao: row['Contribuição'].to_i,
          comentarios_contribuicao: row['Comentários - Contribuição'],
          aprendizado_desenvolvimento: row['Aprendizado e Desenvolvimento'].to_i,
          comentarios_aprendizado: row['Comentários - Aprendizado e Desenvolvimento'],
          feedback: row['Feedback'].to_i,
          comentarios_feedback: row['Comentários - Feedback'],
          interacao_gestor: row['Interação com Gestor'].to_i,
          comentarios_gestor: row['Comentários - Interação com Gestor'],
          clareza_carreira: row['Clareza sobre Possibilidades de Carreira'].to_i,
          comentarios_clareza: row['Comentários - Clareza sobre Possibilidades de Carreira'],
          expectativa_permanencia: row['Expectativa de Permanência'].to_i,
          comentarios_expectativa: row['Comentários - Expectativa de Permanência'],
          enps: row['eNPS'].to_i,
          enps_aberta: row['[Aberta] eNPS']
        )
      end
      import_file_record.update!(status: :completed)
    end
  end
end