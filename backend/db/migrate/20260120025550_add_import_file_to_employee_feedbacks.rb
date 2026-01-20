class AddImportFileToEmployeeFeedbacks < ActiveRecord::Migration[7.1]
  def change
    add_reference :employee_feedbacks, :import_file, null: false, foreign_key: true
  end
end
