# LAUDO — Operação Resgate: Central de Achados e Perdidos

Disciplina: Frameworks
Dupla: Guilherme Domingues e ________________

Resumo: foram corrigidos 13 problemas em 4 arquivos (`central_page.dart`, `ocorrencia.dart`, `central_service.dart`, `detalhe_page.dart`). Nenhum recurso foi apagado, a autenticação com Google foi mantida e as regras de segurança não foram desativadas.

Observação sobre dados: documentos criados antes das correções ficaram com `autorId` como e-mail e pistas no caminho errado. Esses dados de teste foram apagados e os registros refeitos antes da validação final.

---

## Etapa 1 — Primeira perícia (o app não compilava)

Bug 01 | Arquivo: `lib/pages/central_page.dart`
Sintoma observado: erro de compilação (string não terminada) no subtítulo de cada ocorrência.
Hipótese: a string entre aspas simples tinha uma quebra de linha real, o que o Dart não permite.
Linha/trecho alterado: `subtitle: Text('${o.local} • ${o.resolvido ? "Resolvido" : "Em aberto"}\nPor ${o.autorNome}')`. A quebra de linha virou `\n`.
Como testei a correção: `flutter analyze` sem o erro de sintaxe e `flutter run` abrindo o app.

Bug 02 | Arquivo: `lib/pages/central_page.dart`
Sintoma observado: erro de compilação, argumento obrigatório `ocorrencia` ausente.
Hipótese: o `onTap` chamava `DetalhePage()` sem passar o item tocado, mas o construtor exige `required this.ocorrencia`.
Linha/trecho alterado: `MaterialPageRoute(builder: (_) => DetalhePage(ocorrencia: o))`.
Como testei a correção: o projeto compila. Ao tocar em um item, o detalhe mostra os dados do item tocado, não de outro.

---

## Etapa 2 — Experimentos

Bug 03 | Arquivo: `lib/pages/central_page.dart`
Sintoma observado: ao ligar "Somente não resolvidos", o switch voltava para desligado (e o inverso).
Hipótese: o `onChanged` guardava o valor negado em vez do valor recebido.
Linha/trecho alterado: `onChanged: (value) => setState(() => somenteAbertos = value)` (antes: `= !value`).
Como testei a correção: ligar o switch e ver que ele permanece ligado, desligar e ver que volta.

Bug 04 | Arquivo: `lib/pages/central_page.dart`
Sintoma observado: com o filtro ligado, apareciam só os casos resolvidos.
Hipótese: a condição do `where` era a oposta da descrição do filtro.
Linha/trecho alterado: `todos.where((o) => !o.resolvido)` (antes: `o.resolvido`).
Como testei a correção: com dois registros, um marcado como resolvido, o filtro ligado mostra só o que está em aberto.

Bug 05 | Arquivo: `lib/pages/central_page.dart`
Sintoma observado: era possível registrar um objeto só com título ou só com local, apesar da mensagem "Informe título e local".
Hipótese: a validação usava `&&`, então só bloqueava quando os dois campos estavam vazios.
Linha/trecho alterado: `if (titulo.text.trim().isEmpty || local.text.trim().isEmpty)` (antes: `&&`).
Como testei a correção: preencher só um dos campos mostra a mensagem e não grava no Firestore. Com os dois preenchidos o registro é criado.

Bug 06 | Arquivo: `lib/models/ocorrencia.dart`
Sintoma observado: casos novos apareciam como "Resolvido" e casos resolvidos como "Em aberto". O botão do detalhe também mostrava o texto errado.
Hipótese: o `fromDoc` negava o valor lido do banco ao montar o objeto.
Linha/trecho alterado: `resolvido: d['resolvido'] as bool? ?? false` (antes: `!(d['resolvido'] as bool? ?? false)`).
Como testei a correção: um caso novo mostra "Em aberto" na lista e "Marcar como resolvido" no detalhe, e o valor do Firestore (`false`) bate com o exibido. Este bug só apareceu com clareza depois de corrigir os bugs 03 e 04, porque as inversões se compensavam.

Bug 07 | Arquivo: `lib/models/ocorrencia.dart`
Sintoma observado: o responsável pelo caso não era reconhecido como dono, e o botão de alterar status não aparecia para ele.
Hipótese: o campo `autorId` do modelo estava sendo lido de `autorNome`, então a comparação com o `uid` nunca batia.
Linha/trecho alterado: `autorId: d['autorId'] as String? ?? ''` (antes: `d['autorNome']`).
Como testei a correção: na conta que registrou o caso, o botão de status aparece no detalhe. Na outra conta não aparece.

Bug 08 | Arquivo: `lib/services/central_service.dart`
Sintoma observado: o dono registrado era incorreto. O Firestore guardava o e-mail no campo `autorId`.
Hipótese: o `registrar` gravava `u.email`, mas as verificações de autoria comparam com `u.uid`.
Linha/trecho alterado: `'autorId': u.uid` (antes: `u.email ?? ''`).
Como testei a correção: no console do Firestore, um registro novo mostra o `uid` em `autorId`.

Bug 09 | Arquivo: `lib/services/central_service.dart`
Sintoma observado: ao tocar em "Marcar como resolvido", o status não mudava.
Hipótese: o `update` regravava o mesmo valor que o item já tinha.
Linha/trecho alterado: `update({'resolvido': !item.resolvido})` (antes: `item.resolvido`).
Como testei a correção: marcar como resolvido muda o campo para `true` no Firestore e a lista mostra "Resolvido". Reabrir volta para `false`.

Bug 10 | Arquivo: `lib/services/central_service.dart`
Sintoma observado: os registros apareciam do mais antigo para o mais novo, e o novo caso ficava no fim da lista.
Hipótese: a consulta ordenava por `criadoEm` de forma crescente.
Linha/trecho alterado: `.orderBy('criadoEm', descending: true)` (antes: `descending: false`) em `acompanhar()`. As pistas continuam em ordem crescente, para ler a conversa na sequência.
Como testei a correção: registrar dois casos em sequência e ver o mais recente no topo.

---

## Etapa 3 — Teste de duas contas

Bug 11 | Arquivo: `lib/services/central_service.dart`
Sintoma observado: a pista enviada em um caso não aparecia nele, e as pistas iam todas para o mesmo lugar.
Hipótese: o `enviarPista` usava um documento fixo (`'pistas'`) em vez do id da ocorrência, então gravava em `ocorrencias/pistas/pistas` enquanto a leitura buscava em `ocorrencias/{id}/pistas`.
Linha/trecho alterado: `.collection('ocorrencias').doc(ocorrenciaId).collection('pistas').add(...)` (antes: `.doc('pistas')`). Também foi incluída uma checagem para não aceitar pista vazia.
Como testei a correção: com a conta B, enviar uma pista no caso X. No Firestore ela aparece em `ocorrencias/{idDoCasoX}/pistas`, e na conta A a pista aparece no caso X e em nenhum outro.

Bug 12 | Arquivo: `lib/pages/detalhe_page.dart`
Sintoma observado: com texto digitado, tocar em enviar não fazia nada.
Hipótese: a guarda de campo vazio estava invertida e saía da função justamente quando havia texto.
Linha/trecho alterado: `if (pista.text.trim().isEmpty) return;` (antes: `isNotEmpty`).
Como testei a correção: digitar uma pista e enviar grava o documento e limpa o campo. Com o campo vazio nada é enviado.

Bug 13 | Arquivo: `lib/pages/detalhe_page.dart`
Sintoma observado: a pista enviada aparecia com mensagem vazia.
Hipótese: a chamada passava uma string vazia em vez do conteúdo do campo. Este bug só ficou visível depois de corrigir o bug 12.
Linha/trecho alterado: `service.enviarPista(widget.ocorrencia.id, pista.text)` (antes: `''`).
Como testei a correção: a pista aparece na lista com o texto digitado e o nome do autor.

---

## Autorização (alterar status de caso de outro usuário)

Com os bugs 07 e 08 corrigidos, o `alterarStatus` compara o `uid` logado com o `autorId` do caso e bloqueia quem não é o dono. Na conta B, o botão não aparece nos casos da conta A.
