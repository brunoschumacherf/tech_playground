# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_01_21_005429) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employee_feedbacks", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.string "email_corporativo"
    t.string "celular"
    t.string "area"
    t.string "cargo"
    t.string "funcao"
    t.string "localidade"
    t.string "tempo_de_empresa"
    t.string "genero"
    t.string "geracao"
    t.string "n0_empresa"
    t.string "n1_diretoria"
    t.string "n2_gerencia"
    t.string "n3_coordenacao"
    t.string "n4_area"
    t.datetime "data_da_resposta"
    t.integer "interesse_no_cargo"
    t.text "comentarios_interesse"
    t.integer "contribuicao"
    t.text "comentarios_contribuicao"
    t.integer "aprendizado_desenvolvimento"
    t.text "comentarios_aprendizado"
    t.integer "feedback"
    t.text "comentarios_feedback"
    t.integer "interacao_gestor"
    t.text "comentarios_gestor"
    t.integer "clareza_carreira"
    t.text "comentarios_clareza"
    t.integer "expectativa_permanencia"
    t.text "comentarios_expectativa"
    t.integer "enps"
    t.text "enps_aberta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "import_file_id", null: false
    t.index ["import_file_id"], name: "index_employee_feedbacks_on_import_file_id"
  end

  create_table "import_files", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.text "error_message"
  end

  add_foreign_key "employee_feedbacks", "import_files"
end
