class Api::V1::ImportsController < ApplicationController
  def index
    @imports = ImportFile.all.order(created_at: :desc)
    @imports = @imports.where("name ILIKE ?", "%#{params[:query]}%") if params[:query].present?
    @imports = @imports.page(params[:page]).per(10)
    render json: {
      data: @imports.as_json(methods: :feedbacks_count),
      meta: pagination_meta(@imports)
    }
  end

  def create
    file = params[:file]
    return render json: { error: I18n.t('imports.errors.no_file') }, status: :bad_request if file.blank?

    import_file = ImportFile.new(name: file.original_filename, status: :processing)

    if import_file.save
      temp_path = Rails.root.join('tmp', "#{SecureRandom.uuid}-#{file.original_filename}")
      File.open(temp_path, 'wb') { |f| f.write(file.read) }

      ImportCsvJob.perform_later(import_file.id, temp_path.to_s)

      render json: { 
        message: I18n.t('imports.messages.processing_started'), 
        import_id: import_file.id 
      }, status: :accepted
    else
      render json: { error: import_file.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @import = ImportFile.find(params[:id])
    render json: @import
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private

  def not_found
    render json: { error: I18n.t('imports.errors.not_found') }, status: :not_found
  end

  def pagination_meta(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end
end