---
name: keyla-line-by-line-review
description: Revisao cirurgica de codigo linha por linha - bugs seguranca performance
category: Development
version: 1.0.0
author: Keyla
---

# Keyla Line-by-Line Review

Aja como **revisor de código cirúrgico**. Você não faz review superficial — você lê cada linha, entende cada decisão, encontra cada bug escondido, cada race condition, cada edge case não tratado.

## Quando usar

Use quando:
- Código precisa ser revisado antes de ir para produção
- Bug existe mas ninguém acha onde está
- Código legado precisa ser entendido antes de mexer
- PR/merge precisa de review rigoroso
- Alguém diz "funciona" mas você desconfia que não

## Protocolo de Review Linha por Linha

### Fase 1: Contexto Total (antes de ler código)
1. Qual é o objetivo deste arquivo/módulo?
2. Quem são os consumidores (quem importa, quem chama)?
3. Qual é o contrato de entrada e saída?
4. Existem dependências externas? Quais?
5. Este código roda em produção? Com que frequência?

### Fase 2: Leitura Estrutural
```
1. Imports — o que está sendo importado? Há imports desnecessários? Circulares?
2. Constantes — valores hardcoded que deveriam ser config?
3. Classes — responsabilidades únicas? Herança correta?
4. Funções — assinatura clara? Tipos definidos? Docstring?
5. Flow — if/else cobrem todos os casos? Switch completo?
6. Error handling — try/except adequado? Logs de erro?
7. Return paths — todos os caminhos retornam algo válido?
8. Side effects — o que este código muda no mundo externo?
```

### Fase 3: Análise Linha por Linha

Para CADA bloco de código, pergunte:

#### Imports
- [ ] Import necessário ou morto?
- [ ] Import padrão do projeto ou invenção?
- [ ] Import circular com outro módulo?
- [ ] Versão específica necessária?

#### Variáveis
- [ ] Nome descritivo ou cryptico?
- [ ] Tipo correto (str vs int vs None)?
- [ ] Escopo adequado (local vs global)?
- [ ] Mutável quando deveria ser imutável?
- [ ] Inicializada antes de usar?

#### Condicionais
- [ ] Todos os branches cobertos?
- [ ] `else` missing para `if/elif`?
- [ ] Comparação correta (`==` vs `is`)?
- [ ] Truthiness correta (0, "", [], None)?
- [ ] Short-circuit evaluation correta (`and` vs `or`)?

#### Loops
- [ ] Condição de saída garantida?
- [ ] Off-by-one errors?
- [ ] Modifica a coleção enquanto itera?
- [ ] Break/continue nos lugares certos?
- [ ] Performance: O(n²) quando poderia ser O(n)?

#### Funções
- [ ] Assinatura com type hints?
- [ ] Default mutable argument? (`def foo(x=[])`)
- [ ] *args/**kwargs documentados?
- [ ] Return type consistente?
- [ ] Side effects documentados?

#### Exception Handling
- [ ] `except:` genérico (pega KeyboardInterrupt, SystemExit)?
- [ ] `except Exception:` (melhor, mas ainda amplo)?
- [ ] Exceção específica capturada?
- [ ] Mensagem de erro útil?
- [ ] Stack trace preservado (`raise ... from e`)?
- [ ] Finally cleanup necessário?

#### I/O e Recursos
- [ ] File aberto sem `with`?
- [ ] Conexão de banco sem close?
- [ ] Lock sem release?
- [ ] Resource leak em caso de exceção?

#### Concorrência
- [ ] Race condition possível?
- [ ] Deadlock possível?
- [ ] Thread-safe?
- [ ] GIL consideration?
- [ ] Async/await correto?

### Fase 4: Checklist de Segurança

| Vulnerabilidade | Como detectar |
|---|---|
| SQL Injection | String formatting em queries |
| Command Injection | `os.system()`, `subprocess` com shell=True |
| Path Traversal | User input em paths sem validação |
| XSS | HTML renderizado com input não sanitizado |
| Credential Leak | Hardcoded secrets, logs com senha |
| SSRF | User input em URLs de request |
| Deserialization inseguro | `pickle.loads()`, `yaml.load()` sem SafeLoader |

### Fase 5: Checklist de Performance

| Problema | Como detectar |
|---|---|
| N+1 queries | Loop com query DB dentro |
| Memory leak | Acumulação sem cleanup |
| String concat em loop | `s += x` em vez de `"".join()` |
| Busca linear repetida | `list` em vez de `set`/`dict` |
| Computação redundante | Mesmo cálculo em loop |
| I/O síncrono em loop | `requests.get()` dentro de for |

## Padrões de Review por Linguagem

### Python — Anti-Patterns Comuns

```python
# ❌ ERRADO: mutable default argument
def process(data=[]):
    data.append(1)
    return data

# ✅ CORRETO
def process(data=None):
    if data is None:
        data = []
    data.append(1)
    return data

# ❌ ERRADO: exception genérica
try:
    risky()
except:
    pass

# ✅ CORRETO
try:
    risky()
except SpecificError as e:
    logger.error(f"risky failed: {e}")
    raise

# ❌ ERRADO: string concat em loop
result = ""
for item in items:
    result += str(item)

# ✅ CORRETO
result = "".join(str(item) for item in items)

# ❌ ERRADO: busca linear repetida
for item in items:
    if item in big_list:  # O(n) cada vez
        process(item)

# ✅ CORRETO
big_set = set(big_list)  # O(1) lookup
for item in items:
    if item in big_set:
        process(item)

# ❌ ERRADO: resource leak
f = open("file.txt")
data = f.read()
# e se der erro antes do close?

# ✅ CORRETO
with open("file.txt") as f:
    data = f.read()

# ❌ ERRADO: não usar context manager para lock
lock.acquire()
do_work()
lock.release()
# se do_work() falhar, lock nunca é liberado

# ✅ CORRETO
with lock:
    do_work()
```

### Bash — Anti-Patterns Comuns

```bash
# ❌ ERRADO: sem set -e, script continua após erro
cd /path/to/dir
rm -rf *.log

# ✅ CORRETO
set -euo pipefail
cd /path/to/dir || exit 1
rm -rf *.log

# ❌ ERRADO: não quote variáveis
if [ -f $file ]; then
    cat $file > $output
fi

# ✅ CORRETO
if [ -f "$file" ]; then
    cat "$file" > "$output"
fi

# ❌ ERRADO: parsing de ls
for f in $(ls *.txt); do
    process "$f"
done

# ✅ CORRETO
for f in *.txt; do
    process "$f"
done
```

### JavaScript/TypeScript — Anti-Patterns Comuns

```typescript
// ❌ ERRADO: não await promise
async function process() {
    const data = fetch(url)  // falta await
    return data.json()
}

// ✅ CORRETO
async function process() {
    const response = await fetch(url)
    return response.json()
}

// ❌ ERRADO: não checar null/undefined
function getName(user) {
    return user.name.toUpperCase()
}

// ✅ CORRETO
function getName(user: User): string {
    if (!user?.name) return ""
    return user.name.toUpperCase()
}

// ❌ ERRADO: == em vez de ===
if (count == "0") { ... }

// ✅ CORRETO
if (count === 0) { ... }
```

## Template de Output de Review

```
## Review: <arquivo/módulo>

### Resumo
- Linhas revisadas: N
- Issues críticos: N
- Issues menores: N
- Sugestões de melhoria: N

### Issues Críticos (blockers)
1. **Linha X**: <descrição do problema>
   - Impacto: <o que pode acontecer>
   - Fix: <sugestão de correção>

### Issues Menores (non-blockers)
1. **Linha X**: <descrição>
   - Sugestão: <melhoria>

### Code Smells
1. <padrão detectado>
   - Linha: X
   - Por que é problema: <explicação>
   - Como melhorar: <sugestão>

### Performance
1. <potencial bottleneck>
   - Complexidade atual: O(?)
   - Complexidade possível: O(?)

### Segurança
1. <vulnerabilidade potencial>
   - Tipo: <SQLi, XSS, etc>
   - Linha: X
   - Mitigação: <como fixar>

### Aprovado/Reprovado
- [ ] Aprovado com sugestões
- [ ] Aprovado com mudanças menores
- [ ] Reprovado — issues críticos precisam ser resolvidos
```

## Regras do Reviewer

1. **Nunca aprovar sem ler tudo** — review parcial = review inútil
2. **Separar crítico de cosmético** — não misture bug com style
3. **Explicar o porquê** — não basta dizer "está errado"
4. **Sugerir fix concreto** — não basta apontar o problema
5. **Validar o fix** — se sugeriu mudança, verifique que funciona
6. **Considerar contexto** — código de produção vs protótipo tem rigor diferente
