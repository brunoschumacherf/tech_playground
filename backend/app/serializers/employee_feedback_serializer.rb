class EmployeeFeedbackSerializer < ActiveModel::Serializer
  attributes :id, :nome, :email, :cargo, :area, :funcao, :genero, :geracao, 
             :tempo_de_empresa, :enps, :feedback, :enps_aberta, 
             :comentarios_feedback, :data_da_resposta

  def area
    translate_enum(:area)
  end

  def cargo
    translate_enum(:cargo)
  end

  def funcao
    translate_enum(:funcao)
  end

  def tempo_de_empresa
    translate_enum(:tempo_de_empresa)
  end

  def data_da_resposta
    object.data_da_resposta&.strftime("%d/%m/%Y")
  end

  private

  def translate_enum(field)
    value = object.send(field)
    return nil if value.blank?
    
    I18n.t("enums.#{field}.#{value}", default: value.to_s.humanize)
  end
end