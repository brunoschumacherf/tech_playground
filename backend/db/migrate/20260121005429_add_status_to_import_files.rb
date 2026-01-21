class AddStatusToImportFiles < ActiveRecord::Migration[7.0]
  def change
    add_column :import_files, :status, :integer, default: 0
    add_column :import_files, :error_message, :text
  end
end