class Api::V1::ImportsController < ApplicationController
  def index
    @imports = ImportFile.all.order(created_at: :desc).page(params[:page]).per(10)
    render json: {
      data: @imports.as_json(methods: :feedbacks_count),
      meta: pagination_meta(@imports)
    }
  end

  def create
    file = params[:file]
    if file.blank? || !file.respond_to?(:original_filename)
      return render json: { error: I18n.t('imports.errors.no_file') }, status: :bad_request
    end

    import_file = ImportFile.new(name: file.original_filename)

    if import_file.save
      begin
        ImportCsvService.call(file.path, import_file)
        render json: { 
          message: I18n.t('imports.messages.success'), 
          import_id: import_file.id 
        }, status: :created
      rescue => e
        import_file.destroy
        render json: { 
          error: I18n.t('imports.errors.import_failed', message: e.message) 
        }, status: :unprocessable_entity
      end
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