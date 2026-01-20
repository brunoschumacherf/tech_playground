FROM ruby:3.3.0

# Instala dependências básicas
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /app

# Copia arquivos de dependências
COPY Gemfile Gemfile.lock ./

# Instala as gems e garante que o bundler instale os executáveis
RUN bundle install

# Copia o projeto
COPY . .

# Garante permissão de execução para os binários do Rails
RUN chmod +x bin/*

EXPOSE 3000

# Comando padrão usando bundle exec para evitar o erro de 'not found'
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]