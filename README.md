
---

# Tech Playground Challenge - Employee Insights Solution

Este projeto é uma plataforma completa de análise de dados de engajamento e feedback de colaboradores. A solução permite a importação de datasets em CSV, processamento estatístico automático, análise de sentimento via PLN (Processamento de Linguagem Natural) e um dashboard interativo para tomada de decisão.

## 🚀 Como Executar o Projeto

Certifique-se de ter o **Docker** e o **Docker Compose** instalados.

1. **Subir os containers:**
```bash
docker-compose up --build -d

```


2. **Preparar o banco de dados:**
```bash
docker-compose run --rm backend bundle exec rails db:prepare

```


3. **Acessar a aplicação:**
* **Frontend (Next.js):** [http://localhost:3001](https://www.google.com/search?q=http://localhost:3001)
* **Backend API (Rails):** [http://localhost:3000](https://www.google.com/search?q=http://localhost:3000)
* **Sidekiq Dashboard (Jobs):** [http://localhost:3000/sidekiq](https://www.google.com/search?q=http://localhost:3000/sidekiq)



---

## 🛠️ Tecnologias Utilizadas

* **Backend:** Ruby on Rails 7.1 (API Mode)
* **Frontend:** Next.js 14, Tailwind CSS, TypeScript
* **Processamento de Background:** Sidekiq & Redis
* **Banco de Dados:** PostgreSQL 15
* **Análise de Dados:** Gem Sentimental (PLN em português)
* **Documentação:** Swagger (RSwag)

---

## ✅ Tarefas Concluídas

### 📊 Engenharia de Dados & API

* **Task 1 & 4:** Modelagem relacional e ambiente Docker orquestrado (App, Worker, Redis, DB).
* **Task 12 (Extra):** **Background Jobs** para processamento assíncrono de arquivos, garantindo que a API não trave durante importações de grandes volumes.
* **Status em Tempo Real:** Sistema de tracking (Processing, Completed, Failed) visível no Dashboard e Listagem.

### 📈 Analytics & Visualização

* **Task 2, 5 & 6:** Dashboard com KPIs e **EDA** (Cálculo de Média, Mediana e Moda) via Serializers.
* **Task 7 & 8:** Visão granular por departamento e modal de perfil individual.

### 🧠 Inteligência & Relatórios

* **Task 10 & 12:** **Sentiment Analysis Pro** — Classificação semântica, extração de palavras-chave críticas e seleção de citações reais impactantes.
* **AI Insights:** Motor de recomendação estratégica baseado na área de menor performance.
* **Task 11:** Exportação PDF otimizada via `@media print`.

---

## 📍 Endpoints da API

| Método | Endpoint | Descrição | Status de Retorno |
| --- | --- | --- | --- |
| **GET** | `/api/v1/imports` | Lista os datasets e seus status | 200 OK |
| **POST** | `/api/v1/imports` | Upload de CSV (Inicia Job) | 202 Accepted |
| **GET** | `/api/v1/imports/:id` | Dashboard e Insights (EDA) | 200 OK / 404 |

---

## 📖 Documentação (Swagger)

Acesse a documentação interativa para testar os endpoints:
🔗 [http://localhost:3000/api-docs](https://www.google.com/search?q=http://localhost:3000/api-docs)

Para atualizar a definição após mudanças nos contratos:

```bash
docker-compose run --rm backend bundle exec rails rswag:specs:swaggerize

```

---

## 💡 Decisões de Arquitetura

1. **Processamento Assíncrono:** Implementado para evitar *timeouts* de requisição. O arquivo é salvo temporariamente, processado pelo Sidekiq e o status é atualizado via banco de dados.
2. **Resiliência:** Uso de transações no serviço de importação; em caso de erro no CSV, o registro é marcado como `failed` com o log do erro, e os dados parciais são revertidos.
3. **Escalabilidade de UI:** O Dashboard carrega dados pesados (como análise de sentimento e EDA) já calculados pelo Backend, garantindo performance de renderização no Next.js.

---

## 🧪 Suíte de Testes

```bash
docker-compose run --rm backend bundle exec rspec

```

*Garante cálculos de eNPS, favorabilidade e integridade das rotas da API.*

---

