# Tech Playground Challenge - Employee Insights Solution

Este projeto é uma plataforma completa de análise de dados de engajamento e feedback de colaboradores. A solução permite a importação de datasets em CSV, processamento estatístico automático, análise de sentimento via PLN (Processamento de Linguagem Natural) e um dashboard interativo para tomada de decisão.

## 🚀 Como Executar o Projeto

Certifique-se de ter o **Docker** e o **Docker Compose** instalados.

1. **Subir os containers:**
```bash
docker-compose up --build

```


2. **Preparar o banco de dados:**
Em um novo terminal, rode:
```bash
docker-compose run --rm backend bundle exec rails db:prepare

```


3. **Acessar a aplicação:**
* **Frontend (Next.js):** [http://localhost:3001](https://www.google.com/search?q=http://localhost:3001)
* **Backend API (Rails):** [http://localhost:3000](https://www.google.com/search?q=http://localhost:3000)



---

## 🛠️ Tecnologias Utilizadas

* **Backend:** Ruby on Rails 7 (API Mode)
* **Frontend:** Next.js 14, Tailwind CSS, TypeScript
* **Banco de Dados:** PostgreSQL 15
* **Análise de Dados:** Gem Sentimental (PLN em português)
* **Serialização:** Active Model Serializers
* **Testes:** RSpec

---

## ✅ Tarefas Concluídas (Checklist)

### 📊 Engenharia de Dados & API

* [x] **Task 1: Database:** Modelagem relacional para gerenciar múltiplos arquivos e milhares de feedbacks.
* [x] **Task 4: Docker Setup:** Ambiente totalmente conteinerizado para facilitar o deploy e desenvolvimento.
* [x] **Task 9: Simple API:** Endpoints RESTful com paginação e metadados estruturados.

### 📈 Analytics & Visualização

* [x] **Task 2 & 6: Basic Dashboard:** Interface de alta fidelidade focada em métricas de alto nível (KPIs).
* [x] **Task 5: EDA:** Cálculo de Média, Mediana e Moda integrado diretamente no Serializer do backend.
* [x] **Task 7 & 8: Granularidade:** Visualizações detalhadas por departamento e perfil individual via modal.

### 🧠 Inteligência & Relatórios

* [x] **Task 10: Sentiment Analysis:** Motor de análise de texto que classifica as respostas abertas em Positivo, Neutro ou Negativo.
* [x] **Task 11: Report Generation:** Sistema de exportação para PDF otimizado para impressão executiva.
* [x] **Task 12: Creative Exploration:** Implementação de **AI Insights**, um motor que gera planos de ação automáticos para as áreas de menor performance.

---

## 🧪 Suíte de Testes (Task 3)

A aplicação conta com testes automatizados para garantir a integridade dos cálculos de eNPS e a estabilidade da API.

Para rodar os testes:

```bash
docker-compose run --rm backend bundle exec rspec

```

---

## 💡 Decisões de Arquitetura

1. **Separação de Preocupações:** Utilizamos **Serializers** para garantir que o Frontend receba dados prontos para exibição (ex: Enums já traduzidos e datas formatadas), mantendo o Controller limpo.
2. **Tradução Dinâmica (I18n):** O sistema armazena dados em inglês para compatibilidade de banco, mas traduz dinamicamente para o usuário final via arquivos de tradução Rails.
3. **Análise Semântica:** Em vez de basear o sentimento apenas na nota numérica, utilizamos análise de texto real, capturando a nuance do que o colaborador escreveu.
4. **Performance de Impressão:** A exportação de PDF foi feita via CSS `@media print`, garantindo que o relatório gerado seja idêntico ao dashboard visualizado, sem latência de servidor.

---

