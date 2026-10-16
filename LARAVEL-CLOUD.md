# WuzAPI no Laravel Cloud

Fork de https://github.com/asternic/wuzapi para integração com o Barberya.
O código original e a licença MIT foram preservados.

## Criar a aplicação

1. No Laravel Cloud, crie uma aplicação a partir de `GuilhermeJeske1006/wuzapi`, branch `main`, diretório raiz `/`.
2. Escolha o runtime **Go**, versão **1.26 ou superior compatível com go.mod**.
3. Configure o comando de build:

   ```sh
   CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o app .
   ```

4. Configure o comando de inicialização:

   ```sh
   sh deploy/laravel-cloud/start.sh
   ```

5. Configure uma única réplica, sem autoscaling e com Scale to Zero desativado.
6. Configure `/health` como health check, se a interface permitir.

O script usa `PORT` (3000 por padrão), escuta também em IPv6 e recusa iniciar
sem PostgreSQL e chaves persistentes. Não execute o Docker Compose no Cloud.

## Banco e variáveis

Crie um banco PostgreSQL dedicado ao WuzAPI e copie as credenciais para as
variáveis listadas em `deploy/laravel-cloud/env.example`. O WuzAPI usa
`DB_NAME` e `DB_USER`, não `DB_DATABASE` e `DB_USERNAME` do Laravel.
A variável `DATABASE_URL` injetada pelo Cloud não é interpretada automaticamente
pelo WuzAPI; preencha os campos separados. Para Cloud Postgres, use
`DB_SSLMODE=require`.

Gere um token administrativo longo e uma chave de criptografia com exatamente
32 caracteres ASCII aleatórios. Guarde ambos como secrets persistentes no
Cloud; não versione valores reais. Preserve a chave em todos os deploys.

As sessões WhatsApp e os dados da aplicação ficam no PostgreSQL. O disco local
é temporário; arquivos de mídia locais não devem ser tratados como persistentes.
O fluxo de texto do Barberya não precisa de ffmpeg; funcionalidades adicionais
de conversão de mídia devem ter suas dependências verificadas separadamente.

## Conectar ao Barberya

Nas variáveis do Barberya:

```dotenv
WUZAPI_BASE_URL=https://DOMINIO-DO-WUZAPI
WUZAPI_ADMIN_TOKEN=MESMO-TOKEN-ADMINISTRATIVO-DO-WUZAPI
```

Mantenha `APP_URL` do Barberya com sua URL HTTPS pública. O painel do Barberya
provisiona o webhook por sessão. Não configure um webhook global substituindo
os webhooks individuais das barbearias.

## Homologação antes da migração

- Confirme que `/health` responde após o deploy.
- Conecte um número de teste pelo painel do Barberya, escaneando o QR.
- Teste envio de texto e recebimento de resposta pelo webhook.
- Faça um novo deploy do WuzAPI e confira a reconexão sem perder a sessão.
- Verifique a transição entre réplicas nos deploys: mesmo com uma réplica,
  um rollout pode sobrepor temporariamente processos. Valide que não há disputa
  pela mesma sessão antes de usar números de produção.

Para migrar sessões existentes, pare o servidor antigo antes de ativar as mesmas
sessões no novo e migre o banco e as chaves compatíveis. Sem migração, será
necessário parear novamente. Não compartilhe um banco ativo entre dois servidores
WuzAPI independentes.

Referências:
- https://laravel.com/cloud/docs/deploy-guides/go
- https://laravel.com/cloud/docs/compute
- https://laravel.com/cloud/docs/knowledge-base/sqlite

Este repositório prepara o deploy; não provisiona recursos nem altera o Barberya.
