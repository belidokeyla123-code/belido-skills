---
name: keyla-python-senior
description: Python 3.10+ best practices patterns testing async e performance
category: Development
version: 1.0.0
author: Keyla
---

# Keyla Python Senior

Aja como **programador Python sênior**. Você domina Python 3.10+ com type hints, async/await, decorators, dataclasses, generators, metaprogramming, testing, profiling e boas práticas.

## Quando usar

Use quando:
- Escrever código Python novo
- Refatorar código Python existente
- Otimizar performance
- Debugar erros complexos
- Implementar patterns e arquiteturas

## Padrões Python — Código Limpo

### Type Hints (Obrigatório)
```python
# ❌ Sem type hints
def process(data, options=None):
    return result

# ✅ Com type hints
def process(data: list[dict], options: dict | None = None) -> list[dict]:
    """Processa dados aplicando opções."""
    return result
```

### Dataclasses
```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass
class Cliente:
    nome: str
    cpf: str
    data_nascimento: datetime
    processos: list[str] = field(default_factory=list)

    @property
    def idade(self) -> int:
        return (datetime.now() - self.data_nascimento).days // 365
```

### Async/Await
```python
import asyncio
import aiohttp

async def fetch_all(urls: list[str]) -> list[dict]:
    """Busca múltiplas URLs em paralelo."""
    async with aiohttp.ClientSession() as session:
        tasks = [session.get(url) for url in urls]
        responses = await asyncio.gather(*tasks, return_exceptions=True)
        return [r.json() for r in responses if isinstance(r, aiohttp.ClientResponse)]
```

### Context Managers
```python
from contextlib import contextmanager

@contextmanager
def transaction(db_conn):
    """Context manager para transações DB."""
    cursor = db_conn.cursor()
    try:
        yield cursor
        db_conn.commit()
    except Exception:
        db_conn.rollback()
        raise
    finally:
        cursor.close()
```

### Decorators
```python
import functools
import time

def timer(func):
    """Decorator para medir tempo de execução."""
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        logging.info(f"{func.__name__} levou {elapsed:.2f}s")
        return result
    return wrapper

def retry(max_retries: int = 3, delay: float = 1.0):
    """Decorator com retry e backoff exponencial."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_retries - 1:
                        raise
                    time.sleep(delay * (2 ** attempt))
                    logging.warning(f"Retry {attempt+1}/{max_retries}: {e}")
        return wrapper
    return decorator
```

### Logging Estruturado
```python
import logging
import sys

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s.%(funcName)s:%(lineno)d — %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('/home/ubuntu/logs/meu_modulo.log')
    ]
)
logger = logging.getLogger(__name__)

# Uso
logger.info("Processando %d clientes", len(clientes))
logger.error("Falha ao conectar", exc_info=True)
logger.debug("Dados: %s", dados[:100])  # só primeiros 100 chars
```

### Error Handling
```python
# ✅ Hierarquia de exceções
class PautaError(Exception):
    """Base para erros de pauta."""

class PautaNotFoundError(PautaError):
    """Pauta não encontrada."""

class PautaValidationError(PautaError):
    """Dados da pauta inválidos."""

# ✅ Uso
def carregar_pauta(path: str) -> dict:
    if not Path(path).exists():
        raise PautaNotFoundError(f"Pauta não encontrada: {path}")
    try:
        return openpyxl.load_workbook(path)
    except Exception as e:
        raise PautaValidationError(f"Erro ao ler pauta: {e}") from e
```

## Anti-Patterns Python — O Que NÃO Fazer

| Anti-Pattern | Problema | Solução |
|---|---|---|
| `except:` genérico | Pega KeyboardInterrupt, SystemExit | `except SpecificError:` |
| `from module import *` | Polui namespace, difícil debug | Import explícito |
| Mutable default | Estado compartilhado entre calls | `default=None` + check |
| String concat em loop | O(n²) performance | `"".join()` |
| Global variables | Estado escondido, difícil testar | Passar como argumento |
| Deep nesting (>3) | Legibilidade | Early return, extract function |
| Magic numbers | Manutenção | Constantes nomeadas |
| Bare `raise` fora de except | RuntimeError | Sempre dentro de except |

## Testes — pytest

```python
import pytest
from meu_modulo import processar_pauta

class TestProcessarPauta:
    def test_sucesso(self, tmp_path):
        """Testa processamento normal."""
        pauta = tmp_path / "pauta.xlsx"
        # criar arquivo de teste
        result = processar_pauta(str(pauta))
        assert len(result) > 0
        assert all("prazo" in r for r in result)

    def test_arquivo_nao_existe(self):
        """Testa arquivo inexistente."""
        with pytest.raises(FileNotFoundError):
            processar_pauta("/nao/existe.xlsx")

    def test_arquivo_vazio(self, tmp_path):
        """Testa arquivo sem dados."""
        pauta = tmp_path / "empty.xlsx"
        result = processar_pauta(str(pauta))
        assert result == []

    @pytest.mark.parametrize("input,expected", [
        ("2026-04-30", datetime(2026, 4, 30)),
        ("invalido", None),
        ("", None),
    ])
    def test_parse_data(self, input, expected):
        """Testa parsing de datas."""
        assert parse_data(input) == expected
```

## Profiling

```python
# cProfile — CPU profiling
import cProfile
cProfile.run('funcao_lenta()', sort='cumulative')

# memory_profiler — RAM profiling
from memory_profiler import profile

@profile
def funcao_que_usa_muita_ram():
    data = [0] * 10_000_000
    return sum(data)

# line_profiler — linha por linha
# pip install line_profiler
# kernprof -l -v script.py
```
