---
name: keyla-debug-deep
description: Debug cirurgico senior - bugs misteriosos race conditions memory leaks
category: Development
version: 1.0.0
author: Keyla
---

# Keyla Debug Deep

Debugging cirúrgico nível sênior. Esta skill é para quando o erro não faz sentido, o stack trace mente, ou o bug é intermitente.

## Quando usar

- Bug que só acontece em produção
- Error silencioso (falha sem log)
- Race condition, deadlock, memory leak
- Comportamento diferente entre ambientes
- Stack trace não aponta para a causa real
- "Funcionava antes" sem mudança óbvia no código

## Mentalidade Debug

1. **Nunca confie no sintoma** — o erro mostrado é consequência, não causa
2. **Isole variáveis** — mude uma coisa por vez, observe o efeito
3. **Pense em reverso** — do erro até a origem, não do código até o erro
4. **Assuma que o bug está onde você não olhou** — o lugar óbvio já foi verificado

## Protocolo Debug Deep

### Fase 1: Triagem
```bash
# O que exatamente está falhando?
# Reproduzir o erro manualmente
# Coletar logs do momento exato da falha
# Verificar se é replicável

journalctl -u <serviço> --since "10 min ago" --no-pager
# ou para app
tail -n 200 /var/log/<app>/<app>.log
```

### Fase 2: Isolamento
```
1. Identificar o componente afetado
2. Verificar se o problema é:
   - Código (lógica)
   - Dados (input corrupto/inesperado)
   - Infra (rede, disco, memória, permissão)
   - Timing (race condition, timeout)
   - Config (env, secrets, paths)
3. Eliminar causas uma a uma
```

### Fase 3: Instrumentação
```python
# Python — adicionar logging cirúrgico
import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Pontos de debug:
logger.debug(f"INPUT: {type(x)} = {repr(x)[:200]}")
logger.debug(f"ANTES: {state}")
logger.debug(f"DEPOIS: {state}")
```

```bash
# Bash — set -x para trace
set -x  # ativa trace
# ... código ...
set +x  # desativa

# strace para ver system calls
strace -p <PID> -f -e trace=file,network 2>&1 | head -100

# lsof para ver arquivos abertos
lsof -p <PID> | head -50
```

### Fase 4: Reprodução Mínima
```
Criar o menor exemplo possível que reproduz o bug:
1. Remover dependências desnecessárias
2. Hardcodar inputs
3. Isolar a função/método problemático
4. Testar standalone
```

### Fase 5: Hipótese → Teste → Confirmação
```
Para cada hipótese:
1. Formular: "Se X é a causa, então Y deve acontecer"
2. Testar: modificar/verificar X
3. Confirmar ou descartar
4. Repetir até isolar a causa raiz
```

## Debug por Sintoma

### "Function not found" / Import error
- Verificar `sys.path` e `PYTHONPATH`
- `python -c "import sys; print(sys.path)"`
- Verificar se o módulo existe: `find . -name "*.py" | grep <nome>`
- Virtual env ativo? `which python`

### "Connection refused" / Timeout
- Serviço rodando? `systemctl status <serviço>`
- Porta aberta? `ss -tlnp | grep <porta>`
- Firewall? `iptables -L -n`
- DNS resolve? `nslookup <host>` ou `dig <host>`
- Conecta localmente? `curl -v http://localhost:<porta>`

### "Permission denied"
- Quem roda o processo? `ps aux | grep <processo>`
- Permissões do arquivo/diretório? `ls -la <path>`
- SELinux/AppArmor ativo? `getenforce` / `aa-status`
- Docker user mapping?

### Memory leak
- `top` → RES cresce continuamente?
- `ps aux --sort=-%mem | head`
- `valgrind --leak-check=full python script.py`
- Python: `tracemalloc` module
- `smem -p <PID>` para ver shared vs private memory

### CPU spike
- `top -H -p <PID>` → qual thread?
- `py-spy top --pid <PID>` para Python
- `perf top` para system-wide
- Verificar loops infinitos, queries N+1, regex catastrófico

### Disco cheio
- `df -h` → qual mount?
- `du -sh /* 2>/dev/null | sort -rh | head`
- `du -sh /home/ubuntu/*/ | sort -rh | head`
- Logs gigantes? `find /var/log -size +100M`
- Docker volumes? `docker system df`

## Python-Specific Debug

### PDB / Breakpoints
```python
import pdb; pdb.set_trace()  # Python < 3.7
breakpoint()                 # Python >= 3.7
```

```bash
# rodar com pdb interativo
python -m pdb script.py
# comandos: n (next), s (step), c (continue), p <var> (print), l (list), q (quit)
```

### Logging remoto (produção sem acesso interativo)
```python
import logging
import traceback

try:
    risky_operation()
except Exception as e:
    logging.error(f"FAIL: {e}\n{traceback.format_exc()}")
    # ou enviar para arquivo externo
    with open("/tmp/debug-fallback.log", "a") as f:
        f.write(f"{e}\n{traceback.format_exc()}\n")
```

### Inspect para entender runtime
```python
import inspect
# Quem chamou esta função?
print(inspect.stack()[1].filename, inspect.stack()[1].lineno)
# Quais variáveis locais?
print(inspect.currentframe().f_locals)
```

## Checklist Anti-Pânico

Antes de entrar em paralisia:
- [ ] O serviço está rodando? `systemctl status`
- [ ] Tem espaço em disco? `df -h`
- [ ] Tem memória? `free -h`
- [ ] O arquivo existe? `ls -la <path>`
- [ ] A config está correta? `cat <config>`
- [ ] O log diz algo útil? `tail -100 <log>`
- [ ] Reproduz localmente? Se sim, isolar
- [ ] Funcionou antes? `git log --oneline -10`
- [ ] Alguém mudou algo? `git diff HEAD~5`

## Regra de Ouro

**Se você está debugando há mais de 30 minutos sem progresso, pare.**
1. Anote o que já tentou
2. Volte ao estado anterior (`git reset`)
3. Comece de novo com outra abordagem
4. Às vezes o bug é óbvio quando você olha com olhos frescos
