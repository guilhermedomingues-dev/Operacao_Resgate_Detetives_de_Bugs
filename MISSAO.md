# Missão: Central de Achados e Perdidos — Operação Resgate

## A situação
A escola inaugurou uma central digital de objetos perdidos. Após uma atualização, o sistema começou a registrar donos incorretos, exibir casos resolvidos como abertos e perder pistas enviadas pelos usuários. Vocês são a equipe de investigação responsável por recuperar a confiança na plataforma.

**Duração:** 100 minutos, em duplas. **Não reescreva o app do zero.** O projeto possui 12 bugs intencionais; alguns só aparecem depois que outros são corrigidos.

## Etapa 1 — Primeira perícia (15 minutos)
- Abrir o projeto, compilar e ler erros do analisador.
- Investigar o caminho `main` → `GatePage` → `CentralPage` → `DetalhePage`.
- Documentar o primeiro diagnóstico.

## Etapa 2 — Experimentos (30 minutos)
- Registrar 2 objetos com locais diferentes.
- Testar o filtro “Somente não resolvidos”.
- Observar o que acontece ao abrir um detalhe.
- Verificar a identificação do responsável pelo registro.
- Investigar a ordem dos registros e mudança de status.

## Etapa 3 — Teste de duas contas (30 minutos)
- Em duas janelas anônimas ou perfis do navegador, entrar com contas diferentes.
- Confirmar se os dados surgem ao vivo para ambos.
- Enviar pistas e verificar se aparecem no caso correto.
- Tentar alterar o status de um caso que não pertence ao usuário.
- Verificar campos vazios e comportamentos invertidos.

## Etapa 4 — Laudo e entrega (25 minutos)
Para cada correção, registrar em `LAUDO.md`:
```
Bug XX | Arquivo:
Sintoma observado:
Hipótese:
Linha/trecho alterado:
Como testei a correção:
```
Enviar repositório GitHub com o código corrigido e `LAUDO.md`. Acrescentar um print das duas contas visualizando a mesma ocorrência.

## Avaliação (10 pontos)
- 4,0 identificação dos bugs; 3,0 correção; 2,0 testes documentados; 1,0 clareza do laudo.

**Importante:** é proibido resolver o problema apagando o recurso, removendo autenticação ou desativando regras de segurança. Não coloque dados pessoais em publicações de teste.
