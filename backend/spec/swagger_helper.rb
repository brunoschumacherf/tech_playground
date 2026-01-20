require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'People Analytics API - Bruno',
        version: 'v1',
        description: 'Documentação dos endpoints de Importação e Dashboards'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Servidor Local (Docker)'
        }
      ]
    }
  }

  config.openapi_format = :yaml
end