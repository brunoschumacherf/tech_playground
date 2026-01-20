class CreateEmployeeFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_feedbacks do |t|
      t.string :nome
      t.string :email
      t.string :email_corporativo
      t.string :celular
      t.string :area
      t.string :cargo
      t.string :funcao
      t.string :localidade
      t.string :tempo_de_empresa
      t.string :genero
      t.string :geracao
      t.string :n0_empresa
      t.string :n1_diretoria
      t.string :n2_gerencia
      t.string :n3_coordenacao
      t.string :n4_area
      t.datetime :data_da_resposta
      t.integer :interesse_no_cargo
      t.text :comentarios_interesse
      t.integer :contribuicao
      t.text :comentarios_contribuicao
      t.integer :aprendizado_desenvolvimento
      t.text :comentarios_aprendizado
      t.integer :feedback
      t.text :comentarios_feedback
      t.integer :interacao_gestor
      t.text :comentarios_gestor
      t.integer :clareza_carreira
      t.text :comentarios_clareza
      t.integer :expectativa_permanencia
      t.text :comentarios_expectativa
      t.integer :enps
      t.text :enps_aberta

      t.timestamps
    end
  end
end
