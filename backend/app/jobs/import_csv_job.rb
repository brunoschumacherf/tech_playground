class ImportCsvJob < ApplicationJob
  queue_as :default

  def perform(import_file_id, file_path)
    import_file = ImportFile.find(import_file_id)
    
    begin
      ImportCsvService.call(file_path, import_file)
    rescue => e
      import_file.update!(status: :failed, error_message: e.message)
    ensure
      File.delete(file_path) if File.exist?(file_path)
    end
  end
end